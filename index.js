const express = require('express');
const { Configuration, OpenAIApi } = require("openai");
const { RedshiftDataClient, ExecuteStatementCommand, DescribeStatementCommand, GetStatementResultCommand } = require("@aws-sdk/client-redshift-data");
const { BigQuery } = require('@google-cloud/bigquery');
const fs = require('fs');
const { inspect } = require('util');

const app = express();
const port = 3000;

// Set up OpenAI configuration
const openaiConfig = new Configuration({
  apiKey: process.env.OPENAPI_API_KEY,
});
const openai = new OpenAIApi(openaiConfig);

// Configure Redshift Data client
const redshiftDataClient = new RedshiftDataClient({ region: process.env.AWS_REGION });

// Parse JSON bodies for POST requests
app.use(express.json());

let schema = null; // Variable to store the Redshift schema
let workgroupName = process.env.REDSHIFT_WORKGROUP_NAME; // Redshift Serverless workgroup name

async function executeSqlAndWait(sql) {
  const executeStatementCommand = new ExecuteStatementCommand({
    Database: process.env.REDSHIFT_DATABASE,
    WorkgroupName: workgroupName, // Use the Redshift Serverless workgroup name
    Sql: sql
  });

  try {
    const executeResponse = await redshiftDataClient.send(executeStatementCommand);
    const executeId = executeResponse.Id;

    // Poll the statement status until it's completed
    let statusResponse;
    let resultResponse;
    do {
      await new Promise(resolve => setTimeout(resolve, 1000)); // Wait for 1 second before checking the status again
      statusResponse = await redshiftDataClient.send(new DescribeStatementCommand({ Id: executeId }));
    } while (statusResponse.Status === "RUNNING" || statusResponse.Status === "STARTED");
    // Wait for the statement to complete and fetch the result set
    if (statusResponse.Error)
      throw Error(statusResponse.Error)
    else
       resultResponse = await redshiftDataClient.send(new GetStatementResultCommand({ Id: executeId }));    
    return {
      ColumnMetadata: resultResponse.ColumnMetadata,
      Records: resultResponse.Records
    };

  } catch (error) {
    console.error("Error executing SQL:", error);
    throw error;
  }
}


function readDatabaseSchemaFromFile(filePath) {
  try {
    const schema = fs.readFileSync(filePath, 'utf8').trim();
    return schema.replace(/\n/g, ' ');
  } catch (error) {
    throw error;
  }
}

// Function to retrieve Redshift schema details (tables and columns)
async function getRedshiftSchema() {
    if (schema) {
      // Return the cached schema if it has already been loaded
      return schema;
    }
  
    const sql = `
      SELECT table_schema, table_name, column_name,data_type
      FROM information_schema.columns
      WHERE table_catalog = '${process.env.REDSHIFT_DATABASE}'
      and table_schema not in ( 'information_schema','pg_catalog')
      ORDER BY table_schema, table_name, ordinal_position;
    `;
  
    try {
      const resultRecords = (await executeSqlAndWait(sql)).Records;
      schema = {};
  
      for (const row of resultRecords) {
        const schemaName = row[0].stringValue;
        const tableName = row[1].stringValue;
        const columnName = row[2].stringValue;
        const dataType  = row[3].stringValue;
  
        if (!schema[schemaName]) {
          schema[schemaName] = {};
        }
  
        if (!schema[schemaName][tableName]) {
          schema[schemaName][tableName] = [];
        }
  
        schema[schemaName][tableName].push(columnName + ":" + dataType);
      }
      console.log(JSON.stringify(schema))
      return schema;
    } catch (error) {
      console.error("Error retrieving Redshift schema:", error);
      throw error;
    }
  }
  
// Define a middleware to set CORS headers
app.use((req, res, next) => {
  res.setHeader('Access-Control-Allow-Origin', '*'); // Adjust the allowed origin if needed
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  next();
});

// Define a route to handle the OpenAI GPT-3.5 Turbo API call
app.post('/generate-response', async (req, res) => {
  try {
    const { query, temp, model} = req.body;
    let response = null;

    if (!schema) {
      schema = readDatabaseSchemaFromFile("tickit.sql");
    }
    console.log(typeof temp, temp, typeof model, model)

    const information = "only provide sql, must not include any other text or notes, must alias all tables,  check for ambigious columns, always qualify tablenames with schema"
    
    const prompt = `given the database schema ${schema} and additional information ${information} answer the following question. Question: ${query}`
    if (model == 'gpt-3.5-turbo') {
        response = (await openai.createChatCompletion({
          model: 'gpt-3.5-turbo',
          temperature: temp,
          n: 1,
          messages: [
            { role: "assistant", content: schema},
            {role: "user", content: information},
            { role: "user", content: query }
          ],
        })).data.choices[0].message.content;
    } else {
        response = (await openai.createCompletion({
        model: 'text-davinci-003',
        prompt: prompt,
        temperature: temp,
        max_tokens: 300
      })).data.choices[0].text;
    }
    
    const generatedResponse = response;
    console.log({ sql: generatedResponse })
    res.json({ sql: generatedResponse });
  } catch (error) {
    console.log(inspect(error, { showHidden: true }));
    res.status(500).json({ error: "Error while generating SQL"});
  }
});

// Define a route to execute SQL against Redshift
app.post('/redshift-query', async (req, res) => {
  try {
    const { sql } = req.body;

    const result = await executeSqlAndWait(sql);

    const columnNames = result.ColumnMetadata.map(metadata => metadata.name);
    const records = result.Records.map(record => {
      const values = record.map(obj => Object.values(obj)[0]);
      return Object.fromEntries(columnNames.map((name, index) => [name, values[index]]));
    });
    console.log(JSON.stringify(records))
    res.json({ records });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'An error occurred' });
  }
});

const bigquery = new BigQuery();
app.post('/bigquery-query', async (req, res) => {
  try {
    const { sql } = req.body;
    const options = {
      query: sql,
      location: 'asia-south1',
    };
    const [rows] = await bigquery.query(options);
    console.log(JSON.stringify(rows))
    res.json({ records: rows });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'An error occurred' });
  }
});

// Start the Express server
app.listen(port, () => {
    console.log(`Server running on port ${port}`);
  });

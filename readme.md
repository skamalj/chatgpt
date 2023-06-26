## This creates an API to convert NLP query to SQL, Redshift compatible,  utilizing GPT

This is built using serverless Redshift and needs following environment variables.
```
REDSHIFT_WORKGROUP_NAME
AWS_REGION
OPENAPI_API_KEY
REDSHIFT_DATABASE
```
Your aws profile must be set and should have sufficient permissions to query/connect to Redshift


##  Some queries to execute
* list categories
* list top 3 cities by number of users attending pop events
* finds the top five sellers in San Diego, based on the number of tickets sold in 2008, use date table
* list top 5 categories based on number of events
* which venue had most events hosted
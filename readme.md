## This creates an API to convert NLP query to SQL, Redshift compatible,  utilizing GPT

This is built using serverless Redshift and needs following environment variables.
```
REDSHIFT_WORKGROUP_NAME
AWS_REGION
OPENAPI_API_KEY
REDSHIFT_DATABASE
```
Your aws profile must be set and should have sufficient permissions to query/connect to Redshift

This uses sample database as described over [here](https://docs.aws.amazon.com/redshift/latest/dg/c_sampledb.html)
##  Some queries to execute
* list categories
* list cities sorted by total number of tickets sold for Pop events
* finds the top five sellers in San Diego, based on the total number of tickets sold in 2008, use date table
* * finds the top five sellers in San Diego, based on the number of tickets sold in 2008, use date table, use sales not listing, show full username
* list top 5 categories based on number of events
* which venue had most events hosted
* write sql to rank venues within the city based on number of events hosted, select venue city, venue name and rank , sort the result on city and rank
* who are top 5 sellers based on number of tickets sold 
* * get seller full name as well ( qualify tablenames with schema )

## Queries where openAI struggles
* how many users have attended events in multiple cities
* * Solution: how many users have attended events in multiple cities, use subquery
* what was revenue each month , select top 5 months, pricepaid is price per ticket, listing is not sales

## Load data to bigquery
bq --location=asia-south1 load --source_format=CSV -F "|"  tickit.category category_pipe.txt
bq --location=asia-south1 load --source_format=CSV -F "|"  tickit.users allusers_pipe.txt
bq --location=asia-south1 load --source_format=CSV -F "|"  tickit.venue venue_pipe.txt
bq --location=asia-south1 load --source_format=CSV -F "|"  tickit.date  date2008_pipe.txt
bq --location=asia-south1 load --source_format=CSV -F "|"  tickit.event  allevents_pipe.txt
bq --location=asia-south1 load --source_format=CSV -F "|"  tickit.listing listings_pipe.txt
bq --location=asia-south1 load --autodetect --source_format=CSV -F "\t"  tickit.sales_temp sales_tab.txt
bq query --use_legacy_sql=false 'insert into tickit.sales select * from tickit.sales_temp'
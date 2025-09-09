# Makefile for Kickstarter Projects Success Analysis
# Requires pre configuraiton with gcloud SDK with BigQuery CLI enabled (bq)

PROJECT_ID = data-analytics-ns-470609
DATASET = kickstarter_project_analysis
TABLE = ks-projects-clean
SOURCE_FILE = data/ks-projects-201801.csv

# Default target
all: upload

# Authenticate with Google Cloud
auth:
	gcloud auth login
	gcloud config set project $(PROJECT_ID)

# Create dataset if it does not exist
create-dataset:
	bq --location=EU mk --dataset --if-not-exists $(PROJECT_ID):$(DATASET)

# Upload CSV into BigQuery
upload: create-dataset
	bq load \
	--replace \
	--autodetect \
	--source_format=CSV \
	$(PROJECT_ID):$(DATASET).$(TABLE) \
	$(SOURCE_FILE)

# Delete table (cleanup)
drop:
	bq rm -f -t $(PROJECT_ID):$(DATASET).$(TABLE)

# Preview table
preview:
	bq head -n 10 $(PROJECT_ID):$(DATASET).$(TABLE)

# Makefile for Kickstarter Platform Analysis Pipeline
# Airflow + dbt Core + BigQuery Pipeline

# Configuration (update these values in config.py)
PROJECT_ID = data-analytics-ns-470609
DATASET = kickstarter_project_analysis
RAW_TABLE = ks-projects-2018
CLEAN_TABLE = ks-projects-clean
SOURCE_FILE = data/ks-projects-201801.csv
DBT_DIR = dbt_kickstarter
AIRFLOW_HOME = ~/airflow

# Colors for output
GREEN = \033[0;32m
YELLOW = \033[1;33m
RED = \033[0;31m
NC = \033[0m # No Color

.PHONY: help setup install-deps auth create-dataset upload-raw dbt-setup dbt-run airflow-setup airflow-start pipeline-run clean

# Default target
help:
	@echo "$(GREEN)Kickstarter Platform Analysis Pipeline$(NC)"
	@echo ""
	@echo "Available commands:"
	@echo "  $(YELLOW)setup$(NC)           - Complete setup (install deps, auth, create dataset)"
	@echo "  $(YELLOW)install-deps$(NC)    - Install Python dependencies"
	@echo "  $(YELLOW)auth$(NC)            - Authenticate with Google Cloud"
	@echo "  $(YELLOW)create-dataset$(NC)  - Create BigQuery dataset"
	@echo "  $(YELLOW)upload-raw$(NC)      - Upload raw CSV to BigQuery"
	@echo "  $(YELLOW)dbt-setup$(NC)       - Setup dbt project"
	@echo "  $(YELLOW)dbt-run$(NC)         - Run dbt transformations"
	@echo "  $(YELLOW)airflow-setup$(NC)   - Initialize Airflow"
	@echo "  $(YELLOW)airflow-start$(NC)   - Start Airflow webserver and scheduler"
	@echo "  $(YELLOW)pipeline-run$(NC)    - Run complete pipeline via Airflow"
	@echo "  $(YELLOW)clean$(NC)           - Clean up generated files"
	@echo ""
	@echo "$(YELLOW)Quick start:$(NC) make setup && make pipeline-run"

# Complete setup
setup: install-deps auth create-dataset dbt-setup
	@echo "$(GREEN)✓ Setup complete! Update config.py with your values, then run 'make pipeline-run'$(NC)"

# Install Python dependencies
install-deps:
	@echo "$(YELLOW)Installing Python dependencies...$(NC)"
	pip install -r requirements.txt
	@echo "$(GREEN)✓ Dependencies installed$(NC)"

# Authenticate with Google Cloud
auth:
	@echo "$(YELLOW)Authenticating with Google Cloud...$(NC)"
	gcloud auth login
	gcloud config set project $(PROJECT_ID)
	gcloud auth application-default login
	@echo "$(GREEN)✓ Authentication complete$(NC)"

# Create BigQuery dataset
create-dataset:
	@echo "$(YELLOW)Creating BigQuery dataset...$(NC)"
	bq --location=US mk --dataset --if-not-exists $(PROJECT_ID):$(DATASET)
	@echo "$(GREEN)✓ Dataset created$(NC)"

# Upload raw CSV to BigQuery (manual method)
upload-raw: create-dataset
	@echo "$(YELLOW)Uploading raw CSV to BigQuery...$(NC)"
	bq load \
	--replace \
	--autodetect \
	--source_format=CSV \
	--skip_leading_rows=1 \
	$(PROJECT_ID):$(DATASET).$(RAW_TABLE) \
	$(SOURCE_FILE)
	@echo "$(GREEN)✓ Raw data uploaded$(NC)"

# Setup dbt project
dbt-setup:
	@echo "$(YELLOW)Setting up dbt project...$(NC)"
	cd $(DBT_DIR) && dbt deps
	cd $(DBT_DIR) && dbt debug
	@echo "$(GREEN)✓ dbt setup complete$(NC)"

# Run dbt transformations
dbt-run:
	@echo "$(YELLOW)Running dbt transformations...$(NC)"
	cd $(DBT_DIR) && dbt run
	cd $(DBT_DIR) && dbt test
	cd $(DBT_DIR) && dbt docs generate
	@echo "$(GREEN)✓ dbt transformations complete$(NC)"

# Initialize Airflow
airflow-setup:
	@echo "$(YELLOW)Initializing Airflow...$(NC)"
	export AIRFLOW_HOME=$(AIRFLOW_HOME) && airflow db init
	export AIRFLOW_HOME=$(AIRFLOW_HOME) && airflow users create \
		--username admin \
		--firstname Admin \
		--lastname User \
		--role Admin \
		--email admin@example.com \
		--password admin
	@echo "$(GREEN)✓ Airflow initialized$(NC)"
	@echo "$(YELLOW)Access Airflow UI at: http://localhost:8080$(NC)"
	@echo "$(YELLOW)Username: admin, Password: admin$(NC)"

# Start Airflow services
airflow-start:
	@echo "$(YELLOW)Starting Airflow services...$(NC)"
	@echo "$(YELLOW)Starting webserver in background...$(NC)"
	export AIRFLOW_HOME=$(AIRFLOW_HOME) && nohup airflow webserver --port 8080 > airflow-webserver.log 2>&1 &
	@echo "$(YELLOW)Starting scheduler in background...$(NC)"
	export AIRFLOW_HOME=$(AIRFLOW_HOME) && nohup airflow scheduler > airflow-scheduler.log 2>&1 &
	@echo "$(GREEN)✓ Airflow services started$(NC)"
	@echo "$(YELLOW)Access UI at: http://localhost:8080$(NC)"

# Run the complete pipeline via Airflow
pipeline-run:
	@echo "$(YELLOW)Triggering Airflow DAG...$(NC)"
	export AIRFLOW_HOME=$(AIRFLOW_HOME) && airflow dags trigger kickstarter_data_pipeline
	@echo "$(GREEN)✓ Pipeline triggered! Check Airflow UI for progress$(NC)"

# Manual pipeline run (without Airflow)
manual-pipeline: upload-raw dbt-run
	@echo "$(GREEN)✓ Manual pipeline complete$(NC)"

# Clean up
clean:
	@echo "$(YELLOW)Cleaning up...$(NC)"
	rm -f airflow-webserver.log airflow-scheduler.log
	rm -rf $(DBT_DIR)/target $(DBT_DIR)/dbt_packages
	@echo "$(GREEN)✓ Cleanup complete$(NC)"

# Stop Airflow services
stop-airflow:
	@echo "$(YELLOW)Stopping Airflow services...$(NC)"
	pkill -f "airflow webserver"
	pkill -f "airflow scheduler"
	@echo "$(GREEN)✓ Airflow services stopped$(NC)"

# Preview tables
preview-raw:
	bq head -n 10 $(PROJECT_ID):$(DATASET).$(RAW_TABLE)

preview-clean:
	bq head -n 10 $(PROJECT_ID):$(DATASET).$(CLEAN_TABLE)

# Delete tables (cleanup)
drop-tables:
	bq rm -f -t $(PROJECT_ID):$(DATASET).$(RAW_TABLE)
	bq rm -f -t $(PROJECT_ID):$(DATASET).$(CLEAN_TABLE)
	bq rm -f -t $(PROJECT_ID):$(DATASET).ks-projects-category

# Validate configuration
validate-config:
	@echo "$(YELLOW)Validating configuration...$(NC)"
	@python -c "import config; print('✓ Configuration loaded successfully')"
	@test -f $(SOURCE_FILE) && echo "$(GREEN)✓ Source file exists$(NC)" || echo "$(RED)✗ Source file missing$(NC)"
	@test -d $(DBT_DIR) && echo "$(GREEN)✓ dbt directory exists$(NC)" || echo "$(RED)✗ dbt directory missing$(NC)"

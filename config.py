# Configuration file for Kickstarter Platform Analysis Pipeline
# Fill in all the values below before running the pipeline

# ============================================================================
# GOOGLE CLOUD / BIGQUERY CONFIGURATION
# ============================================================================
GCP_PROJECT_ID = "data-analytics-ns-470609"  # Your GCP Project ID
BIGQUERY_DATASET = "kickstarter_project_analysis"  # BigQuery dataset name
BIGQUERY_LOCATION = "US"  # BigQuery location (US, EU, etc.)
GCP_SERVICE_ACCOUNT_KEY_PATH = "/path/to/your/service-account-key.json"  # Path to service account JSON key
GCP_CONNECTION_ID = "google_cloud_default"  # Airflow connection ID for GCP

# ============================================================================
# DATA SOURCE CONFIGURATION
# ============================================================================
DATA_FOLDER_PATH = "/Users/mac_dee/Documents/Dee/code/data_analytics_projects/kickstarter-platform-analysis/data"
SOURCE_CSV_FILE = "ks-projects-201801.csv"
SOURCE_FILE_PATH = f"{DATA_FOLDER_PATH}/{SOURCE_CSV_FILE}"

# ============================================================================
# BIGQUERY TABLE CONFIGURATION
# ============================================================================
# Raw data table (initial load)
RAW_TABLE_NAME = "ks-projects-2018"
RAW_TABLE_ID = f"{GCP_PROJECT_ID}.{BIGQUERY_DATASET}.{RAW_TABLE_NAME}"

# Clean data table (after transformations)
CLEAN_TABLE_NAME = "ks-projects-clean"
CLEAN_TABLE_ID = f"{GCP_PROJECT_ID}.{BIGQUERY_DATASET}.{CLEAN_TABLE_NAME}"

# Category analysis table
CATEGORY_TABLE_NAME = "ks-projects-category"
CATEGORY_TABLE_ID = f"{GCP_PROJECT_ID}.{BIGQUERY_DATASET}.{CATEGORY_TABLE_NAME}"

# ============================================================================
# AIRFLOW CONFIGURATION
# ============================================================================
AIRFLOW_DAG_ID = "kickstarter_data_pipeline"
AIRFLOW_SCHEDULE_INTERVAL = None  # Set to None for manual trigger, or use cron expression
AIRFLOW_START_DATE = "2024-01-01"
AIRFLOW_CATCHUP = False
AIRFLOW_MAX_ACTIVE_RUNS = 1
AIRFLOW_RETRIES = 2
AIRFLOW_RETRY_DELAY_MINUTES = 5

# ============================================================================
# DBT CONFIGURATION
# ============================================================================
DBT_PROJECT_DIR = "/Users/mac_dee/Documents/Dee/code/data_analytics_projects/kickstarter-platform-analysis/dbt_kickstarter"
DBT_PROFILES_DIR = "/Users/mac_dee/.dbt"
DBT_TARGET = "dev"  # dbt target environment

# ============================================================================
# CSV SCHEMA CONFIGURATION
# ============================================================================
CSV_SCHEMA = [
    {"name": "ID", "type": "INTEGER", "mode": "REQUIRED"},
    {"name": "name", "type": "STRING", "mode": "NULLABLE"},
    {"name": "category", "type": "STRING", "mode": "NULLABLE"},
    {"name": "main_category", "type": "STRING", "mode": "NULLABLE"},
    {"name": "currency", "type": "STRING", "mode": "NULLABLE"},
    {"name": "deadline", "type": "DATE", "mode": "NULLABLE"},
    {"name": "goal", "type": "FLOAT", "mode": "NULLABLE"},
    {"name": "launched", "type": "TIMESTAMP", "mode": "NULLABLE"},
    {"name": "pledged", "type": "FLOAT", "mode": "NULLABLE"},
    {"name": "state", "type": "STRING", "mode": "NULLABLE"},
    {"name": "backers", "type": "INTEGER", "mode": "NULLABLE"},
    {"name": "country", "type": "STRING", "mode": "NULLABLE"},
    {"name": "usd_pledged", "type": "FLOAT", "mode": "NULLABLE"},
    {"name": "usd_pledged_real", "type": "FLOAT", "mode": "NULLABLE"},
    {"name": "usd_goal_real", "type": "FLOAT", "mode": "NULLABLE"},
]

# ============================================================================
# EMAIL NOTIFICATION CONFIGURATION (Optional)
# ============================================================================
EMAIL_ON_FAILURE = True
EMAIL_ON_RETRY = False
EMAIL_ON_SUCCESS = False
EMAIL_RECIPIENTS = ["your-email@example.com"]  # Add your email addresses

# ============================================================================
# LOGGING CONFIGURATION
# ============================================================================
LOG_LEVEL = "INFO"

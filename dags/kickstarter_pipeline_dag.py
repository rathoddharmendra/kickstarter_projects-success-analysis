"""
Airflow DAG for Kickstarter Platform Analysis Pipeline
Loads CSV data from local folder to BigQuery and runs dbt transformations
"""

from datetime import datetime, timedelta
import os
import sys

from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.bash import BashOperator
from airflow.providers.google.cloud.operators.bigquery import (
    BigQueryCreateEmptyDatasetOperator,
    BigQueryCreateEmptyTableOperator,
    BigQueryInsertJobOperator,
)
from airflow.providers.google.cloud.transfers.local_to_gcs import LocalFilesystemToGCSOperator
from airflow.providers.google.cloud.transfers.gcs_to_bigquery import GCSToBigQueryOperator
from airflow.providers.google.cloud.operators.gcs import GCSCreateBucketOperator
from airflow.utils.dates import days_ago

# Add project root to path to import config
sys.path.append('/Users/mac_dee/Documents/Dee/code/data_analytics_projects/kickstarter-platform-analysis')
from config import *

# Default arguments for the DAG
default_args = {
    'owner': 'data-team',
    'depends_on_past': False,
    'start_date': datetime.strptime(AIRFLOW_START_DATE, '%Y-%m-%d'),
    'email_on_failure': EMAIL_ON_FAILURE,
    'email_on_retry': EMAIL_ON_RETRY,
    'email_on_success': EMAIL_ON_SUCCESS,
    'email': EMAIL_RECIPIENTS,
    'retries': AIRFLOW_RETRIES,
    'retry_delay': timedelta(minutes=AIRFLOW_RETRY_DELAY_MINUTES),
}

# Create the DAG
dag = DAG(
    AIRFLOW_DAG_ID,
    default_args=default_args,
    description='Kickstarter data pipeline with dbt transformations',
    schedule_interval=AIRFLOW_SCHEDULE_INTERVAL,
    catchup=AIRFLOW_CATCHUP,
    max_active_runs=AIRFLOW_MAX_ACTIVE_RUNS,
    tags=['kickstarter', 'bigquery', 'dbt', 'analytics'],
)

# GCS bucket for staging data
GCS_BUCKET_NAME = f"{GCP_PROJECT_ID}-kickstarter-staging"
GCS_OBJECT_NAME = f"raw-data/{SOURCE_CSV_FILE}"

def validate_source_file():
    """Validate that the source CSV file exists and is readable"""
    if not os.path.exists(SOURCE_FILE_PATH):
        raise FileNotFoundError(f"Source file not found: {SOURCE_FILE_PATH}")
    
    # Check file size
    file_size = os.path.getsize(SOURCE_FILE_PATH)
    if file_size == 0:
        raise ValueError(f"Source file is empty: {SOURCE_FILE_PATH}")
    
    print(f"Source file validated: {SOURCE_FILE_PATH} ({file_size} bytes)")
    return True

def check_dbt_installation():
    """Check if dbt is installed and configured"""
    import subprocess
    try:
        result = subprocess.run(['dbt', '--version'], capture_output=True, text=True)
        if result.returncode == 0:
            print(f"dbt version: {result.stdout}")
            return True
        else:
            raise Exception(f"dbt check failed: {result.stderr}")
    except FileNotFoundError:
        raise Exception("dbt is not installed or not in PATH")

# Task 1: Validate source file
validate_file_task = PythonOperator(
    task_id='validate_source_file',
    python_callable=validate_source_file,
    dag=dag,
)

# Task 2: Check dbt installation
check_dbt_task = PythonOperator(
    task_id='check_dbt_installation',
    python_callable=check_dbt_installation,
    dag=dag,
)

# Task 3: Create GCS bucket for staging
create_gcs_bucket = GCSCreateBucketOperator(
    task_id='create_gcs_bucket',
    bucket_name=GCS_BUCKET_NAME,
    project_id=GCP_PROJECT_ID,
    location=BIGQUERY_LOCATION,
    gcp_conn_id=GCP_CONNECTION_ID,
    dag=dag,
)

# Task 4: Create BigQuery dataset
create_dataset = BigQueryCreateEmptyDatasetOperator(
    task_id='create_bigquery_dataset',
    dataset_id=BIGQUERY_DATASET,
    project_id=GCP_PROJECT_ID,
    location=BIGQUERY_LOCATION,
    gcp_conn_id=GCP_CONNECTION_ID,
    dag=dag,
)

# Task 5: Upload CSV to GCS
upload_to_gcs = LocalFilesystemToGCSOperator(
    task_id='upload_csv_to_gcs',
    src=SOURCE_FILE_PATH,
    dst=GCS_OBJECT_NAME,
    bucket=GCS_BUCKET_NAME,
    gcp_conn_id=GCP_CONNECTION_ID,
    dag=dag,
)

# Task 6: Load data from GCS to BigQuery
load_to_bigquery = GCSToBigQueryOperator(
    task_id='load_csv_to_bigquery',
    bucket=GCS_BUCKET_NAME,
    source_objects=[GCS_OBJECT_NAME],
    destination_project_dataset_table=RAW_TABLE_ID,
    schema_fields=CSV_SCHEMA,
    write_disposition='WRITE_TRUNCATE',
    skip_leading_rows=1,
    allow_quoted_newlines=True,
    allow_jagged_rows=False,
    gcp_conn_id=GCP_CONNECTION_ID,
    dag=dag,
)

# Task 7: Run dbt deps (install dependencies)
dbt_deps = BashOperator(
    task_id='dbt_deps',
    bash_command=f'cd {DBT_PROJECT_DIR} && dbt deps --profiles-dir {DBT_PROFILES_DIR}',
    dag=dag,
)

# Task 8: Run dbt debug (test connection)
dbt_debug = BashOperator(
    task_id='dbt_debug',
    bash_command=f'cd {DBT_PROJECT_DIR} && dbt debug --profiles-dir {DBT_PROFILES_DIR}',
    dag=dag,
)

# Task 9: Run dbt run (execute transformations)
dbt_run = BashOperator(
    task_id='dbt_run',
    bash_command=f'cd {DBT_PROJECT_DIR} && dbt run --profiles-dir {DBT_PROFILES_DIR} --target {DBT_TARGET}',
    dag=dag,
)

# Task 10: Run dbt test (data quality tests)
dbt_test = BashOperator(
    task_id='dbt_test',
    bash_command=f'cd {DBT_PROJECT_DIR} && dbt test --profiles-dir {DBT_PROFILES_DIR} --target {DBT_TARGET}',
    dag=dag,
)

# Task 11: Generate dbt docs
dbt_docs_generate = BashOperator(
    task_id='dbt_docs_generate',
    bash_command=f'cd {DBT_PROJECT_DIR} && dbt docs generate --profiles-dir {DBT_PROFILES_DIR} --target {DBT_TARGET}',
    dag=dag,
)

# Define task dependencies
validate_file_task >> check_dbt_task
check_dbt_task >> [create_gcs_bucket, create_dataset]
create_gcs_bucket >> upload_to_gcs
[create_dataset, upload_to_gcs] >> load_to_bigquery
load_to_bigquery >> dbt_deps
dbt_deps >> dbt_debug
dbt_debug >> dbt_run
dbt_run >> dbt_test
dbt_test >> dbt_docs_generate

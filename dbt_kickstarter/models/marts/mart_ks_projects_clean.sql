{{
  config(
    materialized='table',
    description='Final cleaned Kickstarter projects table for analysis'
  )
}}

select * from {{ ref('int_ks_projects_clean') }}

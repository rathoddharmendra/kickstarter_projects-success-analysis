{{
  config(
    materialized='view',
    description='Raw Kickstarter projects data with basic cleaning and type casting'
  )
}}

with source_data as (
    select * from {{ source('kickstarter', 'ks-projects-2018') }}
),

cleaned_data as (
    select
        ID as project_id,
        name as project_name,
        category,
        main_category,
        currency,
        safe.parse_date('%Y-%m-%d', deadline) as deadline,
        goal,
        safe.parse_timestamp('%Y-%m-%d %H:%M:%S', launched) as launched,
        pledged,
        state,
        backers,
        country,
        `usd pledged` as usd_pledged,
        usd_pledged_real,
        usd_goal_real
    from source_data
    where 
        -- Filter out undefined states as per EDA analysis
        state != 'undefined'
        -- Filter out invalid launch dates (before 2009-01-02)
        and safe.parse_timestamp('%Y-%m-%d %H:%M:%S', launched) > '{{ var("min_launch_date") }}'
)

select * from cleaned_data

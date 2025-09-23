{{
  config(
    materialized='table',
    description='Global platform metrics and KPIs for Kickstarter analysis'
  )
}}

with clean_data as (
    select * from {{ ref('int_ks_projects_clean') }}
),

global_metrics as (
    select
        -- Overall counts
        count(*) as total_projects,
        sum(status) as successful_projects,
        sum(case when status = 0 then 1 else 0 end) as failed_projects,
        
        -- Global success rate (target: 36.46% from EDA)
        round(safe_divide(sum(status), count(*)) * 100, 2) as global_success_rate_pct,
        round(safe_divide(sum(case when status = 0 then 1 else 0 end), count(*)) * 100, 2) as global_failure_rate_pct,
        
        -- Financial metrics
        sum(goal) as total_goal_amount,
        sum(pledged) as total_pledged_amount,
        round(safe_divide(sum(pledged), sum(goal)), 4) as global_pledge_goal_ratio,
        
        -- Average funding per project
        round(avg(pledged), 2) as avg_funding_per_project,
        
        -- Date ranges
        min(launched) as earliest_launch_date,
        max(launched) as latest_launch_date,
        min(deadline) as earliest_deadline,
        max(deadline) as latest_deadline,
        
        -- Backers metrics
        sum(backers) as total_backers,
        round(avg(backers), 2) as avg_backers_per_project,
        
        -- Currency and country diversity
        count(distinct currency) as unique_currencies,
        count(distinct country) as unique_countries,
        count(distinct main_category) as unique_main_categories,
        count(distinct category) as unique_subcategories
        
    from clean_data
)

select 
    *,
    current_timestamp() as metrics_calculated_at
from global_metrics

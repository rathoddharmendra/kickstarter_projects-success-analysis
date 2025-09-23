{{
  config(
    materialized='table',
    description='Category-level analysis of Kickstarter projects with success rates and funding metrics'
  )
}}

with clean_data as (
    select * from {{ ref('int_ks_projects_clean') }}
),

category_metrics as (
    select
        main_category,
        count(*) as total_projects,
        sum(status) as successful_projects,
        sum(case when status = 0 then 1 else 0 end) as failed_projects,
        
        -- Success rate calculation
        round(safe_divide(sum(status), count(*)) * 100, 2) as success_rate_pct,
        
        -- Financial metrics
        sum(goal) as total_goal_amount,
        sum(pledged) as total_pledged_amount,
        round(safe_divide(sum(pledged), sum(goal)), 4) as pledge_goal_ratio,
        
        -- Average metrics
        round(avg(goal), 2) as avg_goal,
        round(avg(pledged), 2) as avg_pledged,
        round(avg(backers), 2) as avg_backers,
        
        -- Funding status distribution
        sum(case when funding_status = 'Fully Funded' then 1 else 0 end) as fully_funded_count,
        sum(case when funding_status = 'Nearly Funded' then 1 else 0 end) as nearly_funded_count,
        sum(case when funding_status = 'Not Nearly Funded' then 1 else 0 end) as not_nearly_funded_count
        
    from clean_data
    group by main_category
),

final as (
    select
        *,
        -- Rank categories by success rate
        row_number() over (order by success_rate_pct desc, total_projects desc) as success_rank,
        
        -- Rank categories by total funding
        row_number() over (order by total_pledged_amount desc) as funding_rank
        
    from category_metrics
)

select * from final
order by success_rate_pct desc, total_projects desc

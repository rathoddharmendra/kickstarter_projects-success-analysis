{{
  config(
    materialized='view',
    description='Cleaned Kickstarter projects with status classification and removed USD columns'
  )
}}

with base_data as (
    select * from {{ ref('stg_ks_projects_raw') }}
),

add_status as (
    select
        *,
        -- Create binary status field: 0 for fail, 1 for success
        case 
            when state in ({{ "'" + var("failed_states") | join("', '") + "'" }}) then 0
            when state in ({{ "'" + var("success_states") | join("', '") + "'" }}) then 1
            else null
        end as status,
        
        -- Calculate pledge to goal ratio
        safe_divide(pledged, goal) as pledge_goal_ratio,
        
        -- Create funding status categories
        case
            when safe_divide(pledged, goal) >= 1 then 'Fully Funded'
            when safe_divide(pledged, goal) >= 0.75 then 'Nearly Funded'
            when safe_divide(pledged, goal) < 0.75 then 'Not Nearly Funded'
            else 'Unknown'
        end as funding_status
        
    from base_data
),

final as (
    select
        -- Remove USD columns as per EDA analysis
        * except (usd_pledged, usd_pledged_real, usd_goal_real)
    from add_status
    where status is not null  -- Only keep records with valid status
)

select * from final

-- EDA

select *
from `data-analytics-ns-470609.kickstarter_project_analysis.ks-projects-2018`
limit 10;

select *
from `data-analytics-ns-470609.kickstarter_project_analysis.ks-projects-2018`;

select
  distinct goal,
from `data-analytics-ns-470609.kickstarter_project_analysis.ks-projects-2018`
order by 1 asc;


select
  distinct state,
  count(*) as count_nr
from `data-analytics-ns-470609.kickstarter_project_analysis.ks-projects-2018`
group by 1
order by 2 desc;


select
  goal,
  backers,
  pledged
from `data-analytics-ns-470609.kickstarter_project_analysis.ks-projects-2018`
limit 10;


select  
  *
from `data-analytics-ns-470609.kickstarter_project_analysis.ks-projects-2018`
where pledged = 9430.0;


select
  goal,
  backers,
  pledged
from `data-analytics-ns-470609.kickstarter_project_analysis.ks-projects-2018`
where state in ('failed', 'canceled', 'suspended')
limit 10;


-- How many projects had at least 100 backers, and more than 20K pledged -> but still failed

select
  *
from `data-analytics-ns-470609.kickstarter_project_analysis.ks-projects-2018`
where state in ('failed', 'canceled', 'suspended')
AND backers >= 100 
AND pledged >= 20000.0;



select
  main_category,
  goal,
  backers,
  pledged,
  pledged / goal as pct_pledged
from `data-analytics-ns-470609.kickstarter_project_analysis.ks-projects-2018`
where state in ('failed')
AND backers >= 100 
AND pledged >= 20000.0
order by goal desc, pct_pledged desc
limit 10;


-- create a funding status categorical field

with result as (
    SELECT
        pledged / goal  as pct_pledged
    from `data-analytics-ns-470609.kickstarter_project_analysis.ks-projects-2018`
)
select
  main_category,
  goal,
  backers,
  pledged,
  CASE
    WHEN result.pct_pledged >= 1 THEN 'Fully Funded'
    WHEN result.pct_pledged >= 0.75 THEN 'Nearly Funded'
    WHEN result.pct_pledged < 0.75 THEN 'Not Nearly Funded'
   END as funding_status
from `data-analytics-ns-470609.kickstarter_project_analysis.ks-projects-2018`, `result`
where state in ('failed')
AND backers >= 100 
AND pledged >= 20000.0
order by main_category asc, pct_pledged desc
limit 10;


-- count of failed and canceled projects?

select
  distinct state,
  count(*) as nr
from `data-analytics-ns-470609.kickstarter_project_analysis.ks-projects-2018`
group by state
order by nr desc;  

-- CLEANING

-- dropping undefined as we don't have the informations and cannot include in analysis

delete from `data-analytics-ns-470609.kickstarter_project_analysis.ks-projects-2018`
where state like 'undefined';

-- creating status field - 0 for fail, 1 for pass
-- Criteria : If backers didn't had to pay, and the project never took off 
-- [Add Image]
create or replace table `data-analytics-ns-470609.kickstarter_project_analysis.ks-projects-clean` as
select
  *,
  case 
    when state in ('failed', 'canceled', 'suspended') then 0
    when state in ('successful', 'live') then 1
  END as status
from `data-analytics-ns-470609.kickstarter_project_analysis.ks-projects-2018`;



-- What factors decide status

-- getting all columns
SELECT 
  column_name, 
  data_type
FROM `data-analytics-ns-470609.kickstarter_project_analysis`.INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'ks-projects-clean'
ORDER BY ordinal_position;
  


-- using visualization on looker to explore trends faster

select
  currency,
  goal,
  usd_goal_real,
  pledged,
  `usd pledged`,
  usd_pledged_real
from `data-analytics-ns-470609.kickstarter_project_analysis.ks-projects-clean`
order by 5 desc
limit 30;

-- dropping usd_* columns as it is not relevant for the analysis

-- alter table `data-analytics-ns-470609.kickstarter_project_analysis.ks-projects-clean`
-- drop column `usd pledged`, `usd_pledged_real`, `usd_goal_real`;

create or replace table `data-analytics-ns-470609.kickstarter_project_analysis.ks-projects-clean` as
select
  * except (`usd pledged`, `usd_pledged_real`, `usd_goal_real`)
from `data-analytics-ns-470609.kickstarter_project_analysis.ks-projects-clean`;


-- distinct main_categories

-- Analyzing by category -- aggregated 
create or replace table `data-analytics-ns-470609.kickstarter_project_analysis.ks-projects-category` as
select
  main_category,
  SUM(status) as successful,
  count(*) as total_pitches,
  ROUND(SAFE_DIVIDE(SUM(status),count(*)) * 100, 2) as success_rate
from `data-analytics-ns-470609.kickstarter_project_analysis.ks-projects-clean`
group by main_category
order by 2 desc, 3 desc;

-- Date Range for deadlines: 2009-05-03	until 2018-03-03

select
  min(deadline),
  max(deadline)
from `data-analytics-ns-470609.kickstarter_project_analysis.ks-projects-clean`;

-- Launched date: 1970-01-01 01:00:00 UTC	until 2018-01-02 15:02:31 UTC
select
  min(launched),
  max(launched)
from `data-analytics-ns-470609.kickstarter_project_analysis.ks-projects-clean`;

select
  *
from `data-analytics-ns-470609.kickstarter_project_analysis.ks-projects-clean`
where launched <= '2009-01-01'
order by 1 asc;
/* >> found 7 entries with mismatch launch date, and they all were cancelled - probably the reason for these wrong entries
"""
for the sake of clear timeline, decided to drop them
"""
*/

delete from `data-analytics-ns-470609.kickstarter_project_analysis.ks-projects-clean`
 where launched <= '2009-01-01';

-- ## Day 2 of analysis

-- Finding important KPIs

-- Get global success rate on Kickstart Platform : 36.46%
with result as (
  select
    status,
    count(*) as nr
  from `data-analytics-ns-470609.kickstarter_project_analysis.ks-projects-clean`
  group by status
)
select
  ROUND((select result.nr from result where status=1)/SUM(nr) * 100, 2) as success_rate,
  ROUND((select result.nr from result where status=0)/SUM(nr) * 100, 2) as failure_rate
from result;

-- goal vs pledged: goal - 18569252485.970009, pledged - 3658446439.390018, ratio - 0.19701635497466338
select
  SUM(goal) as total_goal,
  SUM(pledged) as total_pledged,
  SUM(pledged)/SUM(goal) as pledge_goal_ratio
from `data-analytics-ns-470609.kickstarter_project_analysis.ks-projects-clean`;

create or replace view `data-analytics-ns-470609.kickstarter_project_analysis.once-ks-projects-ratio-by-category` as
select
  main_category,
  SUM(goal) as total_goal,
  SUM(pledged) as total_pledged,
  SUM(pledged)/SUM(goal) as pledge_goal_ratio
from `data-analytics-ns-470609.kickstarter_project_analysis.ks-projects-clean`
group by main_category;

-- AVG funding per project -
-- 1. Average across all projects:
select
  avg(pledged) as avg_funding_mean,
  PERCENTILE_CONT(pledged, 0.5) over (PARTITION BY category) AS avg_funding_median,
from `data-analytics-ns-470609.kickstarter_project_analysis.ks-projects-clean`;


-- handling typo in country names as N'O" doesn't make sense in visual

select
  distinct country
from `data-analytics-ns-470609.kickstarter_project_analysis.ks-projects-clean`;

select
  *
from `data-analytics-ns-470609.kickstarter_project_analysis.ks-projects-clean`
where country like 'N,0"';

-- seems like N,0" is a typo for null values: found 235 corrupt entries
-- trial 1 - impeding correct country code by currency used

with res as (
  select
  *
from `data-analytics-ns-470609.kickstarter_project_analysis.ks-projects-clean`
where country like 'N,0"'
)

select 
  distinct currency
from res

alter table `data-analytics-ns-470609.kickstarter_project_analysis.ks-projects-clean`
set country = (
  when 'EUR' then ''
)
where country like 'N,0"'

-- cleaning data : removing outliers on deadlines and launched datetime
-- converting to datetime






  
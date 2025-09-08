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


select
  status,
  count(*) as nr
from `data-analytics-ns-470609.kickstarter_project_analysis.ks-projects-clean`
group by status
  
  
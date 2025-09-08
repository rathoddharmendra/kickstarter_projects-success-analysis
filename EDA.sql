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


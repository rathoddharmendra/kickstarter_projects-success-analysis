
> -- goal vs pledged: goal - 18,569,252,485.97, pledged - 3,658,446,439.39, 
ratio - 0.19701635497466338

> kickstarter recieved only 1/5th of it's goal 

##### Q: It is specific to a particular category?

``select
  main_category,
  SUM(goal) as total_goal,
  SUM(pledged) as total_pledged,
  SUM(pledged)/SUM(goal) as pledge_goal_ratio
from data-analytics-ns-470609.kickstarter_project_analysis.ks-projects-clean
group by main_category;``

#### To do:
* creating range on goals - categorical columns
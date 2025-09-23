# About Project
📊 Analyzing Kickstarter Dataset — A Product Mindset Approach

`Blending both my skills from PdM days, and as a data analyst`

This project analyzes the [Kickstarter dataset](https://www.kaggle.com/datasets/kemical/kickstarter-projects/data) with a **product-oriented lens**. Instead of only visualizing data, the goal is to answer:  

👉 **“What makes Kickstarter projects succeed?”**

---

## 📑 Table of Contents
- [About Project](#about-project)
  - [📑 Table of Contents](#-table-of-contents)
  - [🎯 Current Goals](#-current-goals)
  - [👥 Who Will Benefit](#-who-will-benefit)
  - [❓ Key Questions](#-key-questions)
  - [📈 KPIs \& Metrics](#-kpis--metrics)
    - [🌟 North Star Metric](#-north-star-metric)
    - [🎯 Supporting KPIs](#-supporting-kpis)
  - [🚀 Delivery Plan](#-delivery-plan)
  - [📊 Dashboard Design](#-dashboard-design)
    - [Color applications](#color-applications)
    - [Typography](#typography)

---

## 🎯 Current Goals
- To provide insights into *factors* that drive project success/failure on Kickstarter.  
  - **Questions**: For the sake of time, I would dive only into main questions based on metrics and dimensions in the dataset - possibly 3 main questions
  - **Statistical Infernence**: Dive into few hypothesis statements to disprove/prove them using statistical tests and looking at p-value
  - **KPIs**: Derive important metrics and KPIs - to use in dashboard later on.  
- Build a **self-explanatory Looker dashboard** supported by README as a storytelling tool, and first step to insight into .  

---

## 👥 Who Will Benefit
- **Creators** → deciding funding goals, duration, and positioning of their campaigns.  
- **Backers/Investors** → spotting reliable categories and countries for pledging.  
- *Possibly* **Kickstarter Product/Strategy Teams** → optimizing the platform for higher success rates.  

---

## ❓ Key Questions
For the sake of focus, the analysis centers around three main questions:  

1. **What factors increase the likelihood of a project succeeding?**  
2. **Which categories and geographies are most successful on Kickstarter?**  
3. **How do campaign goals and durations impact success?**  

---

## 📈 KPIs & Metrics

### 🌟 North Star Metric  
**Success Rate** = % of projects that met or exceeded their funding goal.  

### 🎯 Supporting KPIs  
- **Total Money Pledged vs. Goal** (funding efficiency)  
- **Average Pledge per Project** (scale of funding)  
- **Average Backers per Project** (engagement level)  
- **Category Success Rate** (what works best)  
- **Country Success Rate** (where it works best)  
- **Average Campaign Duration** (time-to-success window)  
- **Pledge-to-Goal Ratio** (extent of overfunding)  

---

## 🚀 Delivery Plan
The project will be delivered in two complementary formats:  

1. **📊 Looker Dashboard**  
   - KPIs at the top (success rate, total pledged, avg. pledge, avg. backers)  
   - Interactive filters (category, country, year, goal range)  
   - Visual storytelling with category, geography, and time trend breakdowns  

2. **📖 README Report (this file)**  
   - Explains the narrative behind the numbers  
   - Structured like a product case study  
   - Can be **published on Tableau Public** (optional) to showcase alternative visualization  

---

## 📊 Dashboard Design
A clean, product-portfolio-oriented dashboard with:  
- **Top KPIs** → quick snapshot of Kickstarter health  
- **Category Insights** → bar charts for success rate & pledged amounts  
- **Geography** → map for projects & success rate  
- **Time Trends** → line charts for growth and seasonality  
- **Deep Dive** → scatterplots for goal vs. pledged, boxplots for duration vs. outcome  

👉 Design principle: Using same designs from N26 Churn report analysis

🎨 DESIGN SYSTEM  
### Color applications
Teal: #46A997
Colal: #CB7B7A
Navy: #276678
Gold: #CCA45F
Status colors
Info: #3993AC
Success: #46A997
Warning: #CB9B4D
Danger: #CB7B7A
### Typography
Title: Cambria
Everything else: Roboto

# Virtual-R-Data-Analyst-Intern-Project
End-to-end R data analytics internship, structured across 4 progressive modules — from raw, messy data to a polished predictive model and final report. Demonstrates practical skills in data wrangling, ggplot2 visualization, hypothesis testing, and regression/classification modeling on real-world sales data.


## Week 1:
Data cleaning, missing value imputation, outlier treatment, and preliminary EDA on a 16,719-record video game sales dataset using R.
r data-analytics data-cleaning EDA data-preprocessing 
ggplot2 exploratory-data-analysis internship-project 
data-visualization statistical-analysis


## week 2
Week2_Visualization_Files.zip — the cleaned dataset plus all 8 PNG charts, for your GitHub repo.
the submission-ready report with 8 distinct chart types, each following the same pattern: chart type rationale → R code → embedded image → plain-language insight for a non-technical reader:

Bar chart — sales by genre
Line chart — top 3 genres over time
Histogram — critic score distribution
Scatter plot — critic score vs sales, colored by genre
Boxplot — sales spread by platform
Stacked area chart — regional sales mix over time
Correlation heatmap
Donut chart — ESRB rating share

## week 3
Week 3 — Statistical Analysis & Predictive Modeling
Still the same dataset. Add hypothesis testing (e.g. t-test comparing sales between two platforms, correlation significance tests) and build one regression or classification model in R — for example, predicting Global_Sales from Critic_Score, Genre, and Platform using lm() or a classification model predicting whether a game is a "hit" (top 10% sales). Include train/test split, model diagnostics (residual plots or confusion matrix), and a performance summary.

## Statistical tests:

Shapiro-Wilk normality test → sales are significantly non-normal
Pearson correlation test → Critic Score vs Sales is significant but weak (r=0.285)
Welch t-test → PS3 vs Xbox 360 sales, no significant difference (p=0.505)
One-way ANOVA → Genre does significantly affect sales (p<0.001)

## Regression model: 
Linear regression predicting Global Sales (R²=0.19), with residual plots, Q-Q plot, and predicted-vs-actual diagnostics — including honest discussion of heteroscedasticity and why the model under-predicts blockbusters.

## Classification model: 
Logistic regression predicting "Hit" games (top 10%), with confusion matrix, accuracy/precision/recall/F1, and an ROC curve (AUC=0.758) — with a section specifically explaining why 91% accuracy is misleading here due to class imbalance, and how threshold tuning could fix the low recall.

A "Diagnostic Summary & Potential Improvements" section is included per the task's evaluation criteria, covering class imbalance handling, non-linear model alternatives, and missing business variables.


## week 4
Week 4 — Comprehensive Final Report
This is a consolidation task, not new analysis. Combine Weeks 1-3 into one structured document: Introduction → Data Preparation (from Week 1) → Visualization Highlights (from Week 2) → Modeling Results (from Week 3) → Discussion → Conclusion with lessons learned and future directions. I can merge all three prior reports into this final one once they exist.


Each week: GitHub URL (only if technical)
Since this whole program is R-based technical data analysis, the GitHub URL looks compulsory for your certificate. Create one repo (e.g. R-Internship-Data-Analytics) and add a new folder or branch each week — week1-cleaning, week2-visualization, etc. — rather than four separate repos, so your GitHub profile shows a coherent project history.

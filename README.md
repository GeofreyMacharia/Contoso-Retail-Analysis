<img width="4100" height="2350" alt="Consto BI-1" src="https://github.com/user-attachments/assets/9c0a5d50-8d0c-4026-81be-ce8f2430cd80" />
# BACKGROUND INFO
In the retail industry, sales often fall short or exceed quotas due to shifting consumer demand, competition, and seasonality.
At the same time, global operations introduce regional differences that affect overall performance.
Without analyzing both quota attainment and regional sales trends, organizations risk misjudging growth, misallocating resources, and missing key opportunities.
# PRELUDE INFO
This project is divided into two parts. The first part focuses on analyzing sales quota against actual sales, while the second part explores sales performance
across global regions. The separation is necessary due to the different levels of aggregation required for each analysis, which will be explained in detail later.
# PREREQUISITE:
To obtain the dataset required for this project, I meticulously analyzed the Contoso Retail Data Warehouse schema for the relevant
tables. Using SQL, I performed the necessary joins, filters, and aggregations to create two primary datasets:
  * Sales vs Sales Quota Dataset – containing actual sales and organizational quota data for comparison.
  * Geographical Sales Dataset – containing non aggregated sales figures across different regions for global analysis (1,000,000 rows).
The flowchart below provides a simplified overview of the data preparation process:

<img width="2708" height="2747" alt="Contoso Dataset Acquisition Flowchart-1" src="https://github.com/user-attachments/assets/7b3ec35e-ecee-4d29-b9e7-57894c16714e" />

#SALES VS QUOTA OBJECTIVE:  
The primary goal of this section is to analyze sales data and determine whether actual sales achieved or fell short of the quotas established by the organization.
## Research Questions – Sales vs Quota:

1. Did actual sales across the years meet the organizational sales quotas?
2. Which products accounted for the highest share of total sales?
3. What was the total revenue acquired compared to the expected (quota) revenue?
4. Which brand contributed the most to overall sales performance?
5. Does seasonality impact sales performance? If so, during which periods and why?

# PHASE ONE FINDINGS: 
1. Overall Sales and revenue acquired did not meet the sales quota. In fact only 7.5% of the expected revenue was met.
2. Overall electronic products accounted for items generating the most sales and revenue,specifically Washers and Driers with North America being the continent with the most sales and revenue
3. The total revenue acquired across the three year period was 2.5billion dollars with the expected revenue being 33.9 billion
4. The brand with the most sales and revenue was Contoso, however despite the low amount of sales made fabrikam acquired a lot of revenue nearly reaching contoso's revenue alone.
5. A strong seasonal trend was observed between May and July, where sales and revenue peaked significantly. This suggests potential links to summer demand, promotional campaigns, or consumer spending cycles.

A representation of the results can be seen from the following dashboard:
<img width="4100" height="2350" alt="Consto BI-2" src="https://github.com/user-attachments/assets/bfa8005a-29cc-4987-97c4-d18822e5e0c4" />


#GLOBAL SALES ANAYSIS:
The primary objective The primary objective of this section is to analyze sales performance across different regions and countries, 
with the goal of identifying high-performing markets, product distribution trends, customer base concentration, and regional profitability.

## Research Questions - Global sales
1. Which continent records the highest total sales?
2. Which top three countries have the highest sales figures?
3. Which products are sold the most in each continent, especially in the top-performing continents?
5. How have sales changed over time across continents?
7. Which continents contribute the most to total profit margin?
8. Do certain product categories dominate in specific regions?
9. Which product subcategories show the highest growth in different continents?


# PHASE TWO FINDINGS: 
1. Overall Sales and revenue acquired did not meet the sales quota. In fact only 7.5% of the expected revenue was met.
2. Overall electronic products accounted for items generating the most sales and revenue,specifically Washers and Driers with North America being the continent with the most sales and revenue
3. The total revenue acquired across the three year period was 2.5billion dollars with the expected revenue being 33.9 billion
4. The brand with the most sales and revenue was Contoso, however despite the low amount of sales made fabrikam acquired a lot of revenue nearly reaching contoso's revenue alone.
5. A strong seasonal trend was observed between May and July, where sales and revenue peaked significantly. This suggests potential links to summer demand, promotional campaigns, or consumer spending cycles.

A representation of the results can be seen from the following dashboard:
<img width="4100" height="2350" alt="Consto BI-3" src="https://github.com/user-attachments/assets/746947e8-774d-4f45-be28-8f045ec202d4" />

# FINAL INSIGHTS AND RECOMMENDATIONS
To avoid redundancyi showcased the final insights and recommendations on the following dashboard page:

<img width="4100" height="2350" alt="Consto BI-4" src="https://github.com/user-attachments/assets/0dcb0cbf-4dfd-4e30-addd-c98956be90ca" />

# EXTENEDED ANALYSIS WITH PYTHON

In addition to SQL-based queries and dashboard visualizations, I developed Python notebooks to conduct a more in-depth analysis of the Contoso Retail dataset. These notebooks allowed for:
* Advanced computations beyond SQL aggregations, including the introduction of new performance metrics such as Profit and Profit Margin.
* Exploratory data analysis (EDA) using libraries like pandas, matplotlib, and seaborn for identifying patterns, anomalies, and correlations in sales data.
* Validation of SQL results, ensuring consistency and accuracy across different analytical approaches.
* Scenario-based insights, such as evaluating profitability across regions, brands, and product categories, providing a richer perspective for recommendations.
* The inclusion of these notebooks ensures that the analysis is both comprehensive and flexible, enabling future adjustments or deeper dives into specific business questions.

# ENDING:
THANK YOU FOR YOUR TIME ❤ 
![have a cookiee](https://github.com/user-attachments/assets/e35aa51d-d2e5-49c6-9120-e39dd7f9293a)

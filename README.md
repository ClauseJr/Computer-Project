# Desktops & Laptops Sales Project


## Objective
The goal of this project is to leverage advanced SQL analytics to evaluate how computer hardware specifications influence pricing, performance, and overall value across device categories. By examining trends in efficiency, performance scoring, pricing behavior, and component impact, the project aims to generate actionable insights that support data-driven product comparison and strategic decision-making in the computer hardware market.

Get the Dataset [all_Computers](https://www.kaggle.com/datasets/paperxd/all-computer-prices)

## Key Questions
1. **Top Selling Price Categories**  
   What are the top 10 most expensive models and their full specifications?
      ```
   SELECT
   	model,
   	storage_type,	
   	SUM(price) total_price
   FROM all_computers
   GROUP BY model, storage_type
   ORDER BY total_price DESC
   LIMIT 10;
      ```
2. **Compare Device Categories by Price & Features**  
   Contrast laptops and desktops in terms of price and release-year trends to reveal category-level differences.

3. **Measure Feature Impact on Price Variation**  
   Quantify how CPU tier, GPU tier, RAM, and storage drive price differences and determine which components are the strongest price predictors.

4. **Track Price Trends Across Release Years**  
   Analyze year-over-year pricing shifts from 2018–2025 to detect market inflation, deflation, or major pricing disruptions.

5. **Analyze Form Factor Pricing Differences**  
   Compare ultrabooks, towers, gaming laptops, and Mainstream to identify which form factors offer the best value relative to performance.

6. **Identifies price–performance relationships**  
   How do average prices vary across CPU performance tiers, and which tier offers the highest value relative to its specifications?
   
7. **Evaluates brand innovation trends**  
   Which brands have introduced the most new models in the past five years, and how do their average prices compare over the same period?

8. **Compares GPU tiering across device_type**  
   What is the distribution of GPU tiers across different device types, and which device category tends to use higher-end GPUs?

9. **Combined performance metrices**  
   Which form factors (e.g., ultrabook, gaming laptop, desktop tower) deliver the best performance-to-weight ratio based on CPU tier, GPU tier, and weight?

10. **Display Specification**  
   How do display specifications (panel type, resolution, refresh rate) influence average device pricing across the dataset?

11. **Explores price trends across hardware**  
    Which CPU and GPU combinations appear most frequently, and how does their average price compare to the dataset’s overall average?

12. **RAM–price relationship**  
    To what extent does RAM capacity affect final pricing across device categories, and is there evidence of diminishing returns at higher RAM levels?


## Conclusions
This SQL Computer Sales Analysis project uses advanced querying techniques to uncover how hardware specifications affect pricing, performance, and value across modern computer devices. By applying CTEs, window functions, correlations, and performance scoring, the project identifies top-performing models, pricing outliers, efficiency leaders, and meaningful trends such as diminishing returns on RAM and the impact of CPU/GPU tiers. The results show how SQL can effectively transform raw product data into clear insights that support pricing strategy, product comparison, and data-driven decision-making in the computer hardware market.

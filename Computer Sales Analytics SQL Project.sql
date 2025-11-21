
-- Q.1 Top Selling Price Categories
-- What are the top 10 most expensive models and their full specifications?

SELECT
	model,
	storage_type,	
	SUM(price) total_price
FROM all_computers
GROUP BY model, storage_type
ORDER BY total_price DESC
LIMIT 10;



-- Q.2 Compare Device Categories by Price & Features
-- Contrast laptops and desktops in terms of price and release-year trends to reveal category-level differences.

SELECT
*,
ROW_NUMBER() OVER(PARTITION BY release_year ORDER BY total_price DESC) rank_yr
FROM
(
	SELECT 
		device_type,
		release_year,
		SUM(price) total_price
	FROM all_computers
	GROUP BY device_type, release_year
	ORDER BY total_price DESC
);



-- Q.3 Measure Feature Impact on Price Variation
-- Quantify how CPU tier, GPU tier, RAM, and storage drive price differences and determine which components are the strongest price predictors.

SELECT
	'Cpu_tier vs Price' features_relation,
	ROUND(CORR(cpu_tier, price)::decimal,3) correlation_coefficient 
FROM all_computers

UNION ALL

SELECT
	'Gpu_tier vs Price',
	ROUND(CORR(gpu_tier, price)::decimal,3)
FROM all_computers

UNION ALL

SELECT
	'Ram_gb vs Price',
	ROUND(CORR(ram_gb, price)::decimal,3)
FROM all_computers

UNION ALL

SELECT
	'Cpu_cores vs Price',
	ROUND(CORR(cpu_cores, price)::decimal,3)
FROM all_computers

UNION ALL

SELECT
	'Vram_gb vs Price',
	ROUND(CORR(vram_gb, price)::decimal,3)
FROM all_computers

UNION ALL

SELECT
	'Storage_gb vs Price',
	ROUND(CORR(storage_gb, price)::decimal,3)
FROM all_computers

UNION ALL

SELECT
	'Display_size vs Price',
	ROUND(CORR(display_size_in, price)::decimal,3)
FROM all_computers

UNION ALL

SELECT
	'Battery watts vs Price',
	ROUND(CORR(battery_wh, price)::decimal,3)
FROM all_computers;

/*
Correlation close to +1 → (higher spec = higher price)
Correlation near 0 → weak impact
cpu_tier, cpu_cores, gpu_tier, ram_gb Used to predict the price of Laptop or Desktop
*/


-- Q.4 Track Price Trends Across Release Years
-- Analyze year-over-year pricing shifts from 2018–2025 to detect market inflation, deflation, or major pricing disruptions.

SELECT
*,
CASE
	WHEN yoy_diff IS NULL THEN 'N/A'
	WHEN avg_price > yoy_diff THEN 'Inflation'
	WHEN avg_price < yoy_diff THEN 'Difflation'
	ELSE 'Stable'
END AS description
FROM(
	WITH yoy_difference AS
	(
		SELECT
			release_year,
			ROUND(AVG(price),3) avg_price
		FROM all_computers
		GROUP BY release_year
	)
	SELECT
		release_year,
		avg_price,
		LAG(avg_price) OVER(ORDER BY release_year) yoy_diff,
		avg_price - LAG(avg_price) OVER(ORDER BY release_year) avg_yoy_diff,
		ROUND(
			((avg_price - LAG(avg_price) OVER(ORDER BY release_year))
			/LAG(avg_price) OVER(ORDER BY release_year))
		* 100,2) pec_yoy_diff
	FROM yoy_difference
);


-- Q.5 Analyze Form Factor Pricing Differences
-- Compare ultrabooks, towers, gaming laptops, and Mainstream to identify which form factors offer the best value relative to performance.

SELECT
    form_factor,
    ROUND(AVG(cpu_tier),3)AS avg_cpu_tier,
    ROUND(AVG(gpu_tier),3) AS avg_gpu_tier,
    ROUND(AVG(ram_gb),3) AS avg_ram,
    ROUND(AVG(storage_gb),3) AS avg_storage,
    ROUND(AVG(display_size_in)::decimal,3) AS avg_display_size
FROM all_computers
WHERE form_factor = 'Gaming' OR form_factor = 'Ultrabook' OR form_factor = 'Mainstream' OR form_factor = 'Full-Tower' 
GROUP BY form_factor
ORDER BY avg_cpu_tier DESC;

-- Gaming => Full-Tower => Mainstream => Ultrabook

-- Q.6 Identifies price–performance relationships
-- How do average prices vary across CPU performance tiers, and which tier offers the highest value relative to its specifications?

SELECT
	cpu_tier,
	ROUND(AVG(cpu_cores),2) avg_cpu_cores,
	ROUND(AVG(cpu_threads),2) avg_cpu_threads,
	ROUND(AVG(cpu_base_ghz)::decimal,2) avg_cpu_base_ghz,
	ROUND(AVG(cpu_boost_ghz)::decimal,2) avg_cpu_boost_ghz,
	ROUND(AVG(price),2) avg_price
FROM all_computers
GROUP BY cpu_tier
ORDER BY avg_price DESC;


/*
-- The following are the CPU tiers that offers the highest value per price depending on its cpu specifications:
	a. cpu_tier 6
	b. cpu_tier 5
	c. cpu_tier 4
*/

-- Q.7 Evaluates brand innovation trends
-- Which brands have introduced the most new models in the past five years, and how do their average prices compare over the same period?


WITH new_models AS
(
	SELECT
		brand,
		model,
		release_year,
		price
	FROM all_computers
	WHERE release_year >= EXTRACT(YEAR FROM CURRENT_DATE) - 5
	
),
number_model AS
(
	SELECT
		brand,
		COUNT(model) num_models,
		ROUND(AVG(price),2) avg_price
	FROM new_models
	GROUP BY brand
	
)
SELECT
brand,
num_models,
avg_price
FROM number_model
GROUP BY brand, num_models, avg_price
ORDER BY num_models DESC;

/*
The following brands have had an increase in the number of models in the last past years
	a. Lenovo 
	-Had the highest number of models of 14014, with a high average price of 1878.78
	b. HP
	-Had a higher number of models of 12402, with an average price of 1868.28
	c. Dell
	-Encountered a higher number of models of 12286, with a higher average price of 1893.47
	d. Apple
	-Encountered a high number of models of 10503, with the highest average price of 2376.23
*/

-- Q.8 Compares GPU tiering across device_type.
-- What is the distribution of GPU tiers across different device types, and which device category tends to use higher-end GPUs?

SELECT 
	device_type,
	ROUND(AVG(gpu_tier),2) avg_gpu_tier,
	ROUND(AVG(vram_gb),2) avg_vram_gb,
	ROUND(AVG(ram_gb),2) avg_ram_gb,
	ROUND(AVG(price)::numeric,2) avg_price
FROM all_computers
GROUP BY device_type;

-- From the analysis, Desktop device type experienced higher end GPUs with 
-- Gpu tier = 3.16
-- Vram Gb = 6.42 
-- Ram Gb = 41.56

-- Q.9 Combined performance metrices 
-- Which form factors (e.g., ultrabook, gaming laptop, desktop tower) deliver the best performance-to-weight ratio based on CPU tier, GPU tier, and weight?


SELECT
*
FROM
(
	WITH performance_weight_calc AS
	(
		SELECT 
			form_factor,
			cpu_tier,
			gpu_tier,
			ram_gb,
			weight_kg,
			(cpu_tier * 0.5) + (gpu_tier * 0.5) + (ram_gb * 0.1) AS performance_weight
		FROM all_computers
		WHERE weight_kg IS NOT NULL
	),
	performance_weight_ratio AS
	(
		SELECT
		form_factor,
		cpu_tier,
		gpu_tier,
		ROUND(performance_weight/weight_kg::decimal,3) AS performance_ratio
		FROM performance_weight_calc
	)
	SELECT *,
	ROW_NUMBER() OVER(PARTITION BY form_factor ORDER BY performance_ratio DESC ) ratio_rank
	FROM performance_weight_ratio
)
WHERE ratio_rank <= 3;


-- Q.10 Display Specification 
-- How do display specifications (panel type, resolution, refresh rate) influence average device pricing across the dataset?

SELECT
*
FROM
(
	WITH display_spec AS 
	(
		SELECT 
			display_type,
			resolution,
			refresh_hz,
			ROUND(AVG(display_size_in)::decimal,3) avg_display_size,
			ROUND(AVG(price)::decimal,2) avg_price
		FROM all_computers
		GROUP BY display_type, resolution, refresh_hz
	)
	SELECT
	display_type,
	resolution,
	refresh_hz,
	avg_display_size,
	avg_price,
	ROW_NUMBER() OVER(PARTITION BY  resolution, display_type ORDER BY avg_price DESC) rank_specification 
	FROM display_spec
)
WHERE rank_specification <= 3;

-- Q.11 Explores price trends across hardware
-- Which CPU and GPU combinations appear most frequently, and how does their average price compare to the dataset’s overall average?


WITH cpu_gpu_combination AS
(
	SELECT
		cpu_brand,
		cpu_model,
		gpu_brand,
		gpu_model,
		COUNT(*) num_models,
		ROUND(AVG(price),2) avg_price
	FROM all_computers
	WHERE price IS NOT NULL
	GROUP BY cpu_brand, cpu_model,gpu_brand,gpu_model
),
avg_price_applic AS
(
	SELECT
		ROUND(AVG(price),2) overal_avg_price
	FROM all_computers
	WHERE price IS NOT NULL

)
SELECT
cgc.cpu_brand,
cgc.cpu_model,
cgc.gpu_brand,
cgc.gpu_model,
cgc.num_models,
cgc.avg_price,
(app.overal_avg_price - cgc.avg_price) price_diff
FROM cpu_gpu_combination cgc
CROSS JOIN avg_price_applic app
ORDER BY cgc.num_models DESC;


-- Q.12 RAM–price relationship
-- To what extent does RAM capacity affect final pricing across device categories, and is there evidence of diminishing returns at higher RAM levels?

SELECT*
FROM
(
	WITH dev_ram_correlation AS
	(
		SELECT
			device_type,
			COUNT(*) num_device,
			ROUND(CORR(ram_gb, price)::numeric,3) ram_correlation
		FROM all_computers
		WHERE price IS NOT NULL
		GROUP BY device_type
		ORDER BY ram_correlation DESC
	),
	price_diminishing AS
	(
		SELECT 
			device_type,
			ram_gb,
			ROUND(AVG(price),2) avg_price,
			LAG(ROUND(AVG(price),2)) OVER(PARTITION BY device_type ORDER BY ram_gb DESC) prev_avg_price,
			ROUND(AVG(price),2)-LAG(ROUND(AVG(price),2)) OVER(PARTITION BY device_type ORDER BY ram_gb DESC) AS price_incriment
		FROM all_computers
		GROUP BY device_type, ram_gb
	)
	SELECT
		drc.device_type,
		pd.ram_gb,
		drc.num_device,
		drc.ram_correlation,
		pd.avg_price,
		pd.prev_avg_price,
		pd.price_incriment
	FROM dev_ram_correlation drc
	LEFT JOIN price_diminishing pd
		ON drc.device_type = pd.device_type
)
WHERE price_incriment IS NOT NULL




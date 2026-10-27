CREATE TABLE financial_performance (
    year INTEGER PRIMARY KEY,
    data_type TEXT,
    revenue REAL,
    operating_costs REAL,
    depreciation REAL,
    capex REAL,
    receivables REAL
);

INSERT INTO financial_performance
(year, data_type, revenue, operating_costs,
 depreciation, capex, receivables)
VALUES
(2023, 'Actual',   80,      58.4,    4,      8,       16),
(2024, 'Actual',   90,      64.8,    4.5,    9,       18),
(2025, 'Actual',   100,     70,      5,      10,      20),
(2026, 'Forecast', 110,     77,      5.5,    11,      22),
(2027, 'Forecast', 118.8,   83.16,   5.94,   11.88,   23.76),
(2028, 'Forecast', 125.928, 88.1496, 6.2964, 12.5928, 25.1856);

SELECT revenue
FROM financial_performance
ORDER BY year;

SELECT * 
FROM financial_performance
GROUP BY year
ORDER by revenue DESC;

SELECT
       year,
	   revenue,
	   operating_costs,
	  ROUND (revenue - operating_costs, 2) AS EBITDA
FROM financial_performance
ORDER BY year;

SELECT 
      year,
	  ROUND((((revenue - operating_costs)/revenue))*100, 2) AS ebitda_margin_pct
FROM financial_performance
ORDER BY year DESC;

SELECT 
      year,
	  revenue,
	  LAG(revenue) OVER (ORDER BY year) AS previous_revenue
FROM financial_performance
ORDER BY year;

WITH revenue_analysis AS(
SELECT 
      year,
	  revenue,
	  LAG (revenue) OVER(ORDER BY year) AS previous_revenue
FROM financial_performance
)
SELECT 
      year,
	  revenue,
	  previous_revenue,
	  ROUND(((revenue-previous_revenue)/previous_revenue)*100, 2) AS revenue_growth_pct
FROM revenue_analysis
ORDER BY year DESC;

SELECT 
      year,
	  revenue,
	  data_type,
	  ROUND(revenue - operating_costs, 2) AS EBITDA
FROM financial_performance
WHERE data_type = "Forecast";

CREATE VIEW financial_indicators AS
SELECT
      year,
	  revenue,
	  operating_costs,
	  ROUND(revenue - operating_costs, 2) AS EBITDA,
	  ROUND(((revenue - operating_costs)/revenue)*100, 2) AS EBITDA_margin_pct
FROM financial_performance;

DROP VIEW IF EXISTS financial_indicators;

CREATE VIEW financial_indicators AS
SELECT
    year,
    data_type,
    revenue,
    operating_costs,
    ROUND(revenue - operating_costs, 2) AS EBITDA,
    ROUND(
        (revenue - operating_costs) * 100.0 / revenue,
        2
    ) AS EBITDA_margin_pct
FROM financial_performance;

SELECT 
      year,
	  revenue, 
	  data_type,
	  EBITDA
FROM financial_indicators;

SELECT 
      year,
	  revenue,
	  data_type,
	  EBITDA,
	  LAG(revenue) OVER (ORDER BY year) AS previous_revenue,
      lAG(EBITDA) OVER(ORDER BY year) AS previous_EBITDA
FROM financial_indicators
ORDER BY year;

WITH comparison AS(
SELECT 
      year,
	  data_type,
	  revenue,
	  EBITDA,
	  LAG(revenue) OVER(ORDER BY year) AS previous_revenue,
	  lag (EBITDA) OVER(ORDER BY year) AS previous_EBITDA
FROM financial_indicators
)
SELECT 
      year,
	  data_type,
	  revenue, 
	  EBITDA,
	  previous_revenue,
	  previous_EBITDA,
	  ROUND(((EBITDA - previous_EBITDA)/previous_EBITDA)*100, 2) AS EBITDA_growth_pct,
	  ROUND(((revenue - previous_revenue)/previous_revenue)*100, 2) AS revenue_growth_pct
FROM comparison
ORDER BY year;

CREATE TABLE financial_budget (
    year INTEGER PRIMARY KEY,
    budget_revenue REAL,
    budget_operating_costs REAL
);

INSERT INTO financial_budget
(year, budget_revenue, budget_operating_costs)
VALUES
(2023, 82, 60),
(2024, 92, 65),
(2025, 105, 72);

SELECT 
      year,
	  budget_revenue,
	  budget_operating_costs
FROM financial_budget
ORDER BY year ASC;

SELECT 
      f.year,
	  f.revenue,
	  b.budget_revenue,
	  ROUND(f.revenue - b.budget_revenue, 2) AS revenue_variance
FROM financial_performance AS f
INNER JOIN financial_budget AS b
      ON f.year = b.year
ORDER BY f.year;

SELECT 
       f.year,
	   f.revenue,
	   b.budget_revenue,
	   ROUND(f.revenue - b.budget_revenue, 2) AS revenue_variance,
	   ROUND(((f.revenue - b.budget_revenue)/b.budget_revenue)*100, 2) AS revenue_variance_pct
FROM financial_performance AS f
     INNER JOIN financial_budget AS b
	 ON f.year = b.year 
ORDER BY f.year; 



SELECT 
      f.year,
	  f.revenue,
	  f.operating_costs,
	  b.budget_revenue,
	  b.budget_operating_costs,
	  ROUND(f.revenue - f.operating_costs, 2) AS actual_EBITDA,
	  ROUND(b.budget_revenue - b.budget_operating_costs, 2) AS budget_EBITDA
FROM financial_performance AS f
     INNER JOIN financial_budget AS b
	 ON f.year = b.year
ORDER BY f.year;

SELECT 
      f.year,
	  f.revenue, 
	  f.operating_costs,
	  b.budget_revenue,
	  b.budget_operating_costs,
	  ROUND(f.revenue - f.operating_costs, 2) AS actual_EBITDA,
	  ROUND(b.budget_revenue - b.budget_operating_costs, 2) AS budget_EBITDA,
	  ROUND ((f.revenue - f.operating_costs) - (b.budget_revenue - b.budget_operating_costs), 2) AS EBITDA_variance
FROM financial_performance AS f
      INNER JOIN financial_budget AS b
	  ON f.year = b.year
ORDER BY f.year;
	  
SELECT 
      f.year,
	  f.revenue, 
	  f.operating_costs,
	  b.budget_revenue,
	  b.budget_operating_costs,
	  ROUND(f.revenue - f.operating_costs, 2) AS actual_EBITDA,
	  ROUND(b.budget_revenue - b.budget_operating_costs, 2) AS budget_EBITDA,
	  ROUND ((f.revenue - f.operating_costs) - (b.budget_revenue - b.budget_operating_costs), 2) AS EBITDA_variance,
	  ROUND (((f.revenue - f.operating_costs) - (b.budget_revenue - b.budget_operating_costs))/(b.budget_revenue - b.budget_operating_costs)*100, 2) AS EBITDA_variance_pct
FROM financial_performance AS f
      INNER JOIN financial_budget AS b
	  ON f.year = b.year
ORDER BY f.year; 

SELECT 
      year,
	  revenue, 
	  depreciation,
	  capex,
	  ROUND((capex/revenue)*100, 2) AS capex_pct
FROM financial_performance
ORDER BY year;

WITH comparison AS(
SELECT
      year,
	  receivables,
	  LAG(receivables) OVER(ORDER BY year) AS previous_receivables
FROM financial_performance
)
SELECT 
	  year,
	  receivables,
	  previous_receivables,
	  ROUND(receivables - previous_receivables, 2) AS receivables_change
FROM comparison 
ORDER BY year;

WITH comparison AS (
SELECT
      year,
	  revenue,
	  operating_costs,
	  depreciation,
	  ROUND(revenue - operating_costs - depreciation, 2) AS EBIT
FROM financial_performance
WHERE data_type = "Forecast"
) 

WITH financial_calc AS (
SELECT
      year,
	  revenue,
	  revenue - operating_costs AS EBITDA,
	  revenue - operating_costs - depreciation AS EBIT
FROM financial_performance
WHERE data_type = "Forecast"
)
SELECT 
      year, 
	  ROUND(revenue, 2) AS revenue,
	  ROUND(EBITDA, 2) AS EBITDA,
	  ROUND(EBIT, 2) AS EBIT,
	  ROUND(EBIT *(1-0.16), 2) AS NOPAT
FROM financial_calc
ORDER BY year;

SELECT 
      *
FROM financial_performance;
   
WITH base AS(
SELECT
      year,
	  data_type,
	  revenue,
	  operating_costs,
	  depreciation,
	  capex,
	  receivables,
	  LAG(receivables) OVER(ORDER BY year) AS previous_receivables
from financial_performance
),
    
financial_calc AS(
SELECT
      *,
	  receivables - previous_receivables AS receivables_change,
	  revenue - operating_costs AS EBITDA,
	  revenue - operating_costs - depreciation AS EBIT
FROM base
)
SELECT 
      year, 
	  ROUND(revenue, 2) AS revenue,
	  ROUND(depreciation, 2) AS depreciation,
	  ROUND(capex, 2) AS capex,
	  ROUND(receivables, 2) AS receivables,
	  ROUND(previous_receivables, 2) AS previous_receivables,
	  ROUND(receivables_change, 4) AS receivables_changes,
	  ROUND(EBITDA, 2) AS EBITDA,
	  ROUND(EBIT, 2) AS EBIT,
	  ROUND(EBIT *(1-0.16), 2) AS NOPAT,
	  ROUND((EBIT *0.84) + depreciation - capex - receivables_change, 5) AS FCFF
FROM financial_calc
WHERE data_type = "Forecast"
ORDER BY year;

SELECT
      year,
	  data_type,
	  revenue,
	  EBITDA,
	  EBITDA_margin_pct
FROM financial_indicators
ORDER BY year;
	  
 
 
 


	  
	  
	  

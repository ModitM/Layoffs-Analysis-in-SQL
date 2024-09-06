
-- EXPLORATORY DATA ANALYSIS OF LAYOFF_STAGED DATASET
-- PERCENTAGE LAID-OFF (1=100%) IS NOT MUCH USEFUL AS WE DON'T KNOW ABOUT THE COMPANY SIZE 
-- I.E TOTAL EMPLOYEES BEFORE THE LAYING-OFF

SELECT MIN(date) Min_date, MAX(date) Max_date FROM layoffs_staged;
-- From the date range we can say that the data regarding layoffs belongs to COVID pandemic period

-- MAXIMUM TOTAL LAID-OFF AND MAXIMUM PERCENTAGE LAID-OFF
SELECT MAX(total_laid_off) Max_laid_off, MAX(percentage_laid_off) as Max_Percent_laid_off
FROM layoffs_staged;

-- DETAILS OF THE COMPANIES WHERE LAID-OFF WAS 100% IN DECREASING ORDER OF TOTAL LAID-OFF
SELECT *
FROM layoffs_staged
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

-- DETAILS OF THE COMPANIES WHERE LAID-OFF WAS 100% AND FUNDS RAISED IS MORE THAN 1 BILLION 
-- IN DECREASING ORDER OF FUNDS RAISED (MILLIONS)
SELECT *
FROM layoffs_staged
WHERE percentage_laid_off = 1 AND funds_raised_millions >= 1000
ORDER BY funds_raised_millions DESC;

-- COMPANY WISE TOTAL LAID-OFF IN DECREASING ORDER OF TOTAL LAID-OFF
SELECT company, SUM(total_laid_off) Total_laid_off
FROM layoffs_staged
GROUP BY company
ORDER BY 2 DESC;

-- INDUSTRY WISE TOTAL LAID-OFF IN DECREASING ORDER OF TOTAL LAID-OFF
SELECT industry, SUM(total_laid_off) Total_laid_off
FROM layoffs_staged
GROUP BY industry
ORDER BY 2 DESC;

-- COUNTRY WISE TOTAL LAID-OFF IN DECREASING ORDER OF TOTAL LAID-OFF
SELECT country, SUM(total_laid_off) Total_laid_off
FROM layoffs_staged
GROUP BY country
ORDER BY 2 DESC;

-- STAGE WISE TOTAL LAID-OFF IN DECREASING ORDER OF TOTAL LAID-OFF
SELECT stage, SUM(total_laid_off) Total_laid_off
FROM layoffs_staged
GROUP BY stage
ORDER BY 2 DESC;

-- DATE WISE TOTAL LAID-OFF CHRONOLOGICALLY
SELECT date, SUM(total_laid_off) Total_laid_off
FROM layoffs_staged
GROUP BY date
ORDER BY 1;

-- YEAR WISE TOTAL LAID-OFF (LATEST TO BEGINNING)
SELECT YEAR(date) Year, SUM(total_laid_off) Total_laid_off
FROM layoffs_staged
GROUP BY YEAR(date)
ORDER BY 1 DESC;

-- MONTH WISE LAID-OFF AND CUMULATIVE LAID-OFF
WITH Rolling AS
(
SELECT CAST(YEAR(date) AS VARCHAR(4)) + '-' + RIGHT('0' + CAST(MONTH(date) AS VARCHAR(2)), 2) AS Month
, SUM(total_laid_off) AS Laid_off
FROM layoffs_staged
GROUP BY
	CAST(YEAR(date) AS VARCHAR(4)) + '-' + RIGHT('0' + CAST(MONTH(date) AS VARCHAR(2)), 2)
)
SELECT Month, Laid_off
,SUM(Laid_off) OVER (ORDER BY Month) AS Rolling_total
FROM Rolling;

-- TOP 5 LAYING-OFF COMPANIES IN EACH YEAR 
WITH company_year AS 
(
SELECT company, YEAR(date) AS Year, SUM(total_laid_off) AS Laid_Off 
FROM layoffs_staged
GROUP BY company, YEAR(date)
HAVING SUM(total_laid_off) IS NOT NULL
), company_rank AS 
(
SELECT *,
DENSE_RANK() OVER (PARTITION BY Year ORDER BY Laid_Off DESC) AS Ranking
FROM company_year)
SELECT * 
FROM company_rank
WHERE Ranking <= 5;

-- TOP 5 LAYING-OFF INDUSTRIES IN EACH YEAR 
WITH industry_year AS 
(
SELECT industry, YEAR(date) AS Year, SUM(total_laid_off) AS Laid_Off 
FROM layoffs_staged
GROUP BY industry, YEAR(date)
HAVING SUM(total_laid_off) IS NOT NULL
), industry_rank AS 
(
SELECT *,
DENSE_RANK() OVER (PARTITION BY Year ORDER BY Laid_Off DESC) AS Ranking
FROM industry_year)
SELECT * 
FROM industry_rank
WHERE Ranking <= 5;

-- TOP 5 LAYING-OFF COUNTRIES IN EACH YEAR 
WITH country_year AS 
(
SELECT country, YEAR(date) AS Year, SUM(total_laid_off) AS Laid_Off 
FROM layoffs_staged
GROUP BY country, YEAR(date)
HAVING SUM(total_laid_off) IS NOT NULL
), country_rank AS 
(
SELECT *,
DENSE_RANK() OVER (PARTITION BY Year ORDER BY Laid_Off DESC) AS Ranking
FROM country_year)
SELECT * 
FROM country_rank
WHERE Ranking <= 5;

-- TOP 5 LAYING-OFF STAGES OF COMPANIES IN EACH YEAR 
WITH stage_year AS 
(
SELECT stage, YEAR(date) AS Year, SUM(total_laid_off) AS Laid_Off 
FROM layoffs_staged
GROUP BY stage, YEAR(date)
HAVING SUM(total_laid_off) IS NOT NULL
), stage_rank AS 
(
SELECT *,
DENSE_RANK() OVER (PARTITION BY Year ORDER BY Laid_Off DESC) AS Ranking
FROM stage_year)
SELECT * 
FROM stage_rank
WHERE Ranking <= 5;
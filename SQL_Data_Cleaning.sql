
-- This data set contains the data about the layoffs in the companies during COVID PANDEMIC
-- Data Cleaning on Layoffs
-- Before proceeding, we will make a copy of raw data where data manipulation will be done.
-- Steps in data cleaning
-- 1. Removing duplicate rows
-- 2. Standardising data set
-- 3. Removing/Filling null or blank places
-- 4. Removing unwanted Rows or Columns

-- Creating copy of raw data
USE [probo]
GO

/****** Object:  Table [dbo].[layoffs_raw]    Script Date: 03-Sep-24 7:25:49 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[layoffs_staged](
	[company] [varchar](50) NULL,
	[location] [varchar](50) NULL,
	[industry] [varchar](50) NULL,
	[total_laid_off] [varchar](50) NULL,
	[percentage_laid_off] [varchar](50) NULL,
	[date] [varchar](50) NULL,
	[stage] [varchar](50) NULL,
	[country] [varchar](50) NULL,
	[funds_raised_millions] [varchar](50) NULL
) ON [PRIMARY]
GO

-- Inserting values from raw data set to staged data set
INSERT INTO layoffs_staged
SELECT * FROM layoffs_raw;

-- 1. Looking for duplicate rows and removing them
WITH t1 AS (
SELECT *,
ROW_NUMBER() OVER (PARTITION BY company,location,industry,total_laid_off,
percentage_laid_off, date, stage,country,funds_raised_millions ORDER BY funds_raised_millions) as rk
FROM layoffs_staged
)
DELETE FROM t1 WHERE rk > 1

-- 2. Standardising the data set by checking for each column
--
SELECT DISTINCT company FROM layoffs_staged ORDER BY 1;
UPDATE layoffs_staged
	SET company = TRIM(company)
--
SELECT DISTINCT location FROM layoffs_staged ORDER BY 1;
UPDATE layoffs_staged
	SET location = TRIM(location)
--
SELECT DISTINCT industry FROM layoffs_staged ORDER BY 1;
UPDATE layoffs_staged
	SET industry = TRIM(industry)
UPDATE layoffs_staged
	SET industry = 'Crypto' WHERE LOWER(industry) LIKE 'crypto%'
--
SELECT DISTINCT stage FROM layoffs_staged ORDER BY 1;
UPDATE layoffs_staged
	SET stage = TRIM(stage)
--
SELECT DISTINCT country FROM layoffs_staged ORDER BY 1;
UPDATE layoffs_staged
	SET country = TRIM(country)
UPDATE layoffs_staged
	SET country = 'United States' WHERE LOWER(country) like 'united state%'

-- Updating data types of numerical and date columns
--
UPDATE layoffs_staged
	SET date = TRY_CAST(date AS DATE)
ALTER TABLE layoffs_staged
	ALTER COLUMN date DATETIME
--
UPDATE layoffs_staged
	SET total_laid_off = TRY_CAST(total_laid_off AS INT)
ALTER TABLE layoffs_staged
	ALTER COLUMN total_laid_off INT
--
UPDATE layoffs_staged
	SET percentage_laid_off = TRY_CAST(percentage_laid_off AS FLOAT)
ALTER TABLE layoffs_staged
	ALTER COLUMN percentage_laid_off FLOAT
--
UPDATE layoffs_staged
	SET funds_raised_millions = TRY_CAST(funds_raised_millions AS FLOAT)
ALTER TABLE layoffs_staged
	ALTER COLUMN funds_raised_millions FLOAT

-- 3. Handling NULL values, Blank values by dropping them  
--
SELECT * FROM layoffs_staged WHERE company = '' OR company IS NULL; 
--
SELECT * FROM layoffs_staged WHERE location = '' OR location IS NULL; 
--
SELECT * FROM layoffs_staged WHERE industry IS NULL or industry = '' OR industry = 'NULL';
UPDATE layoffs_staged
SET industry = NULL
WHERE industry IS NULL or industry = '' OR industry = 'NULL';

UPDATE t1
SET t1.industry = t2.industry
FROM layoffs_staged t1
INNER JOIN layoffs_staged t2
    ON t1.company = t2.company AND t1.location = t2.location
WHERE (t1.industry IS NULL) 
    AND (t2.industry IS NOT NULL);

SELECT * FROM layoffs_staged WHERE industry IS NULL;
DELETE FROM layoffs_staged
WHERE industry IS NULL;
--
SELECT * FROM layoffs_staged WHERE date = '' OR date IS NULL; 
DELETE FROM layoffs_staged
WHERE date IS NULL;
--
SELECT * FROM layoffs_staged WHERE stage = '' OR stage IS NULL; 
--
SELECT * FROM layoffs_staged WHERE country = '' OR country IS NULL; 
--
SELECT * FROM layoffs_staged WHERE funds_raised_millions = '' OR funds_raised_millions IS NULL;
--
SELECT * FROM layoffs_staged WHERE total_laid_off = '' OR total_laid_off IS NULL; 
SELECT * FROM layoffs_staged WHERE percentage_laid_off = '' OR percentage_laid_off IS NULL; 
SELECT * FROM layoffs_staged WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL; 

DELETE FROM layoffs_staged
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

SELECT * FROM layoffs_staged;
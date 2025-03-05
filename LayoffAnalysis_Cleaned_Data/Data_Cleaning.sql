-- Data Cleaning

-- Create a temporary staging table with the same structure as the original table
CREATE TABLE layoffs_staging LIKE layoffs;

-- Insert data from the original table into the staging table
INSERT INTO layoffs_staging
SELECT * FROM layoffs;

-- 1. Remove Duplicates (Optimized)
WITH duplicate_cte AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
               ORDER BY company, location) AS row_num
    FROM layoffs_staging
)
-- Delete duplicate records by keeping the first instance of each
DELETE FROM layoffs_staging
WHERE row_num > 1;

-- Standardizing Data (Optimized)
-- Trim any unnecessary spaces from the `company` column
UPDATE layoffs_staging
SET company = TRIM(company);

-- Standardize 'industry' values for crypto-related companies
UPDATE layoffs_staging
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Remove any trailing period from country names
UPDATE layoffs_staging
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- Convert date column to the appropriate date format
UPDATE layoffs_staging
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Alter column type for 'date' after conversion
ALTER TABLE layoffs_staging MODIFY `date` DATE;

-- Handle Null or Blank Values (Optimized)
-- Fill industry values for missing values based on company name
UPDATE layoffs_staging AS t1
JOIN layoffs_staging AS t2 ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;

-- Remove records with both total_laid_off and percentage_laid_off as null
DELETE FROM layoffs_staging
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

-- Clean up unnecessary columns (row_num in this case)
ALTER TABLE layoffs_staging DROP COLUMN row_num;

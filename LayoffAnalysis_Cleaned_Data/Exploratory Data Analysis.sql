-- EDA: Explore the Data and Identify Trends, Patterns, or Outliers

-- Explore the dataset
SELECT * FROM world_layoffs.layoffs_staging2;

-- EASIER QUERIES

-- Find the maximum number of total layoffs
SELECT MAX(total_laid_off) FROM world_layoffs.layoffs_staging2;

-- Explore the percentage of layoffs (maximum and minimum)
SELECT MAX(percentage_laid_off), MIN(percentage_laid_off)
FROM world_layoffs.layoffs_staging2
WHERE percentage_laid_off IS NOT NULL;

-- Companies with 100% layoffs (percentage = 1)
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE percentage_laid_off = 1;

-- Order companies by funds raised, showing large companies with 100% layoffs
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- GROUP BY QUERIES

-- Companies with the biggest single-day layoffs
SELECT company, total_laid_off
FROM world_layoffs.layoffs_staging
ORDER BY total_laid_off DESC
LIMIT 5;

-- Companies with the most total layoffs (grouped by company)
SELECT company, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY company
ORDER BY SUM(total_laid_off) DESC
LIMIT 10;

-- Companies with the most layoffs by location
SELECT location, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY location
ORDER BY SUM(total_laid_off) DESC
LIMIT 10;

-- Total layoffs by country
SELECT country, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY country
ORDER BY SUM(total_laid_off) DESC;

-- Layoffs by year
SELECT YEAR(date) AS year, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY YEAR(date)
ORDER BY year ASC;

-- Total layoffs by industry
SELECT industry, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY industry
ORDER BY SUM(total_laid_off) DESC;

-- Layoffs by stage
SELECT stage, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY stage
ORDER BY SUM(total_laid_off) DESC;

-- TOUGHER QUERIES

-- Top 3 companies with the most layoffs per year
WITH Company_Year AS (
    SELECT company, YEAR(date) AS year, SUM(total_laid_off) AS total_laid_off
    FROM layoffs_staging2
    GROUP BY company, YEAR(date)
),
Company_Year_Rank AS (
    SELECT company, year, total_laid_off,
           DENSE_RANK() OVER (PARTITION BY year ORDER BY total_laid_off DESC) AS ranking
    FROM Company_Year
)
SELECT company, year, total_laid_off, ranking
FROM Company_Year_Rank
WHERE ranking <= 3 AND year IS NOT NULL
ORDER BY year ASC, total_laid_off DESC;

-- Rolling total of layoffs per month
SELECT SUBSTRING(date, 1, 7) AS month, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY month
ORDER BY month ASC;

-- Use a CTE to calculate the rolling total of layoffs
WITH DATE_CTE AS (
    SELECT SUBSTRING(date, 1, 7) AS month, SUM(total_laid_off) AS total_laid_off
    FROM layoffs_staging2
    GROUP BY month
    ORDER BY month ASC
)
SELECT month, SUM(total_laid_off) OVER (ORDER BY month ASC) AS rolling_total_layoffs
FROM DATE_CTE
ORDER BY month ASC;

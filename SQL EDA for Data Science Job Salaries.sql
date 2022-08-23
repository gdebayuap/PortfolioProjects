/*
EDA for Data Science Job Salaries Dataset
You can get the dataset from --> https://www.kaggle.com/datasets/ruchi798/data-science-job-salaries/download?datasetVersionNumber=1
*/

SELECT *
FROM PortfolioProject.dbo.ds_salaries

SELECT *
FROM PortfolioProject.dbo.country_iso3

/*
DATA CLEANING
*/

-- Change experience_level EN, ..., EX into experience_category Entry-level, ..., Executive-level.
SELECT 
	experience_level,
	CASE
		WHEN experience_level = 'EN' THEN 'Entry-Level/Junior'
		WHEN experience_level = 'MI' THEN 'Mid-Level/Intermediate'
		WHEN experience_level = 'SE' THEN 'Senior-Level/Expert'
		WHEN experience_level = 'EX' THEN 'Executive-Level/Director'
		ELSE experience_level
	END AS experience_category
FROM PortfolioProject.dbo.ds_salaries

ALTER TABLE PortfolioProject.dbo.ds_salaries
ADD experience_category nvarchar(255);

UPDATE PortfolioProject.dbo.ds_salaries
SET experience_category = CASE
				WHEN experience_level = 'EN' THEN 'Entry-Level/Junior'
				WHEN experience_level = 'MI' THEN 'Mid-Level/Intermediate'
				WHEN experience_level = 'SE' THEN 'Senior-Level/Expert'
				WHEN experience_level = 'EX' THEN 'Executive-Level/Director'
				ELSE experience_level
			END

-- Change employment_type CT, ..., PT into employment_category Contract, ..., Part-time.
SELECT DISTINCT(employment_type)
FROM PortfolioProject.dbo.ds_salaries

SELECT 
	DISTINCT(employment_type),
	CASE
		WHEN employment_type = 'CT' THEN 'Contract'
		WHEN employment_type = 'FL' THEN 'Freelance'
		WHEN employment_type = 'FT' THEN 'Full-time'
		WHEN employment_type = 'PT' THEN 'Part-time'
		ELSE employment_type
	END AS employment_category
FROM PortfolioProject.dbo.ds_salaries

ALTER TABLE PortfolioProject.dbo.ds_salaries
ADD employment_category nvarchar(255);

UPDATE PortfolioProject.dbo.ds_salaries
SET employment_category = CASE 
				WHEN employment_type = 'CT' THEN 'Contract'
				WHEN employment_type = 'FL' THEN 'Freelance'
				WHEN employment_type = 'FT' THEN 'Full-time'
				WHEN employment_type = 'PT' THEN 'Part-time'
				ELSE employment_type
			END

-- Create location by country name instead of country code
SELECT *
FROM PortfolioProject.dbo.ds_salaries s
LEFT JOIN PortfolioProject.dbo.country_iso3 c
	ON s.employee_residence = c.alpha_2_code

ALTER TABLE PortfolioProject.dbo.ds_salaries
ADD employee_location nvarchar(255);

UPDATE PortfolioProject.dbo.ds_salaries
SET ds_salaries.employee_location = country_iso3.country
FROM ds_salaries INNER JOIN country_iso3 ON ds_salaries.employee_residence = country_iso3.alpha_2_code

ALTER TABLE PortfolioProject.dbo.ds_salaries
ADD company_loc nvarchar(255);

UPDATE PortfolioProject.dbo.ds_salaries
SET ds_salaries.company_loc = country_iso3.country
FROM ds_salaries INNER JOIN country_iso3 ON ds_salaries.company_location = country_iso3.alpha_2_code

-- Drop unused column
ALTER TABLE PortfolioProject.dbo.ds_salaries
DROP COLUMN salary, salary_currency, experience_level, employment_type, employee_residence, company_location

/*
START ANALYSIS
*/

-- Top 10 popular job
SELECT experience_category, COUNT(employment_category) AS num_experience
FROM PortfolioProject.dbo.ds_salaries
GROUP BY experience_category
ORDER BY num_experience DESC

-- Experience level available in industry
SELECT TOP 10 job_title, COUNT(job_title) AS total_employee
FROM PortfolioProject.dbo.ds_salaries
GROUP BY job_title
ORDER BY total_employee DESC

-- AVG salary per job title
SELECT TOP 10 job_title, AVG(salary_in_usd) AS avg_salary
FROM PortfolioProject.dbo.ds_salaries
GROUP BY job_title
ORDER BY avg_salary DESC

-- MAX and MIN salary per job title
SELECT job_title, MAX(salary_in_usd) AS max_salary, MIN(salary_in_usd) AS min_salary
FROM PortfolioProject.dbo.ds_salaries
GROUP BY job_title
ORDER BY job_title ASC

-- Job title trend by work year
SELECT work_year, job_title, COUNT(job_title) as total_employee
FROM PortfolioProject.dbo.ds_salaries
GROUP BY job_title, work_year
ORDER BY work_year, total_employee DESC

-- Employment_category distribution
SELECT employment_category, COUNT(employment_category) as total_employee
FROM PortfolioProject.dbo.ds_salaries
GROUP BY employment_category
ORDER BY total_employee DESC

-- Employee residence location
SELECT employee_location, COUNT(employee_location) as total_employee
FROM PortfolioProject.dbo.ds_salaries
GROUP BY employee_location
ORDER BY total_employee DESC
-- LIMIT TO 5
SELECT TOP 5 employee_location, COUNT(employee_location) as total_employee
FROM PortfolioProject.dbo.ds_salaries
GROUP BY employee_location
ORDER BY total_employee DESC

-- Company size distribution
SELECT company_size, COUNT(company_size) as total_employee
FROM PortfolioProject.dbo.ds_salaries
GROUP BY company_size
ORDER BY total_employee DESC

-- Remote work ratio
SELECT CASE
		WHEN remote_ratio = 100 THEN 'Fully Remote'
		WHEN remote_ratio = 50 THEN 'Partial Remote'
		ELSE 'No Remote Work'
	 END remote_ratio, 
	 COUNT(remote_ratio) as total_employee
FROM PortfolioProject.dbo.ds_salaries
GROUP BY remote_ratio
ORDER BY total_employee DESC

-- Distribution of experience level by employment type (all work_year)
SELECT employment_category, experience_category, COUNT(experience_category) AS total_employee
FROM PortfolioProject.dbo.ds_salaries
GROUP BY employment_category, experience_category
ORDER BY total_employee DESC

-- Distribution of experience level by employment type work_year 2020
SELECT employment_category, experience_category, COUNT(experience_category) AS total_employee
FROM PortfolioProject.dbo.ds_salaries
WHERE work_year = 2020
GROUP BY employment_category, experience_category
ORDER BY total_employee DESC

-- Distribution of experience level by employment type work_year 2021
SELECT employment_category, experience_category, COUNT(experience_category) AS total_employee
FROM PortfolioProject.dbo.ds_salaries
WHERE work_year = 2021
GROUP BY employment_category, experience_category
ORDER BY total_employee DESC

-- Distribution of experience level by employment type work_year 2022
SELECT employment_category, experience_category, COUNT(experience_category) AS total_employee
FROM PortfolioProject.dbo.ds_salaries
WHERE work_year = 2022
GROUP BY employment_category, experience_category
ORDER BY total_employee DESC

--Distribution of experience level by job title
SELECT job_title, experience_category, COUNT(experience_category) AS total_employee
FROM PortfolioProject.dbo.ds_salaries
GROUP BY job_title, experience_category
ORDER BY job_title, total_employee, experience_category DESC

--Distribution of experience level by company size
SELECT company_size, experience_category, COUNT(experience_category) AS total_employee
FROM PortfolioProject.dbo.ds_salaries
GROUP BY company_size, experience_category
ORDER BY company_size, total_employee, experience_category DESC

-- Company Location distribution
SELECT company_loc, COUNT(job_title) AS total_employee
FROM PortfolioProject.dbo.ds_salaries
GROUP BY company_loc

-- Company Location distribution by experience level (entry-level)
SELECT company_loc, COUNT(job_title) AS total_employee
FROM PortfolioProject.dbo.ds_salaries
WHERE experience_category LIKE '%entry%'
GROUP BY company_loc

-- Company Location distribution by experience level (mid-level)
SELECT company_loc, COUNT(job_title) AS total_employee
FROM PortfolioProject.dbo.ds_salaries
WHERE experience_category LIKE '%mid%'
GROUP BY company_loc

-- Company Location distribution by experience level (senior-level)
SELECT company_loc, COUNT(job_title) AS total_employee
FROM PortfolioProject.dbo.ds_salaries
WHERE experience_category LIKE '%senior%'
GROUP BY company_loc

-- Company Location distribution by experience level (executive-level)
SELECT company_loc, COUNT(job_title) AS total_employee
FROM PortfolioProject.dbo.ds_salaries
WHERE experience_category LIKE '%executive%'
GROUP BY company_loc

-- Salary distribution by Company size
SELECT company_size, salary_in_usd
FROM PortfolioProject.dbo.ds_salaries
ORDER BY company_size, salary_in_usd ASC

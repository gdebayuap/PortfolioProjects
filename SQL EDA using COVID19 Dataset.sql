-- This is my first project by following AlexTheAnalyst Youtube Video -- https://www.youtube.com/watch?v=qfyynHBFOsM
-- And for the Dataset Covid-19 -- https://ourworldindata.org/covid-deaths

--Read from CovidDeaths Table

SELECT 
	*
FROM 
	PortfolioProject..CovidDeaths

-- Looking at Total Cases, Total Deaths and the Percentage of Cases vs Deaths per Date

SELECT  
	location, 
	date, 
	total_cases, 
	total_deaths,
	(total_deaths/total_cases) * 100 as Death_Percentage
FROM 
	PortfolioProject..CovidDeaths
ORDER BY
	location, date

-- Looking at Total Cases, Total Deaths and the Percentage of Cases vs Deaths per Date
-- For 2 queries below i only look data from my country Indonesia

SELECT  
	location, 
	date, 
	total_cases, 
	total_deaths,
	(total_deaths/total_cases) * 100 as Death_Percentage
FROM 
	PortfolioProject..CovidDeaths
WHERE 
	location = 'Indonesia'
ORDER BY
	date

-- Looking at Total Cases, Total Deaths and the Percentage of Cases vs Deaths
-- In my country Indonesia

SELECT  
	location, 
	SUM(new_cases) AS total_cases,	-- in here i use sum for new_cases and new_deaths instead of looking max for total_cases or total_deaths
	SUM(CONVERT(int, new_deaths)) AS total_deaths, -- need to convert from nvarchar to integer to do aggerate function (sum)
	SUM(CONVERT(int, new_deaths)) / SUM(new_cases) * 100 as Death_Percentage
FROM 
	PortfolioProject..CovidDeaths
WHERE 
	location = 'Indonesia'
GROUP BY
	location
	
-- Looking  at Total  Cases vs Population
-- Shows the percentage of population got infected by covid

SELECT  
	location, 
	date, 
	total_cases, 
	population,
	(total_cases/population) * 100 as Percentage_Population_Infected
FROM 
	PortfolioProject..CovidDeaths
ORDER BY
	location, date

-- Looking at Countries with the Highest Infection Rate compared to Population

SELECT  
	location, 
	population, 
	MAX(total_cases) as Highest_Infection_Count, 
	MAX((total_cases/population)) * 100 as Percentage_Population_Infected
FROM 
	PortfolioProject..CovidDeaths
GROUP BY
	location, population
ORDER BY
	Percentage_Population_Infected desc

-- Showing Countries with the Highest Death Count

SELECT  
	location, 
	MAX(CAST(total_deaths as int)) as Total_Death_Count -- need to convert from nvarchar to integer to get real results
FROM 
	PortfolioProject..CovidDeaths
WHERE
	continent is not null -- exclude the null in continent column
GROUP BY
	location
ORDER BY
	Total_Death_Count desc;

-- Total Death Count by Continent

SELECT  
	continent,
	SUM(new_cases) as Total_Cases,
	SUM(CAST(new_deaths as int)) as Total_Death_Count
FROM 
	PortfolioProject..CovidDeaths
WHERE
	continent is not null -- exclude the null in continent column
GROUP BY
	continent
ORDER BY
	Total_Death_Count desc;

-- Count world cases and deaths per date

SELECT 
	date,
	SUM(new_cases) as Total_Cases,
	SUM(cast(new_deaths as int)) as Total_Deaths,
	(SUM(cast(new_deaths as int)) / SUM(new_cases)) * 100 as DeathPercentage
FROM 
	PortfolioProject..CovidDeaths
WHERE
	continent is not null -- exclude the null in continent column
GROUP BY
	date
ORDER BY
	date;

-- Total  World Cases and Total World Deaths of Covid 19 as per 14/8/2022

SELECT 
	SUM(new_cases) as Total_Cases,
	SUM(cast(new_deaths as int)) as Total_Deaths,
	(SUM(cast(new_deaths as int)) / SUM(new_cases)) * 100 as DeathPercentage
FROM 
	PortfolioProject..CovidDeaths
WHERE
	continent is not null -- exclude the null in continent column

-- Read from CovidVaccinations Table

SELECT
	*
FROM 
	PortfolioProject..CovidVaccinations

-- Looking at the percentage of Population that has received vaccine includes booster

SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS People_Vaccinated
FROM
	PortfolioProject..CovidDeaths AS dea
JOIN
	PortfolioProject..CovidVaccinations AS vac 
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE
	dea.continent is not null
ORDER BY location, date;

-- We're using CTE to calculated on Partition By in previous query

WITH pop_vs_vac (continent, location, date, population, new_vaccinations, People_Vaccinated)
AS
(
SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS People_Vaccinated
FROM
	PortfolioProject..CovidDeaths AS dea
JOIN
	PortfolioProject..CovidVaccinations AS vac 
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE
	dea.continent is not null
)
SELECT
	*,
	(People_Vaccinated / population) * 100 AS Percentage_Population_Vaccinated
FROM
	pop_vs_vac
ORDER BY 
	location, date

-- We're using Temp Table to perform calculation on Partition By in previous query

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
People_Vaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS People_Vaccinated
FROM
	PortfolioProject..CovidDeaths AS dea
JOIN
	PortfolioProject..CovidVaccinations AS vac 
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE
	dea.continent is not null
--ORDER BY location, date;

SELECT
	*,
	(People_Vaccinated / population) * 100 AS Percentage_Population_Vaccinated
FROM
	#PercentPopulationVaccinated
ORDER BY
	location, date

-- Creating View to store for  later Visualizations

CREATE VIEW percentage_population_vaccinated AS
SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS People_Vaccinated
FROM
	PortfolioProject..CovidDeaths AS dea
JOIN
	PortfolioProject..CovidVaccinations AS vac 
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE
	dea.continent is not null

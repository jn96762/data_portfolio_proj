-- Whole table
SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent = 'North America'
ORDER BY 2,3


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2

-- Looking at total cases vs population
SELECT location, date, total_cases, total_deaths, population, ROUND((total_cases/population),2)*100 AS infection_rate
FROM PortfolioProject..CovidDeaths
WHERE location like '%states'
ORDER BY 1, 2

-- Looking at total deaths vs total cases
SELECT location, date, total_cases, total_deaths, population, ROUND((total_deaths/total_cases),2)*100 AS death_rate
FROM PortfolioProject..CovidDeaths
WHERE continent is not null AND location like '%states'
ORDER BY 1, 2

-- Looking at countries with highest infection rates 
SELECT location, population, MAX(total_cases) AS max_infection_count, MAX(ROUND((total_cases/population),2)*100) AS infection_rate
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY infection_rate DESC

-- Looking at countries with highest death rates 
SELECT location, population, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY total_death_count DESC

-- highest death rates by continents
SELECT location, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent is null AND location NOT LIKE '%income'
GROUP BY location
ORDER BY total_death_count DESC

-- OR
SELECT continent, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT null
GROUP BY continent
ORDER BY total_death_count DESC


-- Global Daily Accumulative
SELECT date, SUM(total_cases) AS global_total_cases, SUM(CAST(total_deaths AS INT)) AS global_total_deaths, ROUND((SUM(CAST(total_deaths AS INT))/SUM(total_cases))*100,2) AS death_rate
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date

-- Global Daily New
SELECT date, SUM(new_cases) AS global_new_cases, SUM(CAST(new_deaths AS INT)) AS global_new_deaths, ROUND((SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100,2) AS daily_death_rate
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date

-- Global Total
SELECT SUM(new_cases) AS global_new_cases, SUM(CAST(new_deaths AS INT)) AS global_new_deaths, ROUND((SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100,2) AS daily_death_rate
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
--ORDER BY date



-- Join Tables and look at total population vs vaccinations 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS total_vaccinations_to_date
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND dea.location = 'albania'
ORDER BY 2,3

-- Use CTE
With PopvsVac (continent, location, date, population, new_vaccinations, total_vaccinations_to_date)
	AS
	(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS total_vaccinations_to_date
	FROM PortfolioProject..CovidDeaths dea 
	JOIN PortfolioProject..CovidVaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL AND dea.location = 'united states'
	)
SELECT *, ROUND((total_vaccinations_to_date/population)*100,2) AS vaccination_rate_to_date
FROM PopvsVac


-- Temp table
DROP TABLE IF EXISTS #Vaccination_rate
CREATE TABLE #Vaccination_rate
	(
	continent nvarchar(255),
	location nvarchar(255), 
	date datetime,
	population numeric,
	new_vaccinations numeric,
	total_vaccinations_to_date numeric
	)
	
INSERT INTO #Vaccination_rate
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS total_vaccinations_to_date
	FROM PortfolioProject..CovidDeaths dea 
	JOIN PortfolioProject..CovidVaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL AND dea.location = 'united states'
SELECT *, ROUND((total_vaccinations_to_date/population)*100,2) AS vaccination_rate_to_date
FROM #Vaccination_rate



-- Creating Views to store data for later visualizations 

CREATE VIEW PercentPopulationVaccinated AS
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS total_vaccinations_to_date
	FROM PortfolioProject..CovidDeaths dea 
	JOIN PortfolioProject..CovidVaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL AND dea.location = 'united states'
  --ORDER BY 2,3
  

SELECT *
FROM PercentPopulationVaccinated
SELECT * FROM PortfolioProjectDB.dbo.CovidDeaths
--ORDER BY 3,4

--SELECT * FROM PortfolioProjectDB.dbo.CovidVaccinations
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population FROM PortfolioProjectDB..CovidDeaths
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths 

SELECT location, date, total_cases, total_Deaths, (total_deaths/total_cases)*100 AS deathpercent
FROM  PortfolioProjectDB..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

-- Looking at the total cases vs the Population
-- Showa the percentage of population got covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS casepercent
FROM PortfolioProjectDB..CovidDeaths
--WHERE location like	'%states%'
ORDER BY 1,2

--Countries with higher infaction rate compared to population

SELECT location, population, MAX(total_cases) AS max_cases, MAX(total_cases/population)*100 AS infaction_rate
FROM PortfolioProjectDB..CovidDeaths
GROUP BY population, location
ORDER BY infaction_rate DESC

--Countries with highest death count per population

SELECT location, MAX(cast (total_deaths as int)) AS totalDeathCount
FROM PortfolioProjectDB..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY totalDeathCount DESC


-- Showing the continent with the highest death count

SELECT continent, MAX(cast(total_deaths as int)) AS totalDeathCount
FROM PortfolioProjectDB..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY totalDeathCount DESC 


--GLOBAL NUMBERS

SELECT date, SUM(new_cases), SUM(cast(new_deaths AS int)), SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS GlobalDeathPercent --, total_cases, total_Deaths, (total_deaths/total_cases)*100 AS deathpercent
FROM  PortfolioProjectDB..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


SELECT * FROM PortfolioProjectDB..CovidDeaths
SELECT * FROM PortfolioProjectDB..CovidVaccinations


-- Total Population vs Vaccinations

	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
	FROM PortfolioProjectDB..CovidDeaths dea
	JOIN PortfolioProjectDB..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	ORDER BY 1,2,3

	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingpplvac,
	(rolligpplvac/population)*100 AS percentpplvac
	FROM PortfolioProjectDB..CovidDeaths dea
	JOIN PortfolioProjectDB..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	ORDER BY 2,3


	--Using CTE

	WITH popvsvac(continent, location, date, population,new_vaccinations, rollingpplvac)
	as
	(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingpplvac
	--(rolligpplvac/population)*100 AS percentpplvac
	FROM PortfolioProjectDB..CovidDeaths dea
	JOIN PortfolioProjectDB..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	--ORDER BY 2,3
	)
	SELECT *, (rollingpplvac/population)*100 AS percntpplvac FROM popvsvac

	
-- CREATING TEMP TABLES

DROP TABLE if exists #percentpopulationvaccinated

CREATE TABLE #percentpopulationvaccinated 
(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_Vaccinations numeric,
	rollingpplvac numeric
)

INSERT INTO #percentpopulationvaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingpplvac
	--(rolligpplvac/population)*100 AS percentpplvac
	FROM PortfolioProjectDB..CovidDeaths dea
	JOIN PortfolioProjectDB..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	--ORDER BY 2,3
	
	SELECT *, (rollingpplvac/population)*100 AS percntpplvac FROM #percentpopulationvaccinated


CREATE VIEW percentpopulationvaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingpplvac
	--(rolligpplvac/population)*100 AS percentpplvac
	FROM PortfolioProjectDB..CovidDeaths dea
	JOIN PortfolioProjectDB..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	--ORDER BY 2,3
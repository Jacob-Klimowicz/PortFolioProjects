SELECT *
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent is not null
order by 3,4

--SELECT *
--FROM PortfolioProject.dbo.CovidVaccinations$
--order by 3,4

-- Select Data that we are going to be using

SELECT Location,date, total_cases, new_cases,total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent is not null
order by 1,2

--Total Cases vs Total Deaths 
-- Shows likelihood of dying if you contract covid in your country

SELECT Location,date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths$
WHERE location = 'netherlands'
AND continent is not null
order by 1,2

-- Looking at Total Cases vs Population
--Shows what percentage of population got covid

SELECT Location,date, population, total_cases,(total_cases/population)*100 as PercentagePopulationInfected
FROM PortfolioProject.dbo.CovidDeaths$
WHERE location = 'netherlands'
AND continent is not null
ORDER BY 1,2

-- Countries with Highest Infection Rate compared to Population

SELECT Location, population, Max(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM PortfolioProject.dbo.CovidDeaths$
--WHERE location like '%states%'
GROUP BY Location,Population
ORDER BY PercentagePopulationInfected DESC

-- Countries with the Highest Death Count per Population

SELECT Location, MAX(cast(Total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths$
--WHERE location = 'Netherlands'
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- 
SELECT location, MAX(cast(Total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- By Continent 
--Showing continents with the highest death count per population

SELECT continent, MAX(cast(Total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global Numbers

SELECT date, SUM(new_cases) AS total_cases,SUM(cast(new_deaths as int)) AS total_deaths , SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent is not null
GROUP BY date
order by 1,2

SELECT SUM(new_cases) AS total_cases,SUM(cast(new_deaths as int)) AS total_deaths , SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent is not null
--GROUP BY date
order by 1,2

SELECT *
FROM PortfolioProject..CovidVaccinations$

-- Looking at Total Population vs Vaccinations

SELECT dea.continent,dea.location,dea.date,dea.population,dea.new_vaccinations,SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) *100
FROM PortfolioProject..CovidDeaths$ AS dea
Join PortfolioProject..CovidVaccinations$ AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent is not NULL
ORDER BY 2,3

-- USE CTE

WITH PopvsVac (Continent, Location, Date, Population,New_Vaccinations,RollingPeopleVaccinated)
AS
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population) *100
FROM PortfolioProject..CovidDeaths$ AS dea
Join PortfolioProject..CovidVaccinations$ AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent is not NULL
--ORDER BY 2,3
)
SELECT *,(RollingPeopleVaccinated/Population)*100
FROM PopvsVac




-- Temp Table

DROP TABLE if Exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255), 
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT into #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population) *100
FROM PortfolioProject..CovidDeaths$ AS dea
Join PortfolioProject..CovidVaccinations$ AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent is not NULL
--ORDER BY 2,3


SELECT *,(RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated



-- Creating view to store data for future Visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population) *100
FROM PortfolioProject..CovidDeaths$ AS dea
Join PortfolioProject..CovidVaccinations$ AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 2,3
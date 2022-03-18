SELECT *
FROM PortfolioProject..COVIDDEATHS
WHERE continent is not NULL
order by 3,4

--SELECT *
--FROM PortfolioProject..COVIDVACCINATIONS
--order by 3,4

--Select Data that we are going

SELECT Location, date, total_cases, total_deaths, population
FROM PortfolioProject..COVIDDEATHS
WHERE continent is not NULL
ORDER BY 1,2

--Looking at total cases vs Total deaths
--Shows likelihood of dying from Covid in a country

SELECT Location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..COVIDDEATHS
WHERE Location like '%states%'
ORDER BY 1,2

--Looking at Total casws vs Population
--Percentage of population got Covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..COVIDDEATHS
--WHERE Location like '%states%'
WHERE continent is not NULL
ORDER BY 1,2

--Looking at countries with highest rate to population

SELECT Location, population, MAX(total_cases) as HighestInvectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..COVIDDEATHS
--WHERE Location like '%states%'
WHERE continent is not NULL
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc

--Showing countries with highest death count per population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..COVIDDEATHS
--WHERE Location like '%states%'
WHERE continent is not NULL
GROUP BY Location, Population
ORDER BY TotalDeathCount desc

--Break things down by Continent 

--SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
--FROM PortfolioProject..COVIDDEATHS
--WHERE Location like '%states%'
--WHERE continent is NULL
--GROUP BY Location
--ORDER BY TotalDeathCount desc

--Showing the continent with highest death rate

SELECT Continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..COVIDDEATHS
--WHERE Location like '%states%'
WHERE continent is not NULL
GROUP BY Continent
ORDER BY TotalDeathCount desc

SELECT *
FROM PortfolioProject..COVIDDEATHS
WHERE continent is NULL
order by 3,4


--GLOBAL NUMBERS

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM PortfolioProject..COVIDDEATHS
--WHERE Location like '%states%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM PortfolioProject..COVIDDEATHS
--WHERE Location like '%states%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


SELECT *
FROM PortfolioProject..COVIDDEATHS dea
JOIN PortfolioProject..COVIDVACCINATIONS vac
on dea.location = vac.location
and dea.date = vac.date


-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..COVIDDEATHS dea
JOIN PortfolioProject..COVIDVACCINATIONS vac
on dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3


USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..COVIDDEATHS dea
JOIN PortfolioProject..COVIDVACCINATIONS vac
on dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

SET ANSI_WARNINGS on

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..COVIDDEATHS dea
JOIN PortfolioProject..COVIDVACCINATIONS vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3


SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Creating view to store data for later visualizations


CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..COVIDDEATHS dea
JOIN PortfolioProject..COVIDVACCINATIONS vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3


CREATE VIEW PercentPopulationInfected as
SELECT Location, population, MAX(total_cases) as HighestInvectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..COVIDDEATHS
--WHERE Location like '%states%'
WHERE continent is not NULL
GROUP BY Location, Population
--ORDER BY PercentPopulationInfected desc

CREATE VIEW TotalDeatPerCountry as
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..COVIDDEATHS
--WHERE Location like '%states%'
WHERE continent is not NULL
GROUP BY Location, Population
--ORDER BY TotalDeathCount desc

CREATE VIEW GlobalDeathPercentage as
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM PortfolioProject..COVIDDEATHS
--WHERE Location like '%states%'
WHERE continent is not null
--GROUP BY date
--ORDER BY 1,2

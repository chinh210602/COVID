SELECT * 
FROM portfolio..CovidDeaths
ORDER BY 3,4

SELECT *
FROM portfolio..CovidVaccinations
ORDER BY 3,4

--Death Percentage in Vietnam

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) as death_rate
FROM portfolio..CovidDeaths
WHERE location = 'Vietnam'
ORDER BY 1,2

--infection_rate in Vietnam
SELECT location, date, total_cases,population, (total_cases/population) as infection_rate
FROM portfolio..CovidDeaths
WHERE location = 'Vietnam'
ORDER BY 1,2

-- New cases and new deaths trend in Vietnam
SELECT location, date, new_cases, new_deaths
FROM portfolio..CovidDeaths
WHERE location = 'Vietnam'
ORDER BY 1,2

-- Highest infection percentage between countries.
SELECT location, population, MAX(total_cases) as total_cases, MAX((total_cases/population)*100) as highest_infection_percentage
FROM portfolio..CovidDeaths
GROUP BY location, population
ORDER BY highest_infection_percentage desc

--Total deaths count
SELECT location, MAX(cast(total_deaths as int)) as total_deaths
FROM portfolio..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY total_deaths desc

--By continents
SELECT location, MAX(cast(total_deaths as int)) as total_deaths
FROM portfolio..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY total_deaths desc

--Vaccination rate
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS total_vaccinations
FROM portfolio..CovidDeaths dea
JOIN portfolio..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--CTE
WITH VacvsPop (Continent, Location, Date, Population, New_Vaccinations, Total_Vaccinations)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS total_vaccinations
FROM portfolio..CovidDeaths dea
JOIN portfolio..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
)
-- Vaccination percentage
SELECT *, (Total_Vaccinations/Population)*100 as Vaccinations_Percentage
FROM VacvsPop
--WHERE Location = 'Vietnam'
ORDER BY 2,3

--Create views
CREATE VIEW VaccinationsVSPopulation as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS total_vaccinations
, (Total_Vaccinations/Population)*100 as Vaccinations_Percentage
FROM portfolio..CovidDeaths dea
JOIN portfolio..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
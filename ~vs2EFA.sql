SELECT * FROM dbo.CovidDeaths

--Total Death VS Cases
SELECT location,date,total_cases,total_deaths,(CAST(total_deaths as int)/total_cases)* 100.00 AS Deaths_Percentage
FROM My_Port..CovidDeaths
ORDER BY 1,2

--Total Death VS Population
SELECT location,date,total_cases,population,(total_cases/population)* 100.00 AS cases_Percentage
FROM My_Port..CovidDeaths
ORDER BY 1,2

--Countries with highest infection rate compare to population
SELECT location,population,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))* 100.00 AS PercentPopulationInfected
FROM My_Port..CovidDeaths
GROUP BY location,population
ORDER BY PercentPopulationInfected DESC

--Countries with highest death count compare to population
SELECT location,population,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))* 100.00 AS PercentPopulationInfected
FROM My_Port..CovidDeaths
GROUP BY location,population
ORDER BY PercentPopulationInfected DESC

--By continent
SELECT continent,MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM My_Port..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY 2 DESC

--Continent with highest death count per population
SELECT continent,MAX(CAST(total_deaths as int)) as TotalDeathCount,MAX(population) as TotalPopulation
FROM My_Port..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY 2 DESC

--Global number
SELECT SUM(new_cases) as total_cases,SUM(CAST(new_deaths as int)) as total_deaths,SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS TotalDeathsPerCases
FROM My_Port..CovidDeaths
WHERE continent is not null


--Vac VS Population
--USE CTE
WITH PopVsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
AS
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM My_Port..CovidDeaths AS dea 
JOIN My_Port..CovidVaccinations AS vac
	ON dea.date = vac.date
	AND dea.location = vac.location
WHERE dea.continent IS NOT NULL
--GROUP BY dea.continent
--ORDER BY 2,3
)
SELECT *,(RollingPeopleVaccinated/population)*100 AS VacPerPopulation
FROM PopVsVac

--TEMP TABLE
DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent NVARCHAR(255)
,Location NVARCHAR(255)
,Date DATETIME
,Population NUMERIC
,New_Vaccinations NUMERIC
,RollingPeopleVaccinated NUMERIC
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM My_Port..CovidDeaths AS dea 
JOIN My_Port..CovidVaccinations AS vac
	ON dea.date = vac.date
	AND dea.location = vac.location
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *,(RollingPeopleVaccinated/population)*100 AS VacPerPopulation
FROM #PercentPopulationVaccinated

--Create view to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM My_Port..CovidDeaths AS dea 
JOIN My_Port..CovidVaccinations AS vac
	ON dea.date = vac.date
	AND dea.location = vac.location
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
-- COVID 19 DATA EXPLORATION
-- Skills used: Joins, CTE's, Windows Functions, Aggregate Functions, Converting Data Types

SELECT *
FROM PortfolioProject.coviddeaths
ORDER BY 3,4;

SELECT *
FROM PortfolioProject.covidvaccinations
ORDER BY 3,4;

-- Select Data that we are going to be starting with 

SELECT Location, Date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.coviddeaths
ORDER BY 1,2;

-- Total Cases vs Total deaths
-- Shows the probability of death if you contract covid in your country

SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProject.coviddeaths
WHERE location LIKE 'India'
ORDER BY 1,2;

-- Total cases vs Population
-- Shows what percentage of population got Covid

SELECT Location, Date, total_cases, population, (total_cases/population)*100 AS death_percentage
FROM PortfolioProject.coviddeaths
-- WHERE location LIKE 'India'
ORDER BY 1,2;

-- Countries with Highest Infection Rate compared to Population

SELECT Location, MAX(total_cases) AS highest_infection_Rate, population, MAX((total_cases/population))*100 AS percent_population_infected
FROM PortfolioProject.coviddeaths
-- WHERE location LIKE 'India'
GROUP BY Location, Population
ORDER BY percent_population_infected DESC;

-- Countries with the Highest Death Count per Population

SELECT location, MAX(cast(total_deaths AS float)) AS total_death_count
FROM PortfolioProject.coviddeaths
-- WHERE location LIKE 'India'
WHERE location NOT IN ('Europe', 'North America', 'European Union', 'South America', 'Africa', 'Asia')
GROUP BY Location
ORDER BY total_death_count DESC;

-- Breaking things down by continent
-- Showing continents with the highest death count per population


SELECT continent, MAX(cast(total_deaths AS float)) AS total_death_count
FROM PortfolioProject.coviddeaths
-- WHERE location LIKE 'India'
-- WHERE location IN ('Europe', 'North America', 'European Union', 'South America', 'Africa', 'Asia', 'Oceania')
GROUP BY continent
ORDER BY total_death_count DESC
LIMIT 1,8;

-- Global Numbers

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS FLOAT)) AS total_deaths, SUM(CAST(new_deaths AS FLOAT))/SUM(new_cases)*100 AS death_percentage
FROM PortfolioProject.coviddeaths 
-- WHERE location LIKE 'India'
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY 1,2;

-- Total Population vs Vaccination
-- Shows Percentage of population that has receieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_people_vaccinated, 
(Rolling_people_vaccinated/population)*100
FROM PortfolioProject.coviddeaths dea
JOIN PortfolioProject.covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

-- Use CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Population, New_vaccinations, Rolling_people_vaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_people_vaccinated
-- (Rolling_people_vaccinated/population)*100
FROM PortfolioProject.coviddeaths dea
JOIN PortfolioProject.covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2, 3;
)
SELECT*, (Rolling_people_vaccinated/Population)*100
FROM PopvsVac


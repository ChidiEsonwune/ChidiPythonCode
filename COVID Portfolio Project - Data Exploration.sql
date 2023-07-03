/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/
use portfolioproject
use test
SELECT DATABASE(); -- show database in use

Select *
From PortfolioProject.CovidDeaths
Where continent is not null 
order by 3,4


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.CovidDeaths
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.CovidDeaths
-- Where location like '%states%'
-- and continent is not NULL  
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject.CovidDeaths
Where location like '%states%'
-- Where location like '%cyprus%'
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject.CovidDeaths
-- Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

-- use test;
-- Countries with Highest Death Count per Population

Select Location, MAX(Total_deaths) as TotalDeathCount
-- Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject.CovidDeaths
-- Where location like '%states%'
Where continent is null 
Group by Location
order by TotalDeathCount desc


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(Total_deaths) as TotalDeathCount
-- Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject.CovidDeaths
-- Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- For null Continets
-- Select continent, MAX(Total_deaths) as TotalDeathCount
-- Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
-- From PortfolioProject.CovidDeaths
-- Where location like '%states%'
-- Where continent is Null 
-- Group by continent
-- order by TotalDeathCount desc

use Portfolioproject
select database ()


-- GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 as DeathPercentage
-- Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject.CovidDeaths
-- Where location like '%states%'
where continent is not null 
Group By date
order by 1,2

-- Looking at the SUM of Global Cases

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 as DeathPercentage
-- Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject.CovidDeaths
-- Where location like '%states%'
where continent is not null 
-- Group By date
order by 1,2

-- Joining the Two tables
Select *
from PortfolioProject.CovidDeaths dea
Join PortfolioProject.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From PortfolioProject.CovidDeaths dea
Join PortfolioProject.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
-- where dea.continent is not null 
order by 2,3

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM
  PortfolioProject.CovidDeaths dea
JOIN
  PortfolioProject.CovidVaccinations vac
ON
  dea.location = vac.location
  AND dea.date = vac.date
WHERE
  dea.continent IS NOT NULL
ORDER BY
  dea.location, dea.date

-- $$$$$
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject.CovidDeaths dea
Join PortfolioProject.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 1,2,3

use Portfolioproject
use test


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From PortfolioProject.CovidDeaths dea
Join PortfolioProject.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
-- order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as percentage
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

-- Drop table if it exists
DROP TABLE IF EXISTS PercentPopulationVaccinated;

-- Create table
CREATE TABLE PercentPopulationVaccinated,
    Continent VARCHAR(50),
    Location VARCHAR(255),
    Date VARCHAR(255),
    Population (int),
    New_vaccinations (int),
    RollingPeopleVaccinated (int)

show tables;

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, 
       NULLIF(vac.new_vaccinations, ''), 
       SUM(NULLIF(vac.new_vaccinations, '')) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject.CovidDeaths dea
JOIN PortfolioProject.CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date;


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject.CovidDeaths dea
Join PortfolioProject.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated1 as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From PortfolioProject.CovidDeaths dea
Join PortfolioProject.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select * from percentpopulationvaccinated;


Select *
From [Portfolio Project].dbo.CovidDeaths
where continent is not null
Order by 3,4

--Select *
--From [Portfolio Project].dbo.CovidVaccination
--Order by 3,4

Select location, date, total_cases, new_cases,total_deaths, population
From [Portfolio Project].dbo.CovidDeaths
where continent is not null
Order by 1,2

--looking at the total cases vs the total deaths
--likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentages
From [Portfolio Project].dbo.CovidDeaths
Where location like '%Africa%'
where continent is not null
Order by 1,2


--looking at total cases vs the population
--shows what percentage of people in the united state with covid

Select location, date, Population, total_cases, (total_cases/Population)*100 as PercentPopulationInfected
From [Portfolio Project].dbo.CovidDeaths
--Where location like '%states%'
where continent is not null
Order by 1,2

--Countries with highest Infection Rate compared to population
Select location, Population, Max(total_cases) as HighestInfectionCount, Max((total_cases/Population))*100 as PercentPopulationInfected
From [Portfolio Project].dbo.CovidDeaths
--Where location like '%states%'
where continent is not null
Group by location, Population
Order by PercentPopulationInfected desc

--showing countries with highest death count per population
Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project].dbo.CovidDeaths
--Where location like '%states%'
where continent is not null
Group by location
Order by TotalDeathCount desc

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project].dbo.CovidDeaths
--Where location like '%states%'
where continent is null
Group by location
Order by TotalDeathCount desc

--lookingg  at data with Continent
--Continents with highest death counts per population

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project].dbo.CovidDeaths
--Where location like '%states%'
where continent is not null
Group by continent
Order by TotalDeathCount desc

--GLOBAL NUMBERS

Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeath, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio Project].dbo.CovidDeaths
--Where location like '%states%'
 where continent is not null
 Group by date
Order by 1,2

--Total number of cases in the world


Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeath, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio Project].dbo.CovidDeaths
--Where location like '%states%'
 where continent is not null
 --Group by date
Order by 1,2


--Covid Vaccination
--looking at total population vs vaccination

Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, SUM(CONVERT(int,Vac.new_vaccinations)) OVER (Partition by Dea.location Order by Dea.location, Dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population|)*100
from [Portfolio Project]..CovidDeaths as Dea
Join [Portfolio Project]..CovidVaccination as Vac
  on Dea.location = Vac.location
  and Dea.date = Vac.date
  where Dea.continent is not null
  Order by 2,3

--Use CTE
With PopvsVac (continent, location, Date, Population,New_vaccinations, RollingPeopleVaccinated)
as
(
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, SUM(CONVERT(int,Vac.new_vaccinations)) OVER (Partition by Dea.location Order by Dea.location, Dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population|)*100
from [Portfolio Project]..CovidDeaths as Dea
Join [Portfolio Project]..CovidVaccination as Vac
  on Dea.location = Vac.location
  and Dea.date = Vac.date
  where Dea.continent is not null
  --Order by 2,3
)
Select*, (RollingPeopleVaccinated/population)*100
from PopvsVac

--TEMP TABLE 

Drop Table if exists #PercentPopoulationVaccinated
Create Table #PercentPopoulationVaccinated
(
continent nvarchar (255), 
location nvarchar (255),
Date datetime,
Population numeric, 
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopoulationVaccinated

Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, SUM(CONVERT(int,Vac.new_vaccinations)) OVER (Partition by Dea.location Order by Dea.location, Dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population|)*100
from [Portfolio Project]..CovidDeaths as Dea
Join [Portfolio Project]..CovidVaccination as Vac
  on Dea.location = Vac.location
  and Dea.date = Vac.date
  --where Dea.continent is not null
  --Order by 2,3

  Select*, (RollingPeopleVaccinated/population)*100
from #PercentPopoulationVaccinated

--creating view to store data later visualizations

Create View PercentPopoulationVaccinated as
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, SUM(CONVERT(int,Vac.new_vaccinations)) OVER (Partition by Dea.location Order by Dea.location, Dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population|)*100
from [Portfolio Project]..CovidDeaths as Dea
Join [Portfolio Project]..CovidVaccination as Vac
  on Dea.location = Vac.location
  and Dea.date = Vac.date
  where Dea.continent is not null
  --Order by 2,3

  Select* 
  from PercentPopoulationVaccinated

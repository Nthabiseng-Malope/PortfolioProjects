select *
from PortfolioSql..CovidDeaths
where continent is not null
order by 3,4

select *
from PortfolioSql..CovidVaccinations
order by 3,4

-- Select the data to be used
Select location, date,total_cases,new_cases,total_deaths, population
from PortfolioSql..CovidDeaths
where continent is not null
order by 1,2

-- Total cases vs Total deaths,showing the likelihood of dying whenever covid is contracted
Select location, date,total_cases,total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from PortfolioSql..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2

--Total cases vs population,showing which population has got covid
Select location, date,total_cases,population, (total_cases/population) * 100 as PercentagePopulationInfected
from PortfolioSql..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2

--Countries with the highest infection rate vs population
Select location,population, max(total_cases) as HighestInfectionCount,max ((total_cases/population)) * 100 as PercentagePopulationInfected
from PortfolioSql..CovidDeaths
group by location, population
order by PercentagePopulationInfected desc

-- Countries with the highst death count per population
Select location, max(cast (total_deaths as int)) as TotalDeathCount
from PortfolioSql..CovidDeaths
where continent is  null
group by location
order by TotalDeathCount desc

-- Continents with the highst death count per population
Select continent, max(cast (total_deaths as int)) as TotalDeathCount
from PortfolioSql..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- Global numbers
Select date,sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum (new_cases) * 100 as DeathPercentage
from PortfolioSql..CovidDeaths
where continent is not null
group by date
order by 1,2


Select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum (new_cases) * 100 as DeathPercentage
from PortfolioSql..CovidDeaths
where continent is not null
order by 1,2

-- Joining the 2 tables
select *
from PortfolioSql..CovidDeaths dea
join PortfolioSql..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date

-- total population vs vaccinations
-- we want the count to start over when it gets to the new location
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioSql..CovidDeaths dea
join PortfolioSql..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE
-- POPULATION VS VACCINATIONS
With PopvsVac (Continent,location,Date,Population,new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioSql..CovidDeaths dea
join PortfolioSql..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population) * 100 
from PopvsVac

-- USE TEMP TABLE
-- POPULATION VS VACCINATIONS

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioSql..CovidDeaths dea
join PortfolioSql..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *, (RollingPeopleVaccinated/population) * 100 
from #PercentPopulationVaccinated

-- Creating view to store data for later visualizations
Create View PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioSql..CovidDeaths dea
join PortfolioSql..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *
from PercentPopulationVaccinated










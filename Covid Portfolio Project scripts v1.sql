select * from CovidDeaths
order by 3,4

--select * from CovidVaccination
--order by 3,4

--Select Data that we are going to be using

select Location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows likelyhood of dying if you contract covid in your country
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathPercentage
from CovidDeaths
where location like '%states%'
order by 1, 2

--Looking at the total_cases vs. Population
--Shows what percentage of population got Covid
select Location, date, population, total_cases, (total_cases/population)*100 as infectedPercentage
from CovidDeaths
--where location like '%states%'
order by 1, 2


-- Looking at countries with Highest Infection Rate compared to Population
select Location, population, max(total_cases) as HighestInfectionCount, 
		max((total_cases/population))*100 as percentPopulationInfected
from CovidDeaths
--where location like '%states%'
group by location, population
order by percentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population

select Location, max(cast(total_deaths as int)) as HighestTotalDeathCount
from CovidDeaths
where continent is not null
group by location
order by HighestTotalDeathCount desc

-- Let's break things down by continent

-- Highest Total Deaths by Continents
select location,  max(cast(total_deaths as int)) as HighestTotalDeathCount
from CovidDeaths
where continent is null
group by location
order by HighestTotalDeathCount desc

--Continent with its Location that has the Highest Total Deaths
select continent, max(location) as location_with_highest_total_deaths, max(cast(total_deaths as int)) as HighestTotalDeathCount
from CovidDeaths
where continent is not null
group by continent
order by HighestTotalDeathCount desc

--Continent with its Location that has the Highest Total Deaths, but the Location is not shown
select continent, max(cast(total_deaths as int)) as HighestTotalDeathCount
from CovidDeaths
where continent is not null
group by continent
order by HighestTotalDeathCount desc

/*select distinct location, continent from CovidDeaths
where continent is not null
order by location, continent

select distinct location, continent from CovidDeaths
where continent is null
order by location, continent

select location, continent, max(cast(total_deaths as int)) max_total_deaths
from CovidDeaths
where --location = 'North America' or 
continent = 'North America'
group by location, continent
order by max_total_deaths desc
*/


-- Global numbers

select --date, 
sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases) as DeathPercentage
from CovidDeaths
where continent is not null
--group by date
order by 1,2


--Looking at total population vs. vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
  as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidDeaths dea
join CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
  as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidDeaths dea
join CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *, (RollingPeopleVaccinated/population)*100
from PopvsVac 

-- Temp Table

drop table if exists #PercentPopulationVaccinated

create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
  as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidDeaths dea
join CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3


select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated 

-- Creating View to store data for later visualisation

CREATE VIEW PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
  as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidDeaths dea
join CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated
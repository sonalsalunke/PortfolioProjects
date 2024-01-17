create view 
WithoutContinent
as
select * 
from Portfolio..CovidDeaths
where continent is not null



--Total Cases vs Total Deaths in INDIA

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from WithoutContinent
where location like 'india'
and continent is not null
order by 1,2

--Total cases vs Population in INDIA
--Shows what percentage of population got covid

select location, continent, date, total_cases, population, (total_cases/population)*100 as PercentagePopulationInfected
from Portfolio.dbo.CovidDeaths
--where location like 'india'
where continent is null
order by 1,2

--Countries with highest infection rate compared to population

select location, population,  max(total_cases) as HighestInfectionCount,  max((total_cases)/population)*100 as PercentagePopulationInfected
from Portfolio.dbo.CovidDeaths
--where location like 'india'
where continent is not null
group by population, location
order by PercentagePopulationInfected desc

--Countries with highest no of deaths

select location, population,  max(cast(total_deaths as int)) as HighestDeathCount,  (max(cast(total_deaths as int))/population)*100 as PercentagePopulationDead
from WithoutContinent
--where location like 'india'
--where continent is not null
group by location, population
order by HighestDeathCount desc

--Breaking things by Continent
--Continents with highest Death Counts
select continent, max(cast(total_deaths as int)) as HighestDeathCount
from Portfolio.dbo.CovidDeaths
where continent is not null
group by continent
order by HighestDeathCount desc

--Global Numbers

select date, sum(new_cases), sum(cast(new_deaths as int))--, total_deaths
from Portfolio..CovidDeaths
where continent is not null
group by date
order by 1,2

--Total Population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolio..CovidDeaths dea
join Portfolio..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


--use CTE
With PopvsVac (Continent, Location, Date, Population, NewVaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolio..CovidDeaths dea
join Portfolio..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100 as PercentageOfPeopleVaccinated
from PopvsVac


--Creating Views
Create View PercentPopulationVaccinated2 as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolio..CovidDeaths dea
join Portfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select * from PercentPopulationVaccinated2

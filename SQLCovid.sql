select * from PortfolioProject.dbo.coviddeath;

select * from PortfolioProject.dbo.covidvac;

select location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject.dbo.coviddeath where continent is not null order by 1,2;

-- total cases vs total deaths
-- shows likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject.dbo.coviddeath 
where location = 'Australia' 
and continent is not null
order by 1,2;

-- looking at total cases vs population 
-- shows what percentage of population got covid
select location, date, total_cases, population, (total_cases/population)*100 as Casepercent
from PortfolioProject.dbo.coviddeath 
where location = 'India'
AND continent is not null
order by 1,2;

--looking at countries at highest infection rate compared to population
select location, MAX(total_cases) as highestinfectCount, population, MAX((total_cases/population)*100) as percentpopulation
from PortfolioProject.dbo.coviddeath 
where continent is not null
--where location = 'India'
group by location, population
order by percentpopulation desc;

--showing countries with highest  death counts per population
select location, MAX(cast(total_deaths as int)) as highestdeathCount
from PortfolioProject.dbo.coviddeath 
where continent is not null
group by location
order by highestdeathCount desc;

--By continent
select continent, MAX(cast(total_deaths as int)) as highestdeathCount
from PortfolioProject.dbo.coviddeath 
where continent is not null
group by continent
order by highestdeathCount desc;

-- showing continents with highest death counts per population
select continent, MAX(cast(total_deaths as int)) as highestdeathCount
from PortfolioProject.dbo.coviddeath 
where continent is not null
group by continent
order by highestdeathCount desc;


-- Global numbers
select date, SUM(new_cases)as Totalcases, SUM(CAST (new_deaths as int)) as globaldeath, SUM(CAST (new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject.dbo.coviddeath 
Where continent is not null
group by date
order by 1,2;

select SUM(new_cases)as Totalcases, SUM(CAST (new_deaths as int)) as globaldeath, SUM(CAST (new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject.dbo.coviddeath 
Where continent is not null
--group by date
order by 1,2;

--vaccination
select * from PortfolioProject.dbo.covidvac;


Select * from PortfolioProject.dbo.coviddeath DEA
JOIN PortfolioProject.dbo.covidvac VAC
ON DEA.location = VAC.location 
AND DEA.date = VAC.date;

--total population vs vaccinations
Select DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
from PortfolioProject.dbo.coviddeath DEA
JOIN PortfolioProject.dbo.covidvac VAC
ON DEA.location = VAC.location 
AND DEA.date = VAC.date
Where DEA.continent is not null
order by 2,3;

-- partition
-- To get a rolling count of vaccinations for each location, we use partition by location
Select DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.coviddeath DEA
JOIN PortfolioProject.dbo.covidvac VAC
ON DEA.location = VAC.location 
AND DEA.date = VAC.date
Where DEA.continent is not null
order by 2,3;

--create CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.coviddeath DEA
JOIN PortfolioProject.dbo.covidvac VAC
ON DEA.location = VAC.location 
AND DEA.date = VAC.date
Where DEA.continent is not null
--order by 2,3
)
select * , (RollingPeopleVaccinated/population)*100 from PopvsVac

-- Temp Table

--drop table if exists #Percentpopvac
create table #Percentpopvac
(
continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #Percentpopvac
Select DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.coviddeath DEA
JOIN PortfolioProject.dbo.covidvac VAC
ON DEA.location = VAC.location 
AND DEA.date = VAC.date
Where DEA.continent is not null
select * , (RollingPeopleVaccinated/population)*100 from #Percentpopvac;

-- View to store data for later visualizations

create view Percentpopvac as
Select DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.coviddeath DEA
JOIN PortfolioProject.dbo.covidvac VAC
ON DEA.location = VAC.location 
AND DEA.date = VAC.date
Where DEA.continent is not null

select * from Percentpopvac
--Tableau queries

select SUM(new_cases)as Totalcases, SUM(CAST (new_deaths as int)) as globaldeath, SUM(CAST (new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject.dbo.coviddeath 
Where continent is not null
--group by date
order by 1,2;

select location, SUM(cast(new_deaths as int)) as highestdeathCount
from PortfolioProject.dbo.coviddeath 
where continent is null
and location not in ('World', 'European Union', 'International', 'Upper middle income', 'High income', 'Lower middle income', 'Low income')
group by location
order by highestdeathCount desc;


select location, MAX(total_cases) as highestinfectCount, population, MAX((total_cases/population)*100) as percentpopulation
from PortfolioProject.dbo.coviddeath 
group by location, population
order by percentpopulation desc;

select location, date, MAX(total_cases) as highestinfectCount, population, MAX((total_cases/population)*100) as percentpopulation
from PortfolioProject.dbo.coviddeath 
group by location, population, date
order by percentpopulation desc;







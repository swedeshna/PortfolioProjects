select location,date,total_cases,new_cases,population,total_deaths
from PortfolioProject..CovidDeaths
order by location,date

--What is the death rate cases of the infected only--
--This result shows the percent dying if infected with covid in India.
select location,date,total_cases,population,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%India%'
order by location,date

--What percentage of population has been affected by covid.
select location,date,total_cases,population,(total_cases/population)*100 as PercentInfectedPopuulation
from PortfolioProject..CovidDeaths
where location like '%India%'
order by location,date

--Highest infected cases compared to respective population
select location,population,max(total_cases) as HighestInfectedCases,max((total_cases/population)*100) as PercentInfectedPopuulation
from PortfolioProject..CovidDeaths
group by location,population
order by PercentInfectedPopuulation desc

--Highest death counts per population
select location,max(cast(total_deaths as int)) as DeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by DeathCount desc --we are not getting proper order of deathcount , check the datatype for the column.

--Breaking down as per the continent
select continent,max(cast(total_deaths as int)) as DeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by DeathCount desc

select location,max(cast(total_deaths as int)) as DeathCount
from PortfolioProject..CovidDeaths
where continent is  null
group by location
order by DeathCount desc

--Lets do the analysis for Globally not on any particulat country.

--On a particular date total cases for all the countries and total deaths
select date, sum(total_cases) as Total_Cases, sum(cast(total_deaths as int)) as Total_Deaths, sum(cast(total_deaths as int))/sum(total_cases)*100 as DeathPercentage
from PortfolioProject ..CovidDeaths
where continent is not null
group by date
order by 1,2


select  sum(total_cases) as Total_Cases, sum(cast(total_deaths as int)) as Total_Deaths, sum(cast(total_deaths as int))/sum(total_cases)*100 as DeathPercentage
from PortfolioProject ..CovidDeaths
where continent is not null
order by 1,2


--Join the vaccine table with covid  death table
--Total population vs Vaccination
--What is the total population that are vaccinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--RolledPeopleVaccinated/population *100
from PortfolioProject..CovidDeaths dea
	join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE for above query--
--why? beause we are not able to RollingPeopleVaccinated column to divide with population to know how many people are vaccinated for that location--
--same columns mentioned in the query otherwise error--
with PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated) 
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--RolledPeopleVaccinated/population *100
from PortfolioProject..CovidDeaths dea
	join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,(RollingPeopleVaccinated/population)*100 from PopvsVac

--Create Temp table--
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent varchar(255),
location varchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)


insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--RolledPeopleVaccinated/population *100
from PortfolioProject..CovidDeaths dea
	join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
--where dea.continent is not null

select *,(RollingPeopleVaccinated/population)*100 from #PercentPopulationVaccinated


--Creating views to store data for visualization later

create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--RolledPeopleVaccinated/population *100
from PortfolioProject..CovidDeaths dea
	join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
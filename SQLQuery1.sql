


select * 
from protfilioproject..CovidDeaths$
where continent is not null
order by 3,4



--select date that we are going to be starting with


select location , date , total_cases,new_cases, total_deaths,population 
from protfilioproject..CovidDeaths$
where continent is not null
order by 1,2



--total cases vs total deaths
--shows likelihood of dying if you contract covid in your country

select location , date , total_cases, total_deaths,(total_deaths/total_cases)*100 
as Deathprecentage
from protfilioproject..CovidDeaths$
order by 1,2


--looking at totalcases vs population

select location , date ,Population , total_cases, (total_cases/Population)*100 
as precentpopulationinfected
from protfilioproject..CovidDeaths$
--where location like'%states%'
order by 1,2



--looking at countries with highest infection rate compared to population
select location,population,max(total_cases)as HighestinfectionCount , 
max(total_cases/population)*100 as DEATHPRECENTAGE from protfilioproject..CovidDeaths$
--where location like'%states%'
group by location, population
order by 1,2





--looking at countries with highest daeth count per population



select location, max(cast(total_deaths as int)) as totaldeathCount 
from protfilioproject..CovidDeaths$
--where location like'%states%'
where continent is not null
group by location, population
order by totaldeathcount desc



--

--looking at cotintents with highest daeth count per population



select continent, max(cast(total_deaths as int)) as totaldeathCount 
from protfilioproject..CovidDeaths$
where continent is not null
group by continent
order by totaldeathcount desc


--global numbers
select sum(

--looking at total population vs vaccination


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT (int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinted
--,(RollingPeopleVaccinted/population)*100
from protfilioproject..CovidDeaths$ dea
join protfilioproject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use CTE

with PopvsVac(continent, location, Date, population,new_vaccinations, Rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date)
   as RollingPeopleVaccinted
--,(RollingPeopleVaccinted/population)*100
from protfilioproject..CovidDeaths$ dea
join protfilioproject..CovidVaccinations$ vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select*
from popvsVac

--TEMP TABLE to perform Calculation on Partition By in previous query

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From protfilioproject..CovidDeaths$ dea
Join protfilioproject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From protfilioproject..CovidDeaths$ dea
Join protfilioproject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


--select * from PortfolioProject..CovidVaccinations
--order by 3,4
select * from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4


select location, date, total_cases, new_cases, total_deaths, Population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Total cases Vs Total deaths
select location,date,total_cases, total_deaths,(total_deaths/total_cases) * 100 As DeathPercentage
from PortfolioProject..CovidDeaths 
where location like'%india%'
and continent is not null
order by 1,2

--Total cases Vs Population
select location,date,total_cases,Population,(total_deaths/Population) * 100 As PercentPopulationInfected
from PortfolioProject..CovidDeaths 
--where location like'%india%'
order by 1,2

--HighestPercentageofInfected

select location,Population,Max(total_cases) as HighestCountOfInfected,Max((total_cases/Population)) * 100 As PercentPopulationInfected
from PortfolioProject..CovidDeaths 
Group by location,Population
order by PercentPopulationInfected desc

--Highest Death counts Per Population
Select Location,Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount Desc

--break things down by continent

Select location,Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is  null
Group by location
order by TotalDeathCount Desc

--Highest Death counts by continents per population

Select date, Sum(new_cases) as Total_Cases, Sum(cast(new_deaths as int)) as Total_Deaths,Sum(cast(new_deaths as int))/sum(new_cases) * 100 As DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
Group by date
order by 1,2
--join tables
select * from PortfolioProject..covidDeaths dea join
PortfolioProject..CovidVaccinations vac on
dea.location=vac.location and
dea.date=vac.date
order by 1,2




--Total population Vs Vaccinations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int))over (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
On dea.location=vac.location and
   dea.date=vac.date
   where dea.continent is not null
   order by 2,3

   --Use CTE
   with PopVsVac  (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)

   as
   (select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int))over (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
On dea.location=vac.location and
   dea.date=vac.date
   where dea.continent is not null
  -- order by 2,3
  )
   select *,(RollingPeopleVaccinated/Population)* 100 
   from PopVsVac

   --TEMP Table
   Drop Table if exists #PercentPopulationVaccinated
   Create Table #PercentPopulationVaccinated
   (
   continent nvarchar(250),
   location nvarchar(250),
   Date datetime,
   Population numeric,
   new_Vaccinations numeric, 
   RollingPeopleVaccinated numeric)

   insert into #PercentPopulationVaccinated  select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int))over (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
On dea.location=vac.location and
   dea.date=vac.date
  -- where dea.continent is not null
  -- order by 2,3
  select *,(RollingPeopleVaccinated/Population)* 100 
   from #PercentPopulationVaccinated


   --Creating View for data visualization

   Create View PercentPopulationVaccinated as
   
   select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int))over (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
On dea.location=vac.location and
   dea.date=vac.date
   where dea.continent is not null
  -- order by 2,3
  select * from PercentPopulationVaccinated
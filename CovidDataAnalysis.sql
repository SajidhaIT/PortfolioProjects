SELECT Location, date, total_cases,new_cases, total_deaths, population
  FROM [PortfolioProject].[dbo].[CovidDeaths]



--Total cases vs total Deaths

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
  FROM [PortfolioProject].[dbo].[CovidDeaths] where location like '%states%'


--Total cases vs Population

SELECT Location, date, total_cases, population, (total_cases/population)*100 as CovidPercentage
  FROM [PortfolioProject].[dbo].[CovidDeaths] where location like '%states%'

--Highest infection rate compared to Population
SELECT Location,  population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as PercentPopulationInfected
  FROM [PortfolioProject].[dbo].[CovidDeaths] 
  Group by Location,  population
  order by PercentPopulationInfected desc

--Highest Death Count per Population
SELECT Location,  MAX(cast(total_deaths as int)) as TotalDeathCount
  FROM [PortfolioProject].[dbo].[CovidDeaths] 
  WHERE continent is not null
  Group by Location
  order by TotalDeathCount desc

  --Highest Death Count per Continent
SELECT continent,  MAX(cast(total_deaths as int)) as TotalDeathCount
  FROM [PortfolioProject].[dbo].[CovidDeaths] 
  WHERE continent is not null
  Group by continent
  order by TotalDeathCount desc


--GLOBAL NUMBERS per Dates

SELECT  date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths,  sum(cast(new_deaths as int))/sum(new_cases) as DeathPercentage
  FROM [PortfolioProject].[dbo].[CovidDeaths] 
  where continent is not null 
  group by date
  order by date


--GLOBAL NUMBERS 

SELECT  sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths,  sum(cast(new_deaths as int))/sum(new_cases) as DeathPercentage
  FROM [PortfolioProject].[dbo].[CovidDeaths] 
  where continent is not null 


--Looking at Total Population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , sum(cast(vac.new_vaccinations as int)) over (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
 from PortfolioProject..CovidDeaths dea
 Join PortfolioProject..CovidVaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  order by 2,3



  --using CTE

  With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
  as
  (
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , sum(cast(vac.new_vaccinations as int)) over (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
 from PortfolioProject..CovidDeaths dea
 Join PortfolioProject..CovidVaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  
  )
  Select *, (RollingPeopleVaccinated/ Population)*100 as PopulationPercentageVaccinated
  from PopVsVac 


  --using TEMP TABLE
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , sum(cast(vac.new_vaccinations as int)) over (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
 from PortfolioProject..CovidDeaths dea
 Join PortfolioProject..CovidVaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
  --where dea.continent is not null

  Select *, (RollingPeopleVaccinated/ Population)*100 as PopulationPercentageVaccinated
  from #PercentPopulationVaccinated 



--Views to store data for later visualizations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , sum(cast(vac.new_vaccinations as int)) over (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
 from PortfolioProject..CovidDeaths dea
 Join PortfolioProject..CovidVaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date


Select *
from PortfolioProject..Coviddeaths
where continent is not null
Order By 3,4

--Select *
--from PortfolioProject..CovidVaccination
--Order By 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..Coviddeaths
where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..Coviddeaths
where continent is not null
order by 1,2

-- Show likelihood dying if you contract by covid  in India


Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..Coviddeaths
where location like '%India%'
and continent is not null
order by 1,2

-- Looking at Total Cases vs Population

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
from PortfolioProject..Coviddeaths
--where location like '%India%'
where continent is not null
order by 1,2

-- Countries with Highest Infection rate compared to population

Select Location, population, Max(total_cases) as Highestinfectioncount, Max((total_cases/population))*100 as PercentagePopulationInfected
from PortfolioProject..Coviddeaths
--where location like '%India%'
Group by location, population
order by PercentagePopulationInfected desc

-- Showing Countries with Highest Death count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..Coviddeaths
where continent is not null
Group by location
order by TotalDeathCount desc



-- Showing Continent's with Highest Death count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..Coviddeaths
where continent is null
Group by location
order by TotalDeathCount desc


-- Looking at Total Population vs Vaccinations


Select *
From PortfolioProject..Coviddeaths dea
Join PortfolioProject..CovidVaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeoplevaccinated
From PortfolioProject..Coviddeaths dea
Join PortfolioProject..CovidVaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3    

-- Use CTE

With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeoplevaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeoplevaccinated
From PortfolioProject..Coviddeaths dea
Join PortfolioProject..CovidVaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
-- order by 2,3    
)
select *, (RollingPeoplevaccinated/population)*100
from PopvsVac



-- Temp Table

Create table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
location nvarchar(255),
date datetime,
Population numeric,
new_vaccinations numeric, 
RollingPeoplevaccinated numeric
) 

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeoplevaccinated
From PortfolioProject..Coviddeaths dea
Join PortfolioProject..CovidVaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
-- order by 2,3


select *, (RollingPeoplevaccinated/population)*100
from #PercentPopulationVaccinated            




-- Creating a view to store data for later visualiazations



Create view PercentPopulationVaccinated as

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeoplevaccinated
From PortfolioProject..Coviddeaths dea
Join PortfolioProject..CovidVaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
-- order by 2,3

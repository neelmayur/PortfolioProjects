Select *
From PortfolioProject..CovidDeaths
where continent is not null
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

-- Select Data to be used
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
Order by 1,2

-- Total cases vs total deaths
-- Shows percentage of death if covid was contracted in United States
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
and continent is not null
Order by 1,2

-- Total cases vs Population
-- Shows percentage of population got covid 
Select Location, date, population, total_cases, (total_cases/population)*100 as CovidPopulationPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

--Country with highest infection rate compared to popualation
Select Location, population, MAX(total_cases) as HighestCovidCount, MAX((total_cases/population))*100 as CovidPopulationPercentage
From PortfolioProject..CovidDeaths
Group by Location, population
order by CovidPopulationPercentage desc

--Showing Countries with highest death count per population
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is null
Group by Location
order by TotalDeathCount desc

--Showing Continents with highest death count
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

--Global Death Percentage
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Total population vs vaccinations

Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, SUM(cast(vacc.new_vaccinations as int)) OVER (Partition by death.location Order by death.Location, death.date)
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vacc
	on death.location = vacc.location
	and death.date = vacc.date
where death.continent is not null
order by 2,3

--Using CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, SUM(cast(vacc.new_vaccinations as int)) OVER (Partition by death.location Order by death.Location, death.date)
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vacc
	on death.location = vacc.location
	and death.date = vacc.date
where death.continent is not null
)
Select *,(RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Creating view for later visualizations

Create View PercentPopulationVaccinated as 
Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, SUM(cast(vacc.new_vaccinations as int)) OVER (Partition by death.location Order by death.Location, death.date)
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vacc
	on death.location = vacc.location
	and death.date = vacc.date
where death.continent is not null


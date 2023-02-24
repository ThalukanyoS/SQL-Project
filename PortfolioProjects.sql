
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

-- Looking at the Total cases vs Total Deaths
-- SHows likelihood of dying if you contract covid in your country
Select Location, date, total_cases,  total_deaths,(total_deaths/total_cases) *100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%South Africa%' 
and continent is not null
order by 1,2

-- Looking at the Total Cases vs Population
--Shows what percentage of population got covid
Select Location, date,Population, total_cases,(total_cases/Population) *100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
where location like '%South Africa%'
order by 1,2

-- Looking at countries with highest infections rate compared to population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population)) *100 as PercentPopulstionInfected
From PortfolioProject..CovidDeaths
--where location like '%South Africa%'
Group by Location, Population
order by PercentagePopulationInfected desc


-- Showing Countries With Highest Death Count per Population

Select Location,MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%South Africa%'
where continent is not null
Group by Location,
order by TotalDeathCount desc

--SHowing Continet with highest Deaath count per population -- try the view

Select continent,MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%South Africa%'
where continent is not null
Group by Continent
order by TotalDeathCount desc


--Global numbers, --try creatinga view
Select date, SUM(new_cases) as total_cases, SUM(cast (new_deaths as int)) as total_deaths, SUM(new_deaths)/SUM(New_cases) *100 
as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%South Africa%' 
Where continent is not null
Group By date
order by 1,2


--Looking at the total population vs vaccinations
Select dea.continet, dea.location, dea.date, dea.population, dea.new_vacination
, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION by dea.Location 
 Order by dea.location, dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
	 Where dea.continet is not null
	 Order by 2 , 3


	 -- use CTE
WITH PopvsVac(Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVacinnated)
as
(
Select dea.continet, dea.location, dea.date, dea.population, dea.new_vacination
, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION by dea.Location 
 Order by dea.location, dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
Where dea.continet is not null
--Order by 2 , 3
)
Select * ,(RollingPeopleVacinnated/Population)*100
FROM PopvsVac

--Temp table
Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(260),
Location nvarchar(260),
Population numeric,
New_VAccinations numeric,
RollingPeopleVaccinated numeric
)
Insert Into #PercentPopulationVaccinated
Select dea.continet, dea.location, dea.date, dea.population, dea.new_vacination
, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION by dea.Location 
 Order by dea.location, dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
Where dea.continet is not null
--Order by 2 , 3
Select * ,(RollingPeopleVacinnated/Population)*100
FROM #PercentPopulationVaccinated

--Creating view to store data for later visulalization

Create View PercentPopulationVaccinated as
Select dea.continet, dea.location, dea.date, dea.population, dea.new_vacination
, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION by dea.Location 
 Order by dea.location, dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
Where dea.continet is not null
--Order by 2 , 3

Select * from PercentPopulationVaccinated
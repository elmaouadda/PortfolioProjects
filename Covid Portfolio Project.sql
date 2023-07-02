Select *
from CovidDeaths

-- Exploring data which we are going to use

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1, 2

-- Comparing total deaths with total cases ( Austria as an example )

Select location, date, total_cases, total_deaths,
Case
WHEN TRY_CONVERT(NUMERIC(10, 2), Total_deaths) IS NOT NULL AND TRY_CONVERT(NUMERIC(10, 2), Total_cases) IS NOT NULL
      THEN CAST(Total_deaths AS NUMERIC(10, 2)) / CAST(Total_cases AS NUMERIC(10, 2))*100
    ELSE NULL
	End as DeathPercentage

from PortfolioProject..CovidDeaths
where location like '%Austria'
Order by DeathPercentage Desc

-- Comparing total cases with population
-- Percentage of people who got infected

Select location, date, total_cases, population,
Case
WHEN TRY_CONVERT(NUMERIC(10, 2), Total_cases) IS NOT NULL AND TRY_CONVERT(NUMERIC(10, 2), population) IS NOT NULL
      THEN CAST(Total_cases AS NUMERIC(10, 2)) / CAST(Population AS NUMERIC(10, 2))*100
    ELSE NULL
	End as PeopleWithCovid

from PortfolioProject..CovidDeaths
where location like '%Austria'
Order by PeopleWithCovid Desc


-- The highiest infection rate related to population

Select Location,Population, MAX(TRY_CAST(Total_cases AS DECIMAL(10, 2)) / TRY_CAST(Population AS DECIMAL(10, 2)))*100 PercentagePopulationInfected, Max(Try_cast(Total_cases as decimal(10, 2))) as HighestInfection
from PortfolioProject..CovidDeaths
Group by location, Population
Order by PercentagePopulationInfected desc

--Countries with highest death count per population

Select location, max(Try_cast(total_deaths as decimal(10, 2))) as TotalDeathsCount
from CovidDeaths
where continent is not null
Group by location
Order by TotalDeathsCount desc

-- Spots by continent 

Select continent, max(Try_cast(total_deaths as decimal(10, 2))) as TotalDeathsCount
from CovidDeaths
where continent is not null
Group by continent
Order by TotalDeathsCount desc


--Continents with the highest death count per population

Select continent, max(try_cast(total_cases as decimal(10, 2))) as TotalDeathCount
from CovidDeaths
group by continent
Order by TotalDeathCount

--Global Numbers

select date, sum(TRY_CAST( new_cases as decimal(10, 2))) as Total_Cases, sum(try_cast(new_deaths as decimal(10, 2))) as Total_Deaths,
Case
	when sum(TRY_CAST(new_cases as decimal(10, 2))) <>0
	Then (sum(TRY_CAST(new_deaths as decimal(10, 2)))/ sum(TRY_CAST(new_cases as decimal(10, 2))))*100
	Else null
	End as DeathPercentage
from CovidDeaths
where continent is not null
group by date
order by DeathPercentage desc





-- Looking at Total Population vs Vaccinations ( Azerbaijan as an example)

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(decimal(10,2), vac.new_vaccinations)) over(partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/ population)
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.location like '%Azer%'
GROUP BY dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
Order by date



-- Use CTE 
With PopVsVac ( Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(decimal(10,2), vac.new_vaccinations)) over(partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/ population)
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.location like '%Azer%'
GROUP BY dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--Order by Date
)

Select *, (RollingPeopleVaccinated/ Population)*100
from PopVsVac


-- Temp Table 

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
( 
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(decimal(10,2), vac.new_vaccinations)) over(partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/ population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.location like '%Azer%'
GROUP BY dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--Order by Date

Select *, (RollingPeopleVaccinated/ Population)*100
from #PercentPopulationVaccinated





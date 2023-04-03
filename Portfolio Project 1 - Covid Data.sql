--Preview Tables:

--Select *
--From PortfolioProject.dbo.CovidDeaths
--Order by 3,4

--Select *
--From PortfolioProject.dbo.CovidVaccinations
--Order by 3,4

-------------------------------

--Converting columns to float:

--Select * 
--From CovidDeaths
--EXEC sp_help 'dbo.CovidDeaths';
--ALTER TABLE dbo.CovidDeaths
--ALTER COLUMN total_deaths float

--Select * 
--From CovidDeaths
--EXEC sp_help 'dbo.CovidDeaths';
--ALTER TABLE dbo.CovidDeaths
--ALTER COLUMN total_cases float

--Select * 
--From CovidDeaths
--EXEC sp_help 'dbo.CovidDeaths';
--ALTER TABLE dbo.CovidDeaths
--ALTER COLUMN new_cases float

--Select * 
--From CovidDeaths
--EXEC sp_help 'dbo.CovidDeaths';
--ALTER TABLE dbo.CovidDeaths
--ALTER COLUMN new_deaths float

--Select * 
--From CovidVaccinations
--EXEC sp_help 'dbo.CovidVaccinations';
--ALTER TABLE dbo.CovidVaccinations
--ALTER COLUMN new_vaccinations float

-------------------------------

--Shows likelihood of dying over time if you contract covid in your country:

Select continent, location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
Where location like '%states' 
Order by 1,2

-------------------------------

--Shows what percentage of the population has gotten covid: 

Select continent, location, date, total_cases, population, (total_cases/population)*100 as CasePercentage
From PortfolioProject.dbo.CovidDeaths
Where location like '%states'
Order by 1,2

-------------------------------

--Shows which locations have the highest infection rates: 

Select continent, location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as MaxCasePercentage
From PortfolioProject.dbo.CovidDeaths
Group by continent, location, population
Order by 1 DESC

-------------------------------

--Shows countries with the highest death count per population: 

Select continent, location, population, max(total_deaths) as HighestDeathCount, max((total_deaths/population))*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group by continent, location, population
Order by 4 DESC

-------------------------------

--Shows continents with the highest death count per population: 

Select location, population, max(total_deaths) as HighestDeathCount, max((total_deaths/population))*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
Where continent is null AND location IN ('South America', 'Europe', 'North America', 'Oceania', 'Asia', 'Africa')
Group by location, population
Order by 4 DESC

-------------------------------

--Global Covid Numbers

Select sum(new_cases) AS Cases, sum(new_deaths) AS Deaths, (sum(new_deaths)/sum(new_cases))*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
where continent is not null and new_cases <> 0
order by 1, 2

-------------------------------

--Shows total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject.dbo.CovidDeaths as dea
Join PortfolioProject.dbo.CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

-------------------------------

--Rolling count of vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) AS RollingVaccinations
From PortfolioProject.dbo.CovidDeaths as dea
Join PortfolioProject.dbo.CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

-------------------------------

--CTE for rolling count of vaccinations: 

With PopvsVac (Continent, Location, Date, Population, NewVaccinations, RollingVaccinations)
As 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) AS RollingVaccinations
From PortfolioProject.dbo.CovidDeaths as dea
Join PortfolioProject.dbo.CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingVaccinations/population)*100
From PopvsVac

-------------------------------

--Temp Table for rolling count of vaccinations: 

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
NewVaccinations numeric, 
RollingVaccinations numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) AS RollingVaccinations
From PortfolioProject.dbo.CovidDeaths as dea
Join PortfolioProject.dbo.CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *, (RollingVaccinations/population)*100
From #PercentPopulationVaccinated
Order by 2,3

-------------------------------

--Creating view to store data for later visualizations 

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) AS RollingVaccinations
From PortfolioProject.dbo.CovidDeaths as dea
Join PortfolioProject.dbo.CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *
From PercentPopulationVaccinated
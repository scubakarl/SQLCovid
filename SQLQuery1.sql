
--Select data that we are going to be using

select location,date, total_cases, new_cases, total_deaths, population
From [Covid Project]..covid_deaths
where continent is not null
order by 1,2


-- Looking at total cases vs total deaths
-- shows liklyhood of dying from covid on a given date in a given 

select location,date, total_cases,total_deaths, (total_deaths/total_cases)*100 as deathpercentage
From [Covid Project]..covid_deaths
where continent is not null
order by 1,2

-- Total cases vs population
-- Shows what percentage of population contracted covid

select location,date, total_cases,population, (total_cases/population)*100 as population_percentage_infected
From [Covid Project]..covid_deaths
where continent is not null
order by 1,2

-- Looking at Countries with Highest infection rate compared to population 

Select location, population, max(total_cases) as highest_infection_count, max((total_cases/population))*100 as Percent_Population_Infected
From [Covid Project]..covid_deaths
where continent is not null
Group by Location, population
order by 4 desc

--Countries with highest death count per population

Select location, max(cast(total_deaths as int)) as total_death_count
From [Covid Project]..covid_deaths
where continent is not null
Group by Location
order by 2 desc

-- Break down by continent
--Showing contintinents with highest death count per population
Select location, max(cast(total_deaths as int)) as total_death_count
From [Covid Project]..covid_deaths
where continent is null
Group by location
order by 2 desc

--Global numbers

select Sum(new_cases) as total_cases , Sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
From [Covid Project]..covid_deaths
where continent is not null
--Group by date
order by 1

-- Global numbers total cases, deaths, death percentage by day for world
-- Shows daily death percentage for based on number of cases for the world

select date, Sum(new_cases) as total_cases , Sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
From [Covid Project]..covid_deaths
where continent is not null
Group by date
order by 1

-- total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From [Covid Project]..covid_deaths as dea  
Join [Covid Project]..covid_vac as vac
	On dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null
Order by 2,3

-- USE CTE

with PopvsVac (continent, location, date, population, new_vacinations, RollingPeopleVaccinated)as
(
Select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
From [Covid Project]..covid_deaths as dea  
Join [Covid Project]..covid_vac as vac
On dea.location = vac.location
AND dea.date = vac.date
where dea.continent is not null 
--Order by 2,3
)
Select*,(RollingPeopleVaccinated/population)*100 as percent_vacinated
From PopvsVac



-- Temp Table
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vacinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
From [Covid Project]..covid_deaths as dea  
Join [Covid Project]..covid_vac as vac
On dea.location = vac.location
AND dea.date = vac.date
where dea.continent is not null AND dea.location like '%states%'
--Order by 2,3

Select*,(RollingPeopleVaccinated/population)*100 as percent_vacinated
From #PercentPopulationVaccinated


Drop table if exists #FullyVacinatedPercentageTBL
Create Table #FullyVacinatedPercentageTBL
Select dea.location,dea.date, dea.population, (vac.people_fully_vaccinated/vac.population)*100 as Fully_Vacinated_Percentage
From [Covid Project]..covid_deaths as dea  
Join [Covid Project]..covid_vac as vac
On dea.location = vac.location
AND dea.date = vac.date
where dea.continent is not null 
order by dea.date desc

--Creating View to store data for later visuals in Tableau Public

Create View PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
From [Covid Project]..covid_deaths as dea  
Join [Covid Project]..covid_vac as vac
On dea.location = vac.location
AND dea.date = vac.date
where dea.continent is not null 
--Order by 2,3


-- Another view for Tableau Public
Create View FullyVacinatedPercentageOfPopulation as
Select dea.location,dea.date, dea.population, (vac.people_fully_vaccinated/vac.population)*100 as Fully_Vacinated_Percentage
From [Covid Project]..covid_deaths as dea  
Join [Covid Project]..covid_vac as vac
On dea.location = vac.location
AND dea.date = vac.date
where dea.continent is not null 


--Another view for Tableau Public
Create View RollingPeopleVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From [Covid Project]..covid_deaths as dea  
Join [Covid Project]..covid_vac as vac
	On dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null



--Another view for Tableau Public
Create View DeathPercentage as
Select date, Sum(new_cases) as total_cases , Sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
From [Covid Project]..covid_deaths
Where continent is not null
Group by date


--Another view for Tableau Public
Create View PositivityRateTotalTests as
select location,date, positive_rate, total_tests
From [Covid Project]..covid_vac
where continent is not null
order by 1,2



select * 
from Portofolio..CovidDeaths
order by 3, 

select * 
from Portofolio..CovidVaccinations
order by 3, 4

-- Sélection des données à utiliser 

select location , date, total_cases , new_cases,total_deaths, population
from Portofolio..CovidDeaths
order by 1, 2 

-- looking at total_cases vs total_deaths
select location , date, total_cases ,total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from Portofolio..CovidDeaths
where location like '%nin%'
order by 1, 2 

--Doone la probabilté de déces de covid dans ton pays

--looking at total_cases vs population
select location , date, total_cases , population , (total_cases/population)* 100 as infectpercentagepopulation 
from Portofolio..CovidDeaths
where location like '%nin%'
order by 1, 2 

--looking at countries with highest infection rate compared to population
select location , population, Max(total_cases ) as highespopulationinfect , max((total_cases/population))* 100 as infectpercentagepopulation 
from Portofolio..CovidDeaths
where location like '%states%'
group by location , population
order by infectpercentagepopulation desc



select location , max(cast(total_deaths as int )) as totalDeathcount
from Portofolio..CovidDeaths
--where location like '%B%'
Where continent is  Null
group by  location
order by totalDeathcount DESC

--Looking at Total population vs vaccinations


select dea.continent, dea.location, Dea.date, dea.population 
from Portofolio..CovidDeaths Dea
join Portofolio..CovidVaccinations Vac
on Dea.location = Vac.location
and Dea.date = Vac.date

-- let's break things down by continent 

-- showing continents with the highest death count per population

select location , max(cast(total_deaths as int )) as totalDeathcount
from Portofolio..CovidDeaths
--where location like '%B%'
Where continent is  Null
group by  location
order by totalDeathcount DESC

--Global Numbers
select date, sum(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int)) / SUM (new_cases )*100 as deathpercentage   --total_cases ,total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from Portofolio..CovidDeaths
--where location like '%nin%'
where continent is not null
group by date
order by 1, 2 
--Looking at Total population vs vaccinations

With PopvsVac (continent,location,date, population , New_vaccinations , RollingPeopleVaccined )
as
(
select dea.continent, dea.location, Dea.date, dea.population , Vac.new_vaccinations, sum(convert(int,vac.new_vaccinations )) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccined--( (cast(RollingPeopleVaccined as int)) /population)*100
from Portofolio..CovidDeaths Dea
join Portofolio..CovidVaccinations Vac

on Dea.location = Vac.location
and Dea.date = Vac.date
WHERE dea.continent  is not null
--order by  2 ,3
)
Select*, (RollingPeopleVaccined/population)*100
from PopvsVac
--USE CTE 

--TEMP TABLE
Drop Table if exists PercentPopulationVaccined

create Table PercentPopulationVaccined
(
continent nvarchar(255),
location nvarchar(255),
data datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccined numeric
)

insert into PercentPopulationVaccined
select dea.continent, dea.location, Dea.date, dea.population , Vac.new_vaccinations, sum(convert(int,vac.new_vaccinations )) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccined--( (cast(RollingPeopleVaccined as int)) /population)*100
from Portofolio..CovidDeaths Dea
join Portofolio..CovidVaccinations Vac

on Dea.location = Vac.location
and Dea.date = Vac.date
WHERE dea.continent  is not null
--order by  2 ,3

Select*, (RollingPeopleVaccined/population)*100
from PercentPopulationVaccined
--order by  2 ,3


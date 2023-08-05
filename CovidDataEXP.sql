-- Using SQL to explore the data and gain some insights
-- Covid Fatality Rate per country
select location,max(total_cases) as totalCases,max(total_deaths) as totalDeaths,(max(total_deaths)/max(total_cases)) * 100 as deathPercent
from NewProj..['covidDeaths']
where location is not null
group by location
order by deathPercent desc

-- Covid Total cases vs population
select location, population,max(total_cases) as totacases,(max(total_cases)/population)*100 as InfectionRate
from NewProj..['covidDeaths']
where location is not null
group by location,population
order by population desc

-- Countries with Highest Death Count
select location,population,max(total_deaths) as totalDeaths
from NewProj..['covidDeaths']
where continent is not null
group by location,population
order by totalDeaths desc

-- Continent wise data
-- Continents with the highest death count
select continent,max(total_deaths) as deathCount,max(population) as totalPopulation
from NewProj..['covidDeaths']
where continent is not null
group by continent

-- Global Cases to Death
select sum(new_cases) as TotalCases,sum(new_deaths) as TotalDeaths,(sum(new_deaths)/sum(new_cases))*100 as DeathPercent
from NewProj..['covidDeaths']
where continent is not null

-- Total population vs Vaccinations
-- Percent of people who has received atleast one dose of the Vaccine

select deaths.location,deaths.date,deaths.new_cases,sum(deaths.new_cases)over (partition by deaths.location order by deaths.location,deaths.date) as RollingCases,vaccs.new_vaccinations,sum(vaccs.new_vaccinations) over (partition by deaths.location order by deaths.location,deaths.date) as RollingVaccs
from NewProj..['covidDeaths'] as deaths
join NewProj..['covidVaccinations'] as vaccs
on deaths.location = vaccs.location
	and deaths.date = vaccs.date
where deaths.continent is not null
and deaths.location like 'india'

-- Using CTE
with PopVsVac (location,date,population,new_cases,RollingCases,new_vaccinations,RollingVaccs)
as
(
select deaths.location,deaths.date,deaths.population,deaths.new_cases,sum(deaths.new_cases)over (partition by deaths.location order by deaths.location,deaths.date) as RollingCases,vaccs.new_vaccinations,sum(vaccs.new_vaccinations) over (partition by deaths.location order by deaths.location,deaths.date) as RollingVaccs
from NewProj..['covidDeaths'] as deaths
join NewProj..['covidVaccinations'] as vaccs
on deaths.location = vaccs.location
	and deaths.date = vaccs.date
where deaths.continent is not null
and deaths.location like 'india'
)

Select *,(RollingVaccs/population) * 100 as percentOfPopVacced
from PopVsVac

-- Using Temp Tables
Drop table if exists #PercentPopVacced
Create table #PercentPopVacced
(location nvarchar(255),
date datetime,
population float,
NewCases float,
RollingCases float,
NewVaccs float,
RollingVaccs float)

insert into #PercentPopVacced
select deaths.location,deaths.date,deaths.population,deaths.new_cases,sum(deaths.new_cases)over (partition by deaths.location order by deaths.location,deaths.date) as RollingCases,vaccs.new_vaccinations,sum(vaccs.new_vaccinations) over (partition by deaths.location order by deaths.location,deaths.date) as RollingVaccs
from NewProj..['covidDeaths'] as deaths
join NewProj..['covidVaccinations'] as vaccs
on deaths.location = vaccs.location
	and deaths.date = vaccs.date
where deaths.continent is not null
and deaths.location like 'india'

Select *
from #PercentPopVacced

-- Creating a View to be used for visualization
Create View PopVaccs as
select deaths.location,deaths.date,deaths.population,deaths.new_cases,sum(deaths.new_cases)over (partition by deaths.location order by deaths.location,deaths.date) as RollingCases,vaccs.new_vaccinations,sum(vaccs.new_vaccinations) over (partition by deaths.location order by deaths.location,deaths.date) as RollingVaccs
from NewProj..['covidDeaths'] as deaths
join NewProj..['covidVaccinations'] as vaccs
on deaths.location = vaccs.location
	and deaths.date = vaccs.date
where deaths.continent is not null
and deaths.location like 'india'
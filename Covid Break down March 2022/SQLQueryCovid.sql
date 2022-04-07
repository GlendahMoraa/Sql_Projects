

------------CovidCases &CovidDeaths------------
select * from CovidDeaths$
order by 1,2


select [location], [date], total_cases, total_deaths, [population] from CovidDeaths$
order by 1,2

---* Looking at total cases vs total deaths
create view DailyDeathRates_Kenya
as
select [location], [date], total_cases, total_deaths,  (total_deaths/total_cases)*100 as DeathPercentage 
from CovidDeaths$
where [location] = 'Kenya'

--- The likely of contracting covid 19 in kenya as per 30/3/2022 is 1.746%

--- *The percentage population that get covid in kenya
create view DailyCovidCases_Kenya
as
select [location], [date], total_cases, [population],  (total_cases/population)*100 as PercentageCases
from CovidDeaths$
where [location] = 'Kenya'
order by 1,2


---*The country that has recorded the highest covid 19 cases and where is kenya ranked?
select [location], max(total_cases) as MaxTotalCases, [population], max((total_cases/population)) *100 as MaximumInfectedPecentage
from CovidDeaths$
group by [location], population
order by MaximumInfectedPecentage desc
--- Faeroe Islands has recorded the highest covid 19 of 70.65% so far as compared to/per the county's population, 
---Kenya is at position 182 out of the 239  with a pacentage of 0.59

select [location], date, max(total_cases) as MaxTotalCases, [population], max(total_cases/population) *100 as MaximumInfectedPecentage
from CovidDeaths$
where continent is not null
group by [location], population, date
order by  max(total_cases) desc
--- But in general, United States has recorded the highest number of people(80057236) who have contracted covid 19
---could be because it is highly populated also
---Kenya on the other hand is at position 95 with 323402 recorded cases


---* The country that has recorded the highest number of deaths and which position is kenya at

select [location], max(cast(total_deaths as int)) as MaxTotaldeaths, MAX(total_cases) as MaxTotalCases,  [population], max(cast(total_deaths as int)/total_cases) *100 as MaximumDeathPecentage
from CovidDeaths$
where continent is not null
group by [location], population
order by  MaxTotaldeaths desc
---Just as the united states Records hight cases of contracting covid 19 it has also recorded the highest number of deaths in the world
--- Kenya is at position 84 with 5648 recorded deaths


--* The Continent that has recorded the highest number of deaths and which position is kenya at

select location, max(total_cases) as MaxCasesPerContinent
from CovidDeaths$
where continent is null AND location not in('World', 'Upper middle income', 'High income', 'Lower middle income', 'Low income', 'European Union', 'International')
group by location
order by  MaxCasesPerContinent desc
---Europe has recorded the highest cases of covid 19 


---*The continent that has recorded highest deaths of covid 19
select location, max(cast(total_deaths as int)) as MaxTotaldeathsPerContinent
from CovidDeaths$
where continent is null AND location not in('World', 'Upper middle income', 'High income', 'Lower middle income', 'Low income', 'European Union', 'International')
group by location
order by  MaxTotaldeathsPerContinent desc
---Europe has recorded the highest deaths of covid 19 


---*World's total cases and total deaths per day 
create view WoldTotalCasesAndDeaths
as
select [date], sum(new_cases) as WorldTotalCases, sum(cast(new_deaths as int)) as WorldTotalDeaths, 
(sum(cast(new_deaths as int))/sum(new_cases)) * 100 as WorldPercentageDeaths
from CovidDeaths$
where continent is not null
group by date


--- World's total cases and total deaths
create view WoldTotalCasesAndDeaths
as
select sum(new_cases) as WorldTotalCases, sum(cast(new_deaths as int)) as WorldTotalDeaths, 
(sum(cast(new_deaths as int))/sum(new_cases)) * 100 as WorldPercentageDeaths
from CovidDeaths$
where continent is not null



----------------CovidVaccination------------
---The Rolling total population vaccinated per county and day
select  CovidDeaths$.continent, CovidDeaths$.location, CovidDeaths$.date, CovidDeaths$.population, CovidVaccination$.new_vaccinations, 
	sum(cast(CovidVaccination$.new_vaccinations as bigint)) Over (partition by CovidDeaths$.location order by CovidDeaths$.location, CovidDeaths$.date ) as RollingVaccinationCount
from CovidDeaths$
join CovidVaccination$ 
on CovidDeaths$.location = CovidVaccination$.location
	and CovidDeaths$.date = CovidVaccination$.date
where CovidDeaths$.continent is not null
order by 1, 2, 3

---The Rolling Persentage population vaccinated per county and day
with VaccinatedPopulation (continent, location, date, population, new_vaccinations, RollingVaccinationCount)
as
(
select  CovidDeaths$.continent, CovidDeaths$.location, CovidDeaths$.date, CovidDeaths$.population, CovidVaccination$.new_vaccinations, 
	sum(cast(CovidVaccination$.new_vaccinations as bigint)) Over (partition by CovidDeaths$.location order by CovidDeaths$.location, CovidDeaths$.date) as RollingVaccinationCount
from CovidDeaths$
join CovidVaccination$ 
on CovidDeaths$.location = CovidVaccination$.location
	and CovidDeaths$.date = CovidVaccination$.date
where CovidDeaths$.continent is not null
)
select  *, RollingVaccinationCount/population *100 from VaccinatedPopulation

---*Creating a table for the above results and view for vusualization
drop table if exists PopulationVaccinateTable
create table PopulationVaccinateTable
(continent nvarchar(700), 
location nvarchar(700), 
date datetime, 
population numeric, 
new_vaccinations numeric,
RollingVaccinationCount numeric
)
insert into PopulationVaccinateTable
select  CovidDeaths$.continent, CovidDeaths$.location, CovidDeaths$.date, CovidDeaths$.population, CovidVaccination$.new_vaccinations, 
	sum(cast(CovidVaccination$.new_vaccinations as bigint)) Over (partition by CovidDeaths$.location order by CovidDeaths$.location, CovidDeaths$.date) as RollingVaccinationCount
from CovidDeaths$
join CovidVaccination$ 
on CovidDeaths$.location = CovidVaccination$.location
	and CovidDeaths$.date = CovidVaccination$.date
where CovidDeaths$.continent is not null
select  *, RollingVaccinationCount/population *100 from PopulationVaccinateTable

create view PopulationVaccinateView
as
select  CovidDeaths$.continent, CovidDeaths$.location, CovidDeaths$.date, CovidDeaths$.population, CovidVaccination$.new_vaccinations, 
	sum(cast(CovidVaccination$.new_vaccinations as bigint)) Over (partition by CovidDeaths$.location order by CovidDeaths$.location, CovidDeaths$.date) as RollingVaccinationCount
from CovidDeaths$
join CovidVaccination$ 
on CovidDeaths$.location = CovidVaccination$.location
	and CovidDeaths$.date = CovidVaccination$.date
where CovidDeaths$.continent is not null



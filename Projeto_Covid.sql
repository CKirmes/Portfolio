
select location,date,total_cases,new_cases,total_deaths,population
from dbo.covid_death
order by 2

-- LOOKING AT TOTAL CASES X TOTAL DEATHS

select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS Percentual_mortes
from dbo.covid_death
order by date desc

alter table dbo.covid_death
alter column total_deaths float

-- LOOKING AT NEW CASES X POPULATIOn
select location,date,population, total_cases,new_cases, (new_cases/population)*100 AS Percentual_novos_casos
from dbo.covid_death
order by Percentual_novos_casos desc

-- LOOKING AT total CASES X POPULATIOn
select location,date,population, total_cases, (total_cases/population)*100 AS Percentual_casos
from dbo.covid_death
where continent like 'South%'
order by Percentual_casos desc

-- Countries whith highest infection rate per population
select location,population, max(total_cases) as Máximo_Infectados, max((total_cases/population))*100 AS Percentual_max_infectados
from dbo.covid_death
group by location, population
--where continent like 'South%'
order by Percentual_max_infectados desc

-- Countries whith highest deaths rate per population
select location, max(total_deaths) as Máximo_mortes, max((total_deaths/population))*100 AS Percentual_max_mortos
from dbo.covid_death
group by location
--where continent like 'South%'
order by Percentual_max_mortos desc


--compare total deaths and cases by continent
select continent,sum(new_cases)as Máximo_casos, sum(new_deaths) as Máximo_mortes, sum(new_deaths)/sum(new_cases)*100 AS Percentual_casos_mortes
from dbo.covid_death
group by continent


-- cases x vaccines
select death.location, death.date, death.population, death.new_cases, death.total_cases,vaccines.new_vaccinations, SUM(convert(int,vaccines.new_vaccinations)) over (partition by death.location order by death.date, 
death.location) as Vacinados
from dbo.covid_death death
join dbo.covid_vaccines vaccines 
on death.location = vaccines.location
and death.date = vaccines.date
order by 1

--cases x % people vaccinated - TEMP TABLE

create table #Percentual_vacinado
(
location nvarchar(50),
date datetime,
population float,
new_cases float,
total_cases float,
new_vaccinations float,
Vacinados float
)

insert into #Percentual_vacinado
select death.location, death.date, death.population, death.new_cases, death.total_cases,vaccines.new_vaccinations, SUM(convert(int,vaccines.new_vaccinations)) 
over (partition by death.location order by death.date, 
death.location) as Vacinados
from dbo.covid_death death
join dbo.covid_vaccines vaccines 
on death.location = vaccines.location
and death.date = vaccines.date
order by 1

select location, date, population, new_cases, total_cases,new_vaccinations, Vacinados, (vacinados/population)*100 from #Percentual_vacinado
order by 1


-- CREATE VIEW
create view Percentual_vacinado as
select death.location, death.date, death.population, death.new_cases, death.total_cases,vaccines.new_vaccinations, SUM(convert(int,vaccines.new_vaccinations)) 
over (partition by death.location order by death.date, 
death.location) as Vacinados
from dbo.covid_death death
join dbo.covid_vaccines vaccines 
on death.location = vaccines.location
and death.date = vaccines.date

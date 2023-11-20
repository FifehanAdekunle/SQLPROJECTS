
--COVID-19 Dataexploration from our ourworldindata Wesbite from jan 8 2020 to Feb 11th 2023   --/

-- Total cases vs total deaths--
-- This shows the likehood of dying if you catch covid in your country--
SELECT location, date,total_cases,total_deaths,(CONVERT(float, total_deaths) / CONVERT(float, total_cases)) * 100 as Deathpercentage
FROM Portfolioprojects ..Coviddeaths$
Where location like 'Nigeria'
ORDER BY 1,2;

--Total cases vs population--
-- This shows what percentage of the population in Nigeria has gotten covid--
SELECT location,population,total_cases,(CONVERT(float, total_cases) / CONVERT(float, population)) * 100 as populationwithcovid
FROM Portfolioprojects ..Coviddeaths$
Where location like 'Nigeria'
ORDER BY 1,2;

-- -- Looking at countries with highest infection rate compared to population--
SELECT location, population, max(total_cases) as Highestinfectioncount, max(CONVERT(float, total_cases) / CONVERT(float, population))*100 as Percentageofpopulationinfected
FROM Portfolioprojects ..Coviddeaths$
Group by location, population
ORDER BY Percentageofpopulationinfected desc;

-- Countries with the highest death count per poulation--
SELECT location,  max(cast(total_deaths as int)) as Totaldeathcount
FROM Portfolioprojects ..Coviddeaths$
Where continent is not null
Group by location
ORDER BY Totaldeathcount desc;


-- EXPLORING DATA BY CONTINENT --
--Showing the continent with the highest deathcount per population---
SELECT continent,  max(cast(total_deaths as int)) as Totaldeathcount
FROM Portfolioprojects ..Coviddeaths$
Where continent is not null
Group by continent
ORDER BY Totaldeathcount desc;

SELECT location,  max(cast(total_deaths as int)) as Totaldeathcount
FROM Portfolioprojects ..Coviddeaths$
Where continent is null
Group by location
ORDER BY Totaldeathcount desc;


-- GLOBAL NUMBERS--
SELECT
    date,
    SUM(new_cases) as total_cases,
    SUM(CAST(new_deaths as int)) as total_deaths,
    CASE 
        WHEN SUM(new_cases) = 0 THEN 0 -- Avoid division by zero
        ELSE SUM(CAST(new_deaths as int)) / SUM(new_cases) * 100 
    END as DeathPercentagePerCase 
FROM
    Portfolioprojects..Coviddeaths$
WHERE
    continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2;

-- Overall percentage--
SELECT
    SUM(new_cases) as total_cases,
    SUM(CAST(new_deaths as int)) as total_deaths,
    CASE 
        WHEN SUM(new_cases) = 0 THEN 0 -- Avoid division by zero
        ELSE SUM(CAST(new_deaths as int)) / SUM(new_cases) * 100 
    END as DeathPercentagePerCase 
FROM
    Portfolioprojects..Coviddeaths$
WHERE
    continent IS NOT NULL
ORDER BY 1, 2;

-- Exploring Covid vacinnations and deaths--
select* 
from Portfolioprojects.dbo.Coviddeaths$ dea
join Portfolioprojects.dbo.Covidvacinnation$ vac
-- You can use and for joins and join on two fields/cols--
on dea.location = vac.location
and dea.date = vac.date

-- Looking at total population vs vacccinations--
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
from Portfolioprojects.dbo.Coviddeaths$ dea
join Portfolioprojects.dbo.Covidvacinnation$ vac
-- You can use and for joins and join on two fields/cols--
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3;

select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) OVER (partition by  dea.location order by dea.location,dea.date ) as Rollingpeoplevacinnated 
from Portfolioprojects.dbo.Coviddeaths$ dea
join Portfolioprojects.dbo.Covidvacinnation$ vac
-- You can use and for joins and join on two fields/cols--
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3;

-- Total Populations vs vacination using cte--
with popvsvac(continent, location,date,population,new_vaccinations,Rollingpeoplevacinnated )
as (
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) OVER (partition by  dea.location order by dea.location,dea.date ) as Rollingpeoplevacinnated 
from Portfolioprojects.dbo.Coviddeaths$ dea
join Portfolioprojects.dbo.Covidvacinnation$ vac
-- You can use and for joins and join on two fields/cols--
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (Rollingpeoplevacinnated/population)*100 as peoplevaccinatedper
from popvsvac;

-- Temp table --
CREATE TABLE #percentpopvac
(
    continent nvarchar(255),
    location nvarchar(255),
    date datetime,
    Population float,
    new_vaccinations nvarchar(255),
    Rollingpeoplevacinnated float
)
Insert into #percentpopvac
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) OVER (partition by  dea.location order by dea.location,dea.date ) as Rollingpeoplevacinnated 
from Portfolioprojects.dbo.Coviddeaths$ dea
join Portfolioprojects.dbo.Covidvacinnation$ vac
-- You can use and for joins and join on two fields/cols--
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Coviddeaths$';

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Covidvacinnation$';


-- Create a temporary table to store the result
CREATE TABLE #TempResult (
    continent NVARCHAR(255),
    location NVARCHAR(255),
    date DATETIME,
    population NUMERIC,
    new_vaccinations NUMERIC,
    Rollingpeoplevacinnated NUMERIC
);

-- Insert the result of the SELECT statement into the temporary table
INSERT INTO #TempResult
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CONVERT(FLOAT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rollingpeoplevacinnated
FROM Portfolioprojects.dbo.Coviddeaths$ dea
JOIN Portfolioprojects.dbo.Covidvacinnation$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

-- Check the data types for the columns in the temporary table
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = '#TempResult';

-- Drop the temporary table when done
DROP TABLE #TempResult;

DROP Table if exists #TempResult
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CONVERT(FLOAT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rollingpeoplevacinnated
FROM Portfolioprojects.dbo.Coviddeaths$ dea
JOIN Portfolioprojects.dbo.Covidvacinnation$ vac
ON dea.location = vac.location
AND dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations
create view PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CONVERT(FLOAT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rollingpeoplevacinnated
FROM Portfolioprojects.dbo.Coviddeaths$ dea
JOIN Portfolioprojects.dbo.Covidvacinnation$ vac
ON dea.location = vac.location
AND dea.date = vac.date
where dea.continent is not null 

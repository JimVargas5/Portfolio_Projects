/*
Portfolio project using Python, SQL, Tableau
on the subject of coronavirus deaths and vaccinations
following a tutorial by Alex The Analyst
by Jim Vargas
*/


--SELECT *
--FROM CovidDeaths
--ORDER BY 3,4
--SELECT *
--FROM CovidVaccinations
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio_Project_Covid..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date




--Total Cases vs Total Deaths in U.S.
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS 'Mortality %'
FROM Portfolio_Project_Covid..CovidDeaths
WHERE location LIKE '%states%'
	AND continent IS NOT NULL
ORDER BY location, date




--Total Cases vs Total Population in U.S.
SELECT location, date, total_cases, (total_cases/population)*100 AS 'Infections as % of Pop.'
FROM Portfolio_Project_Covid..CovidDeaths
WHERE location LIKE '%states%'
	AND continent IS NOT NULL
ORDER BY location, date




--Countries with highest infection rate
SELECT location, population, MAX(total_cases) AS 'Highest infection count',
	MAX((total_cases/population)*100) AS 'Max. Infections as % of Pop.'
FROM Portfolio_Project_Covid..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY [Max. Infections as % of Pop.] DESC




--Countries with highest mortality
SELECT location, population, MAX(CAST(total_deaths AS int)) AS 'Max. mortality count',
	MAX((total_deaths/population)*100) AS 'Max. mortality rate (%)'
FROM Portfolio_Project_Covid..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY [Max. mortality rate (%)] DESC




--Now, by continent
SELECT location, MAX(CAST(total_deaths AS int)) AS 'Max. mortality count',
	MAX((total_deaths/population)*100) AS 'Max. mortality rate (%)'
FROM Portfolio_Project_Covid..CovidDeaths
WHERE continent IS NULL --observe why this is necessary in the data
GROUP BY location
ORDER BY [Max. mortality rate (%)] DESC
/*
The data in "CovidDeaths" has observations for Continent in Location with Continent==NULL
*/




--Infection and Mortality rates Globally
SELECT SUM(new_cases) AS 'Total cases', SUM(CAST(new_deaths AS int)) AS 'Total deaths',
	SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 'Mortality Rate (%)'
FROM Portfolio_Project_Covid..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
--ORDER BY 1, 2









--Global cases and mortality
SELECT SUM(new_cases) AS 'Total Cases', SUM(CAST(new_deaths AS int)) 'Total Deaths',
	SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS 'Mortality Rate'
FROM Portfolio_Project_Covid..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2




--Death Rate by continent
SELECT location, SUM(CAST(new_deaths AS int)) AS 'Total Death Count',
	SUM(CAST(new_deaths AS int)/population*100) AS 'Death Rate'
FROM Portfolio_Project_Covid..CovidDeaths
WHERE continent IS NULL
	AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY [Total Death Count] DESC

/*
The data tallies up statistics for continents in various rows (as well as EU and the whole world, etc.),
so we filter "WHERE continent is NULL" to find the "Europe" tallied row, etc.

In calculating 'Death Rate', SQL throws an error when applying the operations to scale by 100
and divide by 'population' *after* the SUM operation, but not *before*.
Applying these operations *before* (should?) increase the number of operations for this querie.
*/




--Max. Infection Rate by country
SELECT location, population, MAX(total_cases) AS 'Max Infection Count', 
	MAX(total_cases/population)*100 AS 'Max Infection Rate'
FROM Portfolio_Project_Covid..CovidDeaths
GROUP BY location, population
ORDER BY 4 DESC

/*
Format NULLs in this table to 0 (zeros)
*/




--Highest Infection Rates across time and space 
SELECT location, population, date, MAX(total_cases) AS 'Max Infection Count',
	MAX(total_cases/population*100) AS 'Infection Rate'
FROM Portfolio_Project_Covid..CovidDeaths
GROUP BY location, population, date
ORDER BY 5 DESC
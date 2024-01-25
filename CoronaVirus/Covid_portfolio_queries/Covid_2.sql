/*
Portfolio project using Python, SQL, Tableau
on the subject of coronavirus deaths and vaccinations
following a tutorial by Alex The Analyst
by Jim Vargas
*/




--Global vaccination counts
SELECT deaths.continent, deaths.location, deaths.date, deaths.population,
	vacc.new_vaccinations,
	SUM(CONVERT(bigint, vacc.new_vaccinations)) OVER
		(PARTITION BY deaths.location ORDER BY deaths.location, deaths.date)
		AS 'Total Vacc. (by location and date)'
From Portfolio_Project_Covid..CovidDeaths AS deaths
JOIN Portfolio_Project_Covid..CovidVaccinations AS vacc
	ON deaths.location = vacc.location
	AND deaths.date = vacc.date
WHERE deaths.continent IS NOT NULL
	--AND deaths.location = 'Germany'
ORDER BY 2, 3




--CTE (common table expresssion): running vacc. stat
WITH CTE_VaccRate (continent, location, date, population, new_vaccinations, [Total Vacc. (by location and date)])
AS
(
SELECT deaths.continent, deaths.location, deaths.date, deaths.population,
	vacc.new_vaccinations,
	SUM(CONVERT(bigint, vacc.new_vaccinations)) OVER
		(PARTITION BY deaths.location ORDER BY deaths.location, deaths.date)
		AS 'Total Vacc. (by location and date)'
From Portfolio_Project_Covid..CovidDeaths AS deaths
JOIN Portfolio_Project_Covid..CovidVaccinations AS vacc
	ON deaths.location = vacc.location
	AND deaths.date = vacc.date
WHERE deaths.continent IS NOT NULL
)
SELECT *, ([Total Vacc. (by location and date)]/population)*100 AS 'Running Vacc. Rate (%)'
FROM CTE_VaccRate
WHERE location = 'Israel'
/*
The CTE (the WITH and AS) are necessary to do operations, e.g. for 
calculating 'Running Vacc. Rate (%)'.
A similar result can be accomplished with a temp. table, and there are pros and cons
to the different approaches.
*/




--Finding countries with highest vacc. rate
WITH CTE_VaccMAX (continent, location, population, [Total Vacc. (by location and date)])
AS
(
SELECT deaths.continent, deaths.location, deaths.population,
	SUM(CONVERT(bigint, vacc.new_vaccinations)) OVER
		(PARTITION BY deaths.location ORDER BY deaths.location, deaths.date)
		AS 'Total Vacc. (by location and date)'
From Portfolio_Project_Covid..CovidDeaths AS deaths
JOIN Portfolio_Project_Covid..CovidVaccinations AS vacc
	ON deaths.location = vacc.location
	AND deaths.date = vacc.date
WHERE deaths.continent IS NOT NULL
)
SELECT continent, location, population,
	MAX([Total Vacc. (by location and date)]/population*100) AS 'Max. vacc. rate'
FROM CTE_VaccMAX
GROUP BY continent, location, population
ORDER BY [Max. vacc. rate] DESC
/*
Gibraltar (182.12%) and Israel (121.28%) have vax rates exceeding 100%. 
Double vax?
*/




--Same as above but with temp tables
DROP TABLE IF EXISTS #PercentPopVacc
CREATE TABLE #PercentPopVacc (
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	total_vacc numeric
)

INSERT INTO #PercentPopVacc
SELECT deaths.continent, deaths.location, deaths.date, deaths.population,
	vacc.new_vaccinations,
	SUM(CONVERT(bigint, vacc.new_vaccinations)) OVER
		(PARTITION BY deaths.location ORDER BY deaths.location, deaths.date)
		AS 'Total Vacc. (by location and date)'
From Portfolio_Project_Covid..CovidDeaths AS deaths
JOIN Portfolio_Project_Covid..CovidVaccinations AS vacc
	ON deaths.location = vacc.location
	AND deaths.date = vacc.date
--WHERE deaths.continent IS NOT NULL

SELECT *, (total_vacc/population)*100 AS 'Running Vacc. Rate (%)'
FROM #PercentPopVacc
WHERE location = 'Israel'




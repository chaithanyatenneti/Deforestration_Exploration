
 
CREATE VIEW forestation
AS
SELECT fa.country_code AS country_code,
fa.country_name AS country_name,
fa.year AS year,
fa.forest_area_sqkm AS forest_area,
la.total_area_sq_mi * 2.59 AS total_area,
r.region AS region,
r.income_group AS income_group 
FROM forest_area fa
JOIN land_area la
ON fa.country_code = la.country_code
AND fa.year = la.year
JOIN  regions r
ON la.country_code = r.country_code

1.Global_Situation
a.What was the total forest area (in sq km) of the world in 1990?

SELECT forest_area AS forest_area_1990
FROM forestation
WHERE year = 1990 AND region = 'World'

b.What was the total forest area (in sq km) of the world in 2016? 

SELECT forest_area AS forest_area_2016
FROM forestation
WHERE year = 2016 AND region = 'World'

c.What was the change (in sq km) in the forest area of the world from 1990 to 2016?

SELECT (f1.forest_area - f2.forest_area) AS forest_area_change 
FROM forestation AS f1
JOIN forestation AS f2
ON f1.country_code = f2.country_code 
WHERE f1.year = 1990 AND f2.year = 2016 AND f1.region = 'World'


d.What was the percent change in forest area of the world from 1990 to 2016?

SELECT ((f1.forest_area - f2.forest_area)/f1.forest_area)*100 AS percent_forest_area_change 
FROM forestation AS f1
JOIN forestation AS f2
ON f1.country_code = f2.country_code 
WHERE f1.year = 1990 AND f2.year = 2016 AND f1.region = 'World'

e.If you compare the amount of forest area lost between 1990 and 2016, to which countrys total area in 2016 is it closest to?

SELECT country_name, total_area
FROM forestation
WHERE (SELECT (f1.forest_area - f2.forest_area) AS forest_area_change 
FROM forestation AS f1
JOIN forestation AS f2
ON f1.country_code = f2.country_code 
WHERE f1.year = 1990 AND f2.year = 2016 AND f1.region = 'World') >= total_area AND year = 2016
ORDER BY total_area DESC
LIMIT 1

2.Regional_outlook
CREATE VIEW region_outlook
AS
SELECT  region,
        SUM(CASE WHEN year = 1990 THEN forest_area ELSE 0 END) / SUM(CASE WHEN year = 1990 THEN total_area ELSE 0 END) * 100 AS percent_forest_area_1990,
        SUM(CASE WHEN year = 2016 THEN forest_area ELSE 0 END) / SUM(CASE WHEN year = 2016 THEN total_area ELSE 0 END) * 100 AS percent_forest_area_2016
FROM    forestation
WHERE   year IN (1990, 2016)
GROUP BY region

a. What was the percent forest of the entire world in 2016? Which region had the HIGHEST percent forest in 2016, and which had the LOWEST, to 2 decimal places?

SELECT percent_forest_area_2016
FROM region_outlook
ORDER BY percent_forest_area_2016


b. What was the percent forest of the entire world in 1990? Which region had the HIGHEST percent forest in 1990, and which had the LOWEST, to 2 decimal places?

SELECT region,percent_forest_area_1990
FROM region_outlook
ORDER BY percent_forest_area_1990

c. Based on the table you created, which regions of the world DECREASED in forest area from 1990 to 2016?

SELECT region, percent_forest_area_1990, percent_forest_area_2016
FROM region_outlook
WHERE percent_forest_area_1990 > percent_forest_area_2016

3. Country-level Detail
a. Which 5 countries saw the largest amount decrease in forest area from 1990 to 2016? What was the difference in forest area for each?

SELECT f1.country_name AS country,
f1.region,
f1.forest_area AS forest_area_1990,
f2.forest_area AS forest_area_2016,
(f1.forest_area - f2.forest_area) AS forest_area_change
FROM forestation f1
JOIN forestation f2
ON f1.country_name = f2.country_name
WHERE f1.year = 1990 AND f2.year = 2016 AND f1.forest_area > f2.forest_area
ORDER BY forest_area_change DESC
LIMIT 6

b. Which 5 countries saw the largest percent decrease in forest area from 1990 to 2016? What was the percent change to 2 decimal places for each?

SELECT f1.country_name AS country,
f1.region,
f1.forest_area AS forest_area_1990,
f2.forest_area AS forest_area_2016,
((f1.forest_area - f2.forest_area)/f1.forest_area)*100 AS percent_forest_area_change
FROM forestation f1
JOIN forestation f2
ON f1.country_name = f2.country_name
WHERE f1.year = 1990 AND f2.year = 2016 AND f1.forest_area > f2.forest_area
ORDER BY percent_forest_area_change DESC
LIMIT 6
c. If countries were grouped by percent forestation in quartiles, which group had the most countries in it in 2016?

SELECT
    CASE
        WHEN percent_forest_area >= 75 THEN '4th quartile'
        WHEN percent_forest_area >= 50 THEN '3rd quartile'
        WHEN percent_forest_area >= 25 THEN '2nd quartile'
        ELSE '1st quartile'
    END AS quartile,
    COUNT(*) AS num_countries
FROM (
    SELECT
        country_name,
        forest_area / total_area * 100 AS percent_forest_area
    FROM 
        forestation
    WHERE 
        year = 2016
)
GROUP BY 
    quartile
ORDER BY 
    quartile

d. List all of the countries that were in the 4th quartile (percent forest > 75%) in 2016.

SELECT country_name,region, percent_forest_area
FROM forestation
WHERE year = 2016 AND percent_forest_area >= 75
ORDER BY percent_forest_area DESC

e. How many countries had a percent forestation higher than the United States in 2016?

SELECT COUNT(*)
FROM forestation
WHERE year = 2016 AND percent_forest_area > (SELECT percent_forest_area FROM forestation WHERE country_name = 'United States' AND year = 2016)


Bonus
SELECT f1.country_name AS country,
f1.region,
f1.forest_area AS forest_area_1990,
f2.forest_area AS forest_area_2016,
((f1.forest_area - f2.forest_area)/f1.forest_area)*100 AS percent_forest_area_change
FROM forestation f1
JOIN forestation f2
ON f1.country_name = f2.country_name
WHERE f1.year = 1990 AND f2.year = 2016 AND f1.forest_area < f2.forest_area
ORDER BY percent_forest_area_change 
LIMIT 6

SELECT quartile, COUNT(*) AS num_countries
FROM  (SELECT country_name,
region,
percent_forest_area,
NTILE(4) OVER (ORDER BY percent_forest_area) AS quartile
FROM forestation
WHERE year = 2016)
GROUP BY quartile
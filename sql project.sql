
CREATE VIEW forestation AS
    SELECT 
        fa.*,
        la.total_area_sq_mi,
        fa.forest_area_sqkm / la.total_area_sq_mi * 2.59 * 100 AS forest_percent
    FROM
        forest_area fa
            JOIN
        land_area la ON fa.country_code = la.country_code
            JOIN
        regions re ON re.country_code = la.country_code


/*What was the total forest area (in sq km) of the world in 1990? */

SELECT 
    forest_area_sqkm forest_area_1990
FROM
    forestation
WHERE
    year = '1990' AND country_name = 'World'
GROUP BY 1
    
/*What was the total forest area (in sq km) of the world in 2016? */
SELECT 
    forest_area_sqkm forest_area_2016
FROM
    forestation
WHERE
    year = '2016' AND country_name = 'World'
GROUP BY 1


/* What was the change (in sq km) in the forest area of the world from 1990 to 2016? */
SELECT 
    
        (SELECT 
                        forest_area_sqkm forest_area_1990
                    FROM
                        forestation
                    WHERE
                        year = '1990' AND country_name = 'World'
                    GROUP BY 1) - (SELECT 
                        forest_area_sqkm forest_area_2016
                    FROM
                        forestation
                    WHERE
                        year = '2016' AND country_name = 'World'
                    GROUP BY 1) AS diff
FROM
    forestation
GROUP BY 1




/*What was the percent change in forest area of the world between 1990 and 2016?*/
SELECT 
    (SELECT 
            ((SELECT 
                        forest_area_sqkm forest_area_1990
                    FROM
                        forestation
                    WHERE
                        year = '1990' AND country_name = 'World'
                    GROUP BY 1) - (SELECT 
                        forest_area_sqkm forest_area_2016
                    FROM
                        forestation
                    WHERE
                        year = '2016' AND country_name = 'World'
                    GROUP BY 1)) AS diff
        FROM
            forestation
        GROUP BY 1) / (SELECT 
            forest_area_sqkm forest_area_1990
        FROM
            forestation
        WHERE
            year = '1990' AND country_name = 'World'
        GROUP BY 1) * 100 AS diff_percent





/* If you compare the amount of forest area lost between 1990 and 2016, to which country's total area in 2016 is it closest to?*/

SELECT 
    country_name, total_area_sq_mi * 2.59 tot_ar
FROM
    forestation
WHERE
    year = '2016'
        AND total_area_sq_mi * 2.59 <= 1324449
GROUP BY 1 , 2
ORDER BY 2 DESC
---------------------------------------------------------------------------------------------------------------------------------------

CREATE VIEW region_forest AS
    SELECT 
        r.region,
        fa.year,
        SUM(fa.forest_area_sqkm) total_forest_area_sqkm,
       	SUM(la.total_area_sq_mi*2.59) AS total_area_sqkm,
        SUM(fa.forest_area_sqkm) / SUM(la.total_area_sq_mi * 2.59) * 100 AS percent_forest_reg
    FROM
        forest_area fa
            JOIN
        land_area la ON fa.country_code = la.country_code
            AND fa.year = la.year
            JOIN
        regions r ON la.country_code = r.country_code
    GROUP BY 1 , 2
    ORDER BY 1 , 2




/* What was the percent forest of the entire world in 2016? Which region had the HIGHEST percent forest in 2016, and which had the LOWEST, to 2 decimal places?*/
SELECT 
    region, percent_forest_reg
FROM
    region_forest
WHERE
    region = 'World' AND year = '2016'


SELECT 
    region, percent_forest_reg
FROM
    region_forest
WHERE
    year = '2016'
ORDER BY percent_fa_region





/* What was the percent forest of the entire world in 1990? Which region had the HIGHEST percent forest in 1990, and which had the LOWEST, to 2 decimal places?*/
SELECT 
    region, percent_forest_reg
FROM
    region_forest
WHERE
    region = 'World' AND year = '1990'
ORDER BY percent_forest_reg

SELECT 
    region, percent_forest_reg
FROM
    region_forest
WHERE
    year = '1990'
ORDER BY percent_forest_reg DESC

SELECT 
    region, percent_forest_reg
FROM
    region_forest
WHERE
    year = '1990'
ORDER BY percent_forest_reg

/*  Based on the table you created, which regions of the world DECREASED in forest area from 1990 to 2016?*/

WITH table1990 AS (SELECT * FROM region_forest WHERE year =1990),
	   table2016 AS (SELECT * FROM region_forest WHERE year = 2016)
SELECT table1990.region,
       table1990.percent_forest_reg AS fa_1990,
       table2016.percent_forest_reg AS fa_2016
    FROM table1990 JOIN table2016 ON table1990.region = table2016.region
    WHERE table1990.percent_forest_reg > table2016.percent_forest_reg;





/*  COUNTRY-LEVEL DETAILS SUCCESS STORIES: */
WITH table1990 as (select* from country_forest where year = '1990'),
	 table2016 as (select * from country_forest where year = '2016')
SELECT 
    table1990.country_name,
    table1990.total_forest_area_sqkm AS r1990,
    table2016.total_forest_area_sqkm AS r2016,
    (table1990.total_forest_area_sqkm - table2016.total_forest_area_sqkm) AS abs_change,
    (table1990.total_forest_area_sqkm - table2016.total_forest_area_sqkm) / table1990.total_forest_area_sqkm * 100 as percent_change
FROM
    table1990
        JOIN
    table2016 ON table1990.country_name = table2016.country_name
WHERE
table1990.total_forest_area_sqkm < table2016.total_forest_area_sqkm
ORDER BY abs_change, percent_change
limit 5



WITH table1990 as (select* from country_forest where year = '1990'),
	 table2016 as (select * from country_forest where year = '2016')
SELECT 
    table1990.country_name,
    table1990.total_forest_area_sqkm AS r1990,
    table2016.total_forest_area_sqkm AS r2016,
    (table1990.total_forest_area_sqkm - table2016.total_forest_area_sqkm) AS abs_change,
    (table1990.total_forest_area_sqkm - table2016.total_forest_area_sqkm) / table1990.total_forest_area_sqkm * 100 as percent_change
FROM
    table1990
        JOIN
    table2016 ON table1990.country_name = table2016.country_name
WHERE
table1990.total_forest_area_sqkm < table2016.total_forest_area_sqkm
ORDER BY percent_change
limit 25


---------------------------------------------------------------------------------------------------------------------------------------------
/*Which 5 countries saw the largest amount decrease in forest area from 1990 to 2016? What was the difference in forest area for each?*/


WITH table1990 as (select* from country_forest where year = '1990'),
	 table2016 as (select * from country_forest where year = '2016')
SELECT 
    table1990.country_name,
    table1990.total_forest_area_sqkm AS r1990,
    table2016.total_forest_area_sqkm AS r2016,
    table1990.total_forest_area_sqkm - table2016.total_forest_area_sqkm AS abs_change
FROM
    table1990
        JOIN
    table2016 ON table1990.country_name = table2016.country_name
WHERE
    table1990.total_forest_area_sqkm > table2016.total_forest_area_sqkm
ORDER BY abs_change DESC
LIMIT 6

 /*Which 5 countries saw the largest percent decrease in forest area from 1990 to 2016? What was the percent change to 2 decimal places for each?*/

WITH table1990 as (select* from country_forest1 where year = '1990'),
	 table2016 as (select * from country_forest1 where year = '2016')
     SELECT 
    table1990.country_name,
    table1990.region,
    table1990.total_forest_area_sqkm AS r1990,
    table2016.total_forest_area_sqkm AS r2016,
    (table2016.total_forest_area_sqkm - table1990.total_forest_area_sqkm) / table1990.total_forest_area_sqkm * 100 AS perc_change
FROM
    table1990
        JOIN
    table2016 ON table1990.country_name = table2016.country_name
ORDER BY perc_change
LIMIT 6

/*If countries were grouped by percent forestation in quartiles, which group had the most countries in it in 2016?*/
With table1 AS (SELECT fa.country_code,
                       fa.country_name,
                       fa.year,
                       fa.forest_area_sqkm,
                       la.total_area_sq_mi*2.59 AS total_area_sqkm,
                        (fa.forest_area_sqkm/(la.total_area_sq_mi*2.59))*100 AS fa_percent
                        FROM forest_area fa
                        JOIN land_area la
                        ON fa.country_code = la.country_code
                        AND (fa.country_name != 'World' AND fa.forest_area_sqkm IS NOT NULL AND la.total_area_sq_mi IS NOT NULL)
                        AND (fa.year=2016 AND la.year = 2016)
                        ORDER BY 6 DESC
                  ),
      table2 AS (SELECT table1.country_code,
                        table1.country_name,
                         table1.year,
                         table1.fa_percent,
                         CASE WHEN table1.fa_percent >= 75 THEN 4
                              WHEN table1.fa_percent < 75 AND table1.fa_percent >= 50 THEN 3
                              WHEN table1.fa_percent < 50 AND table1.fa_percent >=25 THEN 2
                              ELSE 1
                         END AS quartile
                         FROM table1 ORDER BY 5 DESC
                  )

SELECT table2.quartile,
       COUNT(table2.quartile)
       FROM table2
       GROUP BY 1
       ORDER BY 2 DESC;

       /*List all of the countries that were in the 4th quartile (percent forest > 75%) in 2016.*/

SELECT table2.country_name,
       r.region,
       table2.fa_percent,
       table2.quartile
       FROM table2
       join regions r on table2.country_code = r.country_code
                         where quartile = 4
       ORDER BY 3 DESC;

/* How many countries had a percent forestation higher than the United States in 2016? 
*/
With table1 AS (SELECT fa.country_code,
                       fa.country_name,
                       fa.year,
                       fa.forest_area_sqkm,
                       la.total_area_sq_mi*2.59 AS total_area_sqkm,
                        (fa.forest_area_sqkm/(la.total_area_sq_mi*2.59))*100 AS fa_percent
                        FROM forest_area fa
                        JOIN land_area la
                        ON fa.country_code = la.country_code
                        AND (fa.country_name != 'World' AND fa.forest_area_sqkm IS NOT NULL AND la.total_area_sq_mi IS NOT NULL)
                        AND (fa.year=2016 AND la.year = 2016)
                        ORDER BY 6 DESC
SELECT COUNT(table1.country_name)
      FROM table1
      WHERE table1.percent_fa > (SELECT table1.percent_fa
                                     FROM table1
                                     WHERE table1.country_name = 'United States'
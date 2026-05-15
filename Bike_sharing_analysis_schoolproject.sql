#3.1 Casual Vs. Registered Users
SELECT 
    SUM(casual) AS total_casual_rentals,
    SUM(registered) AS total_registered_rentals,
    SUM(total_rentals) AS total_rentals,
    ROUND(SUM(casual) * 100.0 / SUM(total_rentals), 2) AS casual_percent,
    ROUND(SUM(registered) * 100.0 / SUM(total_rentals), 2) AS registered_percent
FROM copy_of_cleaned_database_project;

#3.2 How does demand vary by season and weather conditions?
SELECT 
    season,
    weather,
    AVG(total_rentals) AS avg_rentals
FROM copy_of_cleaned_database_project
GROUP BY season, weather
ORDER BY season, weather;

#3.3 How do working days compare to non-working days in terms of rentals?
SELECT 
    CASE
        WHEN workingday = 1 THEN 'Working Day'
        ELSE 'Non-Working Day'
    END AS day_type,
    ROUND(AVG(total_rentals), 2) AS avg_rentals,
    SUM(total_rentals) AS total_rentals
FROM copy_of_cleaned_database_project
GROUP BY workingday
ORDER BY workingday;

#3.4 At what times of day is demand highest and lowest?
SELECT 
    TIME_FORMAT(time, '%H:%i') AS hour_of_day,
    ROUND(AVG(total_rentals), 2) AS avg_rentals,
    SUM(total_rentals) AS total_rentals
FROM copy_of_cleaned_database_project
GROUP BY time
ORDER BY avg_rentals DESC;

#3.5 How do temperature, humidity, and wind speed relate to bike rentals?
SELECT 
    AVG(temp) AS avg_temp,
    AVG(humidity) AS avg_humidity,
    AVG(windspeed) AS avg_windspeed,
    AVG(total_rentals) AS avg_rentals
FROM copy_of_cleaned_database_project;

#3.6 During which months is demand highest? Lowest?
SELECT 
    MONTH(date) AS month_number,
    MONTHNAME(date) AS month_name,
    ROUND(AVG(total_rentals), 2) AS avg_rentals,
    SUM(total_rentals) AS total_rentals
FROM copy_of_cleaned_database_project
GROUP BY MONTH(date), MONTHNAME(date)
ORDER BY avg_rentals DESC;

#3.7 Which user group (casual vs. registered) is more sensitive to weather conditions?
SELECT 
    CASE
        WHEN weather = 1 THEN 'Clear'
        WHEN weather = 2 THEN 'Mist/Cloudy'
        WHEN weather = 3 THEN 'Light Rain/Snow'
        WHEN weather = 4 THEN 'Severe Weather'
    END AS weather_name,
    ROUND(AVG(casual), 2) AS avg_casual,
    ROUND(AVG(registered), 2) AS avg_registered,
    ROUND(
        (AVG(casual) - 
            (SELECT AVG(casual) FROM copy_of_cleaned_database_project WHERE weather = 1)
        ) * 100.0 /
            (SELECT AVG(casual) FROM copy_of_cleaned_database_project WHERE weather = 1), 
    2) AS casual_percent_change_from_clear,
    ROUND(
        (AVG(registered) - 
            (SELECT AVG(registered) FROM copy_of_cleaned_database_project WHERE weather = 1)
        ) * 100.0 /
            (SELECT AVG(registered) FROM copy_of_cleaned_database_project WHERE weather = 1), 
    2) AS registered_percent_change_from_clear
FROM copy_of_cleaned_database_project
GROUP BY weather
ORDER BY weather;

#3.8  How does rental demand change as temperature increases or decreases? Is there an optimal temperature range for bike usage?
SELECT 
    CASE
        WHEN temp < 10 THEN 'Below 10°C'
        WHEN temp >= 10 AND temp < 20 THEN '10–19°C'
        WHEN temp >= 20 AND temp < 30 THEN '20–29°C'
        WHEN temp >= 30 AND temp < 35 THEN '30–34°C'
        ELSE '35°C+'
    END AS temp_range,
    ROUND(AVG(total_rentals), 2) AS avg_rentals,
    SUM(total_rentals) AS total_rentals
FROM copy_of_cleaned_database_project
GROUP BY 
    CASE
        WHEN temp < 10 THEN 'Below 10°C'
        WHEN temp >= 10 AND temp < 20 THEN '10–19°C'
        WHEN temp >= 20 AND temp < 30 THEN '20–29°C'
        WHEN temp >= 30 AND temp < 35 THEN '30–34°C'
        ELSE '35°C+'
    END
ORDER BY avg_rentals DESC;

#3.9 Do registered users show more consistent riding behavior than casual users across different weather conditions?
SELECT 
    CASE
        WHEN weather = 1 THEN 'Clear'
        WHEN weather = 2 THEN 'Mist/Cloudy'
        WHEN weather = 3 THEN 'Light Rain/Snow'
        WHEN weather = 4 THEN 'Severe Weather'
    END AS weather_name,
    ROUND(AVG(casual), 2) AS avg_casual,
    ROUND(STDDEV(casual), 2) AS sd_casual,
    ROUND(STDDEV(casual) / AVG(casual), 3) AS casual_cv,
    ROUND(AVG(registered), 2) AS avg_registered,
    ROUND(STDDEV(registered), 2) AS sd_registered,
    ROUND(STDDEV(registered) / AVG(registered), 3) AS registered_cv
FROM copy_of_cleaned_database_project
GROUP BY weather
ORDER BY weather;

#3.10 Which combination of factors (season, weather, working day, time of day) results in the highest average number of rentals?
SELECT 
    CASE
        WHEN season = 1 THEN 'Spring'
        WHEN season = 2 THEN 'Summer'
        WHEN season = 3 THEN 'Fall'
        WHEN season = 4 THEN 'Winter'
    END AS season_name,
    CASE
        WHEN weather = 1 THEN 'Clear'
        WHEN weather = 2 THEN 'Mist/Cloudy'
        WHEN weather = 3 THEN 'Light Rain/Snow'
        WHEN weather = 4 THEN 'Severe Weather'
    END AS weather_name,
    CASE
        WHEN workingday = 1 THEN 'Working Day'
        ELSE 'Non-Working Day'
    END AS day_type,
    CASE
        WHEN HOUR(time) BETWEEN 6 AND 11 THEN 'Morning'
        WHEN HOUR(time) BETWEEN 12 AND 16 THEN 'Afternoon'
        WHEN HOUR(time) BETWEEN 17 AND 21 THEN 'Evening'
        ELSE 'Night'
    END AS time_of_day,
    ROUND(AVG(total_rentals), 2) AS avg_rentals,
    SUM(total_rentals) AS total_rentals,
    COUNT(*) AS number_of_records
FROM copy_of_cleaned_database_project
GROUP BY season, weather, workingday, time_of_day
ORDER BY avg_rentals DESC
LIMIT 10;










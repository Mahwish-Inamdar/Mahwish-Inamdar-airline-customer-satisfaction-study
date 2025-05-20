-- Overall Customer Satisfaction Analysis
SELECT satisfaction, 
       COUNT(*) AS count,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM `my-first-project-441914.airline_satisfaction.customer_satisfaction_airline_analysis`
GROUP BY satisfaction
ORDER BY percentage DESC;


-- Satisfaction by Customer Type
SELECT customer_type, 
       satisfaction, 
       COUNT(*) AS count,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY customer_type), 2) AS percentage
FROM `my-first-project-441914.airline_satisfaction.customer_satisfaction_airline_analysis`
GROUP BY customer_type, satisfaction
ORDER BY customer_type, percentage DESC;


-- Satisfaction by Type of Travel
SELECT type_of_travel, 
       satisfaction, 
       COUNT(*) AS count,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY type_of_travel), 2) AS percentage
FROM `my-first-project-441914.airline_satisfaction.customer_satisfaction_airline_analysis`
GROUP BY type_of_travel, satisfaction
ORDER BY type_of_travel, percentage DESC;


-- Satisfaction by Class Type
SELECT class, 
       satisfaction, 
       COUNT(*) AS count,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY class), 2) AS percentage
FROM `my-first-project-441914.airline_satisfaction.customer_satisfaction_airline_analysis`
GROUP BY class, satisfaction
ORDER BY class, percentage DESC;


-- Service Ratings & Key Factors (Overall Average)
SELECT 
    AVG(departure_and_arrival_time_convenience) AS avg_departure_arrival_convenience,
    AVG(ease_of_online_booking) AS avg_online_booking,
    AVG(check_in_service) AS avg_check_in,
    AVG(online_boarding) AS avg_online_boarding,
    AVG(gate_location) AS avg_gate_location,
    AVG(on_board_service) AS avg_on_board_service,
    AVG(seat_comfort) AS avg_seat_comfort,
    AVG(leg_room_service) AS avg_leg_room,
    AVG(cleanliness) AS avg_cleanliness,
    AVG(food_and_drink) AS avg_food_drink,
    AVG(in_flight_service) AS avg_in_flight_service,
    AVG(in_flight_wifi_service) AS avg_wifi_service,
    AVG(in_flight_entertainment) AS avg_entertainment,
    AVG(baggage_handling) AS avg_baggage_handling
FROM `my-first-project-441914.airline_satisfaction.customer_satisfaction_airline_analysis`;


-- Service Ratings by Class Type
SELECT 
    class,
    ROUND(AVG(departure_and_arrival_time_convenience), 2) AS avg_departure_arrival_time,
    ROUND(AVG(ease_of_online_booking), 2) AS avg_online_booking,
    ROUND(AVG(check_in_service), 2) AS avg_checkin_service,
    ROUND(AVG(online_boarding), 2) AS avg_online_boarding,
    ROUND(AVG(gate_location), 2) AS avg_gate_location,
    ROUND(AVG(on_board_service), 2) AS avg_onboard_service,
    ROUND(AVG(seat_comfort), 2) AS avg_seat_comfort,
    ROUND(AVG(leg_room_service), 2) AS avg_legroom_service,
    ROUND(AVG(cleanliness), 2) AS avg_cleanliness,
    ROUND(AVG(food_and_drink), 2) AS avg_food_drink,
    ROUND(AVG(in_flight_service), 2) AS avg_inflight_service,
    ROUND(AVG(in_flight_wifi_service), 2) AS avg_wifi_service,
    ROUND(AVG(in_flight_entertainment), 2) AS avg_entertainment,
    ROUND(AVG(baggage_handling), 2) AS avg_baggage_handling
FROM my-first-project-441914.airline_satisfaction.customer_satisfaction_airline_analysis
WHERE class IN ('Economy', 'Economy Plus', 'Business')  -- Fix class names
GROUP BY class
ORDER BY 
    CASE 
        WHEN class = 'Business' THEN 1
        WHEN class = 'Economy Plus' THEN 2
        WHEN class = 'Economy' THEN 3
    END;


-- Age-Based Customer Satisfaction Analysis
SELECT age_group, 
       satisfaction, 
       COUNT(*) AS count
FROM (
    SELECT CASE 
               WHEN age BETWEEN 18 AND 25 THEN '18-25'
               WHEN age BETWEEN 26 AND 35 THEN '26-35'
               WHEN age BETWEEN 36 AND 45 THEN '36-45'
               WHEN age BETWEEN 46 AND 60 THEN '46-60'
               ELSE '60+' 
           END AS age_group,
           satisfaction
    FROM `my-first-project-441914.airline_satisfaction.customer_satisfaction_airline_analysis`
) AS age_data
WHERE satisfaction = 'Neutral or Dissatisfied'
GROUP BY age_group, satisfaction
ORDER BY count ASC;



-- Gender-Based Customer Satisfaction Analysis
SELECT gender, 
       satisfaction, 
       COUNT(*) AS count,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY gender), 2) AS percentage
FROM `my-first-project-441914.airline_satisfaction.customer_satisfaction_airline_analysis`
GROUP BY gender, satisfaction
ORDER BY gender, percentage DESC;



-- Impact of Travel Distance on Customer Satisfaction
SELECT satisfaction, 
       AVG(flight_distance) AS avg_distance
FROM `my-first-project-441914.airline_satisfaction.customer_satisfaction_airline_analysis`
GROUP BY satisfaction;



-- Service Factor Comparison: Long vs. Short Distance
WITH MedianDistance AS (
  SELECT APPROX_QUANTILES(flight_distance, 2)[OFFSET(1)] AS median_distance
  FROM `my-first-project-441914.airline_satisfaction.customer_satisfaction_airline_analysis`
)
SELECT 
  CASE 
    WHEN flight_distance <= (SELECT median_distance FROM MedianDistance) THEN 'Short Distance'
    ELSE 'Long Distance'
  END AS distance_category,
  AVG(departure_and_arrival_time_convenience) AS avg_departure_convenience,
  AVG(ease_of_online_booking) AS avg_online_booking,
  AVG(check_in_service) AS avg_checkin_service,
  AVG(online_boarding) AS avg_online_boarding,
  AVG(gate_location) AS avg_gate_location,
  AVG(on_board_service) AS avg_onboard_service,
  AVG(seat_comfort) AS avg_seat_comfort,
  AVG(leg_room_service) AS avg_legroom,
  AVG(cleanliness) AS avg_cleanliness,
  AVG(food_and_drink) AS avg_food_drink,
  AVG(in_flight_service) AS avg_in_flight_service,
  AVG(in_flight_wifi_service) AS avg_wifi_service,
  AVG(in_flight_entertainment) AS avg_entertainment,
  AVG(baggage_handling) AS avg_baggage_handling
FROM `my-first-project-441914.airline_satisfaction.customer_satisfaction_airline_analysis`
GROUP BY distance_category;



-- Impact of Flight Delays on Customer Satisfaction
SELECT 
  CASE 
    WHEN arrival_delay <= 15 THEN '0-15 min'
    WHEN arrival_delay <= 30 THEN '16-30 min'
    WHEN arrival_delay <= 60 THEN '31-60 min'
    WHEN arrival_delay <= 120 THEN '61-120 min'
    ELSE '120+ min'
  END AS delay_category,
  class, 
  AVG(total_satisfaction_level) AS avg_satisfaction
FROM `my-first-project-441914.airline_satisfaction.customer_satisfaction_airline_analysis`
WHERE arrival_delay IS NOT NULL
GROUP BY 1, 2
ORDER BY 
  CASE delay_category 
    WHEN '0-15 min' THEN 1 
    WHEN '16-30 min' THEN 2 
    WHEN '31-60 min' THEN 3 
    WHEN '61-120 min' THEN 4 
    ELSE 5 
  END;

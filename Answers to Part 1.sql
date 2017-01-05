--Part 1 ­ SQL Syntax
--[2 points]
--Given the below subset of Uber’s schema, write executable SQL queries to answer the questions below. Please answer in a single query for each question and assume read­only access to the database (i.e. do not use CREATE TABLE).
--1. For the last 30 days deduce the mean and median difference between Actual 
--and Predicted ETA of all trips in the cities of ‘Qarth’ and ‘Meereen’

select a.join_key, a.mean_difference,b.media_difference from

(select join_key, avg(difference_in_time) as mean_difference from(

select (a.actual_eta-a.predicte_eta) as difference_in_time,
'x' as join_key

from
trips a
join
cities b
on a.city_id=b.city_id

where b.city_name in ('Qarth','Meereen')  ----- for only the mentioned cities
	and a.request_at > now()-interval '30 days'  ---- for the last 30 days
	and a.status='completed'
) a 

GROUP by join_key ) a --- has the mean value

join 

(select join_key,median_difference from   
( SELECT join_key,
  MAX(difference_difference_in_time) as median_diiference from 
  (
    SELECT 'x' as join_key
     (a.actual_eta-a.predicte_eta) as difference_in_time ,
      ntile(2) OVER (ORDER BY difference_in_time) AS bucket
    FROM
      trips a
join
cities b
on a.city_id=b.city_id

where b.city_name in ('Qarth','Meereen')  ----- for only the mentioned cities
	and a.request_at > now()-interval '30 days'  ---- for the last 30 days
	and a.status='completed'
  ) as t
WHERE bucket = 1
GROUP BY bucket,join_key) a

) b

on a.join_key=b.join_key

--2.An event is logged in the events table with a timestamp each time a 
--new rider attempts a sign up (with an event name 'attempted_sign_up') 
--or successfully signs up (with an event name of 'sign_up_success'). 
--For all riders signing up successfully in ‘Qarth’ and ‘Meereen’ in the first of week of 2016, 
--find in each city for each day of the week, the percentage of riders
--who then complete a trip within 168 hours of the sign up date.


select trip_completed_168, 
(trips_168.num_riders_completed/riders.num_tot_riders) as percentage_of_riders_who_complete_in168hours

from

(select count(distinct riders.rider_id) as num_riders_completed, 'x' as trip_completed_168 
from
(select rider_id,ts

from events a
join
cities b
on a.city_id=b.city_id

where b.city_name in in ('Qarth','Meereen')  ----- for only the mentioned cities
and a.ts>='2016-01-01' and a.ts<='2016-01-07'  ----- first week of 2016
and a.event_name='sign_up_success'
) riders
join

trips b

on riders.rider_id=b.rider_id
where

b.status='completed' --- trips completed
and (b.request_at+b.actual_eta)<riders.ts + interval '168 hours' ---- trips within 168 hours
) trips_168


join

(select count(distinct rider_id) as num_tot_riders, 'x' as all_riders

from events a
join
cities b
on a.city_id=b.city_id

where b.city_name in in ('Qarth','Meereen')  ----- for only the mentioned cities
and a.ts>='2016-01-01' and a.ts<='2016-01-07'  ----- first week of 2016
and a.event_name='sign_up_success'
) riders

on 

riders.all_riders=trips_168.trip_completed_168


--Part 1:

--1. Between Oct 1, 2013 at 10am PDT and Oct 22, 2013 at 5pm PDT, what percentage of
--requests made by unbanned clients each day were canceled in each city?
--2. For city_ids 1, 6, and 12, list the top three drivers by number of completed trips for each
--week between June 3, 2013 and June 24, 2013.


--1. Answer to question 1

select a.request, a.cancelled_requests/b.requests as percent_of_cancelled_req from -----comment percent of cancelled request

(select 'requests' as request, count(distinct id) as cancelled_requests ---comment- taking distinct request to make sure that there aren't any duplicate requests
from trips t
join users u
t.client_id=u.userid
where
date_trunc('hour',t.request_at)>='2013-10-01 18:00:00' and date_trunc('hour',t.request_at)<='2013-10-23 01:00:00' ---comment using PDT for UTC
u.banned='F' ---comment unnbanned users
and t.status in (ëcancelled_by_driverí,'cancelled_by_client') ----comment cancelled requests
group by request
) a

join


(select 'requests' as request,
count( distinct id) as requests ---comment- taking distinct request to make sure that there aren't any duplicate requests
from trips t
join users u
t.client_id=u.userid
where
date_trunc('hour',t.request_at)>='2013-10-01 18:00:00' and date_trunc('hour',t.request_at)<='2013-10-23 01:00:00' ---comment using PDT for UTC
u.banned='F' ---comment unnbanned users
group by request
) b

on a.request=b.request



---2a. Assuming the question is asking for top 3 drivers in cities 1,6 and 12 combined


select u.userid as drivers,count(id) as num_trips from trips t
join users u
t.driver_id=u.userid
where
date_trunc('day',t.request_at)>='2013-06-03 00:00:00' and date_trunc('day',t.request_at)<='2013-06-24 00:00:00' ---comment assuming the question is for UTC
and u.signup_city_id in (1,6,12)   ---- comment for the cities 1,6 and 12
and t.status='completed'

group by drivers
order by num_trips desc limit 3 --- comment top 3 drivers in the 3 cities combined

--2b. Assuming the question is asking for top 3 drivers in each of cities 1,6 and 12

select a.city,a.userid as top_driver_city_1,b.userid as top_driver_city_6, c.userid as top_driver_city_12

(select 'city' as city, u.userid as drivers,count(id) as num_trips from trips t
join users u
t.driver_id=u.userid
where
date_trunc('day',t.request_at)>='2013-06-03 00:00:00' and date_trunc('day',t.request_at)<='2013-06-24 00:00:00' ---comment assuming the question is for UTC
and u.signup_city_id=1 ---- comment for the city 1
and t.status='completed'
group by city, drivers
order by num_trips desc limit 3 --- comment top 3 drivers in city 1
) a

join

(select 'city' as city, u.userid as drivers,count(id) as num_trips from trips t
join users u
t.driver_id=u.userid
where
date_trunc('day',t.request_at)>='2013-06-03 00:00:00' and date_trunc('day',t.request_at)<='2013-06-24 00:00:00' ---comment assuming the question is for UTC
and u.signup_city_id=6 ---- comment for city 6
and t.status='completed'
group by city, drivers
order by num_trips desc limit 3 --- comment top 3 drivers in city 6
) b

on a.city=b.city

join


(select 'city' as city, u.userid as drivers,count(id) as num_trips from trips t
join users u
t.driver_id=u.userid
where
date_trunc('day',t.request_at)>='2013-06-03 00:00:00' and date_trunc('day',t.request_at)<='2013-06-24 00:00:00' ---comment assuming the question is for UTC
and u.signup_city_id=12 ---- comment for city 12
and t.status='completed'
group by city, drivers
order by num_trips desc limit 3 --- comment top 3 drivers in city 12
) c

on c.city=b.city

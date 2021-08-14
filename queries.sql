-- Q1: what has been the search trend of people over time 

-- Find min, max to see what period of time is in data exactly
--    min     |    max     
-- ------------+------------
--  2020-03-02 | 2020-06-29

-- select min(date), max(date) from searchtrend;



-- Split by months: 03, 04-05, 06

-- 30 rows
drop view if exists march_search_trend cascade;
create view march_search_trend as
select *
from searchtrend
where extract(month from date) = '03';

-- 61 rows
drop view if exists april_may_search_trend cascade;
create view april_may_search_trend as
select *
from searchtrend
where extract(month from date) = '04' or extract(month from date) = '05';

-- 29 rows
drop view if exists june_search_trend cascade;
create view june_search_trend as
select *
from searchtrend
where extract(month from date) = '06';



-- Confirm all rows across views
-- expect 120
-- actual 61+29+30 =120
-- select count(*) from searchtrend;


-- Recall search trend for each word is an index
-- the higher the index the higher the search trend


-- RESULT MARCH:
--  cold_march | pneumonia_march | coronavirus_march 
-- ----------+---------------+-----------------
--  19.64762 |       9.00304 |       607.46175
select sum(cold) as cold_march, sum(pneumonia) as pneumonia_march, sum(coronavirus) as coronavirus_march
from march_search_trend;


-- RESULT APRIL - MAY:
-- cold_april_may | pneumonia_april_may | coronavirus_april_may 
-- ----------+---------------+-----------------
--   8.94097 |       6.61432 |       297.03866

select sum(cold) as cold_april_may, sum(pneumonia) as pneumonia_april_may, sum(coronavirus) as coronavirus_april_may
from april_may_search_trend;


-- RESULT JUNE:
--  cold_june | pneumonia_june | coronavirus_june 
-- ----------+---------------+-----------------
--   3.10016 |       3.29486 |        78.62803

select sum(cold) as cold_june, sum(pneumonia) as pneumonia_june, sum(coronavirus) as coronavirus_june
from june_search_trend;


-- Q2: which groups of people have been most affected - Gender


-- select * 
-- from patientprofileInfo
-- order by sex;

-- Total num rows: 5164
select count(*)
from patientprofileInfo;

-- Total num rows where sex is not null: 4042
-- i.e. 5164 - 4042 = 1122 are null
select count(*)
from patientprofileInfo
where sex is not null;


-- patient info by gender (roughly similar, but more female)
-- female |         2217 | 54.8490846115784
--  male   |         1825 | 45.1509153884216

-- RESULT
select sex, count(*) as num_patients, (count(*) / 4042::float) * 100 as percentage
from patientprofileInfo
group by sex
having sex is not null;


-- Q2: which groups of people have been most affected - Region

-- select * 
-- from patientregioninfo
-- order by city;

-- 162 diff korean cities (not including null, with null it's 163)
drop view if exists koreancities cascade;
create view koreancities as
select distinct city
from patientregioninfo
where country  = 'Korea' and city is not null;


-- weird country entries 
-- eg Jongno-gu shows up as a city in Korea, Canada, US
-- select distinct  city, country 
-- from patientregioninfo
-- where city is not null
-- and country <> 'Korea';

-- Notice: 5164 total rows in patientregioninfo
-- select count(*)
-- from patientregioninfo;


-- Patient region info for korean cities only
-- 5069 rows
drop view if exists patientregioninfo_koreancities cascade;
create view patientregioninfo_koreancities as
select p.*
-- no null in koreancities => no null cities match
from patientregioninfo p join koreancities c
on p.city = c.city;




-- num patients by city in korea
drop view if exists num_patients_by_city cascade;
create view num_patients_by_city as 
select city, count(*) as num_patients
from patientregioninfo_koreancities
group by city;

-- 5069 patientes confirmed
-- select sum(num_patients)
-- from num_patients_by_city;

drop view if exists num_patients_and_percentage_by_city cascade;
create view num_patients_and_percentage_by_city as
select city, num_patients, (num_patients / 5069::float) * 100 as percentage_in_korea
from num_patients_by_city;

-- confirmed 100 percent
-- select sum(percentage_in_korea)
-- from num_patients_and_percentage_by_city;


-- top 3 cities max:
-----------------+--------------+---------------------
--  Gyeongsan-si    |          639 |    12.6060366936279
--  Seongnam-si     |          173 |    3.41290195304794
--  Bucheon-si      |          162 |    3.19589662655356

-- top 3 cities min:
--  Gyeongju-si     |           52 |    1.02584336160978
--  Chilgok-gun     |           51 |    1.00611560465575
--  Yongsan-gu      |           50 |   0.986387847701716

-- RESULT
select *
from num_patients_and_percentage_by_city
order by percentage_in_korea desc limit 20;


--Q3 How have the implemented policies influenced the number of cases

--all test cases and number of infected and negated cases

select * from covidstatovertime order by test desc limit 1;


-- creating view for mating test cases, number of infected peoples with the start date of -- the policies
drop view if exists beforePolicy cascade;
create view beforePolicy as 
select covidstatovertime.*, policyid, type, govpolicy, startdate  
from covidstatovertime join policy on date=startdate;


-- cresting view for end date of the policies
drop view if exists afterPolicy cascade;
create view afterPolicy as 
select covidstatovertime.*, policyid, type, govpolicy, enddate  
from covidstatovertime join policy on date=endDate;


-- 3rd view to see the difference in number of infected people between	start and end dates, also number of tests run during the period when policy was in effect. 
drop view if exists difference cascade;
Create view difference as 
select a.test - b.test as test, a.negative - b.negative as negative,
a.confirmed-b.confirmed as confirmed, a.released-b.released released,
a.policyid, a.type, a.govpolicy from afterpolicy a join beforepolicy b using(policyid);		


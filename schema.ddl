
drop schema if exists projectschema cascade; 
create schema projectschema;
set search_path to projectschema; 

-- IC's:
-- PatientInfectionInfo[patientid] ⊆ PatientProfileInfo[patientid]
-- PatientInfectionInfo[infectedBy] ⊆ PatientProfileInfo[patientid]
-- PatientRegionInfo[patientid] ⊆ PatientProfileInfo[patientid]

-- PatientProfileInfo(patientid, sex, age)
-- patientid example: '1000000001'
-- sex: 'male' or 'female'
-- age: '20s', '30s', etc
create table PatientProfileInfo (
patientid varchar(50), 
sex varchar(20), 
age varchar(20),
primary key (patientid));



-- PatientInfectionInfo(patientid, infection_case, infected_by, number_of_contacts, symptom_onset_date)
-- patientid example: '1000000001'
-- infection_case example: 'overseas inflow'
-- infected_by example: 1000000001
-- number_of_contacts: 1,2,3, etc
-- symptom_onset_date example: 2020-02-06
create table PatientInfectionInfo (
patientid varchar(50),
infection_case text, 
infected_by varchar(50),
number_of_contacts integer check (number_of_contacts >=0),
symptom_onset_date date,
primary key (patientid),
foreign key (patientid) references PatientProfileInfo(patientid),
foreign key (infected_by) references PatientProfileInfo(patientid));



-- PatientRegionInfo(patientid, country, province, city)
-- patientid example: '1000000001'
-- country example: 'Korea'
-- province example: 'Seoul'
-- city example: 'Seongdong-gu'
create table PatientRegionInfo (
patientid varchar(50), 
country varchar(50),
province varchar(50), 
city varchar(50),
primary key (patientid),
foreign key (patientid) references PatientProfileInfo);

-- This table represents search trend during the target period 
--and each value shows search volume of that word on given date 
-- SearchTrend(date, cold, pneumonia,coronavirus)
-- date example: '2020-04-10'
-- cold example: 10.55
-- pneumonia example: 2.5
-- coronavirus example: 5.8
create table SearchTrend(
    date date primary key,
    cold float not null,
    pneumonia float not null,
    coronavirus float not null,
    check (cold >= 0 AND pneumonia >= 0 AND coronavirus>=0),
    check(date> '2020-03-01') 
    );



-- number of tested(both positive and negative) poeple 
-- CovidStatOverTime(date, test, negative, confirmed, released)
-- test example: 1,2,3
-- negative example: 10,50,80
-- confirmed example: 4,89,14
-- released example: 4,8,6
create table CovidStatOverTime(
    date date primary key,
    test int not null,
    negative int not null,
    confirmed int not null,
    released int not null,
    check(test >= 0 AND negative >= 0 AND confirmed >= 0 AND released >= 0),
    check(date> '2020-03-01')
);





-- Policies that were adapted 
-- Policy(policyID, type, govPolicy, detail, startDate, endDate)
-- date example: '2020-04-10'
-- type example: 'Alert', 'Immigration'
-- govPolicy example: 'Infectious Disease Alert Level', 'Special Immigration Procedure'
-- detail example: 'Level 2 (Yellow)', 'Level 4 (Red)'
-- startDate: '2020-01-20'
-- endDate: '2021-01-20'
create table Policy(
    policyID int primary key,
    type text not null,
    govPolicy text not null,
    detail text not null,
    startDate date not null,
    endDate date not null,
    check(startDate < endDate),
    check(startDate> '2020-03-01')
);


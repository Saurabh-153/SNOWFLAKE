-- Processing semi-structured data (Ex.JSON Data)

--Creating required schemas
CREATE OR REPLACE SCHEMA MYDB.external_stages;
CREATE OR REPLACE SCHEMA MYDB.STAGE_TBLS;
CREATE OR REPLACE SCHEMA MYDB.INTG_TBLS;
CREATE OR REPLACE SCHEMA MYDB.FILE_FORMATS;

--Creating file format object
CREATE OR REPLACE FILE FORMAT MYDB.file_formats.FILE_FORMAT_JSON
	TYPE = JSON;

--Creating stage object
CREATE OR REPLACE STAGE MYDB.external_stages.STAGE_JSON
    STORAGE_INTEGRATION = s3_int
    URL = 's3://sau-s3-snowflake/json/';

--Listing files in the stage
LIST @MYDB.external_stages.STAGE_JSON;

--Creating Stage Table to store RAW Data	
CREATE OR REPLACE TABLE MYDB.STAGE_TBLS.PETS_DATA_JSON_RAW 
(raw_file variant);


--Copy the RAW data into a Stage Table
COPY INTO MYDB.STAGE_TBLS.PETS_DATA_JSON_RAW 
    FROM @MYDB.external_stages.STAGE_JSON
    file_format= MYDB.file_formats.FILE_FORMAT_JSON
    FILES=('pets_data.json');

--View RAW table data
SELECT * FROM MYDB.STAGE_TBLS.PETS_DATA_JSON_RAW;

--Extracting single column
SELECT raw_file:Name::string as Name FROM MYDB.STAGE_TBLS.PETS_DATA_JSON_RAW;

--Extracting Array data
SELECT raw_file:Name::string as Name,
       raw_file:Pets[0]::string as Pet 
FROM MYDB.STAGE_TBLS.PETS_DATA_JSON_RAW;

--Get the size of ARRAY
SELECT raw_file:Name::string as Name, ARRAY_SIZE(RAW_FILE:Pets) as PETS_AR_SIZE 
FROM MYDB.STAGE_TBLS.PETS_DATA_JSON_RAW;

SELECT max(ARRAY_SIZE(RAW_FILE:Pets)) as PETS_AR_SIZE 
FROM MYDB.STAGE_TBLS.PETS_DATA_JSON_RAW;

--Extracting nested data
SELECT raw_file:Name::string as Name,
       raw_file:Address."House Number"::string as House_No,
       raw_file:Address.City::string as City,
       raw_file:Address.State::string as State
FROM MYDB.STAGE_TBLS.PETS_DATA_JSON_RAW;

--Parsing entire file
SELECT raw_file:Name::string as Name,
       raw_file:Gender::string as Gender,
       raw_file:DOB::date as DOB,
       raw_file:Pets[0]::string as Pets,
       raw_file:Address."House Number"::string as House_No,
	   raw_file:Address.City::string as City,
	   raw_file:Address.State::string as State,
	   raw_file:Phone.Work::number as Work_Phone,
	   raw_file:Phone.Mobile::number as Mobile_Phone
from MYDB.STAGE_TBLS.PETS_DATA_JSON_RAW
UNION ALL
SELECT raw_file:Name::string as Name,
       raw_file:Gender::string as Gender,
       raw_file:DOB::date as DOB,
       raw_file:Pets[1]::string as Pets,
       raw_file:Address."House Number"::string as House_No,
	   raw_file:Address.City::string as City,
	   raw_file:Address.State::string as State,
	   raw_file:Phone.Work::number as Work_Phone,
	   raw_file:Phone.Mobile::number as Mobile_Phone
from MYDB.STAGE_TBLS.PETS_DATA_JSON_RAW
UNION ALL
SELECT raw_file:Name::string as Name,
       raw_file:Gender::string as Gender,
       raw_file:DOB::date as DOB,
       raw_file:Pets[2]::string as Pets,
       raw_file:Address."House Number"::string as House_No,
	   raw_file:Address.City::string as City,
	   raw_file:Address.State::string as State,
	   raw_file:Phone.Work::number as Work_Phone,
	   raw_file:Phone.Mobile::number as Mobile_Phone
from MYDB.STAGE_TBLS.PETS_DATA_JSON_RAW
WHERE Pets is not null;

--Creating/Loading parsed data to another table
CREATE TABLE MYDB.INTG_TBLS.PETS_DATA
AS
SELECT raw_file:Name::string as Name,
       raw_file:Gender::string as Gender,
       raw_file:DOB::date as DOB,
       raw_file:Pets[0]::string as Pets,
       raw_file:Address."House Number"::string as House_No,
	   raw_file:Address.City::string as City,
	   raw_file:Address.State::string as State,
	   raw_file:Phone.Work::number as Work_Phone,
	   raw_file:Phone.Mobile::number as Mobile_Phone
from MYDB.STAGE_TBLS.PETS_DATA_JSON_RAW
UNION ALL
SELECT raw_file:Name::string as Name,
       raw_file:Gender::string as Gender,
       raw_file:DOB::date as DOB,
       raw_file:Pets[1]::string as Pets,
       raw_file:Address."House Number"::string as House_No,
	   raw_file:Address.City::string as City,
	   raw_file:Address.State::string as State,
	   raw_file:Phone.Work::number as Work_Phone,
	   raw_file:Phone.Mobile::number as Mobile_Phone
from MYDB.STAGE_TBLS.PETS_DATA_JSON_RAW
UNION ALL
SELECT raw_file:Name::string as Name,
       raw_file:Gender::string as Gender,
       raw_file:DOB::date as DOB,
       raw_file:Pets[2]::string as Pets,
       raw_file:Address."House Number"::string as House_No,
	   raw_file:Address.City::string as City,
	   raw_file:Address.State::string as State,
	   raw_file:Phone.Work::number as Work_Phone,
	   raw_file:Phone.Mobile::number as Mobile_Phone
from MYDB.STAGE_TBLS.PETS_DATA_JSON_RAW
WHERE Pets is not null;

--Viewing final data
SELECT * from MYDB.INTG_TBLS.PETS_DATA;

--Truncate and Reload by using flatten

TRUNCATE TABLE MYDB.INTG_TBLS.PETS_DATA;

INSERT INTO MYDB.INTG_TBLS.PETS_DATA
select  
       raw_file:Name::string as Name,
       raw_file:Gender::string as Gender,
       raw_file:DOB::date as DOB,
       f1.value::string as Pet,
       raw_file:Address."House Number"::string as House_No,
	   raw_file:Address.City::string as City,
	   raw_file:Address.State::string as State,
	   raw_file:Phone.Work::number as Work_Phone,
	   raw_file:Phone.Mobile::number as Mobile_Phone
FROM MYDB.STAGE_TBLS.PETS_DATA_JSON_RAW, 
table(flatten(raw_file:Pets)) f1;


--Viewing final data
SELECT * from MYDB.INTG_TBLS.PETS_DATA;
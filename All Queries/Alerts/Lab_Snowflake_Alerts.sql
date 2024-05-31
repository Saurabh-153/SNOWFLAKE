-- Create Database and Schemas required
CREATE DATABASE IF NOT EXISTS EMP;
CREATE SCHEMA IF NOT EXISTS EMP.hrdata;

-- Create employees Table
CREATE TABLE hrdata.employees
   ( employee_id NUMBER(6)
   , first_name VARCHAR(20)
   , last_name VARCHAR(25) NOT NULL
   , email VARCHAR(25) NOT NULL
   , phone_number VARCHAR(20)
   , hire_date DATE NOT NULL
   , job_id VARCHAR(10) NOT NULL
   , salary NUMBER(8,2)
   , commission_pct NUMBER(2,2)
   , manager_id NUMBER(6)
   , dept_id NUMBER(4)
   , PRIMARY KEY (employee_id)
   ) ; 

-- Create high_salaried employees table
CREATE OR REPLACE TABLE hrdata.high_salaried_emp
   ( employee_id NUMBER(6), salary NUMBER(6), insert_ts TIMESTAMP_NTZ(9));

-- Create an Alert to store High salaried employees(salary > 30000)
CREATE OR REPLACE ALERT hrdata.alert_high_salary
   WAREHOUSE = compute_wh
  SCHEDULE = '1 minute'
  IF( EXISTS(
    SELECT employee_id, salary FROM hrdata.employees WHERE salary > 30000))
  THEN
    INSERT OVERWRITE INTO hrdata.high_salaried_emp 
    SELECT employee_id, salary, CURRENT_TIMESTAMP() FROM hrdata.employees WHERE salary > 30000; 
	
   
-- Now Insert some data
INSERT INTO hrdata.employees VALUES 
( 100,  'Ramana',  'Rao',  'RRAO',  '420.271.4567',  TO_DATE('17-JUN-1987', 'dd-MON-yyyy'),  'ADM_PRES',  32000,  NULL,  NULL,  90),
   ( 101,  'Devi',  'Kapoor',  'DKAPOOR',  '420.271.4568',  TO_DATE('21-SEP-1989', 'dd-MON-yyyy'),  'ADM_VP',  17000,  NULL,  100,  90),
   ( 102,  'Nagesh',  'Reddy',  'RNAGESH',  '420.271.4569',  TO_DATE('13-JAN-1993', 'dd-MON-yyyy'),  'ADM_VP',  17000,  NULL,  100,  90),
   ( 103,  'Ranga',  'Rayudu',  'RRANGA',  '590.423.4567',  TO_DATE('03-JAN-1990', 'dd-MON-yyyy'),  'IT_PRG',  9000,  NULL,  102,  60),
   ( 104,  'Sivarama',  'Krishna',  'SKRISHNA',  '590.423.4568',  TO_DATE('21-MAY-1991', 'dd-MON-yyyy'),  'IT_PRG',  6000,  NULL,  103,  60),
   ( 105,  'Shoban',  'Reddy',  'RSHOBAN',  '590.423.4569',  TO_DATE('25-JUN-1997', 'dd-MON-yyyy'),  'IT_PRG',  4800,  NULL,  103,  60),
   ( 106,  'Jamuna',  'Kumari',  'KJAMUNA',  '590.423.4560',  TO_DATE('05-FEB-1998', 'dd-MON-yyyy'),  'IT_PRG',  4800,  NULL,  103,  60),
   ( 107,  'Jaya',  'Prakash',  'PJAYA',  '590.423.5567',  TO_DATE('07-FEB-1999', 'dd-MON-yyyy'),  'IT_PRG',  4200,  NULL,  103,  60),
   ( 108,  'Raja',  'Krishna',  'RKRISHNA',  '613.234.4569',  TO_DATE('17-AUG-1994', 'dd-MON-yyyy'),  'GI_MGR',  12000,  NULL,  101,  100),
   ( 109,  'Mohan',  'Chandra',  'MCHANDRA',  '613.234.4169',  TO_DATE('16-AUG-1994', 'dd-MON-yyyy'),  'GI_ACCOUNT',  9000,  NULL,  108,  100)
;

-- Check the data after a minute 
SELECT * FROM hrdata.high_salaried_emp;

SELECT * FROM hrdata.employees WHERE salary > 30000;

-- Start the Alert
ALTER ALERT hrdata.alert_high_salary RESUME;

-- Now check the data
SELECT * FROM hrdata.high_salaried_emp;


-- Now insert 2 more records
INSERT INTO hrdata.employees VALUES 
( 501,  'Narayan',  'Patil',  'NPATIL',  '420.271.4567',  TO_DATE('22-SEP-1989', 'dd-MON-yyyy'),  'ADM_PRES',  37500,  NULL,  NULL,  90),
( 502,  'Paresh',  'Raval',  'PRAVAL',  '420.271.4567',  TO_DATE('09-NOV-1988', 'dd-MON-yyyy'),  'ADM_PRES',  29000,  NULL,  NULL,  90);

-- Check data after a minute or Execute immediately
EXECUTE ALERT hrdata.alert_high_salary;

SELECT * FROM hrdata.high_salaried_emp;

-- Suspend the Alert, otherwise it will consume warehouse for every minute.
ALTER ALERT hrdata.alert_high_salary SUSPEND;

-- See all Alerts
SHOW ALERTS;

-- Drop Alert
DROP ALERT hrdata.alert_high_salary;

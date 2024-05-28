Assuming..
1. You have AWS account and s3 bucket created
2. AWS - Snowflake integration done
3. Files uploaded to diff folders in s3 bucket

-- I have explained all above steps in AWS - Snowflake integration video

-- Create database and schemas required
create database if not exists mydb;
create schema if not exists mydb.external_stages;
create schema if not exists mydb.staging;
create schema if not exists mydb.control;

-- Create the control table with data load details
CREATE or REPLACE TABLE mydb.control.copy_ctrl
(
stage_table_name string,
schema_name string,
database_name string,
storage_int string,
storage_loc string,
files_typ string,
files_pattern string,
field_delim string,
on_error string,
skip_header int,
force boolean,
truncate_cols boolean,
is_active boolean,
PRIMARY KEY(stage_table_name, schema_name, database_name)
);

-- Create target tables
CREATE OR REPLACE TABLE mydb.staging.customer_data 
(
customerid NUMBER,
custname STRING,
email STRING,
city STRING,
state STRING,
DOB DATE
);

CREATE OR REPLACE TABLE mydb.staging.pets_data_raw 
(raw_file variant);

CREATE OR REPLACE TABLE mydb.staging.emp_data 
(
  id INT,
  first_name STRING,
  last_name STRING,
  email STRING,
  location STRING,
  department STRING
);

CREATE OR REPLACE TABLE mydb.staging.customer
(
customerid NUMBER,
custname STRING,
email STRING,
city STRING,
state STRING,
DOB DATE
);

-- Insert entries into Control table
DELETE FROM mydb.control.copy_ctrl;

INSERT INTO mydb.control.copy_ctrl VALUES
('customer_data', 'staging', 'mydb', 's3_int', 's3://awss3bucketjana/csv/', 'csv', '.*customer.*', '|', 'CONTINUE', 1, True, True, True),
('pets_data_raw', 'staging', 'mydb', 's3_int', 's3://awss3bucketjana/json/', 'json', '.*pets_data.*', Null, 'CONTINUE', Null, True, True, True),
('emp_data', 'staging', 'mydb', 's3_int', 's3://awss3bucketjana/pipes/csv/', 'csv', '.*sp_employee.*', '\,', 'CONTINUE', 1, True, True, True),
('customer', 'staging', 'mydb', 's3_int', 's3://awss3bucketjana/files/', 'csv', '.*customer_.*', '|', 'CONTINUE', 1, True, True, True)
;

select * from mydb.control.copy_ctrl;

/*
truncate table mydb.staging.customer_data;
truncate table mydb.staging.pets_data_raw;
truncate table mydb.staging.emp_data;
truncate table mydb.staging.customer;
*/
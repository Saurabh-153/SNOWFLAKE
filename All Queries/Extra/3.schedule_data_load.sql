-- Automate this process to run every day
CREATE OR REPLACE TASK staging.task_automate_data_load
SCHEDULE = 'USING CRON 0 7 * * * UTC'
AS
call mydb.staging.sp_automate_data_copy()
;

-- Process different files at diff timings
CREATE OR REPLACE PROCEDURE mydb.staging.sp_automate_data_copy("table_name" varchar)

curs cursor for SELECT * FROM mydb.control.copy_ctrl WHERE is_active = True and stage_table_name=:table_name;

-- every day at 8 am
CREATE OR REPLACE TASK staging.task_automate_data_load
SCHEDULE = 'USING CRON 0 8 * * * UTC'
AS
call mydb.staging.sp_automate_data_copy('customer_data')
;

-- every day at 10 am and 10 pm
CREATE OR REPLACE TASK staging.task_automate_data_load
SCHEDULE = 'USING CRON 0 10,22 * * * UTC'
AS
call mydb.staging.sp_automate_data_copy('emp_data')
;

-- every monday at 6.30 am
CREATE OR REPLACE TASK staging.task_automate_data_load
SCHEDULE = 'USING CRON 30 6 * * 1 UTC'
AS
call mydb.staging.sp_automate_data_copy('pets_data_raw')
;
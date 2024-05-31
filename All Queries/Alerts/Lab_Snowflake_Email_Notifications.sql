-- Create notification integration object
CREATE NOTIFICATION INTEGRATION email_alerts
  TYPE = EMAIL
  ENABLED = TRUE;

-- Test email
CALL SYSTEM$SEND_EMAIL
('email_alerts', 'jana.snowflake3@gmail.com', 'Hi', 'This is a test email');

-- Create another integration object with non-verified email-address
CREATE NOTIFICATION INTEGRATION email_alerts2
  TYPE = EMAIL
  ENABLED = TRUE;
  ALLOWED_RECIPIENTS = ('jana.snowflake2@gmail.com', 'jana.snowflake3@gmail.com');

-- Test email with newly created intg object
CALL SYSTEM$SEND_EMAIL
('email_alerts2', 'jana.snowflake3@gmail.com, jana.snowflake2@gmail.com', 'Hi', 'This is a test email');


-- Alert on long running queries
CREATE OR REPLACE ALERT HRDATA.LONG_RUNNING_QUERY_ALERT
WAREHOUSE = COMPUTE_WH
SCHEDULE = '1 MINUTE'
IF (EXISTS
(
	SELECT QUERY_ID, QUERY_TEXT, EXECUTION_STATUS, START_TIME, END_TIME, TOTAL_ELAPSED_TIME 
    FROM TABLE(SNOWFLAKE.INFORMATION_SCHEMA.QUERY_HISTORY())
	WHERE EXECUTION_STATUS ILIKE 'RUNNING'
	AND START_TIME <= CURRENT_TIMESTAMP() - INTERVAL '1 MINUTE'
))
THEN CALL SYSTEM$SEND_EMAIL (
	'email_alerts',
	'jana.snowflake3@gmail.com',
	'Alert: Long Running Queries',
	'There are one or more queries running for more than 1 minute, Please check query history'
);

-- Start the alert
ALTER ALERT HRDATA.LONG_RUNNING_QUERY_ALERT RESUME;

-- Run a query that will take atleast for 2 minutes
SELECT C.C_CUSTKEY, C.C_NAME, SUM(O.O_TOTALPRICE)
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1000.CUSTOMER C
LEFT JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1000.ORDERS O
ON C.C_CUSTKEY = O.O_CUSTKEY
GROUP BY C.C_CUSTKEY, C.C_NAME;

-- Turn off the results cahce if you want to rerun the above query
ALTER SESSION SET USE_CACHED_RESULT = FALSE;

-- Stop the alert
ALTER ALERT HRDATA.LONG_RUNNING_QUERY_ALERT SUSPEND;


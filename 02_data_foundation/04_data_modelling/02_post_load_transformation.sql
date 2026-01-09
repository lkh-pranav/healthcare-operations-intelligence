
-- ==================================================================================================================
--                                            Date key columns in fact tables:
-- ==================================================================================================================

-- Add ALL Date Key Columns to fact tables:

ALTER TABLE fact_appnt
ADD COLUMN appointment_date_key INT;


-- Populate fact_appnt

UPDATE fact_appnt
SET 
    appointment_date_key = TO_CHAR(appointment_datetime::DATE, 'YYYYMMDD')::INT;

-- ==================================================================================================================
--                                    Add Foreign Key Constraints to Date key columns
-- ==================================================================================================================

ALTER TABLE fact_appnt
ADD CONSTRAINT fk_appnt_appointment_date 
    FOREIGN KEY (appointment_date_key) REFERENCES dim_date(date_key);

-- ==================================================================================================================
--                                           DATE KEY VALIDATION CHECK
-- ==================================================================================================================


-- fact_appnt date key FK Check:

--1.appointment_date_key
SELECT
	appnt.appointment_date_key,
	COUNT(*) AS unmatched_rows
FROM fact_appnt appnt
LEFT JOIN dim_date d
ON d.date_key = appnt.appointment_date_key
WHERE d.date_key IS NULL
GROUP BY appnt.appointment_date_key;


/*********************************************************************************************
 ANALYTICAL FACT VIEW: vw_fact_appointment_journey 
 ********************************************************************************************/


CREATE OR REPLACE VIEW vw_fact_appointment_journey AS
SELECT
	--Key Columns
    appnt.appointment_id,
    appnt.patient_id,
    appnt.clinician_id,
    appnt.department_id,
    appnt.appointment_date_key,

	-- Dimensions
	appnt.appointment_datetime,
	
	-- Appointment Scheduled hour
    EXTRACT(HOUR FROM appnt.appointment_datetime) AS hour_of_day,

	--1. Encounter type segment 
	CASE 
		WHEN appnt.encounter_type = 'OPD' THEN 'Outpatient (OPD)'
		WHEN appnt.encounter_type = 'IPD' THEN 'Inpatient (IPD)'
		ELSE 'Emergency (ED)'
	END AS encounter_category,
	
    -- 2. Appointment outcome segment
	CASE 
		WHEN appnt.no_show_flag = true THEN 'No-Show'
		WHEN appnt.appointment_status = 'Cancelled' THEN 'Cancelled'
		ELSE 'Attended'
		END AS appointment_outcome_category,
    
    -- 3. Throughput metrics (Only for Completed Visits)

	-- Handle negative values for Early Visits
	CASE 
        WHEN appnt.appointment_datetime IS NOT NULL AND appnt.consultation_start_time IS NOT NULL THEN
            ROUND(GREATEST(0, EXTRACT(EPOCH FROM (appnt.consultation_start_time - appnt.appointment_datetime)) / 60), 2)
        ELSE NULL 
    END AS delay_minutes,

	CASE 
        WHEN appnt.consultation_start_time IS NOT NULL AND appnt.check_in_time IS NOT NULL THEN
            ROUND(EXTRACT(EPOCH FROM (appnt.consultation_start_time - appnt.check_in_time)) / 60, 2)
        ELSE NULL 
    END AS wait_time_minutes,

    CASE
        WHEN appnt.consultation_end_time IS NOT NULL AND appnt.consultation_start_time IS NOT NULL THEN
            ROUND(EXTRACT(EPOCH FROM (appnt.consultation_end_time - appnt.consultation_start_time)) / 60, 2)
        ELSE NULL 
    END AS service_time_minutes,

    CASE
        WHEN appnt.check_out_time IS NOT NULL AND appnt.check_in_time IS NOT NULL THEN
            ROUND(EXTRACT(EPOCH FROM (appnt.check_out_time - appnt.check_in_time)) / 60, 2)
        ELSE NULL 
    END AS total_los_minutes, 

    -- 4. Punctuality (SLA) Logic: Using 30-min SLA
	appnt.no_show_flag,
    CASE
        WHEN appnt.appointment_datetime IS NOT NULL AND appnt.consultation_start_time IS NOT NULL THEN
            CASE
                WHEN (appnt.consultation_start_time - appnt.appointment_datetime) <= INTERVAL '30 minutes' THEN 'SLA Met On Time'
                ELSE 'SLA Missed Late'
            END
        ELSE 'Not_Applicable'
    END AS sla_performance_category,

    -- 5.  Patient Age
	EXTRACT(YEAR FROM AGE(CURRENT_DATE, pat.date_of_birth)) AS age,
	
	-- Age group segment
	CASE
		WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, pat.date_of_birth)) < 5 THEN 'Early Childhood (0–4)'
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, pat.date_of_birth)) BETWEEN 5 AND 12 THEN 'Pediatric – School Age (5–12)'
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, pat.date_of_birth)) BETWEEN 13 AND 17 THEN 'Adolescent (13–17)'
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, pat.date_of_birth)) BETWEEN 18 AND 24 THEN 'Young Adult (18–24)'
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, pat.date_of_birth)) BETWEEN 25 AND 44 THEN 'Adult (25–44)'
    	WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, pat.date_of_birth)) BETWEEN 45 AND 64 THEN 'Middle-Aged Adult (45–64)'
    	WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, pat.date_of_birth)) >= 65 THEN 'Geriatric Care (65+)'	 
		ELSE 'Unknown Age'
	END AS age_group

FROM
	fact_appnt appnt
JOIN
	dim_patient pat
ON
	appnt.patient_id = pat.patient_id;

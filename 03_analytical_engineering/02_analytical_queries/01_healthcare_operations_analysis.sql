
/***********************************************************************************************************************

Executive question 1: Patient Demand & Bottlenecks

How is patient volume distributed across departments, weekdays, and hours — and where are peak bottlenecks
occurring in ApexCare Medical Center?

************************************************************************************************************************/

/*
Question 1:
Which hospital departments carry the highest share of total scheduled patient demand,and how concentrated is
patient volume across departments?

Why this matters:
Department-level demand concentration directly drives staffing pressure, clinic congestion, and resource allocation risk.
*/

WITH dept_volume AS
(
SELECT
    d.department_name,
    COUNT(v.appointment_id) AS total_appointments
FROM
    vw_fact_appointment_journey v
JOIN
    dim_dept d
    ON v.department_id = d.department_id
GROUP BY
        d.department_name
),
total_volume AS
(
SELECT
    SUM(total_appointments) AS hospital_total_appointments
FROM
    dept_volume
)
SELECT
    dv.department_name,
    dv.total_appointments,
    ROUND((dv.total_appointments * 100.0) / tv.hospital_total_appointments, 2) AS department_volume_pct_share
FROM
    dept_volume dv
CROSS JOIN
    total_volume tv
ORDER BY
    dv.total_appointments DESC;


/*
Question 2:
How does scheduled patient demand vary by weekday within each department, and which weekdays represent
peak demand for individual departments?

Why this matters:
Identifying department-specific peak weekdays enables hospital operations to align staffing and prevent overload.
*/

WITH weekday_volume AS
(
SELECT
    d.department_name,
    dt.day_of_week,
    COUNT(v.appointment_id) AS appointment_count
FROM
	vw_fact_appointment_journey v
JOIN
	dim_dept d
ON 
	v.department_id = d.department_id
JOIN 
	dim_date dt
ON 
	v.appointment_date_key = dt.date_key
GROUP BY
    d.department_name, dt.day_of_week
)
SELECT
	department_name,
	day_of_week,
	appointment_count,
	DENSE_RANK() OVER(PARTITION BY department_name ORDER BY appointment_count DESC) weekday_volume_rank
FROM
	weekday_volume
ORDER BY department_name;


/*
Question 3:
How does scheduled patient demand vary by hour of the day within each department, and which hours consistently
represent peak congestion windows?

Why this matters:
Identifies department-specific peak hours and congestion windows.
*/

WITH hourly_volume AS
(
SELECT
    d.department_id,
	d.department_name,
    v.hour_of_day,
    COUNT(v.appointment_id) AS appointment_count
FROM
	vw_fact_appointment_journey v
JOIN
	dim_dept d
ON 
	v.department_id = d.department_id
GROUP BY
	d.department_id, d.department_name, v.hour_of_day
)
SELECT
    department_name,
    hour_of_day,
    appointment_count,
	DENSE_RANK() OVER(PARTITION BY department_name ORDER BY appointment_count DESC) hourly_volume_rank
FROM 
	hourly_volume
ORDER BY
    department_name;


/*
Question 4:
Which specific weekday–hour combinations generate the highest scheduled patient demand within each department,
and where are the most critical operational bottlenecks concentrated?

Why it maters:
Identifying the top weekday–hour demand hotspots by department allows hospital leadership to:
1.) Target staffing reinforcements precisely where congestion occurs
2.) Reduce wait times during predictable peak periods and Improve patient flow
*/

WITH dept_weekday_hour_volume AS
(
SELECT
    d.department_name,
    dt.day_of_week,
    v.hour_of_day,
    COUNT(v.appointment_id) AS appointment_count
FROM 
	vw_fact_appointment_journey v
JOIN
	dim_dept d
ON 
	v.department_id = d.department_id
JOIN 
	dim_date dt
ON
	v.appointment_date_key = dt.date_key
GROUP BY
    d.department_name,
    dt.day_of_week,
    v.hour_of_day
),
ranked_bottlenecks AS
(
SELECT
    department_name,
    day_of_week,
    hour_of_day,
    appointment_count,
    DENSE_RANK() OVER (PARTITION BY department_name ORDER BY appointment_count DESC) AS bottleneck_rank
FROM dept_weekday_hour_volume
)
SELECT
    department_name,
    day_of_week,
    hour_of_day,
    appointment_count,
    bottleneck_rank
FROM 
	ranked_bottlenecks
WHERE
	bottleneck_rank <= 3
ORDER BY
    department_name,
    bottleneck_rank,
    hour_of_day;


/*
Question 5:
How does scheduled patient demand trend month-over-month and year-over-year, and are there
recurring seasonal peaks that amplify operational bottlenecks?

Why this matters:
Understanding month and year-wise demand trends allows hospital leadership to:
1.) Anticipate seasonal surges that compound daily and hourly bottlenecks
2.) Proactively plan staffing, clinic capacity, and operating hours ahead of high-demand periods
3.) Distinguish temporary demand spikes from sustained growth requiring structural capacity expansion
*/

WITH monthly_volume AS
(
SELECT
    dt.cal_year,
    dt.cal_month,
    dt.month_name,
    COUNT(v.appointment_id) AS appointment_count
FROM
    vw_fact_appointment_journey v
JOIN
    dim_date dt
ON
    v.appointment_date_key = dt.date_key
WHERE
	month_name NOT IN ('Dec 2023', 'Dec 2025')
GROUP BY
    dt.cal_year,
    dt.cal_month,
    dt.month_name
)
SELECT
    cal_year,
    cal_month,
    month_name,
    appointment_count,
    LAG(appointment_count) OVER (PARTITION BY cal_year ORDER BY cal_month) AS prev_month_appointments,
    ROUND(
        ((appointment_count - LAG(appointment_count) OVER (PARTITION BY cal_year ORDER BY cal_month)) * 100.0)
        / 
          NULLIF(LAG(appointment_count) OVER (PARTITION BY cal_year ORDER BY cal_month), 0)
        , 2) AS month_over_month_pct_change 
FROM
    monthly_volume
ORDER BY
    cal_year,
    cal_month;


/***********************************************************************************************************************

Executive question 2: Clinical throughput & SLA

How efficiently do patients move through the clinical visit, and where do delays and on-time performance
gaps occur across departments and clinicians in ApexCare Medical Center?

************************************************************************************************************************/


/*
Question 6:
What is the hospital’s overall patient throughput efficiency and SLA compliance for completed (attended) appointments?

Why it matters:
This is the baseline performance check. Executives need this before diagnosing where problems exist.
*/

SELECT
    ROUND(AVG(wait_time_minutes), 2) AS avg_wait_time_mins,
    ROUND(AVG(service_time_minutes), 2) AS avg_consultation_time_mins,
    ROUND(AVG(total_los_minutes), 2) AS avg_los_mins,
    ROUND((SUM(CASE WHEN sla_performance_category = 'SLA Met On Time' THEN 1 ELSE 0 END)* 100.0)/ COUNT(*), 2) AS on_time_appointment_rate_pct
FROM
	vw_fact_appointment_journey
WHERE
	appointment_outcome_category = 'Attended';



/*
Question 7:
Are department-level delays driven more by workflow inefficiency or by clinical workload?

Why this matters:
This separates operational inefficiency from genuine clinical complexity. It determines whether leadership should:
- Fix operational processes and scheduling
OR
- Invest in capacity, staffing, or clinical redesign
*/

WITH dept_metrics AS (
SELECT
    department_id,
    ROUND(AVG(wait_time_minutes), 2) AS avg_wait_time_mins,
    ROUND(AVG(service_time_minutes), 2) AS avg_consultation_time_mins,
    COUNT(*) AS completed_appointments
FROM
	vw_fact_appointment_journey
WHERE
	appointment_outcome_category = 'Attended'
GROUP BY
	department_id
)
SELECT
    d.department_name,
    dm.avg_wait_time_mins,
    dm.avg_consultation_time_mins,
    dm.completed_appointments
FROM
	dept_metrics dm
JOIN
	dim_dept d
ON
	dm.department_id = d.department_id
ORDER BY
	dm.avg_wait_time_mins DESC;


/*
Question 8:
How do clinicians rank against each other on on-time appointment performance,
relative to the hospital’s overall SLA baseline (40.85%)?

Why this matters:
Enables fair, data-driven accountability by identifying consistently
underperforming and outperforming clinicians in a system under SLA stress.
*/

WITH clinician_sla AS (
SELECT
    f.department_id,
    d.department_name,
    f.clinician_id,
    c.clinician_name,
    ROUND(AVG(f.wait_time_minutes), 2) AS avg_wait_time_mins,
    ROUND(AVG(f.service_time_minutes), 2) AS avg_consultation_time_mins,
    ROUND((SUM(CASE WHEN f.sla_performance_category = 'SLA Met On Time' THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 2) AS on_time_appointment_rate_pct,
    COUNT(*) AS completed_appointments
FROM
	vw_fact_appointment_journey f
JOIN
	dim_dept d
ON 
	f.department_id = d.department_id
JOIN	
	dim_clinician c
ON 
	f.clinician_id = c.clinician_id
WHERE
	f.appointment_outcome_category = 'Attended'
GROUP BY
    f.department_id,
    d.department_name,
    f.clinician_id,
    c.clinician_name
)

SELECT
    department_name,
    clinician_name,
    avg_wait_time_mins,
    avg_consultation_time_mins,
    on_time_appointment_rate_pct,
    completed_appointments,

    -- Performance Category based on SLA bands 
    CASE
        WHEN on_time_appointment_rate_pct < 35 THEN 'Underperforming'
        WHEN on_time_appointment_rate_pct >= 35 AND on_time_appointment_rate_pct < 45 THEN 'At Risk / Near Baseline'
        ELSE 'Above Baseline Performer'
    END AS sla_performance_category,

    -- Best to worst clinician ranking 
    DENSE_RANK() OVER (ORDER BY on_time_appointment_rate_pct DESC) AS clinician_sla_rank
FROM
	clinician_sla
ORDER BY
	clinician_sla_rank;


/***********************************************************************************************************************

Executive question 3: No-Show Impact Analysis

What is the overall no-show rate, and which patient segments (age, nationality, insurance) contribute most to missed appointments
in ApexCare Medical Center.

************************************************************************************************************************/


/*
Question 9:
What is the overall no-show rate and how large is the absolute volume of missed appointments relative to total scheduled visits?

Why this matters:
To understand both percentage impact and absolute volume to assess severity and prioritize intervention.
*/

WITH appointment_counts AS
(
SELECT
    COUNT(appointment_id) AS total_appointments,
    COUNT(CASE WHEN appointment_outcome_category = 'No-Show' THEN 1 END) AS no_show_appointments
FROM
    vw_fact_appointment_journey
)
SELECT
    total_appointments,
    no_show_appointments,
    ROUND((no_show_appointments::DECIMAL / total_appointments) * 100, 2) AS no_show_rate_pct
FROM
    appointment_counts;


/*
Question 10:
Which age groups account for the highest number of missed appointments, and how does no-show rate provide
behavioral context to their overall operational impact?

Why this matters:
Age is a strong behavioral predictor of appointment reliability.
Understanding how no-show behavior varies across age groups helps to identify patterns in appointment reliability.
*/

WITH age_group_stats AS
(
SELECT
    age_group,
    COUNT(appointment_id) AS total_appointments,
    COUNT(CASE WHEN appointment_outcome_category = 'No-Show' THEN 1 END) AS no_show_appointments
FROM
    vw_fact_appointment_journey
WHERE
    age_group <> 'Unknown Age'
GROUP BY
    age_group
)
SELECT
    age_group,
    total_appointments,
    no_show_appointments,
	DENSE_RANK() OVER (ORDER BY no_show_appointments DESC) AS no_show_rank,
    ROUND((no_show_appointments::DECIMAL / total_appointments) * 100, 2) AS no_show_rate_pct  
FROM
    age_group_stats
ORDER BY
    no_show_rank;



/*
Question 11:
Within each age group, which gender segments contribute the most to missed appointments?

Why this matters:
Aggregated age trends can mask important behavioral differences by gender.
This insight supports targeted reminder strategies and more precise engagement interventions.
*/

WITH gender_age_stats AS
(
SELECT
    f.age_group,
    p.gender,
    COUNT(f.appointment_id) AS total_appointments,
    COUNT(CASE WHEN f.appointment_outcome_category = 'No-Show' THEN 1 END) AS no_show_appointments
FROM
    vw_fact_appointment_journey f
JOIN
    dim_patient p
    ON f.patient_id = p.patient_id
WHERE
    f.age_group <> 'Unknown Age'
GROUP BY
    f.age_group,
    p.gender
)
SELECT
    age_group,
    gender,
    total_appointments,
    no_show_appointments,
	DENSE_RANK() OVER (PARTITION BY age_group ORDER BY no_show_appointments DESC) AS no_show_rank
FROM
    gender_age_stats
ORDER BY
    age_group,
    no_show_rank;



/*
Question 12:
Which patient nationalities contribute the highest number of missed appointments?

Why this matters:
To understand which nationalities consume the most wasted capacity to prioritize outreach, communication, and policy interventions.
*/

WITH nationality_stats AS
(
SELECT
    p.nationality,
    COUNT(f.appointment_id) AS total_appointments,
    COUNT(CASE WHEN f.appointment_outcome_category = 'No-Show' THEN 1 END) AS no_show_appointments
FROM
    vw_fact_appointment_journey f
JOIN
    dim_patient p
ON
	f.patient_id = p.patient_id
WHERE
    p.nationality IS NOT NULL
GROUP BY
    p.nationality
)
SELECT
    nationality,
    total_appointments,
    no_show_appointments,
    DENSE_RANK() OVER (ORDER BY no_show_appointments DESC) AS no_show_rank
FROM
    nationality_stats
ORDER BY
    no_show_rank;


/*
Question 13:
Which insurance providers account for the highest number of missed appointments, and how does no-show rate provide additional
context to their overall operational impact?

Why this matters:
Insurance-driven no-shows often reflect process or administrative barriers rather than
patient intent. Identifying high-risk payers enables workflow optimization and revenue protection.
*/

WITH insurance_stats AS
(
SELECT
    p.insurance_provider,
    COUNT(f.appointment_id) AS total_appointments,
    COUNT(CASE WHEN f.appointment_outcome_category = 'No-Show' THEN 1 END) AS no_show_appointments
FROM
    vw_fact_appointment_journey f
JOIN
    dim_patient p
ON
	f.patient_id = p.patient_id
WHERE
    p.insurance_provider IS NOT NULL
GROUP BY
    p.insurance_provider
)
SELECT
    insurance_provider,
    total_appointments,
    no_show_appointments,
    DENSE_RANK() OVER (ORDER BY no_show_appointments DESC) AS insurance_risk_rank,
	ROUND((no_show_appointments::DECIMAL / total_appointments) * 100, 2) AS no_show_rate_pct
FROM
    insurance_stats
ORDER BY
    insurance_risk_rank;

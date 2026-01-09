

-- ==================================================================================================================
--                                             Data Validation:
-- ==================================================================================================================


--1. dim_dept

--Table structure & Row-count

SELECT * FROM dim_dept LIMIT 5;

SELECT COUNT(*) FROM dim_dept;

--2.Primary Key (PK) Uniqueness

SELECT
	department_id,
	COUNT(*) AS duplicate_rows
FROM
	dim_dept
GROUP BY 
	department_id
HAVING
	COUNT(*) > 1;

----------------------------------

--2. dim_clinician

--Table structure & Row-count

SELECT * FROM dim_clinician LIMIT 5;

SELECT COUNT(*) FROM dim_clinician;

--Primary Key (PK) Uniqueness

SELECT
	clinician_id,
	COUNT(*) AS duplicate_rows
FROM
	dim_clinician
GROUP BY 
	clinician_id
HAVING
	COUNT(*) > 1;

--Foreign Key (FK) Check

SELECT
	c.department_id,
	COUNT(*) AS unmatched_rows
FROM
	dim_clinician c
LEFT JOIN
	dim_dept d
ON d.department_id = c.department_id
WHERE
	d.department_id IS NULL
GROUP BY
	c.department_id;


----------------------------------

--3.dim_patient

--Table structure & Row-count

SELECT * FROM dim_patient LIMIT 5;

SELECT COUNT(*) FROM dim_patient;

--Primary Key (PK) Uniqueness

SELECT
	patient_id,
	COUNT(*) AS duplicate_rows
FROM
	dim_patient
GROUP BY 
	patient_id
HAVING
	COUNT(*) > 1;


----------------------------------


--4.dim_date

--Table structure & Row-count

SELECT * FROM dim_date LIMIT 5;

SELECT COUNT(*) FROM dim_date;

--Primary Key (PK) Uniqueness

SELECT
	date_key,
	COUNT(*) AS duplicate_rows
FROM
	dim_date
GROUP BY 
	date_key
HAVING
	COUNT(*) > 1;


----------------------------------

--5.fact_appnt

--Table structure & Row-count


SELECT * FROM fact_appnt LIMIT 5;

SELECT COUNT(*) FROM fact_appnt;


--Primary Key (PK) Uniqueness

SELECT
	appointment_id,
	COUNT(*) AS duplicate_rows
FROM
	fact_appnt
GROUP BY 
	appointment_id
HAVING
	COUNT(*) > 1;


--Foreign Key (FK) Check

--1.department_id

SELECT
	appnt.department_id,
	COUNT(*) AS unmatched_rows
FROM
	fact_appnt appnt
LEFT JOIN
	dim_dept d
ON d.department_id = appnt.department_id
WHERE
	d.department_id IS NULL
GROUP BY
	appnt.department_id;


--2.patient_id

SELECT
	appnt.patient_id,
	COUNT(*) AS unmatched_rows
FROM
	fact_appnt appnt
LEFT JOIN
	dim_patient p
ON p.patient_id = appnt.patient_id
WHERE
	p.patient_id IS NULL
GROUP BY
	appnt.patient_id;


--3.clinician_id

SELECT
	appnt.clinician_id,
	COUNT(*) AS unmatched_rows
FROM
	fact_appnt appnt
LEFT JOIN
	dim_clinician c
ON c.clinician_id = appnt.clinician_id
WHERE
	c.clinician_id IS NULL
GROUP BY
	appnt.clinician_id;


--4.appointment_date_key

SELECT
	appnt.appointment_date_key,
	COUNT(*) AS unmatched_rows
FROM 
	fact_appnt appnt
LEFT JOIN
	dim_date d
ON
	d.date_key = appnt.appointment_date_key
WHERE
	d.date_key IS NULL
GROUP BY
	appnt.appointment_date_key;


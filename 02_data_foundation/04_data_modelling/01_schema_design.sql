
-- ============================================================
-- 1. DIMENSION: DEPARTMENT
-- ============================================================
CREATE TABLE dim_dept (
    department_id     INT PRIMARY KEY,
    department_name   VARCHAR(50) NOT NULL,
    department_group  VARCHAR(10) NOT NULL,

-- Business Constraints:
    CONSTRAINT chk_department_name
        CHECK (department_name IN (
            'General Practice',
            'Cardiology',
            'Pediatrics',
            'Orthopedics',
            'Dermatology',
            'Emergency',
            'ICU',
            'Surgery',
            'Neurology'
        )),
    CONSTRAINT chk_department_group
        CHECK (department_group IN ('OPD', 'ED', 'IPD'))
);

-- ============================================================
-- 2. DIMENSION: PATIENT
-- ============================================================
CREATE TABLE dim_patient (
    patient_id               INT PRIMARY KEY,   
    date_of_birth            DATE,
    gender                   VARCHAR(20) NOT NULL,
    nationality              VARCHAR(50),
    insurance_provider       VARCHAR(50),
    registration_date        DATE NOT NULL,
	patient_name             VARCHAR(100) NOT NULL, 
    patient_email            VARCHAR(100),          
    patient_phone            VARCHAR(20),
	date_logic_error_flag    BOOLEAN,

--Logic constraints:
	CONSTRAINT chk_patient_dob_not_future
      CHECK (date_of_birth IS NULL OR date_of_birth <= CURRENT_DATE),
	CONSTRAINT chk_patient_registration_not_future
      CHECK (registration_date <= CURRENT_DATE),  
	  
--Business constraints:
    CONSTRAINT chk_patient_gender
      CHECK (gender IN ('Male','Female','Other')),
    CONSTRAINT chk_patient_registration_vs_dob
      CHECK (date_of_birth IS NULL OR registration_date >= date_of_birth)
);

-- ============================================================
-- 3. DIMENSION: CLINICIAN  
-- ============================================================
CREATE TABLE dim_clinician (
    clinician_id      INT PRIMARY KEY,
    clinician_name    VARCHAR(50) NOT NULL,
    department_id     INT NOT NULL,
    designation       VARCHAR(20) NOT NULL,
    years_experience  INT,
	
--Foreign key constraints:
    FOREIGN KEY (department_id) REFERENCES dim_dept(department_id),

-- Business constraints:
    CONSTRAINT chk_dim_clinician_designation
        CHECK (designation IN ('Specialist', 'GP', 'Consultant'))
);

-- ============================================================
-- 4. DIMENSION: DATE
-- ============================================================
CREATE TABLE dim_date (
    date_key         INT PRIMARY KEY,
    calendar_date    DATE,
    cal_year         INT,
    cal_month        SMALLINT,
    cal_day          SMALLINT,
    day_of_week      VARCHAR(10),
    day_of_week_num  SMALLINT,
    is_weekend       BOOLEAN,
	month_name       VARCHAR(9),
	month_sort_key   VARCHAR(7)
    
);

-- ============================================================
-- 5. FACT: APPOINTMENTS  
-- ============================================================
CREATE TABLE fact_appnt (
    appointment_id           INT PRIMARY KEY,
    patient_id               INT NOT NULL,
    clinician_id             INT NOT NULL,
    appointment_type         VARCHAR(50) NOT NULL,
    appointment_datetime     TIMESTAMP NOT NULL,
    check_in_time            TIMESTAMP,
    consultation_start_time  TIMESTAMP,
    consultation_end_time    TIMESTAMP,
    check_out_time           TIMESTAMP,
    appointment_status       VARCHAR(20),
    no_show_flag             BOOLEAN,
    room_or_area             VARCHAR(50),
    department_id            INT NOT NULL,
    encounter_type           VARCHAR(50),

-- Foreign key constraints:
    FOREIGN KEY (patient_id)    REFERENCES dim_patient(patient_id),
    FOREIGN KEY (clinician_id)  REFERENCES dim_clinician(clinician_id),
    FOREIGN KEY (department_id) REFERENCES dim_dept(department_id),
	
-- Logic constraints:
    CONSTRAINT chk_fact_appnt_status
        CHECK (appointment_status IN ('Scheduled','Completed','Cancelled','No-show')),
    CONSTRAINT chk_fact_appnt_no_show_flag
        CHECK (no_show_flag IN (TRUE, FALSE) OR no_show_flag IS NULL),

-- Business constraints:
    CONSTRAINT chk_fact_appnt_timeline_integrity
        CHECK (
               check_in_time <= consultation_start_time
           AND consultation_start_time < consultation_end_time
           AND consultation_end_time <= check_out_time
		   AND consultation_start_time >= (appointment_datetime - INTERVAL '60 minutes')
        ),
    CONSTRAINT chk_fact_appnt_max_consult_duration
        CHECK (consultation_end_time <= consultation_start_time + INTERVAL '120 minutes'),
    CONSTRAINT chk_fact_appnt_no_show_consistency
        CHECK (
               (no_show_flag = TRUE  AND appointment_status = 'No-show')
            OR (no_show_flag = FALSE AND appointment_status <> 'No-show')
        )
);

-- ============================================================
-- Indexes
-- ============================================================
CREATE INDEX idx_fact_appnt_patient_id ON fact_appnt (patient_id);
CREATE INDEX idx_fact_appnt_department_id ON fact_appnt (department_id);
CREATE INDEX idx_fact_appnt_status ON fact_appnt (appointment_status);
CREATE INDEX idx_fact_appnt_appointment_datetime ON fact_appnt (appointment_datetime);
------------------------------------------------------------------------------------------------------------


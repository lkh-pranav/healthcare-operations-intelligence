# Data Sources Overview

This section provides a high-level view of the key data sources used in this project, describing their purpose, role in the analytics model, and contents. The data forms the foundation for analyzing patient demand, clinical throughput, and no-show impact at ApexCare Medical Center. Each source has been mapped to either a **fact** or **dimension** table in the analytical model.

| CSV File | Table | Description |
|----------|----------------|-------------|
| **appointments.csv** | `fact_appnt` | Core fact table capturing every patient appointment, including scheduling, check-in/out, consultation times, clinician and department assignments, appointment type, status, and no-show flag. |
| **departments.csv** | `dim_dept` | Dimension table describing hospital departments, including department ID, name, and grouping (OPD / ED / IPD). Supports department-level analysis of demand and throughput. |
| **clinicians.csv** | `dim_clinician` | Dimension table containing clinician details, including ID, name, department assignment, designation, and years of experience. Enables clinician-level performance and SLA analysis. |
| **patients.csv** | `dim_patient` | Dimension table with patient demographics and registration info, including age, gender, nationality, insurance provider, and contact details. Supports segmentation for no-show and utilization analysis. |
| **date.csv** | `dim_date` | Custom dimension table generated for analytical purposes, including date keys, calendar date, year, month, day, day of week, weekend flag, and month sort order. Enables time-based demand and throughput analysis. |



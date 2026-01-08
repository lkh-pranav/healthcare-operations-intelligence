# Data Profiling Summary  
## Data Quality Assessment & Cleaning Strategy

This document summarizes the key data quality issues identified during profiling across all core datasets. It defines the **business impact**, **risk level**, and the **prioritized cleaning actions** that guide the next phase of data preparation.

The objective is to ensure the analytical layer is built on **trusted, decision-grade data**.

---

## Data Quality Issues Overview

| Dataset / Dimension | Issue Type | Records Affected | Business Impact | Cleaning Action |
|--------------------|------------|------------------|-----------------|-----------------|
| **Appointments (Fact)** | Logical conflict (Status vs No-Show Flag) | 1 | Distorts No-Show Rate and Completion KPIs | Correct `no_show_flag` to `FALSE` |
| **Appointments (Fact)** | Referential integrity (Invalid FK) | 393 | Excludes records from departmental performance analysis | Impute invalid `department_id` to default Department ID = 1 |
| **Appointments (Fact)** | Domain standardization | 1 | Creates reporting inconsistency due to misspelled status | Standardize `"Cancleld"` → `"Cancelled"` |
| **Patients (Dimension)** | Temporal integrity (DOB logic) | 673 | Invalidates age-based cohorts and trend analysis | Set conflicting `date_of_birth` to `NULL` and flag for audit |
| **Patients (Dimension)** | Domain standardization | Low | Splits demographic reporting categories | Map values (`M`, `FEMALE`) → standard (`Male`, `Female`) |
| **Departments (Dimension)** | Domain standardization | 1 | Breaks linkage for Cardiology appointment analysis | Correct `"Cardiologgy"` → `"Cardiology"` |
| **Clinicians (Dimension)** | Referential integrity (Invalid FK) | 1 | Excludes clinician activity from department reports | Reassign from `department_id = 999` → `department_id = 1` |

---

## Risk Assessment

- **High impact risks**
  - Temporal integrity issues in patient DOB data (673 records)
  - Referential integrity failures in appointment data (393 records)

- **Medium impact risks**
  - Domain inconsistencies affecting appointment status and department naming

- **Low impact risks**
  - Minor demographic value inconsistencies

No **primary key violations** were found across any dataset, confirming that structural integrity of the model is strong.

---

## Cleaning Strategy

The cleaning phase will follow a **risk-based prioritization**:

1. **Stabilize analytical accuracy**
   - Resolve referential integrity issues in fact and clinician data  
   - Correct logical conflicts affecting KPI computation  

2. **Protect segmentation and trend analysis**
   - Address invalid patient birth dates  
   - Standardize demographic attributes  

3. **Ensure reporting consistency**
   - Fix domain spelling and status value inconsistencies  


---

## Conclusion

Overall data quality is **high and fit for analytical use** after targeted remediation.  
The identified issues are **isolated, well-understood, and operationally correctable**.



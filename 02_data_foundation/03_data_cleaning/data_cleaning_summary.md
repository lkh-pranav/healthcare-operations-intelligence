# Data Cleaning Summary

This document summarizes the key data corrections performed to ensure the dataset is reliable for operational and leadership decision-making.  
All actions were targeted, evidence-based, and designed to **recover usable data without distorting operational insights**.

---

## Cleaning Actions Overview

| Table | Cleaning Actions Performed |
|------|----------------------------|
| **Appointments (Fact)** | • Recovered 393 orphaned appointment records by correcting an invalid department reference<br>• Reassigned all records from invalid **Department ID 999** to **Department ID 1 (General Practice)** based on clinician role and department logic<br>• Corrected inconsistent appointment status values to ensure reliable reporting |
| **Clinicians (Dimension)** | • Validated clinician-to-department alignment for records linked to invalid department IDs<br>• Confirmed General Practice designation to support safe department reassignment |
| **Departments (Dimension)** | • Corrected department naming inconsistencies to maintain accurate department-level reporting |
| **Patients (Dimension)** | • Addressed invalid date-of-birth values that could distort age-based analysis<br>• Standardized demographic values to avoid fragmented reporting categories |

---

## Why These Changes Matter

- **Recovered lost capacity data:** 393 appointments were restored to analysis instead of being excluded  
- **Preserved analytical accuracy:** Department volumes remain balanced, with minimal impact on trends  
- **Improved trust in insights:** Eliminated hidden data errors that could mislead staffing and scheduling decisions  

All corrections were validated against real operational context (department role, clinician designation, and volume impact).

---

## Outcome

After cleaning, the dataset accurately represents:

- Department-level workload
- Patient flow and appointment activity
- Reliable input for demand, throughput, and no-show analysis

The data is now **fit for executive-level operational analysis**.




# Semantic Model Overview

## Purpose of This Layer

This semantic model represents the **business-ready analytical layer** of the project.  
It translates clean, governed tables into a format that directly supports **decision-making, KPI measurement, and executive reporting**.

This step sits **between data engineering and Power BI**, ensuring that business logic is standardized **before** visualization.

---

## Modeling Logic & Grain Definition

### Analytical Grain
- **1 row = 1 patient appointment**
- Each record represents the *full appointment journey*, from scheduling to completion or no-show.

### Core Modeling Principles
- Lifecycle timestamps are converted into **operational metrics** (delay, wait time, service time, total length of stay).
- Raw flags and codes are standardized into **business-friendly categories** (appointment outcome, encounter type, SLA status).
- Patient attributes (age, age group) are derived once at the semantic level to avoid duplication in BI logic.

This ensures:
- No double counting
- Consistent KPI definitions
- Safe aggregation across departments, clinicians, and time

---

## Semantic Fact View Used

**Primary Analytical View**
- `vw_fact_appointment_journey`

This view models the **end-to-end patient appointment flow**, enabling analysis of:
- Throughput and delays
- SLA adherence
- No-show behavior
- Time-of-day and patient-segment patterns

---

## Semantic Model Relationships

The Power BI model is assembled using **one analytical fact view** connected to four conformed dimensions:

### Semantic Model Relationships (Business-Ready View)

| Fact View / Dimension | Join Key | Business Role |
|----------------------|---------|---------------|
| `vw_fact_appointment_journey` | — | Central analytical fact |
| `dim_patient` | patient_id | Patient demographics & age cohorts |
| `dim_dept` | department_id | Departmental performance analysis |
| `dim_clinician` | clinician_id | Provider-level throughput & load |
| `dim_date` | appointment_date_key | Time-series and trend analysis |

This forms a **clean star schema at the semantic level**, optimized for BI consumption.

---

## Why This Step Matters

Without this layer:
- KPIs would be redefined inconsistently in Power BI
- SLA and timing logic would be duplicated across visuals
- Dashboards would answer *data questions* instead of *business questions*

With this layer:
- Power BI focuses purely on **aggregation and storytelling**
- SQL becomes the **single source of truth** for metrics
- Executive dashboards remain simple, reliable, and scalable

---

## Contribution to the Overall Project

This semantic model:
- Bridges raw data and executive insights
- Converts operational events into measurable performance signals
- Enables leadership to evaluate access, efficiency, and patient experience with confidence

In short, this layer turns **data into decisions**.

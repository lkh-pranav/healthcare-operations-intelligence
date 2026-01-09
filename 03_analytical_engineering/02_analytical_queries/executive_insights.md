# Combined Executive Insights — Healthcare Operations Analytics  
*A consolidated, measurable view across patient demand, clinical throughput, and no-show impact*  

This document summarizes **three core analytical questions** addressed through SQL-based analysis on a governed semantic model.  
The insights are designed to be **quantifiable, easy to interpret, and professionally credible** for both senior stakeholders and recruiters.

---

## Executive Question 1 — Patient Demand & Bottlenecks  
**What is the overall patient demand pattern across time and departments, and where do operational bottlenecks emerge?**

### Combined Measurable Insights  

- **Demand is structurally concentrated**:  
  - Cardiology (14.6%) and Orthopedics (13.7%) together account for **~28% of total appointments**.  
  - The **top three departments exceed 40% of total demand**, while remaining departments contribute evenly (~9–10% each).

- **Bottlenecks are time-bound, not evenly distributed**:  
  - Cardiology peaks mid-week (Tuesday); Orthopedics peaks on Mondays and Fridays.  
  - General Practice and Neurology show **higher weekend demand**, contradicting weekday-only staffing assumptions.

- **Hourly congestion is predictable and repeatable**:  
  - Orthopedics peaks during **08:00–11:00**.  
  - Cardiology and Neurology experience **early-morning and late-evening pressure**.  
  - Emergency demand spans extended hours rather than sharp spikes.

- **Seasonality amplifies existing stress points**:  
  - February demand dips are consistent year-over-year.  
  - March rebounds (+7% to +12%) indicate deferred demand.  
  - Q4 demand increases compound weekday–hour bottlenecks without structural growth.

**Consolidated Insight**  
Operational bottlenecks arise from **misalignment between staffing and known demand patterns**, not from unpredictable volume surges or insufficient total capacity.

---

## Executive Question 2 — Clinical Throughput & Appointment Timeliness  
**How efficiently do patients move through care, and where do delays and SLA gaps occur?**

### Combined Measurable Insights  

- **Baseline throughput inefficiency is front-loaded**:  
  - Average wait time: **35.0 minutes**  
  - Average consultation time: **27.5 minutes**  
  - Nearly **46% of visit time is spent waiting**, not receiving care.

- **On-time performance is structurally weak**:  
  - Only **40.9% of appointments start on time**.  
  - Nearly **6 out of 10 appointments breach SLA**, indicating systemic delay.

- **Delays are uniform across departments**:  
  - Wait-time variation across departments is **< 1 minute**.  
  - Both high- and low-volume departments experience similar delays.

- **Clinician performance is constrained by the system**:  
  - Only **11.6% of clinicians** perform meaningfully above baseline SLA.  
  - Best observed performance is **<50% on-time**, just ~8 points above baseline.  
  - Appointment volume does not explain SLA variance.

**Consolidated Insight**  
Patients move **slowly into care, not slowly through care**.  
Throughput and timeliness issues are **system-wide workflow problems**, limiting individual clinician upside without operational redesign.

---

## Executive Question 3 — No-Show Impact on Capacity  
**Which patient groups contribute most to missed appointments, and how can no-shows be reduced?**

### Combined Measurable Insights  

- **No-shows represent material capacity loss**:  
  - Total scheduled appointments: **120,000**  
  - Missed appointments: **11,897**  
  - Overall no-show rate: **9.91% (~1 in 10 visits)**

- **Impact is driven by volume, not extreme behavior**:  
  - Adult (25–44), Middle-Aged (45–64), and Geriatric (65+) patients account for **8,667 no-shows**.  
  - No-show rates are consistent across ages (~9.7%–10.4%).

- **Gender is a secondary factor**:  
  - Male–female differences within age groups are minimal and operationally insignificant.

- **High-volume nationalities dominate lost capacity**:  
  - India, Philippines, and UAE patients account for **7,100+ missed appointments**.  
  - High counts reflect population size, not disengagement.

- **Insurance-related no-shows are scale-driven**:  
  - Daman, Oman Insurance, and MetLife represent **6,100+ no-shows**.  
  - No-show rates are uniform across providers (~9.5%–10.3%).

**Consolidated Insight**  
No-shows are a **persistent capacity leakage issue** driven by **high-volume patient and payer segments**.  
Even **1–2% attendance improvement** in these groups would recover **hundreds of appointments annually**.

---

## Cross-Question Strategic Takeaway  

Across demand, throughput, and no-shows, operational inefficiency is **predictable and structural**:

- Demand is **concentrated and time-specific**
- Delays originate **before clinician interaction**
- Capacity loss is driven by **scale, not outliers**

The strongest improvements will come from **targeted, data-aligned interventions**, not blanket staffing increases or policy tightening.

---

**Data & Methodology Note**  
All insights are derived from SQL-based analysis on a governed semantic fact view, ensuring consistent definitions, auditability, and reproducibility.

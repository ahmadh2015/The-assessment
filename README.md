# Clinical Data Analysis Assessment

This repository contains a three-part technical assessment focused on Clinical Data Science using the `{pharmaverse}` ecosystem. The project demonstrates the derivation of Treatment-Emergent Adverse Events (TEAEs), regulatory-standard summary tables, and interactive data visualization.

## Repository Structure

* **`question_1/`**: Contains `question_1.R` and `question_1.html`. Generates a TEAE summary table by System Organ Class and Preferred Term.
* **`question_2/`**: Contains `question_2.R` and `question_2.png`. Creates a stacked bar chart of unique subject counts by SOC and Severity.
* **`question_3/`**: Contains `question_3.R`. A Shiny application for interactive filtering of AE severity by treatment arm.

## Setup and Requirements

 **R (version 4.1+)** and the following libraries installed:

```r
install.packages(c('tidyverse', 'pharmaverseadam', 'admiral', 'gtsummary', 'gt', 'shiny', 'ggplot2'))
```

## Methodology and Clinical Logic

The analysis follows CDISC ADaM-to-Table principles:

### **Population Selection (Denominator)**
* **Safety Population**: Restricted to subjects who received at least one dose of the study drug (`SAFFL == "Y"`).
* **Target Arms**: Focuses on `Placebo`, `Xanomeline High Dose`, and `Xanomeline Low Dose`.

### **Event Flagging (Numerator)**
* **Treatment-Emergent Adverse Events (TEAE)**: Only events flagged as `TRTEMFL == "Y"` are included.
* **Incidence**: Calculated as unique subjects with an event divided by the total Safety Population per arm.

## Instructions

### **Question 1: TEAE Summary Table**
* **Logic**: Joins `ADAE` to `ADSL` to ensure denominators include subjects with zero AEs.
* **Output**: HTML table with bolded SOCs and Preferred Terms.

### **Question 2: AE Severity Bar Chart**
* **Visuals**: Stacked bars with **Severe** (Red) at the tip, **Moderate** (Orange) in the center, and **Mild** (Yellow) at the base.
* **Styling**: Increased Y-axis font size and vertical legend on the right-middle side.

### **Question 3: Interactive Shiny App**
* **Feature**: Users can dynamically filter the severity plot by treatment arm using the sidebar.

---
*Note: Data sourced from `pharmaverseadam` (ADSL and ADAE datasets).*

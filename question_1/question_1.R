library(pharmaverseadam)
library(tidyverse)
library(gtsummary)
library(gt)

# 1. Load data
adsl <- pharmaverseadam::adsl
adae <- pharmaverseadam::adae

# 2. Define the target treatment arms
target_arms <- c("Placebo", "Xanomeline High Dose", "Xanomeline Low Dose")

# 3. Create the Safety Population Base (The Denominator)
# This population must include all subjects who received at least one dose
safe_pop <- adsl %>%
  filter(SAFFL == "Y", ACTARM %in% target_arms) %>%
  mutate(ACTARM = factor(ACTARM, levels = target_arms))

# 4. Join only TEAE records to the Safety Population
# This ensures N represents all treated subjects, but counts only emergent events
analysis_data <- safe_pop %>%
  left_join(
    adae %>% 
      filter(TRTEMFL == "Y") %>% 
      select(USUBJID, AESOC, AEDECOD), 
    by = "USUBJID"
  ) %>%
  mutate(
    # Create a flag for 'Any TEAE' based on whether an AE record exists
    any_teae = if_else(!is.na(AESOC), "Yes", "No")
  )

# 5. Build the Summary Table
teae_table <- analysis_data %>%
  select(ACTARM, any_teae, AESOC, AEDECOD) %>%
  tbl_summary(
    by = ACTARM,
    label = list(
      any_teae ~ "Treatment Emergent Adverse Events",
      AESOC ~ "System Organ Class",
      AEDECOD ~ "Preferred Term"
    ),
    type = list(any_teae ~ "dichotomous"),
    value = list(any_teae ~ "Yes"), 
    missing = "no" 
  ) %>%
  modify_header(
    label = "**System Organ Class / Preferred Term**",
    all_stat_cols() ~ "**{level}** \n N = {n}"
  ) %>%
  bold_labels()

# 6. Save as HTML
# Now we just convert and save, the footnote is already included
teae_table %>%
  as_gt() %>%
  gtsave(filename = "question_1.html")

# Display table
teae_table
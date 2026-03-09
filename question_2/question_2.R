library(pharmaverseadam)
library(tidyverse)
library(ggplot2)

# 1. Load data
adsl <- pharmaverseadam::adsl
adae <- pharmaverseadam::adae

# 2. Define the target treatment arms
target_arms <- c("Placebo", "Xanomeline High Dose", "Xanomeline Low Dose")

# 3. Prepare the Data (Safety Population + TEAEs)
# Start with ADSL to lock in the population base, then join AEs
plot_data <- adsl %>%
  filter(SAFFL == "Y", ACTARM %in% target_arms) %>%
  inner_join(
    adae %>% filter(TRTEMFL == "Y", !is.na(AESOC)), 
    by = "USUBJID"
  ) %>%
  # Count unique subjects per SOC and Severity level
  distinct(USUBJID, AESOC, AESEV) %>%
  mutate(
    # CHANGE: Reverse factor order so Mild is first (left)
    AESEV = factor(AESEV, levels = c("MILD", "MODERATE", "SEVERE")),
    AESOC = str_to_title(AESOC)
  )

# 4. Determine SOC order by total frequency (most frequent at top)
soc_order <- plot_data %>%
  count(AESOC) %>%
  arrange(n) %>%
  pull(AESOC)

plot_data$AESOC <- factor(plot_data$AESOC, levels = soc_order)

# 5. Create the Visualization
severity_plot <- ggplot(plot_data, aes(y = AESOC, fill = AESEV)) +
  # CHANGE: Set position_stack(reverse = TRUE) so red (Severe) is at the tip
  geom_bar(position = position_stack(reverse = TRUE)) +
  # Use defined color palette
  scale_fill_manual(
    values = c("MILD" = "#FFEDA0", "MODERATE" = "#FEB24C", "SEVERE" = "#E31A1C")
  ) +
  labs(
    title = "Unique Subjects per SOC and Severity Level",
    # CHANGE: Subtitle removed per request
    x = "Number of Unique Subjects",
    y = "System Organ Class",
    fill = "Severity"
  ) +
  theme_minimal() +
  # CHANGE: Move legend to right middle, decrease font size, stack vertically
  theme(
    legend.position = "right",
    legend.justification = "center",
    legend.title = element_text(size = 9),
    legend.text = element_text(size = 8),
    legend.box.just = "right"
  ) +
  guides(fill = guide_legend(ncol = 1)) # Forces the legend into a single column

# 6. Save the plot
ggsave("question_2/question_2.png", plot = severity_plot, width = 11, height = 8)

# Display
print(severity_plot)
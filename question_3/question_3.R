library(shiny)
library(pharmaverseadam)
library(tidyverse)
library(ggplot2)

# 1. Pre-process Data (Load outside server for performance)
adsl <- pharmaverseadam::adsl
adae <- pharmaverseadam::adae

# 2. Define target arms
target_arms <- c("Placebo", "Xanomeline High Dose", "Xanomeline Low Dose")

# 3. UI Definition
ui <- fluidPage(
  titlePanel("AE Summary Interactive Dashbaord"),
  
  sidebarLayout(
    sidebarPanel(
      # Checkbox Filter to allow multiple arm selection
      checkboxGroupInput(
        "arms", 
        "Select Treatment Arm(s):", 
        choices = target_arms,
        selected = target_arms
      ),
    ),
    
    mainPanel(
      plotOutput("severity_plot", height = "700px")
    )
  )
)

# 4. Server Logic
server <- function(input, output) {
  
  # Reactive data processing based on user input
  filtered_plot_data <- reactive({
    req(input$arms) # Ensure at least one arm is selected
    
    adsl %>%
      filter(SAFFL == "Y", ACTARM %in% input$arms) %>%
      inner_join(
        adae %>% filter(TRTEMFL == "Y", !is.na(AESOC)), 
        by = "USUBJID"
      ) %>%
      distinct(USUBJID, AESOC, AESEV) %>%
      mutate(
        # Standard factor levels for consistent bar stacking
        AESEV = factor(AESEV, levels = c("MILD", "MODERATE", "SEVERE")),
        AESOC = str_to_title(AESOC)
      )
  })
  
  output$severity_plot <- renderPlot({
    data <- filtered_plot_data()
    
    # Calculate SOC order dynamically based on the filtered data frequency
    soc_order <- data %>%
      count(AESOC) %>%
      arrange(n) %>%
      pull(AESOC)
    
    data$AESOC <- factor(data$AESOC, levels = soc_order)
    
    # Generate the visualization with your specific color and legend requirements
    ggplot(data, aes(y = AESOC, fill = AESEV)) +
      geom_bar(position = position_stack(reverse = TRUE)) +
      scale_fill_manual(
        values = c("MILD" = "#FFEDA0", "MODERATE" = "#FEB24C", "SEVERE" = "#E31A1C")
      ) +
      labs(
        title = "Unique Subjects per SOC and Severity Level",
        x = "Number of Unique Subjects",
        y = "System Organ Class",
        fill = "Severity"
      ) +
      theme_minimal() +
      theme(
        axis.text.y = element_text(size = 12),
        legend.position = "right",
        legend.justification = "center",
        legend.title = element_text(size = 12, face= "bold"),
        legend.text = element_text(size = 12, face= "bold")
      ) +
      guides(fill = guide_legend(ncol = 1))
  })
}

# 5. Run the Application
shinyApp(ui = ui, server = server)

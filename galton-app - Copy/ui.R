## Predict child height from parents heights based on Galton Data
source("helpers.R")

shinyUI(fluidPage(
  titlePanel("Children Height Prediction based on Galton's data "),
  
  sidebarLayout(
    sidebarPanel(
      helpText("Prediction of child's height from parents heights based on Galton's data. Choose parameters for prediction."),
      selectInput("par", 
                  label = "Prediction based on:",
                  choices = c("Father's Height" = "F", "Mother's Height" = "M", "Both Parents' Heights" = "B"),
                  selected = "B"),
      
      conditionalPanel(
        condition = "(input.par == 'B') || (input.par == 'F')",
        sliderInput("fh", label = "Father's Height in cm:", min = 150, max = 200, step = 1, value = 180)
      ),

      conditionalPanel(
        condition = "(input.par == 'B') || (input.par == 'M')",
        sliderInput("mh", label = "Mother's Height in cm:", min = 150, max = 200, step = 1, value = 160)
      ),

      radioButtons("gd", "Child's Gender:", choices = c("Male" ="M", "Female" = "F"), selected = "M"),
      
      tags$hr(), ## horizontal line
      
      numericInput("ci", "Confidence Interval %", min = 5, max = 95, step = 5, value = 95, width = "60%")
      ),
    
    mainPanel(
      tabsetPanel(
        ## Prediction Pane
        tabPanel("Prediction",
                 h5(strong("You entered:")),
                 textOutput("text1"),
                 textOutput("text2"),
                 textOutput("text3"),
                 h5(strong("Result:")),
                 textOutput("text4"),
                 h5(strong("Predicted Child's Height compared to Parents'"), align="center"),
                 plotOutput("plot")
        ), 
        tabPanel("Documentation",
                 ## can helpers.R's show_doc() function
                 show_doc()
        )
      )
    )
  )
))
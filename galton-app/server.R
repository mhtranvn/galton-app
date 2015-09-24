## Predict child height from parents heights based on Galton Data
## Tran Manh Hien, 2015. MOOC Developing Data Products
require(shiny)
require(ggplot2)

## Read data
gdata <- read.csv("./data/Galton.csv", stringsAsFactors = FALSE)
## strip-off unused columns
gdata <- gdata[,c(2:5)]
## convert to cm unit of measure
gdata[,c(1,2,4)] <- gdata[,c(1,2,4)]*2.54

## models: fit a model for both parents, father's only and mother's only
fitb <- lm(Height ~ ., data = gdata)
fitf <- lm(Height ~ Father + Gender, data = gdata)
fitm <- lm(Height ~ Mother + Gender, data = gdata)

shinyServer(
  function(input, output) {
    
    ## check user selection
    sfit <- reactive({
      if (input$par == "F") fitf
      else if (input$par == "M") fitm
      else fitb
    })  

    ## build newdata data frame for prediction based on user selection
    nd <- reactive({
      if (input$par == "F") data.frame(Father = input$fh , Gender = input$gd)
      else if (input$par == "M") data.frame(Mother = input$mh, Gender = input$gd)
      else data.frame(Father = input$fh , Mother = input$mh, Gender = input$gd)
    })  
    
    ## get prediction result based on user selection
    ch <- reactive({round(predict.lm(sfit(), newdata = nd(), interval ="prediction", level = input$ci/100))})

    ## create data frame for plotting result    
    pd <- reactive({
      if (input$par == "F") data.frame(x=c("Child","Child","Father"), y=c(ch()[2], ch()[3]-ch()[2],input$fh))
      else if (input$par == "M") data.frame(x=c("Child","Child","Mother"), y=c(ch()[2], ch()[3]-ch()[2],input$mh))
      else data.frame(x=c("Child","Child","Father","Mother"), y=c(ch()[2], ch()[3]-ch()[2],input$fh, input$mh))   
    })  
    
    ## Rendering outputs
    
    txt1 <- reactive({
      if (input$par == "B") paste("Prediction based on: both parents with father's height ", input$fh, "cm and mother's height ", input$mh, "cm")
      else if (input$par == "F") paste("Prediction based on: father's height ", input$fh, "cm")
      else if (input$par == "M") paste("Prediction based on: mother's height ", input$mh, "cm")
    })
    
    output$text1 <- renderText(txt1())
    output$text2 <- renderText(paste("Child's Gender: ", input$gd))
    output$text3 <- renderText(paste("Confidence Interval: ", input$ci, "%"))
    
    
    output$text4 <- renderText(paste("Child's Height: ", ch()[1], " cm (", input$ci, "% prediction interval: ", ch()[2], " cm to ", ch()[3], " cm)" ))
    
    output$plot <- renderPlot({
      ## draw comparison plot
      p <- ggplot(data = pd(), aes(x, y, fill=y)) + geom_bar(stat="identity", position="stack")
      p <- p + geom_hline(yintercept=ch()[1], color="red", size=1) + geom_text(data=data.frame(x=c("Child"), y=ch()[1]), aes(0, y[1], label=y[1], vjust= -0.5, hjust=0))
      p <- p + ylab("Height in cm") + xlab("") + labs(fill="Height")
      p
    })
  }
)
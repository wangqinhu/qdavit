shinyServer(function(input, output) {

  # Errorbar fuction
  error.bar <- function(x, y, upper, lower=upper, length=0.5, ...){
    if(length(x) != length(y) | length(y) !=length(lower) | length(lower) != length(upper))
      stop("vectors must be same length")
    arrows(x,y+upper, x, y-lower, angle=90, code=3, length=length/3, ...)
  }
  
  output$ct <- renderTable({
    inFile <- input$file1
    if (is.null(inFile))
      return(NULL)
    read.csv(inFile$datapath, header=input$header, sep=input$sep, quote=input$quote)
  })

  output$barplot <- renderPlot({
    
    inFile <- input$file1

    if (is.null(inFile))
      return(NULL)

    ct<-read.csv(inFile$datapath, header=input$header, sep=input$sep, quote=input$quote, row.names = 1)

    #----------------
    # Configuration
    #----------------
    # Number of sample
    num_sam <- nrow(ct);
    # Number of repeat
    num_rep <- dim(ct)[2]/2;
    # Line of control
    lctrl <- input$lctrl;
    # Sample name
    sam_name <- rownames(ct)

    expr=rep(NA, num_sam*num_rep)
    dim(expr)<-c(num_sam,num_rep)
    
    # ctr_ref
    ref_calibrator<-mean(as.numeric(ct[lctrl,1:num_rep]))
    calibrator<-mean(as.numeric(ct[lctrl,(num_rep+1):(2*num_rep)]-ref_calibrator))
    
    for (i in 1:num_sam) {
      ref<-mean(as.numeric(ct[i,1:num_rep]))
      # dCt
      dct<-ct[i,(num_rep+1):(2*num_rep)]-ref
      # ddCt
      ddct<-dct-calibrator
      # fold
      expr[i,1:num_rep]<-2^-ddct
    }
    fold<-t(expr)
    
    fold.means=rep(NA, num_sam)
    fold.sd=rep(NA, num_sam)

    for (i in 1:num_sam) {
      fold.means[i]<-mean(fold[,i])
      fold.sd[i]<-sd(fold[,i])
    }
    
    ymax=max(fold.means)+1.1*max(fold.sd)
    barx <- barplot(fold.means,
                    col=1,
                    ylim=c(0,ymax),
                    names.arg=sam_name,
                    ylab="Relative expression level")
    error.bar(barx,fold.means, fold.sd)
    
  })
  
  output$downloadData <- downloadHandler(
    filename <- function() {
      paste("demo", "csv", sep=".")
    },
    
    content <- function(file) {
      file.copy("demo.csv", file)
    },
    contentType = "text/csv"
  )
  
})

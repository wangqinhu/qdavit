shinyServer(function(input, output) {

  # Errorbar fuction
  error.bar <- function(x, y, upper, lower=upper, length=0.5, ...){
    if(length(x) != length(y) | length(y) !=length(lower) | length(lower) != length(upper))
      stop("vectors must be same length")
    arrows(x,y+upper, x, y, angle=90, code=1, length=length/3, ...)
  }
  
  # load CT
  load_ct <- reactive({
    inFile <- input$file1
    if (is.null(inFile))
      return(NULL)
    val<-read.csv(inFile$datapath, header=input$header, sep=input$sep, quote=input$quote, row.names = 1)
    nrow<-nrow(val)
    sam<-rownames(val)
    if (is.null(sam))
      return(NULL)
    if (is.null(val[1,1]))
      return(NULL)
    list(val=val, nrow=nrow, sam=sam, lctl=input$lctrl, col=input$col)
  })
  
  # calculate expression level
  calculate_expression <- reactive({
    
    dat<-load_ct()
    ct<-dat$val
    
    #----------------
    # Configuration
    #----------------
    # Number of sample
    num_sam <- dat$nrow
    # Number of repeat
    num_rep <- dim(ct)[2]/2
    # Line of control
    lctrl <- dat$lctl
    # Sample name
    sam_name <- dat$sam
    
    if (is.null(num_sam))
      return(NULL)
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
    
    fold.mean<-rep(NA, num_sam)
    fold.sd<-rep(NA, num_sam)
    
    for (i in 1:num_sam) {
      fold.mean[i]<-mean(fold[,i])
      fold.sd[i]<-sd(fold[,i])
    }
    
    list(mean=fold.mean, sd=fold.sd, sam=sam_name, col=dat$col)
    
  })

  # show CT values in broswer
  output$ct <- renderTable(rownames = TRUE,
                           caption = "Uploaded CT Values",
                           caption.placement = getOption("xtable.caption.placement", "top"), {
    dat<-load_ct()
    dat$val
  })

  # show expression in broswer
  output$expr <- renderTable(rownames = TRUE,
                             caption = "Relative Expression Levels",
                             caption.placement = getOption("xtable.caption.placement", "top"), {
    fold<-calculate_expression()
    if (is.null(fold))
      return(NULL)
    dat <- matrix(rbind(fold$mean, fold$sd), nrow = 2,
                  dimnames = list(c("mean", "sd"), fold$sam))
  })
  
  # show barplot in broswer
  output$barplot <- renderPlot({
    
    fold<-calculate_expression()
    if (is.null(fold))
      return(NULL)
    if (is.na(fold$mean[1]))
      return(NULL)
    ymax<-max(fold$mean)+1.1*max(fold$sd)
    
    barx <- barplot(fold$mean,
                    col=fold$col,
                    ylim=c(0,ymax),
                    names.arg=fold$sam,
                    ylab="Relative expression level")
    error.bar(barx, fold$mean, fold$sd)

  })
  
  # save pdf plot
  output$savepdf <- downloadHandler(
    filename = function() {
      paste('qPCR-', format(Sys.time(), "%Y%m%d-%H%M%S"), '.pdf', sep='')
    },
    # generate pdf file
    content <- function(file) {
      fold<-calculate_expression()
      if (is.null(fold))
        return(NULL)
      ymax<-max(fold$mean)+1.1*max(fold$sd)
      num_sam<-length(fold$sam)
      pdf(file, height = 3, width =  num_sam * 0.6)
      par(mar=c(2.5,4.5,1,1))
      barx <- barplot(fold$mean,
                      col=fold$col,
                      ylim=c(0,ymax),
                      names.arg=fold$sam,
                      ylab="Relative expression level")
      error.bar(barx, fold$mean, fold$sd, length = 0.2)
      dev.off()
    }
  )

  # download demo data
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

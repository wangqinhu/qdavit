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
    list(val=val, nrow=nrow, sam=sam, lctl=input$lctrl)
  })

  # show CT values in broswer
  output$ct <- renderTable(rownames = TRUE, {
    dat<-load_ct()
    dat$val
  })

  # show barplot in broswer
  output$barplot <- renderPlot({
    
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
      return("No samples found")
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
                    col="grey",
                    ylim=c(0,ymax),
                    names.arg=sam_name,
                    ylab="Relative expression level")
    error.bar(barx,fold.means, fold.sd)
    
  })
  
  # generate pdf plot
  output$pdfplot <- renderPlot({
    
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
      return("No samples found")
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

    pdf("plot.pdf", height = 3, width = num_sam * 0.6)
    par(mar=c(2.5,4.5,1,1))
    barx <- barplot(fold.means,
                    col="grey",
                    ylim=c(0,ymax),
                    names.arg=sam_name,
                    ylab="Relative expression level")
    error.bar(barx,fold.means, fold.sd, length = 0.2)
    dev.off()
    
  })
  
  # download pdf plot
  output$pdflink <- downloadHandler(
    filename = function() {
      paste('qPCR-', format(Sys.time(), "%Y%m%d-%H%M%S"), '.pdf', sep='')
    },
    content <- function(file) {
      file.copy("plot.pdf", file)
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

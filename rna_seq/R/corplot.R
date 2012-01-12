#correlation plot

myImagePlot <- function(x, ...){
     min <- min(x)
     max <- max(x)
     yLabels <- rownames(x)
     xLabels <- colnames(x)
     title <-c()
  # check for additional function arguments
  if( length(list(...)) ){
    Lst <- list(...)
    if( !is.null(Lst$zlim) ){
       min <- Lst$zlim[1]
       max <- Lst$zlim[2]
    }
    if( !is.null(Lst$yLabels) ){
       yLabels <- c(Lst$yLabels)
    }
    if( !is.null(Lst$xLabels) ){
       xLabels <- c(Lst$xLabels)
    }
    if( !is.null(Lst$title) ){
       title <- Lst$title
    }
  }
# check for null values
if( is.null(xLabels) ){
   xLabels <- c(1:ncol(x))
}
if( is.null(yLabels) ){
   yLabels <- c(1:nrow(x))
}

layout(matrix(data=c(1,2), nrow=1, ncol=2), widths=c(4,1), heights=c(1,1))

 # Red and green range from 0 to 1 while Blue ranges from 1 to 0
 ColorRamp <- rgb( seq(0,1,length=256),  # Red
                   seq(0.2,0.8,length=256),  # Green
                   seq(0.8,0.2,length=256))  # Blue
 ColorLevels <- seq(min, max, length=length(ColorRamp))

 # Reverse Y axis
 reverse <- nrow(x) : 1
 yLabels <- yLabels[reverse]
 x <- x[reverse,]

 # Data Map
 par(mar = c(7,7,2.5,1))
 div<-1
 image(1:length(xLabels), 1:length(yLabels), t(x), col=ColorRamp, xlab="",
 ylab="", axes=FALSE, zlim=c(min,max))
 if( !is.null(title) ){
    title(main=title)
 }
axis(BELOW<-1, at=1:length(xLabels), labels=xLabels, cex.axis=0.7, las=2)
 axis(LEFT <-2, at=1:length(yLabels), labels=yLabels, las= HORIZONTAL<-1,
 cex.axis=0.7)

 # Color Scale
 par(mar = c(3,2.5,2.5,2))
 image(1, ColorLevels,
      matrix(data=ColorLevels, ncol=length(ColorLevels),nrow=1),
      col=ColorRamp,
      xlab="",ylab="",
      xaxt="n")

 layout(1)
}

corplot<-function(MA,targets)
{
	myselect <- function (maM1,maA1,maM2,maA2,Amin){
	   index <- !is.na(maM1) & !is.na(maM2) & maA1 > Amin & maA2 > Amin
	   return(index)
	}

	arrays <- ncol(MA$M)
	# define a matrix to hold the correlation data
	cm <- array(dim=c(arrays,arrays))

	# loop through the arrays and calculate the correlations, skip NA values
	for( j in 1:arrays ){
	  for( i in 1:arrays ){
	    mi <- myselect(MA$M[,j],MA$A[,j],MA$M[,i],MA$A[,i], 5)
	    thing1 <- MA$M[mi,j]
	    thing2 <- MA$M[mi,i]
	    cm[j,i] <- cor(thing1, thing2,use="complete.obs")
	  }
	}
	# label the correlation matrix with the info in targets
	rownames(cm) <- targets$alias
	colnames(cm) <- targets$alias
	# get image plot function
	myImagePlot(cm, title="Correlation Matrix")
	return(cm);
}

corplotd<-function(d,names)
{
	arrays <- ncol(d)
	# define a matrix to hold the correlation data
	cm <- array(dim=c(arrays,arrays))

	# loop through the arrays and calculate the correlations, skip NA values
	for( j in 1:arrays ){
	  for( i in 1:arrays ){
	    thing1 <- d[,j]
	    thing2 <- d[,i]
	    cm[j,i] <- cor(thing1, thing2,use="complete.obs")
	  }
	}
	# label the correlation matrix with the info in targets
	rownames(cm) <-names 
	colnames(cm) <-names 
	# get image plot function
	myImagePlot(cm, title="Correlation Matrix")
	return(cm);
}

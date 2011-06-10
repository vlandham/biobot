library(RColorBrewer) # for blues in heatmap

raw.data <- read.delim("testDat.txt")
# use gene names for row names
row.names(raw.data) <- raw.data$gene
# remove the gene column now that it is captured in the row.names
raw.data <- raw.data[,2:ncol(raw.data)]

# find the column means for each column
data.col.means <- colMeans(raw.data, na.rm = TRUE)
# replace missing values in each column with the column mean
#  using a loop as I couldn't come up with a way to do this
#  with sapply() or something similar
filled.data <- raw.data
for (x in c(1:ncol(filled.data))) {
  filled.data[, x] <- replace(filled.data[, x], is.na(filled.data[, x]), data.col.means[x])
}

# convert into matrix for heatmap use
matrix.data <- data.matrix(filled.data)

# hack to have positive means for top plot
bar.data <- abs(data.col.means)

# save original par
orig.par <- par(no.readonly = TRUE)

# values used by various graphs
linecolor <- "dimgray"
border.width <- 0.25

# setup layout to have 1 column and 2 rows
nf <- layout(matrix(c(1, 2), 2, 1, byrow = TRUE), widths = c(1), heights = c(1, 3), respect = FALSE)

#setup plot
#TODO: width and xlim need a lot of tweaking to make them look decent
par(mar = c(0, border.width, border.width, border.width))
barplot(bar.data, axes = FALSE, ylim = c(0, max(bar.data)), space = 0, col = "#4292C6", border = linecolor, width = 1.04, xlim = c(0.40, 10))

#setup heatmap
par(mar = c(2.5, border.width, 0, border.width))
# Reason it needs to be transposed:
# Notice that image interprets the z matrix as a table of f(x[i], y[j]) values, 
#   so that the x axis corresponds to row number and the y axis to column number, 
#   with column 1 at the bottom, i.e. a 90 degree counter-clockwise rotation of the 
#   conventional printed layout of a matrix.
image(t(matrix.data), axes = FALSE, col = brewer.pal(9, "Blues"))
box( col = linecolor, lwd = 3)
axis(1, col = linecolor)

#restore par
par(orig.par)


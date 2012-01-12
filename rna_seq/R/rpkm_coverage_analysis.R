setwd('/Volumes/core/Bioinformatics/analysis/MolBio/kzg/molng_23/')
opar <- par(col = "#88C2F1", fg = "#8C9195", bg = "#ffffff", family = "sans")

#sample.names = c("UMR_10ng", "UMR_100ng", "UMR_1ug")

#sample.names = c("UMR_SuperAmp0.12", "UMR_SuperAmp1.1", "UMR_SuperAmp3.3", "UMR_SuperAmp10")
sample.names = c("UMR_SuperAmp0.12", "UMR_SuperAmp1.1", "UMR_SuperAmp3.3", "UMR_SuperAmp10", "UMR_10ng", "UMR_100ng", "UMR_1ug")
image.suffix <- "_all"
image.dir <- "images_all"

express.dir <- "unique_genes_expressed"

dir.create(express.dir)

dir.create(image.dir)
dir.create(paste(image.dir, "ma", sep="/"))
dir.create(paste(image.dir, "scatter", sep="/"))
#dir.create(paste("analysis", "scatter", sep="/"))

for (sample.name in sample.names) {
  sample.file.name <- paste("fpkm/", sample.name, ".genes.fpkm_tracking", sep="")
  sample.var.name <- paste(sample.name, ".genes.fpkm", sep="")
  assign(sample.var.name, read.table(sample.file.name, quote = '', header = T, sep = '\t', skip = 0, comment.char = ""))
}

genes.count <- nrow(get(paste(sample.names[1], ".genes.fpkm", sep="")))

all.fpkms.short <- data.frame(0,0,0,0)
fpkm.col.names <- c( "tracking_id", "gene_id", "locus")
names(all.fpkms.short) <- c(fpkm.col.names, "FPKM")
previous.name <- "null"
expressed.genes <- vector()
for (sample.name in sample.names) {
  sample.var.name <- paste(sample.name, ".genes.fpkm", sep="")
  fpkms <- get(sample.var.name)
  fpkms[fpkms$status != "OK",]$FPKM <- 0.0
  sample.var.name <- paste(sample.name, ".genes.fpkm.short", sep="")
  assign(sample.var.name, fpkms[,c("tracking_id", "gene_id", "locus", "FPKM")])
  fpkms.short <- get(sample.var.name)
  all.fpkms.short <- merge(all.fpkms.short, fpkms.short, all.y=TRUE, by = c("tracking_id", "gene_id", "locus"), sort = FALSE, suffixes = c(paste(".", previous.name, sep=""), paste(".",sample.name,sep="")))
  
  previous.name <- sample.name
  fpkm.col.names <- c(fpkm.col.names, sample.name)
  
  expressed.gene <- nrow(subset(fpkms, FPKM > 0.1))
  expressed.genes <- c(expressed.genes, expressed.gene) 
}
expressed.genes <- data.frame(expressed.genes)
row.names(expressed.genes) <- sample.names


image.name <- paste("./", image.dir, "/number_genes_expression_values", image.suffix, ".png", sep = "")
png(image.name, height=500, width=800)
temppar <- par(col = "#88C2F1", fg = "#8C9195", bg = "#ffffff", family = "sans", cex.axis = 0.5)
barplot(expressed.genes[,1], ylab = "Number of Genes", names.arg = sample.names, xlab = "Sample", main = "Number of Genes with Expression Values")
par(temppar)
dev.off()

percent.genes.expressed <- round((expressed.genes[,1] / genes.count) * 100, digit = 2)

image.name <- paste("./", image.dir, "/percent_genes_expression_values", image.suffix, ".png", sep = "")
png(image.name, height=500, width=800)
temppar <- par(col = "#88C2F1", fg = "#8C9195", bg = "#ffffff", family = "sans", cex.axis = 0.5)
barplot(percent.genes.expressed, ylim = c(0,50), ylab = "% Genes Expressed", names.arg = sample.names, xlab = "Sample", main = "Percentage of Total with Expression Values")
par(temppar)
dev.off()

all.fpkms.short$FPKM.null = NULL
names(all.fpkms.short) <- fpkm.col.names

image.name <- paste("./", image.dir, "/samples_expression_values_scatter", image.suffix, ".png", sep = "")
png(image.name, height=500, width=800)
temppar <- par(col = "#88C2F1", fg = "#8C9195", bg = "#ffffff", family = "sans")
plot(all.fpkms.short[,sample.names], main = "Expression Values of Samples")
par(temppar)
dev.off()

image.name <- paste("./", image.dir, "/samples_log_expression_values_scatter", image.suffix, ".png", sep = "")
png(image.name, height=500, width=800)
temppar <- par(col = "#88C2F1", fg = "#8C9195", bg = "#ffffff", family = "sans")
plot(log2(all.fpkms.short[,sample.names]), main = "Log2 Expression Values of Samples")
par(temppar)
dev.off()

source('./code/corplot.R')

image.name <- paste("./", image.dir, "/correlation_plot_samples", image.suffix, ".png", sep = "")
png(image.name, height=500, width=800)
temppar <- par(col = "#88C2F1", fg = "#8C9195", bg = "#ffffff", family = "sans")
corplotd(all.fpkms.short[, sample.names], sample.names)
par(temppar)
dev.off()

# log based analysis
log2.fpkms.short <- log2(all.fpkms.short[,sample.names])
log2.fpkms.short.fixed <- data.frame(apply(log2.fpkms.short, 2, function(x) {x[is.infinite(x)] <- min(x[!is.infinite(x)]); x}))

#plot(log2.fpkms.short.fixed)

image.name <- paste("./", image.dir, "/correlation_plot_log2_samples", image.suffix, ".png", sep = "")
png(image.name, height=500, width=800)
temppar <- par(col = "#88C2F1", fg = "#8C9195", bg = "#ffffff", family = "sans")
corplotd(log2.fpkms.short.fixed, sample.names)
par(temppar)
dev.off()

for (sample.name in sample.names) {
  for(sample.name.2 in sample.names) {
    if(sample.name != sample.name.2) {
    image.name <- paste("./", image.dir, "/scatter/samples_log_expression_values_scatter_", sample.name, "_vs_", sample.name.2, image.suffix, ".png", sep = "")
    graph.title <- paste("Log2 Expression Values: ", sample.name, " vs ", sample.name.2, sep = "")
    xlab = paste("log2 ", sample.name, sep="")
    ylab = paste("log2 ", sample.name.2, sep="")
    png(image.name, height=500, width=800)
    temppar <- par(col = "#88C2F1", fg = "#8C9195", bg = "#ffffff", family = "sans")
    plot(log2(all.fpkms.short[,sample.name]),log2(all.fpkms.short[,sample.name.2]), main = graph.title, xlab = xlab, ylab = ylab)
    abline(0,1)
    par(temppar)
    dev.off()
    
    
    ### MA Plots
    high.mean.points <- all.fpkms.short[log2(all.fpkms.short[, sample.name]) - log2(all.fpkms.short[, sample.name.2]) > 1,]
    low.mean.points <- all.fpkms.short[log2(all.fpkms.short[, sample.name]) - log2(all.fpkms.short[, sample.name.2]) < -1,]
    mid.mean.points <- all.fpkms.short[(log2(all.fpkms.short[, sample.name]) - log2(all.fpkms.short[, sample.name.2]) >= -1) & (log2(all.fpkms.short[, sample.name]) - log2(all.fpkms.short[, sample.name.2]) <= 1),]
    #plot(rowMeans(log2(all.fpkms.short[,c(sample.name, sample.name.2)])), log2(all.fpkms.short[, sample.name]) - log2(all.fpkms.short[, sample.name.2]), main = "MA Plot of UMR_10ng vs UMR_1ug Expression Values", ylab = "log2(UMR_10ng) - log2(UMR_1ug)", xlab = "Mean of log2(UMR_10ng) and log2(UMR_1ug)")

    image.name <- paste("./", image.dir, "/ma/lsk_maplot_", sample.name, "_vs_", sample.name.2, image.suffix, ".png", sep = "")
    png(image.name, height=800, width=800)
    temppar <- par(col = "#88C2F1", fg = "#8C9195", bg = "#ffffff", family = "sans")
    main <- paste("MA Plot of ", sample.name, " vs ", sample.name.2, " Expression Values", sep="")
    ylab <- paste("log2(", sample.name, ") - log2(", sample.name.2, ")", sep="")
    xlab <- paste("Mean of log2(", sample.name,") and log2(", sample.name.2, ")", sep="")
    plot(rowMeans(log2(mid.mean.points[,c(sample.name, sample.name.2)])), log2(mid.mean.points[, sample.name]) - log2(mid.mean.points[, sample.name.2]), main = main, ylab = ylab, xlab = xlab, ylim = c(-15,15), xlim = c(-15,15))
    points( rowMeans(log2(low.mean.points[,c(sample.name, sample.name.2)])),log2(low.mean.points[, sample.name]) - log2(low.mean.points[, sample.name.2]), col = "green")
    points( rowMeans(log2(high.mean.points[,c(sample.name, sample.name.2)])),log2(high.mean.points[, sample.name]) - log2(high.mean.points[, sample.name.2]), col = "red")
    par(temppar)
    dev.off()
    }
  }
}

# determine genes only expressed in one sample - for each sample
library(biomaRt)
ensembl = useMart("ensembl")
mart <- useMart(biomart="ensembl", dataset="mmusculus_gene_ensembl")
for (i in 1:length(sample.names)) {
  not.cols <- sample.names[-i]
  sums <- rowSums(all.fpkms.short[,not.cols])
  iv <- sums == 0
  iv.2 <- all.fpkms.short[,sample.names[i]] > 0
  
  
  uniq.exp <- all.fpkms.short[iv & iv.2,]
  unique.exp.var.name <- paste("only.", sample.names[i], ".expressed", sep = "")
  
  assign(unique.exp.var.name, uniq.exp)
  
  table.name <- paste("analysis/", unique.exp.var.name, ".txt", sep = "")
  write.table(uniq.exp, file =table.name, sep = "\t", quote = FALSE)
  
  gene.info <- getBM(attributes = c("ensembl_gene_id", "external_gene_id", "chromosome_name",  "gene_biotype", "description"), filters = "ensembl_gene_id", values = uniq.exp$gene_id, mart = mart)
  uniq.exp.and.info <- merge(gene.info, uniq.exp, by.x = "ensembl_gene_id", by.y = "gene_id", sort = FALSE)
  
  unique.exp.and.info.var.name <- paste(unique.exp.var.name, ".with.info", sep = "")
  table.name <- paste(express.dir, "/", unique.exp.and.info.var.name, ".csv", sep = "")
  write.csv(uniq.exp.and.info, file = table.name, quote = FALSE)
  assign(unique.exp.and.info.var.name, uniq.exp.and.info)
}

exp.values <- all.fpkms.short[,sample.names] > 0
exp.values.int <- exp.values * 1
#hist(rowSums(exp.values.int), freq = T, right = T, breaks = 9)
exp.values.not.zero <- exp.values.int[(rowSums(exp.values.int) != 0),]
#hist(rowSums(exp.values.not.zero), breaks = 8, freq = T)

image.name <- paste("./", image.dir, "/histogram_number_genes_covered_by_num_samples", image.suffix, ".png", sep = "")
png(image.name, height=500, width=800)
temppar <- par(col = "#444444", fg = "#8C9195", bg = "#ffffff", family = "sans")
hist(rowSums(exp.values.not.zero), breaks = 8, freq = T,col = "#dddddd", ylab = "Number of Genes", xlab = "Number of Samples", main = "Histogram of Genes Expressed in Samples")
par(temppar)
dev.off()



par(opar)

### only expressed in UMR_1ug
#source("http://www.bioconductor.org/biocLite.R")
#biocLite("biomaRt")
#library(biomaRt)
#all.only.UMR_1ug.expressed <- subset(all.fpkms.short, ((UMR_1ug > 0) & (UMR_10ng == 0  & UMR_100ng == 0)))
#all.only.UMR_10ng.expressed <- subset(all.fpkms.short, ((UMR_10ng > 0) & (UMR_1ug == 0  & UMR_100ng == 0)))
#all.only.UMR_100ng.expressed <- subset(all.fpkms.short, ((UMR_100ng > 0) & (UMR_1ug == 0  & UMR_10ng == 0)))
#write.table(all.only.UMR_1ug.expressed, file = "./analysis/genes_only_expressed_in_UMR_1ug.txt", sep = "\t", quote = FALSE)

#ensembl = useMart("ensembl")
#mart <- useMart(biomart="ensembl", dataset="mmusculus_gene_ensembl")
#all.only.UMR_1ug.expressed.info <- getBM(attributes = c("ensembl_gene_id", "external_gene_id", "chromosome_name",  "gene_biotype", "description"), filters = "ensembl_gene_id", values = all.only.UMR_1ug.expressed$gene_id, mart = mart)
#all.only.UMR_1ug.expressed.info.expression <- merge(all.only.UMR_1ug.expressed.info, all.only.UMR_1ug.expressed, by.x = "ensembl_gene_id", by.y = "gene_id", sort = FALSE)

#write.table(all.only.UMR_1ug.expressed.info, file = "./analysis/genes_only_expressed_in_UMR_1ug.info.txt", sep = "\t", quote = FALSE)
#write.csv(all.only.UMR_1ug.expressed.info.expression, file = "./genes_only_expressed_in_UMR_1ug_info_and_expression.csv", quote = FALSE)

### MA Plots
#high.mean.points <- all.fpkms.short[log2(all.fpkms.short[, "UMR_10ng"]) - log2(all.fpkms.short[, "UMR_1ug"]) > 1,]
#low.mean.points <- all.fpkms.short[log2(all.fpkms.short[, "UMR_10ng"]) - log2(all.fpkms.short[, "UMR_1ug"]) < -1,]
#mid.mean.points <- all.fpkms.short[(log2(all.fpkms.short[, "UMR_10ng"]) - log2(all.fpkms.short[, "UMR_1ug"]) >= -1) & (log2(all.fpkms.short[, "UMR_10ng"]) - log2(all.fpkms.short[, "UMR_1ug"]) <= 1),]
#plot(rowMeans(log2(all.fpkms.short[,c("UMR_10ng", "UMR_1ug")])), log2(all.fpkms.short[, "UMR_10ng"]) - log2(all.fpkms.short[, "UMR_1ug"]), main = "MA Plot of UMR_10ng vs UMR_1ug Expression Values", ylab = "log2(UMR_10ng) - log2(UMR_1ug)", xlab = "Mean of log2(UMR_10ng) and log2(UMR_1ug)")


#png("./analysis/lsk_maplot_umr_10ng_umr_1ug.png", height=800, width=800)
#temppar <- par(col = "#88C2F1", fg = "#8C9195", bg = "#ffffff", family = "sans")
#plot(rowMeans(log2(mid.mean.points[,c("UMR_10ng", "UMR_1ug")])), log2(mid.mean.points[, "UMR_10ng"]) - log2(mid.mean.points[, "UMR_1ug"]), main = "MA Plot of UMR_10ng vs UMR_1ug Expression Values", ylab = "log2(UMR_10ng) - log2(UMR_1ug)", xlab = "Mean of log2(UMR_10ng) and log2(UMR_1ug)", ylim = c(-15,15), xlim = c(-15,15))
#points( rowMeans(log2(low.mean.points[,c("UMR_10ng", "UMR_1ug")])),log2(low.mean.points[, "UMR_10ng"]) - log2(low.mean.points[, "UMR_1ug"]), col = "green")
#points( rowMeans(log2(high.mean.points[,c("UMR_10ng", "UMR_1ug")])),log2(high.mean.points[, "UMR_10ng"]) - log2(high.mean.points[, "UMR_1ug"]), col = "red")
#par(temppar)
#dev.off()


#high.mean.points <- all.fpkms.short[log2(all.fpkms.short[, "UMR_100ng"]) - log2(all.fpkms.short[, "UMR_1ug"]) > 1,]
#low.mean.points <- all.fpkms.short[log2(all.fpkms.short[, "UMR_100ng"]) - log2(all.fpkms.short[, "UMR_1ug"]) < -1,]
#mid.mean.points <- all.fpkms.short[(log2(all.fpkms.short[, "UMR_100ng"]) - log2(all.fpkms.short[, "UMR_1ug"]) >= -1) & (log2(all.fpkms.short[, "UMR_100ng"]) - log2(all.fpkms.short[, "UMR_1ug"]) <= 1),]
#plot(rowMeans(log2(all.fpkms.short[,c("UMR_100ng", "UMR_1ug")])), log2(all.fpkms.short[, "UMR_100ng"]) - log2(all.fpkms.short[, "UMR_1ug"]), main = "MA Plot of UMR_100ng vs UMR_1ug Expression Values", ylab = "log2(UMR_100ng) - log2(UMR_1ug)", xlab = "Mean of log2(UMR_100ng) and log2(UMR_1ug)")


#png("./analysis/lsk_maplot_umr_100ng_umr_1ug.png", height=800, width=800)
#temppar <- par(col = "#88C2F1", fg = "#8C9195", bg = "#ffffff", family = "sans")
#plot(rowMeans(log2(mid.mean.points[,c("UMR_100ng", "UMR_1ug")])), log2(mid.mean.points[, "UMR_100ng"]) - log2(mid.mean.points[, "UMR_1ug"]), main = "MA Plot of UMR_100ng vs UMR_1ug Expression Values", ylab = "log2(UMR_100ng) - log2(UMR_1ug)", xlab = "Mean of log2(UMR_100ng) and log2(UMR_1ug)", ylim = c(-15,15), xlim = c(-15,15))
#points( rowMeans(log2(low.mean.points[,c("UMR_100ng", "UMR_1ug")])),log2(low.mean.points[, "UMR_100ng"]) - log2(low.mean.points[, "UMR_1ug"]), col = "green")
#points( rowMeans(log2(high.mean.points[,c("UMR_100ng", "UMR_1ug")])),log2(high.mean.points[, "UMR_100ng"]) - log2(high.mean.points[, "UMR_1ug"]), col = "red")
#par(temppar)
#dev.off()


###
# deltas in FPKM
###
# deltas <- list(c(1,1), c(1,2), c(2,3))
# 
# 
# #all.deltas <- list(c(1,1),c(1,2), c(2,3), c(3,4), c(4,5), c(5,6))
# f <- function(delta.set, fpkms) {
#   #rtn <- foldchange(fpkms[,delta.set[1]], fpkms[,delta.set[2]])
#   rtn <- fpkms[,delta.set[2]] - fpkms[,delta.set[1]]
#   rtn[is.infinite(rtn)] <- 0
#   rtn
# }
# lsk.deltas <- sapply(deltas, FUN=f, fpkms = LSK.fpkms)
# #lsk.deltas[is.infinite(lsk.deltas)] <- 0
# mouseqk90 <- apply(lsk.deltas, 2, FUN=function(x){quantile(x, c(0.05,0.95), na.rm=T)})

# png("./analysis/RPKM_stability.png", height=500, width=500)
# temppar <- par(cex=1.3, font.axis=2, font.lab=2, las=1, font=2)
# plot(0, 0, col=0, xlim=c(1,3), ylim=c(-30,30), xaxt="n", xlab="Samples", ylab="Fold-Change", main="RPKM Stability as Cell Numbers Increase")
# abline(h=0)
# lines(lowess(mouseqk90[1,], f=0.5), col=4, lwd=2, lty=2)
# lines(lowess(mouseqk90[2,], f=0.5), col=4, lwd=2, lty=2)
# axis(1, at=1:3, labels=names(LSK.fpkms))
# par(temppar)
# dev.off()
# 
# 

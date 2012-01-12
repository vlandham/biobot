setwd('/Volumes/core/Bioinformatics/analysis/MolBio/kzg/molng_23/')

opar <- par(col = "#88C2F1", fg = "#8C9195", bg = "#ffffff", family = "sans")

get.gene.names <- function(names.column) {
  split <- strsplit(as.vector(names.column), ":")
  split.names <- lapply(split, function(x) x[1])
  split.names
}
annotation.file <- "mm9.uxons.bed"
exons <- read.table(paste("annotations/", annotation.file, sep=""), quote = '', header = F, sep = '\t', skip = 0, comment.char = "")
exons.count <- nrow(exons)

genes <- read.table(paste("annotations/", annotation.file, ".genes.txt", sep=""), quote = '', header = F, sep = '\t', skip = 0, comment.char = "")
genes.count <- nrow(genes)
unique.genes.count <- nrow(unique(genes))

#sample.names = c("UMR_10ng", "UMR_100ng", "UMR_1ug")
sample.names = c("UMR_SuperAmp0.12", "UMR_SuperAmp1.1", "UMR_SuperAmp3.3", "UMR_SuperAmp10", "UMR_10ng", "UMR_100ng", "UMR_1ug")
image.suffix <- "_all"
image.dir <- "images_all_uxon"

min.coverage <- 0.10

sample.count <- length(sample.names)

for (sample.name in sample.names) {
  sample.file.name <- paste("coverage/", annotation.file, ".", sample.name, ".coverageBed.out.txt", sep="")
  sample.var.name <- paste(sample.name, ".exon.coverage", sep="")
  assign(sample.var.name, read.table(sample.file.name, quote = '', header = F, sep = '\t', skip = 0, comment.char = ""))
  exons <- get(sample.var.name)
}

chrs <- c("chr1", "chr2", "chr3", "chr4", "chr5", "chr6", "chr7", "chr8", "chr9", "chr10", "chr11", "chr12", "chr13", "chr14", "chr15", "chr16", "chr17", "chr18", "chr19", "chrX", "chrY")
chrs.totals <- vector()
for(chr in chrs) {
  chr.total <- nrow(subset(exons, V1 == chr))
  chrs.totals <- c(chrs.totals, chr.total)
}

covered.counts <- vector()
covered.unique.genes <- vector()
covered.chroms.counts <- data.frame()
for (sample.name in sample.names) {
  sample.var.name <- paste(sample.name, ".exon.coverage", sep="")
  exons <- get(sample.var.name)
  
  sample.only.covered.name <- paste(sample.name, ".covered.exons", sep="")
  assign(sample.only.covered.name, subset(exons, V10 > min.coverage ))
  covered.exons <- get(sample.only.covered.name)
  
  covered.count <-  nrow(covered.exons)
  covered.counts <- c(covered.counts, covered.count)
  sample.exon.names.name <- paste(sample.name, ".covered.exons.names", sep="")
  
  assign(sample.exon.names.name, covered.exons$V4)

  gene.names <- get.gene.names(covered.exons$V4)
  covered.unique.genes <- c(covered.unique.genes, length(unique(gene.names)))
  
  chr.counts <- vector()
  for(chr in chrs) {
    chr.count <- nrow(covered.exons[covered.exons$V1 == chr,])
    chr.counts <- c(chr.counts, chr.count)
  }
  covered.chroms.counts <- rbind(covered.chroms.counts, chr.counts)
  
}
names(covered.chroms.counts) <- chrs
row.names(covered.chroms.counts) <- sample.names
  
covered.unique.genes.percents <- round((covered.unique.genes / unique.genes.count) * 100.0, digits = 2)

image.name <- paste("./", image.dir, "/percent_genes_covered", image.suffix, ".png", sep = "")
png(image.name, height=500, width=800)
temppar <- par(col = "#88C2F1", fg = "#8C9195", bg = "#ffffff", family = "sans", cex.axis = 0.5)
barplot(covered.unique.genes.percents, ylim = c(0,70), ylab = "% of Total Genes Covered", names.arg = sample.names, xlab = "Sample", main = "Percentage of All Genes Covered per Sample")
par(temppar)
dev.off()

covered.counts <- data.frame(covered.counts)
row.names(covered.counts) <- sample.names

#png("./analysis/covered_counts.png", height=500, width=800)
#temppar <- par(col = "#88C2F1", fg = "#8C9195", bg = "#ffffff", family = "sans")
barplot(as.matrix(covered.counts), beside = TRUE)
#par(temppar)
#dev.off()

covered.exon.percent <- round((covered.counts$covered.counts / exons.count) * 100, digits = 2)

image.name <- paste("./", image.dir, "/percent_exons_covered", image.suffix, ".png", sep = "")
png(image.name, height=500, width=800)
temppar <- par(col = "#88C2F1", fg = "#8C9195", bg = "#ffffff", family = "sans", cex.axis = 0.5)
barplot(covered.exon.percent,  ylim = c(0,70), ylab = "% Unique Exons Covered", names.arg = sample.names, xlab = "Sample", main = "Percentage of All Exons Covered per Sample")
par(temppar)
dev.off()

image.name <- paste("./", image.dir, "/number_exons_covered", image.suffix, ".png", sep = "")
png(image.name, height=500, width=800)
temppar <- par(col = "#88C2F1", fg = "#8C9195", bg = "#ffffff", family = "sans", cex.axis = 0.5)
barplot(as.matrix(covered.chroms.counts), beside = TRUE, space = c(0,3), legend.text = T, ylab = "Number of Exons Covered", main = "Number of Exons Covered per Sample by Chromosome")
par(temppar)
dev.off()
  
f <- function(x) {
  d <- round((x / x[sample.count + 1]) * 100, digits = 2)
  d
}
covered.chroms.counts.with.total <- rbind(covered.chroms.counts, chrs.totals)
covered.chroms.percent <- apply(covered.chroms.counts.with.total, 2, f)
covered.chroms.percent <- covered.chroms.percent[c(1:sample.count),]

image.name <- paste("./", image.dir, "/percent_all_exons_covered", image.suffix, ".png", sep = "")
png(image.name, height=500, width=800)
temppar <- par(col = "#88C2F1", fg = "#8C9195", bg = "#ffffff", family = "sans", cex.axis = 0.5)
barplot(as.matrix(covered.chroms.percent), beside = TRUE, space = c(0,3), legend.text = T, ylab = "% Unique Exons Covered", main = "Percentage of All Exons Covered per Sample by Chromosome")
par(temppar)
dev.off()


########

#install.packages("stringr")
#install.packages("sm")
library(stringr)
#library(sm)
shared.exons.10ng.SuperAmp10 <- merge(UMR_10ng.covered.exons, UMR_SuperAmp10.covered.exons, by = c("V1", "V2", "V3", "V4", "V5", "V6"), sort = F, suffixes = c(".10ng", ".SA10"))
nrow(shared.exons.10ng.SuperAmp10) / nrow(UMR_SuperAmp10.covered.exons)
nrow(shared.exons.10ng.SuperAmp10) / nrow(UMR_SuperAmp10.covered.exons)


names <- str_split_fixed(shared.exons.10ng.SuperAmp10$V4, ":", 2)
shared.exons.10ng.SuperAmp10$gene.name <- names[,1]

UMR_10ng.unique.iv <- !(UMR_10ng.covered.exons[,"V4"] %in% shared.exons.10ng.SuperAmp10$V4)
UMR_10ng.unique <- UMR_10ng.covered.exons[UMR_10ng.unique.iv,]
names <- str_split_fixed(UMR_10ng.unique$V4, ":", 2)
UMR_10ng.unique$gene.name <- names[,1]

(nrow(UMR_10ng.unique) + nrow(shared.exons.10ng.SuperAmp10)) - nrow(UMR_10ng.covered.exons)

genes.bed <- read.table(paste("annotations/", "mm9.Ens_63.genes.bed", sep=""), quote = '', header = F, sep = '\t', skip = 0, comment.char = "")

colnames(genes.bed) <- c("chr", "gene.start", "gene.end", "gene.name", "num", "strand")

shared.exons.10ng.SuperAmp10.with.genes <- merge(shared.exons.10ng.SuperAmp10, genes.bed, by.x ="gene.name", by.y = "gene.name", sort = F)

UMR_10ng.unique.with.genes <- merge(UMR_10ng.unique, genes.bed, by.x ="gene.name", by.y = "gene.name", sort = F)

uniq.shared.gene.names <- unique(shared.exons.10ng.SuperAmp10.with.genes$gene.name)
uniq.uniq.gene.names <- unique(UMR_10ng.unique.with.genes$gene.name)

shared.genes <- subset(genes.bed, gene.name %in% uniq.shared.gene.names)
uniq.genes <- subset(genes.bed, gene.name %in% uniq.uniq.gene.names)

library(biomaRt)
ensembl = useMart("ensembl")
mart <- useMart(biomart="ensembl", dataset="mmusculus_gene_ensembl")
uniq.gene.info <- getBM(attributes = c("ensembl_gene_id", "external_gene_id", "chromosome_name",  "gene_biotype", "description"), filters = "ensembl_gene_id", values = UMR_10ng.unique.with.genes$gene.name, mart = mart)

shared.gene.info <- getBM(attributes = c("ensembl_gene_id", "external_gene_id", "chromosome_name",  "gene_biotype", "description"), filters = "ensembl_gene_id", values = shared.exons.10ng.SuperAmp10.with.genes$gene.name, mart = mart)

uniq.start.site <-log2(UMR_10ng.unique.with.genes$V2 - UMR_10ng.unique.with.genes$gene.start)
shared.start.site <- log2(shared.exons.10ng.SuperAmp10.with.genes$V2 - shared.exons.10ng.SuperAmp10.with.genes$gene.start)
plot(density(uniq.start.site))
lines(density(shared.start.site), col = "steelblue")

uniq.gene.length <- log2(uniq.genes$gene.end - uniq.genes$gene.start)
shared.gene.length <- log2(shared.genes$gene.end - shared.genes$gene.start)
plot(density(uniq.gene.length))
lines(density(shared.gene.length), col = "steelblue")

uniq.end.site <-log2(UMR_10ng.unique.with.genes$gene.end - UMR_10ng.unique.with.genes$V3)
shared.end.site <-log2(shared.exons.10ng.SuperAmp10.with.genes$gene.end - shared.exons.10ng.SuperAmp10.with.genes$V3)
plot(density(uniq.end.site))
lines(density(shared.end.site), col = "steelblue")


uniq.start.from.end <-log2(UMR_10ng.unique.with.genes$gene.end - UMR_10ng.unique.with.genes$V2)
shared.start.from.end <-log2(shared.exons.10ng.SuperAmp10.with.genes$gene.end - shared.exons.10ng.SuperAmp10.with.genes$V2)
plot(density(uniq.start.from.end))
lines(density(shared.end.site), col = "steelblue")

uniq.exon.length <- log2(UMR_10ng.unique.with.genes$V3 - UMR_10ng.unique.with.genes$V2)
shared.exon.length <- log2(shared.exons.10ng.SuperAmp10.with.genes$V3 - shared.exons.10ng.SuperAmp10.with.genes$V2)
plot(density(uniq.exon.length))
lines(density(shared.exon.length), col = "steelblue")

shared.gene.loc <- as.numeric(shared.gene.info$chromosome_name)
shared.gene.loc[is.na(shared.gene.loc)] <- 30

uniq.gene.loc <- as.numeric(uniq.gene.info$chromosome_name)
uniq.gene.loc[is.na(uniq.gene.loc)] <- 30

plot(density(uniq.gene.loc))
lines(density(shared.gene.loc), col = "steelblue")


hist(log2(UMR_10ng.unique.with.genes$V2 - UMR_10ng.unique.with.genes$gene.start), breaks = 1000, freq = F)
hist(log2(shared.exons.10ng.SuperAmp10.with.genes$V2 - shared.exons.10ng.SuperAmp10.with.genes$gene.start), breaks = 1000, freq = F)

hist(log2(shared.exons.10ng.SuperAmp10.with.genes$gene.end - shared.exons.10ng.SuperAmp10.with.genes$gene.start), breaks = 1000, freq = T)
hist(log2(UMR_10ng.unique.with.genes$gene.end - UMR_10ng.unique.with.genes$gene.start), breaks = 1000, freq = T)
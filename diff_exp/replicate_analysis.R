replace.with.lowest<-function(dataframe, column)
{
  not.zero <- dataframe[, column] != 0
  min_value <- min(dataframe[not.zero, column])
  dataframe[!not.zero, column] <- min_value
  return(dataframe)
}

combine.replicates<-function(dataframe_1, dataframe_2)
{
  dataframe_1.short <- dataframe_1[, c("tracking_id","gene_short_name","FPKM")]
  dataframe_2.short <- dataframe_2[, c("tracking_id","gene_short_name", "FPKM")]
  dataframes.fpkm <- merge(dataframe_1.short, dataframe_2.short, suffixes = c(".1", ".2"), by = c("tracking_id", "gene_short_name"), sort = FALSE, all = TRUE)
  dataframes.exp <- subset(dataframes.fpkm, (FPKM.1 != 0 & FPKM.2 != 0))
  return(dataframes.exp)
}

fix.missing.values<-function(dataframes.exp)
{
  dataframes.fix <- dataframes.exp
  dataframes.fix$org.FPKM.1 <- dataframes.fix$FPKM.1
  dataframes.fix$org.FPKM.2 <- dataframes.fix$FPKM.2
  
  dataframes.fix <- replace.with.lowest(dataframes.fix, "FPKM.1")
  dataframes.fix <- replace.with.lowest(dataframes.fix, "FPKM.2")
  
  return(dataframes.fix)
}

add.log2.values<-function(dataframe)
{
  dataframe$log2.FPKM.1 <- log2(dataframe$FPKM.1)
  dataframe$log2.FPKM.2 <- log2(dataframe$FPKM.2)
  return(dataframe)
}

source('/Volumes/projects/mcm/R/utilities/corplot.R')
setwd('/Volumes/core/Bioinformatics/analysis/Trainor/kei/trainor_2011_05_09/')

g14mull04_1.all <- read.table('raw_cufflinks_output/g14mull04_1/genes.fpkm_tracking', quote = '', header = T, sep = '\t', skip = 0, comment.char = "")
g14mull04_1.all <- subset(g14mull04_1.all, status == "OK")
g14mull04_2.all <- read.table('raw_cufflinks_output/g14mull04_2/genes.fpkm_tracking', quote = '', header = T, sep = '\t', skip = 0, comment.char = "")
g14mull04_2.all <- subset(g14mull04_2.all, status == "OK")
g14wtd_1.all <- read.table('raw_cufflinks_output/g14wtd_1/genes.fpkm_tracking', quote = '', header = T, sep = '\t', skip = 0, comment.char = "")
g14wtd_1.all <- subset(g14wtd_1.all, status == "OK")
g14wtd_2.all <- read.table('raw_cufflinks_output/g14wtd_2/genes.fpkm_tracking', quote = '', header = T, sep = '\t', skip = 0, comment.char = "")
g14wtd_2.all <- subset(g14wtd_2.all, status == "OK")

g14mull04 <- combine.replicates(g14mull04_1.all, g14mull04_2.all)
g14mull04.only.1 <- subset(g14mull04, FPKM.2 == 0)
g14mull04.only.2 <- subset(g14mull04, FPKM.1 == 0)
g14mull04.fix <- add.log2.values(g14mull04)

g14wtd <- combine.replicates(g14wtd_1.all, g14wtd_2.all)
g14wtd.only.1 <- subset(g14wtd, FPKM.2 == 0)
g14wtd.only.2 <- subset(g14wtd, FPKM.1 == 0)
g14wtd.fix <- add.log2.values(g14wtd)

g14.all <- merge(g14wtd, g14mull04, suffixes = c(".wtd", ".mull"), by = c("tracking_id", "gene_short_name"), sort = FALSE, all = TRUE)
g14.all.fix <- merge(g14wtd.fix, g14mull04.fix, suffixes = c(".wtd", ".mull"), by = c("tracking_id", "gene_short_name"), sort = FALSE, all = TRUE)
corplotd(g14.all[, c("FPKM.1.wtd","FPKM.2.wtd", "FPKM.1.mull", "FPKM.2.mull")], c("g14wtd_1", "g14wtd_2", "g14mull04_1","g14mull04_2"))
corplotd(g14.all.fix[, c("log2.FPKM.1.mull","log2.FPKM.2.mull", "log2.FPKM.1.wtd", "log2.FPKM.2.wtd")], c("g14mull04_1", "g14mull04_2", "g14wtd_1","g14wtd_2"))

plot(g14wtd.fix$log2.FPKM.1, g14wtd.fix$log2.FPKM.2)
plot(g14mull04.fix$log2.FPKM.1, g14mull04.fix$log2.FPKM.2)

plot(g14.all.fix$log2.FPKM.1.wtd, g14.all.fix$log2.FPKM.2.wtd, g14.all.fix$log2.FPKM.1.mull, g14.all.fix$log2.FPKM.2.mull)
#plot(g14.all.fix[,c("log2.FPKM.1.wtd","log2.FPKM.2.wtd","log2.FPKM.1.mull", "log2.FPKM.2.mull")])
plot(g14.all.fix[,c("log2.FPKM.1.mull","log2.FPKM.2.mull","log2.FPKM.1.wtd", "log2.FPKM.2.wtd")], labels = c("g14mull04_1\nlog2 FPKM", "g14mull04_2\nlog2 FPKM", "g14wtd_1\nlog2 FPKM", "g14wtd_2\nlog2 FPKM"))
#g14mull04.fpkm.only.1 <- subset(g14mull04.fpkm.exp, FPKM.2 == 0)
#g14mull04.fpkm.only.2 <- subset(g14mull04.fpkm.exp, FPKM.1 == 0)


#corplotd(g14mull04.fix[, c("FPKM.1","FPKM.2")], c("g14mull04_1","g14mull04_2"))

#plot(g14mull04.fix$FPKM.1, g14mull04.fix$FPKM.2)
#plot(g14mull04.fix$org.FPKM.1, g14mull04.fix$org.FPKM.2)

#corplotd(g14mull04.fix[, c("log2.FPKM.1","log2.FPKM.2")], c("g14mull04_1","g14mull04_2"))

#write.table(expression.diff.2fold.chr5.down, "analysis/diff_expressed_genes_2fold_chr5_down_regulated.txt", sep = '\t', quote = F, row.names = F)

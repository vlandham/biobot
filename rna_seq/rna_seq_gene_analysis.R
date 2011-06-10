setwd('/Volumes/core/Genomics/Analysis/Yu/ron_yu/cry6/data/long/expr_files')
exprs <- dir(pattern = "*genes_100.expr")
all.genes.uniq <- read.table("justgeneids.txt")
cuff.df <- data.frame(matrix(data = NA, nrow = nrow(all.genes.uniq), ncol = length(exprs) + 1))
colnames(cuff.df)[1] <- "ens_id"
colnames(cuff.df)[2:ncol(cuff.df)] <- exprs
cuff.df[,1] <- all.genes.uniq

for(i in 1:length(exprs))
{
  f <- read.table(exprs[i], quote = '', header = F, sep = '\t', skip = 1, comment.char = "")
  cuff.df[, i+1] <- f[match(cuff.df[, 1], f[, 1]), 6]
}

# add gene symbols
ensemble.annotations <- read.table('ensembl_annotation.txt', as.is = T, sep = '\t', quote = '', comment.char = "", header = T)
cuff.df$gene_name <- ensemble.annotations[match(cuff.df[, 1], ensemble.annotations[, 1]), ][, 2]
cuff.df$description <- ensemble.annotations[match(cuff.df[, 1], ensemble.annotations[, 1]), ][, 3]

# read previous cufflink data
all.cuff.df <- read.table("cufflinks_rpkm.txt", header = T, sep = '\t', quote = '', comment.char = "")

names(cuff.df) # to see which p10's we have for 100bp
cuff.df$p10mut_183676_genes_40.expr = all.cuff.df[match(cuff.df[, 1], all.cuff.df[, 1]), ][, "p10mut_183676_genes.expr"]
cuff.df$p10mut_192850_genes_40.expr = all.cuff.df[match(cuff.df[, 1], all.cuff.df[, 1]), ][, "p10mut_192850_genes.expr"]

p10_192850 <- cuff.df[c("ens_id", "gene_name", "p10mut_192850_genes_100.expr", "p10mut_192850_genes_40.expr", "description")]
names(p10_192850)[3] <- "100"
names(p10_192850)[4] <- "40"
# doesn't do anything useful
#plot(p10_192850[c("100","40")])

p10_183676 <- cuff.df[c("ens_id", "gene_name", "p10mut_183676_genes_100.expr", "p10mut_183676_genes_40.expr", "description")]
names(p10_183676)[3] <- "100"
names(p10_183676)[4] <- "40"

p10_19.only.40.ensembl.ids <- p10_192850["ens_id"][(is.na(p10_192850["100"]) & !is.na(p10_192850["40"]))]
p10_19.only.100.ensembl.ids <- p10_192850["ens_id"][(is.na(p10_192850["40"]) & !is.na(p10_192850["100"]))]
p10_19.only.40 <- p10_192850[match(p10_19.only.40.ensembl.ids, p10_192850[, 1]), ]
p10_19.only.100 <- p10_192850[match(p10_19.only.100.ensembl.ids, p10_192850[, 1]), ]

p10_18.only.40.ensembl.ids <- p10_183676["ens_id"][(is.na(p10_183676["100"]) & !is.na(p10_183676["40"]))]
p10_18.only.100.ensembl.ids <- p10_183676["ens_id"][(is.na(p10_183676["40"]) & !is.na(p10_183676["100"]))]
p10_18.only.40 <- p10_183676[match(p10_18.only.40.ensembl.ids, p10_183676[, 1]), ]
p10_18.only.100 <- p10_183676[match(p10_18.only.100.ensembl.ids, p10_183676[, 1]), ]

all.only.100 <- merge(p10_18.only.100, p10_19.only.100, suffixes = c(".p10_18", ".p10_19"), by = c("ens_id", "gene_name", "description"), sort = FALSE, all = TRUE)
all.only.40 <- merge(p10_18.only.40, p10_19.only.40, suffixes = c(".p10_18", ".p10_19"), by = c("ens_id", "gene_name", "description"), sort = FALSE, all = TRUE)

all.only.100.reorder <- all.only.100[c("ens_id", "gene_name", "description", "100.p10_18", "100.p10_19")]
write.table(all.only.100.reorder, "genes_only_in_100bp.txt", sep = '\t', quote = F, row.names = F)

all.only.40.reorder <- all.only.40[c("ens_id", "gene_name", "description", "40.p10_18", "40.p10_19")]
write.table(all.only.40.reorder, "genes_only_in_40bp.txt", sep = '\t', quote = F, row.names = F)
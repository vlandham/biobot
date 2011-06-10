setwd('/Volumes/core/Bioinformatics/analysis/Trainor/kei/trainor_2011_05_09/')
expression.all <- read.table("cufflinks_output/gene_exp.diff", quote = '', header = T, sep = '\t', skip = 0, comment.char = "")
expression.all$log2.fold_change <- log2(expression.all$value_2 / expression.all$value_1)
expression.valid <- subset(expression.all, status == "OK")
expression.same <- subset(expression.valid, significant == "no")
expression.diff <- subset(expression.valid, significant == "yes")
expression.diff.up <- subset(expression.diff, ln.fold_change. > 0)
expression.diff.down <- subset(expression.diff, ln.fold_change. <= 0)
#wt.only <- subset(expression.diff, value_2 == 0)
#mut.only <- subset(expression.diff, value_1 == 0)
plot(log2(expression.same$value_1), log2(expression.same$value_2), main = "Differentially Expressed Gene FPKM Values", xlab = "log2 g14wtd FPKM", ylab = "log2 g14mull04 FPKM")
points(log2(expression.diff.up$value_1), log2(expression.diff.up$value_2), col = "red")
points(log2(expression.diff.down$value_1), log2(expression.diff.down$value_2), col = "green")

expression.sort <- expression.diff[order(abs(expression.diff$ln.fold_change.), decreasing = TRUE), ]

write.table(expression.sort, "analysis/diff_expressed_genes_all.txt", sep = '\t', quote = F, row.names = F)
write.table(expression.diff.up, "analysis/diff_expressed_genes_all_up_regulated.txt", sep = '\t', quote = F, row.names = F)
write.table(expression.diff.down, "analysis/diff_expressed_genes_all_down_regulated.txt", sep = '\t', quote = F, row.names = F)

expression.same.2fold <- subset(expression.valid, (((significant == "no") | (abs(log2.fold_change) <= 1.0))))
expression.diff.2fold <- subset(expression.diff, abs(log2.fold_change) > 1.0)
expression.diff.2fold.up <- subset(expression.diff, log2.fold_change > 1.0)
expression.diff.2fold.down <- subset(expression.diff, log2.fold_change < -1.0)

write.table(expression.diff.2fold, "analysis/diff_expressed_genes_2fold_all.txt", sep = '\t', quote = F, row.names = F)
write.table(expression.diff.2fold.up, "analysis/diff_expressed_genes_2fold_up_regulated.txt", sep = '\t', quote = F, row.names = F)
write.table(expression.diff.2fold.down, "analysis/diff_expressed_genes_2fold_down_regulated.txt", sep = '\t', quote = F, row.names = F)

plot(log2(expression.same.2fold$value_1), log2(expression.same.2fold$value_2), main = "2-fold Differentially Expressed Gene FPKM Values", xlab = "log2 g14wtd FPKM", ylab = "log2 g14mull04 FPKM")
points(log2(expression.diff.2fold.up$value_1), log2(expression.diff.2fold.up$value_2), col = "red")
points(log2(expression.diff.2fold.down$value_1), log2(expression.diff.2fold.down$value_2), col = "green")

expression.diff.2fold.chr5 <- subset(expression.diff.2fold, grepl("^5:",expression.diff.2fold$locus))
expression.diff.2fold.chr5.up <- subset(expression.diff.2fold.up, grepl("^5:",expression.diff.2fold.up$locus))
expression.diff.2fold.chr5.down <- subset(expression.diff.2fold.down, grepl("^5:",expression.diff.2fold.down$locus))
write.table(expression.diff.2fold.chr5, "analysis/diff_expressed_genes_2fold_chr5_all.txt", sep = '\t', quote = F, row.names = F)
write.table(expression.diff.2fold.chr5.up, "analysis/diff_expressed_genes_2fold_chr5_up_regulated.txt", sep = '\t', quote = F, row.names = F)
write.table(expression.diff.2fold.chr5.down, "analysis/diff_expressed_genes_2fold_chr5_down_regulated.txt", sep = '\t', quote = F, row.names = F)

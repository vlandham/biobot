setwd('/Volumes/core/Bioinformatics/analysis/LinhengLi/rsu/li_linheng_2011_07_12/')
gene_name <- "lsk30_gene_exp.diff"
gene_file <- paste("spikeins/", gene_name, sep = "")
output_prefix <- "analysis/spikeins_"
spikes <- read.table(gene_file, quote = '', header = T, sep = '\t', skip = 0, comment.char = "")
spikes$log2.fold_change <- log2(spikes$value_1 / spikes$value_2)
expected <- read.table("spikeins/expected.txt", quote = '', header = T, sep = '\t', skip = 0, comment.char = "")
spikes.all <- merge(spikes, expected, by.x = "gene_id", by.y = "ERCC.ID", sort = F)
spikes.data <- spikes.all[, c("gene_id", "sample_1", "sample_2", "value_1", "value_2", "subgroup","log2.fold_change", "log2.fold.change.", "concentration.in.Mix.1..atmol.ul.", "concentration.in.Mix.2..atmol.ul.")]
names(spikes.data) <- c("ERCCID", "sample_1", "sample_2", "rpkm_1", "rpkm_2", "subgroup", "actual_log2_fold_change", "expected_log2_fold_change", "concentration_1", "concentration_2")

replace.missing<-function(dataframe, column, new_value)
{
  matching.values <- is.nan(dataframe[, column])
  dataframe[matching.values, column] <- new_value
  matching.values <- dataframe[, column] == -Inf
  dataframe[matching.values, column] <- new_value
  matching.values <- dataframe[, column] == Inf
  dataframe[matching.values, column] <- new_value
  return(dataframe)
}

spikes.data$log2.rpkm_1 <- log2(spikes.data$rpkm_1)
spikes.data <- replace.missing(spikes.data, "log2.rpkm_1", 0)
spikes.data$log2.concentration_1 <- log2(spikes.data$concentration_1)
spikes.data$log2.rpkm_2 <- log2(spikes.data$rpkm_2)
spikes.data <- replace.missing(spikes.data, "log2.rpkm_2", 0)
spikes.data$log2.concentration_2 <- log2(spikes.data$concentration_2)

spikes.plot <- spikes.data
spikes.plot <- subset(spikes.plot, rpkm_1 >= 5 & rpkm_2 >= 5)
spikes.plot$group <- factor(spikes.plot$subgroup)
spikes.plot$color[spikes.plot$group == "A"] <- "red"
spikes.plot$color[spikes.plot$group == "B"] <- "green"
spikes.plot$color[spikes.plot$group == "C"] <- "blue"
spikes.plot$color[spikes.plot$group == "D"] <- "darkgoldenrod"
spikes.plot <- replace.missing(spikes.plot, "actual_log2_fold_change", 0)
fit <- lm(spikes.plot$actual_log2_fold_change ~ spikes.plot$expected_log2_fold_change, data = spikes.plot)

#plot(spikes.plot$expected_log2_fold_change, spikes.plot$actual_log2_fold_change, col = spikes.plot$color, xlab = "Log2(expected fold-change)", ylab = "Log2(RPKM Mix 1: Mix 2)")

#min.value <- min(spikes.plot[spikes.plot$log2.fold_change > -Inf,]$log2.fold_change, na.rm = TRUE) - 0.5

filename <- paste(output_prefix, "log2_expected_vs_actual_", gene_name, ".png", sep = "")
png(filename, height=500, width=800)
plot(spikes.plot$expected_log2_fold_change, spikes.plot$actual_log2_fold_change, col = spikes.plot$color, xlab = "Log2(expected fold-change)", ylab = "Log2(RPKM Mix 1: Mix 2)")
abline(fit)
lm.slope <- round(fit$coefficients[[2]], digits = 3)
lm.y.intercept <- fit$coefficients[[1]]
r.squared <- round(summary(fit)$r.squared, digits = 3)
slope.text <- paste("Slope = ", lm.slope, sep = "")
text(1, -0.5, labels = slope.text)
r2.text <- paste("R2 = ", r.squared, sep = "")
text(1, -0.7, labels = r2.text)
dev.off()

## MIX 1

spikes.plot.con_1.filtered <- subset(spikes.plot, rpkm_1 >= 5.0)

filename <- paste(output_prefix, "log2_expected_vs_actual_mix_1_", gene_name, ".png", sep = "")
png(filename, height=500, width=800)
plot(spikes.plot.con_1.filtered$log2.concentration_1, spikes.plot.con_1.filtered$log2.rpkm_1, col = spikes.plot.con_1.filtered$color, xlab = "Log2(pM) Mix 1", ylab = "Log2(RPKM Mix 1)")
mix1.fit <- lm(spikes.plot.con_1.filtered$log2.rpkm_1 ~ spikes.plot.con_1.filtered$log2.concentration_1, data = spikes.plot.con_1.filtered)
abline(mix1.fit)
mix.1.fit.r.squared <- round(summary(mix1.fit)$r.squared, digits = 3)
mix1.lm.slope <- round(mix1.fit$coefficients[[2]], digits = 3)
slope.text <- paste("Slope = ", mix1.lm.slope, sep = "")
text(12, 10, labels = slope.text)
r2.text <- paste("R2 = ", mix.1.fit.r.squared, sep = "")
text(12, 9.4, labels = r2.text)
dev.off()


## MIX 2

spikes.plot.con_2.filtered <- subset(spikes.plot, rpkm_2 >= 5.0)

filename <- paste(output_prefix, "log2_expected_vs_actual_mix_2_", gene_name, ".png", sep = "")
png(filename, height=500, width=800)
plot(spikes.plot.con_2.filtered$log2.concentration_2, spikes.plot.con_2.filtered$log2.rpkm_2, col = spikes.plot.con_2.filtered$color, xlab = "Log2(pM) Mix 2", ylab = "Log2(RPKM Mix 2)")
mix2.fit <- lm(spikes.plot.con_2.filtered$log2.rpkm_2 ~ spikes.plot.con_2.filtered$log2.concentration_2, data = spikes.plot)
abline(mix2.fit)
mix2.lm.slope <- round(mix2.fit$coefficients[[2]], digits = 3)
mix.2.fit.r.squared <- round(summary(mix2.fit)$r.squared, digits = 3)
slope.text <- paste("Slope = ", mix2.lm.slope, sep = "")
text(12, 10, labels = slope.text)
r2.text <- paste("R2 = ", mix.2.fit.r.squared, sep = "")
text(12, 9.4, labels = r2.text)
dev.off()

#max(spikes.plot.con_1.filtered$log2.concentration_1) - min(spikes.plot.con_1.filtered$log2.concentration_1)
#filename <- paste(output_prefix, "log2_expected_vs_actual_mix_2", gene_name, ".png", sep = "")
#legend(0, 2, levels(spikes.plot$group), cex=0.8, col=c("red", "green", "blue", "darkgoldenrod"), pch=21);

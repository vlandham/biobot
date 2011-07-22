args = commandArgs(TRUE)
print(args)
setwd('/scratch/jfv/trainor_rna_seq/coverage')
filepath <- args[1]
filename <- args[2]
output.dir <- "./coverage.images"
print(filename)
dir.create(output.dir, showWarnings = FALSE)
coverage <- read.table(filepath, quote = '', header = F, sep = '\t', skip = 0, comment.char = "", fill = T)
log10.coverage <- log10(coverage$V8)
log10.coverage[is.infinite(log10.coverage)] <- 0.0

normal.png.name <- paste(filename, ".png", sep = "")
path <- file.path(output.dir, normal.png.name)
png(filename = path, width = 800, height = 600)
plot(coverage$V8, type = "h")
dev.off()

log.png.name <- paste(filename, ".log.png", sep = "")
path <- file.path(output.dir, log.png.name)
png(filename = path, width = 800, height = 600)
print(path)
plot(log10.coverage, type = "h")
dev.off()

q()

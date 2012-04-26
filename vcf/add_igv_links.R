#!/usr/bin/Rscript

library( getopt )

opt = getopt( matrix(byrow=TRUE, nrow=2, ncol=4, data=c(
   'input','i','1','character', 
   'help','h', '0', 'logical'
)) )

usage <- function( mess="", quit=FALSE ) {
   cat( paste( mess, "\n", sep='' ) ) 
   cat("Usage: Rscript plotter.R -i <input_file>\n\nOptions:\n-i/--input <string>   - the input file\n\nDescription:\n.\n")
   if(quit) {
      q("no")
   } 
}

if( !is.null(opt$help) ) {
   usage( quit=TRUE )
}

if ( is.null(opt$input) ) {
   usage( mess="Error: Input not defined", quit=TRUE )
}

input_file <- opt$input

snps.data <- read.delim(input_file, header = T)

snps.data$igv_link <- paste("=HYPERLINK(\"http://localhost:60151/goto?locus=chr", snps.data$Chrom, ":", snps.data$Position, "\", \"chr", snps.data$Chrom, ":", snps.data$Position, "\")", sep = "")

output_file <- paste(input_file, ".links.csv", sep = "")

write.csv(snps.data, file = output_file, row.names = F)


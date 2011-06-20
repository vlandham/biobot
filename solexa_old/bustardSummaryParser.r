laneTilePF <- read.delim("allTiles.tsv",header=TRUE)
colnames(laneTilePF) <- c("Lane","Tile","PF_percent"); 
pdf("PF_percentage_by_Lane_Tile.pdf")
for(i in (1:8)){
	title <- paste("Lane ", i ," Pass Fail Percentage All Cycles")
	plot(subset(laneTilePF,Lane==i)[,c("Tile","PF_percent")],main=title,ylim=c(1,100))
}
dev.off()

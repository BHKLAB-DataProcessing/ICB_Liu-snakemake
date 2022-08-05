library(data.table)

args <- commandArgs(trailingOnly = TRUE)
input_dir <- args[1]
output_dir <- args[2]

expr = as.data.frame( fread( file.path(input_dir, "EXPR.txt.gz") , stringsAsFactors=FALSE  , sep="\t"))
rownames(expr)  = expr[,1] 
expr = expr[,-1]

case = read.csv( file.path(output_dir, "cased_sequenced.csv"), stringsAsFactors=FALSE , sep=";" )
expr = log2( expr[ rownames(expr) %in% case[ case$expr %in% 1 , ]$patient , ] + 0.001 )

write.table( t( expr ) , file= file.path(output_dir, "EXPR.csv") , quote=FALSE , sep=";" , col.names=TRUE , row.names=TRUE )


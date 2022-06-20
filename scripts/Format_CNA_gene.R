library(data.table)

args <- commandArgs(trailingOnly = TRUE)
input_dir <- args[1]
output_dir <- args[2]

case = read.csv( file.path(output_dir, "cased_sequenced.csv") , stringsAsFactors=FALSE , sep=";" )

cna = as.data.frame( fread( file.path(input_dir, "CNA_gene.txt.gz") , stringsAsFactors=FALSE , sep="\t" ) )
rownames(cna) = cna[ , 1 ]
cna = cna[ , -1 ] 

for(i in 1:ncol(cna)){
	cna[ , i ] = ifelse( cna[ , i ] %in% "HDEL" , -2 ,
					ifelse( cna[ , i ] %in% "LOH" , -1 ,
						ifelse( cna[ , i ] %in% "AMP" , 1 ,
							ifelse( cna[ , i ] %in% "HIGH_AMP" , 2 , 0 ))))
}


cna = cna[ , colnames(cna) %in% case[ case$cna %in% 1 , ]$patient ]

write.table( cna , file= file.path(output_dir, "CNA_gene.csv") , quote=FALSE , sep=";" , col.names=TRUE , row.names=TRUE )

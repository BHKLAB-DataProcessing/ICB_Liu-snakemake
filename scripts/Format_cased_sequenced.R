library(data.table)

args <- commandArgs(trailingOnly = TRUE)
input_dir <- args[1]
output_dir <- args[2]

rna = as.data.frame( fread( file.path(input_dir, "EXPR.txt.gz") , stringsAsFactors=FALSE  , sep="\t"))[,1]

clin = read.csv( file.path(input_dir, "CLIN.txt"), stringsAsFactors=FALSE , sep="\t" )
rownames(clin) = clin$X

patient = sort( unique( clin$X ) )

case = as.data.frame( cbind( patient , rep( 1 , length(patient) ) , rep( 1 , length(patient) ) , rep( 0 , length(patient) ) ) )
colnames(case) = c( "patient" , "snv" , "cna" , "expr" )
rownames(case) = patient

case$snv = as.numeric( as.character( case$snv ) )
case$cna = as.numeric( as.character( case$cna ) )
case$expr = as.numeric( as.character( case$expr ) )

for( i in 1:nrow(case)){
	# if( rownames(case)[i] %in% genome ){
	# 	case$snv[i] = 1
	# 	case$cna[i] = 1
	# }
	if( rownames(case)[i] %in% rna ){
		case$expr[i] = 1
	}
}

write.table( case , file=file.path(output_dir, "cased_sequenced.csv") , quote=FALSE , sep=";" , col.names=TRUE , row.names=FALSE )



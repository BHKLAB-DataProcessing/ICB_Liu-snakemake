library(data.table)

args <- commandArgs(trailingOnly = TRUE)
input_dir <- args[1]
output_dir <- args[2]

snv = as.data.frame( fread( file.path(input_dir, "SNV.txt.gz") , stringsAsFactors=FALSE , sep="\t" ) )

ref = as.character( sapply( snv[ , "cDNA_Change" ] , function(x){ 
		output = NULL
		if( length( grep( ">" , x ) ) ){
			if( length( grep( "_" , x ) ) ){
				z = unlist( strsplit( x , ">" , fixed=TRUE ) )[1] ; 
				output = unlist( strsplit( z , "([A-Za-z].[0-9]+_[0-9]+)" , perl=TRUE ) )[2] 
			} else{
				z = unlist( strsplit( x , ">" , fixed=TRUE ) )[1] ; 
				output = unlist( strsplit( z , "([A-Za-z].[0-9]+)" , perl=TRUE ) )[2] 
			}
		} 

		if( length( grep( "del" , x ) ) ){
			output = unlist( strsplit( x , "del" , fixed=TRUE ) )[2]
		}  
		if( length( grep( "ins" , x ) ) ){
			output = ""
		}  
		output 
	} ) )


alt = as.character( sapply( snv[ , "cDNA_Change" ] , function(x){ 
		output = NULL
		if( length( grep( ">" , x ) ) ){
			output = unlist( strsplit( x , ">" , fixed=TRUE ) )[2] ; 
		} 

		if( length( grep( "del" , x ) ) ){
			output = ""
		}  
		if( length( grep( "ins" , x ) ) ){
			output = unlist( strsplit( x , "ins" , fixed=TRUE ) )[2]
		}   
		output
	} ) )

data = cbind( snv[ , c("Start_position" , "Patient" , "Hugo_Symbol", "Variant_Classification" ) ] ,
				sapply( snv[ , "Chromosome" ] , function(x){ paste( "chr" , x , sep="" ) } ) ,
				 ifelse( ref %in% "NULL" , "" , ref ) ,
				 ifelse( ref %in% "NULL" , "" , alt ) ,
				 ifelse( snv[ , "Variant_Type"] %in% c("DEL","INS"), "INDEL" , "SNV" )
				 
			)

colnames(data) = c( "Pos" , "Sample" , "Gene" , "Effect" , "Chr", "Ref" , "Alt", "MutType" )

case = read.csv( file.path(output_dir, "cased_sequenced.csv"), stringsAsFactors=FALSE , sep=";" )
data = data[ data$Sample %in% case[ case$snv %in% 1 , ]$patient , c( "Sample" , "Gene" , "Chr" , "Pos" , "Ref" , "Alt" , "Effect" , "MutType" ) ]

write.table( data , file= file.path(output_dir, "SNV.csv") , quote=FALSE , sep=";" , col.names=TRUE , row.names=FALSE )




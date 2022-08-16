library(tibble)

args <- commandArgs(trailingOnly = TRUE)
input_dir <- args[1]
output_dir <- args[2]
annot_dir <- args[3]

source("https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Common/main/code/Get_Response.R")
source("https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Common/main/code/format_clin_data.R")
source("https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Common/main/code/annotate_tissue.R")
source("https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Common/main/code/annotate_drug.R")

clin_original = read.csv( file.path(input_dir, "CLIN.txt"), stringsAsFactors=FALSE , sep="\t")
selected_cols <- c( "X" , "gender..Male.1..Female.0." , "BR" , "PFS.days.","OS","Mstage..IIIC.0..M1a.1..M1b.2..M1c.3.","progressed","dead","Primary_Type","Histology" , "priorCTLA4" )
clin = cbind( clin_original[ ,  selected_cols] , "PD-1/PD-L1" , NA , NA , NA , NA , NA )
colnames(clin) = c( "patient" , "sex" , "recist" , "t.pfs"  ,"t.os"  , "stage" , "pfs" , "os", "primary"  , "histo" , "priorCTLA4" , "drug_type" , "age" , "dna" , "rna" , "response.other.info" , "response" )

clin$sex = ifelse(clin$sex %in% 0 , "F" , "M")

clin$t.os = clin$t.os/30.5
clin$t.pfs = clin$t.pfs/30.5

clin$drug_type = ifelse( clin$priorCTLA4 , "Combo" , "PD-1/PD-L1" )
clin$recist[ clin$recist %in% "MR" ] = "SD"
clin$response = Get_Response( data=clin )
clin$primary = "Melanoma"


clin$stage = ifelse( clin$stage %in% 0 , "III" , 
				ifelse( clin$stage %in% c(1,2,3,4) , "IV" , NA ) )

case = read.csv( file.path(output_dir, "cased_sequenced.csv"), stringsAsFactors=FALSE , sep=";" )
clin$rna[ clin$patient %in% case[ case$expr %in% 1 , ]$patient ] = "fpkm"
clin$dna[ clin$patient %in% case[ case$cna %in% 1 , ]$patient ] = "wes"

clin = clin[ , c("patient" , "sex" , "age" , "primary" , "histo" , "stage" , "response.other.info" , "recist" , "response" , "drug_type" , "dna" , "rna" , "t.pfs" , "pfs" , "t.os" , "os" ) ]

clin <- format_clin_data(clin_original, 'X', selected_cols, clin)

# Tissue and drug annotation
annotation_tissue <- read.csv(file=file.path(annot_dir, 'curation_tissue.csv'))
clin <- annotate_tissue(clin=clin, study='Liu', annotation_tissue=annotation_tissue, check_histo=TRUE)

annotation_drug <- read.csv(file=file.path(annot_dir, 'curation_drug.csv'))
clin <- add_column(clin, treatmentid='', .after='tissueid')

write.table( clin , file=file.path(output_dir, "CLIN.csv") , quote=FALSE , sep=";" , col.names=TRUE , row.names=FALSE )


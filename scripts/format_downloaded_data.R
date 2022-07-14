# wget 'https://static-content.springer.com/esm/art%3A10.1038%2Fs41591-019-0654-5/MediaObjects/41591_2019_654_MOESM4_ESM.xlsx' \
# -O ~/Documents/ICBCuration/data_source/Liu/41591_2019_654_MOESM4_ESM.xlsx
# 
# wget 'https://static-content.springer.com/esm/art%3A10.1038%2Fs41591-019-0654-5/MediaObjects/41591_2019_654_MOESM3_ESM.txt' \
# -O ~/Documents/ICBCuration/data_source/Liu/41591_2019_654_MOESM3_ESM.txt
# 
# wget 'https://static-content.springer.com/esm/art%3A10.1038%2Fs41591-019-0654-5/MediaObjects/41591_2019_654_MOESM2_ESM.xlsx' \
# -O ~/Documents/ICBCuration/data_source/Liu/41591_2019_654_MOESM2_ESM.xlsx

library(readxl) 
library(data.table)
library(stringr)
library(dplyr)

args <- commandArgs(trailingOnly = TRUE)
work_dir <- args[1]

# CLIN.txt
clin <- read_excel(file.path(work_dir, '41591_2019_654_MOESM4_ESM.xlsx'), sheet='Supplemental Table 1')
colnames(clin) <- c('X', clin[2, ][!is.na(clin[2, ])])
clin <- clin[-c(1, 2), ]
clin <- clin[!is.na(clin$X) & str_detect(clin$X, '^Patient(?=\\d+)'), ]
colnames(clin) <- c(
  "X", "total_muts", "nonsyn_muts", "clonal_muts", "subclonal_muts", "heterogeneity", "total_neoantigens", "CNA_prop",
  "gender..Male.1..Female.0.", "biopsy.site", "monthsBiopsyPreTx", "BR", "PFS.days.", "OS", "TimeToBR", "cyclesOnTherapy", 
  "txOngoing", "Tx", "Mstage..IIIC.0..M1a.1..M1b.2..M1c.3.", "Tx_Start_ECOG", "Tx_Start_LDH", "LDH_Elevated", 
  "Brain_Met", "Cut_SubQ_Met", "LN_Met", "Lung_Met", "Liver_Visc_Met", "Bone_Met", "progressed", "dead", "Primary_Type", "Histology", 
  "IOTherapy", "steroidsGT10mgDaily", "priorMAPKTx", "priorCTLA4", "postCTLA4", "postMAPKTx", "postCombinedCTLA_PD1", "numPriorTherapies", 
  "biopsy.site_categ", "biopsyContext..1.Pre.Ipi..2.On.Ipi..3.Pre.PD1..4.On.PD1.", "daysBiopsyToPD1", "daysBiopsyAfterIpiStart", "purity", "ploidy"
) 

is_all_numeric <- function(x) {
  !any(is.na(suppressWarnings(as.numeric(na.omit(x))))) & is.character(x)
}
clin %>% 
  mutate_if(is_all_numeric,as.numeric) %>%
  str()

write.table( clin , file=file.path(work_dir, 'CLIN.txt') , quote=FALSE , sep="\t" , col.names=TRUE , row.names=FALSE )

# EXPR.txt.gz
expr <- as.data.frame( fread( file.path(work_dir, "41591_2019_654_MOESM3_ESM.txt") , stringsAsFactors=FALSE  , sep="\t"))
gz <- gzfile(file.path(work_dir, 'EXPR.txt.gz'), "w")
write.table( expr , file=gz , quote=FALSE , sep="\t" , col.names=TRUE , row.names=FALSE )
close(gz)

# CNA_gene.txt.gz
cna <- read_excel(file.path(work_dir, '41591_2019_654_MOESM2_ESM.xlsx'), sheet='Gene CNAs')
colnames(cna) <- cna[4, ]
cna <- cna[-c(1:4), ]
gz <- gzfile(file.path(work_dir, 'CNA_gene.txt.gz'), "w")
write.table( cna , file=gz , quote=FALSE , sep="\t" , col.names=TRUE , row.names=FALSE )
close(gz)

# SNV.txt.gz
snv <- read_excel(file.path(work_dir, '41591_2019_654_MOESM2_ESM.xlsx'), sheet='All mutations')
colnames(snv) <- snv[5, ]
snv <- snv[-c(1:5), ]
gz <- gzfile(file.path(work_dir, 'SNV.txt.gz'), "w")
write.table( snv , file=gz , quote=FALSE , sep="\t" , col.names=TRUE , row.names=FALSE )
close(gz)


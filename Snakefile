from snakemake.remote.S3 import RemoteProvider as S3RemoteProvider
S3 = S3RemoteProvider(
    access_key_id=config["key"],
    secret_access_key=config["secret"],
    host=config["host"],
    stay_on_remote=False
)
prefix = config["prefix"]
filename = config["filename"]
data_source = "https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Liu-data/main/"

rule get_multiassay:
    input:
        S3.remote(prefix + "scripts/get_multiassay.R"),
        S3.remote(prefix + "processed/CNA.rds"),
        S3.remote(prefix + "processed/EXPR.rds"),
        S3.remote(prefix + "processed/SNV.rds")
    output:
        S3.remote(prefix + filename)
    resources:
        mem_mb = 3000,
        disk_mb = 3000
    shell:
        """
        Rscript {prefix}scripts/get_multiassay.R \
        {prefix}processed \
        {prefix} \
        ICB_Liu \
        EXPR:SNV:CNA      
        """

rule get_exp_se:
    input:
        S3.remote(prefix + "annotation/Gencode.v40.annotation.RData"),
        S3.remote(prefix + "scripts/get_exp_se.R"),
        S3.remote(prefix + "processed/EXPR.csv"),
        S3.remote(prefix + "processed/CLIN.rds"),
        S3.remote(prefix + "processed/cased_sequenced.rds"),
        S3.remote(prefix + "processed/feat_snv.rds"),
        S3.remote(prefix + "processed/feat_cna.rds"),
        S3.remote(prefix + "processed/feat_cin.rds")
    output:
        S3.remote(prefix + "processed/EXPR.rds")
    shell:
        """
        Rscript {prefix}scripts/get_exp_se.R \
        {prefix}processed \
        Liu \
        TRUE \
        TRUE \
        FALSE \
        {prefix}annotation/Gencode.v40.annotation.RData        
        """

rule get_cna_se:
    input:
        S3.remote(prefix + "annotation/Gencode.v40.annotation.RData"),
        S3.remote(prefix + "scripts/get_cna_se.R"),
        S3.remote(prefix + "processed/CNA_gene.csv"),
        S3.remote(prefix + "processed/CLIN.rds"),
        S3.remote(prefix + "processed/cased_sequenced.rds"),
        S3.remote(prefix + "processed/feat_snv.rds"),
        S3.remote(prefix + "processed/feat_cna.rds"),
        S3.remote(prefix + "processed/feat_cin.rds")
    output:
        S3.remote(prefix + "processed/CNA.rds")
    shell:
        """
        Rscript {prefix}scripts/get_cna_se.R \
        {prefix}processed \
        TRUE \
        {prefix}annotation/Gencode.v40.annotation.RData        
        """

rule get_snv_se:
    input:
        S3.remote(prefix + "annotation/Gencode.v40.annotation.RData"),
        S3.remote(prefix + "scripts/get_snv_se.R"),
        S3.remote(prefix + "processed/SNV.csv"),
        S3.remote(prefix + "processed/CLIN.rds"),
        S3.remote(prefix + "processed/cased_sequenced.rds"),
        S3.remote(prefix + "processed/feat_snv.rds"),
        S3.remote(prefix + "processed/feat_cna.rds"),
        S3.remote(prefix + "processed/feat_cin.rds")
    output:
        S3.remote(prefix + "processed/SNV.rds")
    shell:
        """
        Rscript {prefix}scripts/get_snv_se.R \
        {prefix}processed \
        TRUE \
        {prefix}annotation/Gencode.v40.annotation.RData        
        """

rule get_snv_feat:
    input:
        S3.remote(prefix + "scripts/get_snv_feat.R"),
        S3.remote(prefix + "processed/SNV.csv"),
        S3.remote(prefix + "processed/cased_sequenced.rds")
    output:
        S3.remote(prefix + "processed/feat_snv.rds")
    shell:
        """
        Rscript {prefix}scripts/get_snv_feat.R \
        {prefix}processed \
        50 \
        TRUE
        """

rule get_cna_feat:
    input:
        S3.remote(prefix + "scripts/get_cna_feat.R"),
        S3.remote(prefix + "processed/CNA_gene.csv"),
        S3.remote(prefix + "processed/cased_sequenced.rds")
    output:
        S3.remote(prefix + "processed/feat_cna.rds"),
        S3.remote(prefix + "processed/feat_cin.rds")
    shell:
        """
        Rscript {prefix}scripts/get_cna_feat.R \
        {prefix}processed \
        FALSE \
        50
        """

rule format_clin_cased_sequenced:
    input:
        S3.remote(prefix + "scripts/format_clin_cased_sequenced.R"),
        S3.remote(prefix + "processed/CLIN.csv"),
        S3.remote(prefix + "processed/cased_sequenced.csv")
    output:
        S3.remote(prefix + "processed/cased_sequenced.rds"),
        S3.remote(prefix + "processed/CLIN.rds")
    shell:
        """
        Rscript {prefix}scripts/format_clin_cased_sequenced.R \
        {prefix}processed
        """

rule download_scripts:
    output:
        S3.remote(prefix + "scripts/get_cna_feat.R"),
        S3.remote(prefix + "scripts/get_snv_feat.R"),
        S3.remote(prefix + "scripts/get_snv_se.R"),
        S3.remote(prefix + "scripts/get_cna_se.R"),
        S3.remote(prefix + "scripts/get_exp_se.R"),
        S3.remote(prefix + "scripts/get_multiassay.R"),
        S3.remote(prefix + "scripts/format_clin_cased_sequenced.R")
    shell:
        """
        wget https://raw.githubusercontent.com/BHKLAB-DataProcessing/ICB_Common/main/code/get_cna_feat.R -O {prefix}scripts/get_cna_feat.R
        wget https://raw.githubusercontent.com/BHKLAB-DataProcessing/ICB_Common/main/code/get_snv_feat.R -O {prefix}scripts/get_snv_feat.R
        wget https://raw.githubusercontent.com/BHKLAB-DataProcessing/ICB_Common/main/code/get_snv_se.R -O {prefix}scripts/get_snv_se.R
        wget https://raw.githubusercontent.com/BHKLAB-DataProcessing/ICB_Common/main/code/get_cna_se.R -O {prefix}scripts/get_cna_se.R
        wget https://raw.githubusercontent.com/BHKLAB-DataProcessing/ICB_Common/main/code/get_exp_se.R -O {prefix}scripts/get_exp_se.R
        wget https://raw.githubusercontent.com/BHKLAB-DataProcessing/ICB_Common/main/code/get_multiassay.R -O {prefix}scripts/get_multiassay.R
        wget https://raw.githubusercontent.com/BHKLAB-DataProcessing/ICB_Common/main/code/format_clin_cased_sequenced.R -O {prefix}scripts/format_clin_cased_sequenced.R
        """

rule download_annotation:
    output:
        S3.remote(prefix + "annotation/Gencode.v40.annotation.RData"),
        S3.remote(prefix + "annotation/curation_drug.csv"),
        S3.remote(prefix + "annotation/curation_tissue.csv")
    shell:
        """
        wget https://github.com/BHKLAB-Pachyderm/Annotations/blob/master/Gencode.v40.annotation.RData?raw=true -O {prefix}annotation/Gencode.v40.annotation.RData
        wget https://github.com/BHKLAB-Pachyderm/ICB_Common/raw/main/data/curation_drug.csv -O {prefix}annotation/curation_drug.csv
        wget https://github.com/BHKLAB-Pachyderm/ICB_Common/raw/main/data/curation_tissue.csv -O {prefix}annotation/curation_tissue.csv 
        """

rule format_snv:
    input:
        S3.remote(prefix + "download/SNV.txt.gz"),
        S3.remote(prefix + "processed/cased_sequenced.csv")
    output:
        S3.remote(prefix + "processed/SNV.csv")
    shell:
        """
        Rscript scripts/Format_SNV.R \
        {prefix}download \
        {prefix}processed \
        """

rule format_expr:
    input:
        S3.remote(prefix + "download/EXPR.txt.gz"),
        S3.remote(prefix + "processed/cased_sequenced.csv")
    output:
        S3.remote(prefix + "processed/EXPR.csv")
    shell:
        """
        Rscript scripts/Format_EXPR.R \
        {prefix}download \
        {prefix}processed \
        """

rule format_cna_gene:
    input:
        S3.remote(prefix + "processed/cased_sequenced.csv"),
        S3.remote(prefix + "download/CNA_gene.txt.gz")
    output:
        S3.remote(prefix + "processed/CNA_gene.csv")
    shell:
        """
        Rscript scripts/Format_CNA_gene.R \
        {prefix}download \
        {prefix}processed \
        """

rule format_clin:
    input:
        S3.remote(prefix + "processed/cased_sequenced.csv"),
        S3.remote(prefix + "download/CLIN.txt"),
        S3.remote(prefix + "annotation/curation_drug.csv"),
        S3.remote(prefix + "annotation/curation_tissue.csv")
    output:
        S3.remote(prefix + "processed/CLIN.csv")
    shell:
        """
        Rscript scripts/Format_CLIN.R \
        {prefix}download \
        {prefix}processed \
        {prefix}annotation
        """

rule format_cased_sequenced:
    input:
        S3.remote(prefix + "download/CLIN.txt"),
        S3.remote(prefix + "download/EXPR.txt.gz")
    output:
        S3.remote(prefix + "processed/cased_sequenced.csv")
    shell:
        """
        Rscript scripts/Format_cased_sequenced.R \
        {prefix}download \
        {prefix}processed \
        """

rule format_downloaded_data:
    input:
        S3.remote(prefix + "download/41591_2019_654_MOESM4_ESM.xlsx"),
        S3.remote(prefix + "download/41591_2019_654_MOESM3_ESM.txt"),
        S3.remote(prefix + "download/41591_2019_654_MOESM2_ESM.xlsx")
    output:
        S3.remote(prefix + "download/CLIN.txt"),
        S3.remote(prefix + "download/EXPR.txt.gz"),
        S3.remote(prefix + "download/SNV.txt.gz"),
        S3.remote(prefix + "download/CNA_gene.txt.gz")
    shell:
        """
        Rscript scripts/format_downloaded_data.R \
        {prefix}download
        """

rule download_data:
    output:
        S3.remote(prefix + "download/41591_2019_654_MOESM4_ESM.xlsx"),
        S3.remote(prefix + "download/41591_2019_654_MOESM3_ESM.txt"),
        S3.remote(prefix + "download/41591_2019_654_MOESM2_ESM.xlsx")
    shell:
        """
        wget 'https://static-content.springer.com/esm/art%3A10.1038%2Fs41591-019-0654-5/MediaObjects/41591_2019_654_MOESM4_ESM.xlsx' \
        -O {prefix}download/41591_2019_654_MOESM4_ESM.xlsx
        wget 'https://static-content.springer.com/esm/art%3A10.1038%2Fs41591-019-0654-5/MediaObjects/41591_2019_654_MOESM3_ESM.txt' \
        -O {prefix}download/41591_2019_654_MOESM3_ESM.txt
        wget 'https://static-content.springer.com/esm/art%3A10.1038%2Fs41591-019-0654-5/MediaObjects/41591_2019_654_MOESM2_ESM.xlsx' \
        -O {prefix}download/41591_2019_654_MOESM2_ESM.xlsx
        """

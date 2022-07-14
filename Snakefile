from snakemake.remote.S3 import RemoteProvider as S3RemoteProvider
S3 = S3RemoteProvider(
    access_key_id=config["key"], 
    secret_access_key=config["secret"],
    host=config["host"],
    stay_on_remote=False
)
prefix = config["prefix"]
filename = config["filename"]
data_source  = "https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Liu-data/main/"

rule get_MultiAssayExp:
    input:
        S3.remote(prefix + "processed/CLIN.csv"),
        S3.remote(prefix + "processed/CNA_gene.csv"),
        S3.remote(prefix + "processed/EXPR.csv"),
        S3.remote(prefix + "processed/SNV.csv"),
        S3.remote(prefix + "processed/cased_sequenced.csv"),
        S3.remote(prefix + "annotation/Gencode.v40.annotation.RData")
    output:
        S3.remote(prefix + filename)
    resources:
        mem_mb=3000,
        disk_mb=3000
    shell:
        """
        Rscript -e \
        '
        load(paste0("{prefix}", "annotation/Gencode.v40.annotation.RData"))
        source("https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Common/main/code/get_MultiAssayExp.R");
        saveRDS(
            get_MultiAssayExp(study = "Liu", input_dir = paste0("{prefix}", "processed")), 
            "{prefix}{filename}"
        );
        '
        """

rule download_annotation:
    output:
        S3.remote(prefix + "annotation/Gencode.v40.annotation.RData")
    shell:
        """
        wget https://github.com/BHKLAB-Pachyderm/Annotations/blob/master/Gencode.v40.annotation.RData?raw=true -O {prefix}annotation/Gencode.v40.annotation.RData 
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
        S3.remote(prefix + "download/CLIN.txt")
    output:
        S3.remote(prefix + "processed/CLIN.csv")
    shell:
        """
        Rscript scripts/Format_CLIN.R \
        {prefix}download \
        {prefix}processed \
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
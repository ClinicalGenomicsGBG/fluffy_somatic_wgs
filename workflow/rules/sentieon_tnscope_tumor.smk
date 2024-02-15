__author__ = "Fanny Berglund"
__copyright__ = "Copyright 2024, Fanny Berglund"
__email__ = "fanny.berglund@gu.se"
__license__ = "GPL-3"


rule sentieon_tnscope_tumor:
    input:
        tumorbam="sentieon/realign/{sample}_T_REALIGNED.bam",
        tumortable="sentieon/qualcal/{sample}_T_RECAL_DATA.TABLE"
    output:
        tnscope="sentieon/tnscope/{sample}_TNscope_t.vcf",
        tnscope_bam="sentieon/tnscope/{sample}_REALIGNED_realignedTNscope.bam",
    params:
        extra=config.get("sentieon", {}).get("extra", ""),
        reference=config.get("sentieon", {}).get("reference", ""),
        sentieon=config.get("sentieon", {}).get("sentieon", ""),
        callsettings=config.get("sentieon", {}).get("tnscope_settings", ""),
        pon=config.get("sentieon", {}).get("pon", ""),
    log:
        "sentieon/tnscope/{sample}_T.output.log",
    benchmark:
        repeat("sentieon/tnscope/{sample}_T.output.benchmark.tsv", config.get("sentieon", {}).get("benchmark_repeats", 1))
    threads: config.get("tnscope", {}).get("threads", config["default_resources"]["threads"])
    resources:
        mem_mb=config.get("sentieon", {}).get("mem_mb", config["default_resources"]["mem_mb"]),
        mem_per_cpu=config.get("sentieon", {}).get("mem_per_cpu", config["default_resources"]["mem_per_cpu"]),
        partition=config.get("sentieon", {}).get("partition", config["default_resources"]["partition"]),
        threads=config.get("tnscope", {}).get("threads", config["default_resources"]["threads"]),
        time=config.get("sentieon", {}).get("time", config["default_resources"]["time"]),
    container:
        config.get("sentieon", {}).get("container", config["default_container"])
    message:
        "{rule}: Call SNVs and structural variants in {input.tumorbam} using Sentieon TNScope"
    shell:
        "{params.sentieon} driver "
        "-t {threads} "
        "-r {params.reference} "
        "-i {input.tumorbam} "
        "-q {input.tumortable} "
        "--algo TNscope "
        "--pon {params.pon} "
        "--tumor_sample {wildcards.sample}_T "
        "--bam_output {output.tnscope_bam} "
        "{params.callsettings} {output.tnscope} &> {log}"



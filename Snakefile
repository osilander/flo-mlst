##############################################################
### The input for this Snakefile is a fasta file of reads from
###############################################################

#shell.executable("/bin/bash")

BC, = glob_wildcards("./data/{barcode}.fastq")
PCR, = glob_wildcards("./data/{pcr}.fas")

rule all:
    input:
        expand("results/{barcode}.{pcr}.move", barcode=BC, pcr=PCR),
        expand("results/{barcode}.{pcr}.depth.txt", barcode=BC, pcr=PCR)

rule trim_reads:
    input:
        reads="data/{barcode}.fastq"
    output: "results/{barcode}.trimmed.fastq"
    shell: "porechop -i {input.reads} > {output}"

rule subset_reads:
    input:
        reads="results/{barcode}.trimmed.fastq",
        product="data/{pcr}.fas"
    output: temp("results/{barcode}.{pcr}.subset.sam")
    shell: "minimap2 -ax map-ont --secondary=no {input.product} {input.reads} > {output}"

rule filter_sam:
    input:
        sam="results/{barcode}.{pcr}.subset.sam"
    output: "results/{barcode}.{pcr}.mapped.bam"
    shell: "samtools view -bS -F 4 -h -bS {input.sam} > {output}"

rule get_depth:
    input:
        sam="results/{barcode}.{pcr}.mapped.bam"
    output: "results/{barcode}.{pcr}.depth.txt"
    shell: "samtools view -bS -F 4 -h -bS {input.sam} > {output}"

rule make_fastq:
    input:
        sam="results/{barcode}.{pcr}.mapped.bam"
    output: "results/{barcode}.{pcr}.mapped.fastq"
    shell: "samtools fastq {input.sam} > {output}"

rule medaka:
    input:
        reads="results/{barcode}.{pcr}.mapped.fastq",
        ref="data/{pcr}.fas",
        bam="results/{barcode}.{pcr}.mapped.bam"
    output: touch("results/{barcode}.{pcr}.medaka.polish.done")
    params:
        dir="results/medaka_{barcode}_{pcr}_variant",
        model="r941_min_hac_g507"
    shell: "medaka_variant -i {input.bam} -f {input.ref} -o {params.dir} -m {params.model} -s {params.model} -d -t 4"

rule bcftools_consensus:
    input: "data/{pcr}.fas"
    output: "results/{pcr}.fas"
    shell: "cp {input} {output}"

rule copy_fasta:
    input: "data/{pcr}.fas"
    output: "results/{pcr}.fas"
    shell: "cp {input} {output}"

rule rename_fasta:
    input: "results/{barcode}.{pcr}.medaka.polish.done"
    output: touch("results/{barcode}.{pcr}.medaka.polish.rename")
    params:
        fasta="results/medaka_{barcode}_{pcr}_polish/consensus.fasta",
        name=">{barcode}_{pcr}",
        pcr=">lb_{pcr}"
    shell: "sed -i 's/{params.pcr}/{params.name}/' {params.fasta}"

rule multi_fasta:
    input:
        medaka_done="results/{barcode}.{pcr}.medaka.polish.rename",
        fasta="results/{pcr}.fas"
    output: touch("results/{barcode}.{pcr}.move")
    params:
        dir="results/medaka_{barcode}_{pcr}_polish",
        fasta="results/{pcr}.fas"
    shell: "cat {params.dir}/consensus.fasta >> {params.fasta}"

rule get_names:
    input:
        multi_fasta_concat="results/{barcode}.{pcr}.move",
    output: touch("results/{barcode}.concat")
    params:
        dir="results/medaka_{barcode}_{pcr}_polish",
        fasta="results/{pcr}.fas"
    shell: "cat {params.dir}/consensus.fasta >> {params.fasta}"

rule concat_fasta:
    input:
        medaka_move="results/{barcode}.{pcr}.move",
        fasta="results/{pcr}.fas"
    output: touch("results/{barcode}.concat")
    params:
        dir="results/medaka_{barcode}_{pcr}_polish",
        fasta="results/{pcr}.fas"
    shell: "cat {params.dir}/consensus.fasta >> {params.fasta}"

#rule tree:
#    input:
        #fasta=expand(),
#        fasta="results/{pcr}.fas"
#    output: touch("results/{barcode}.{pcr}.move")

version 1.0

task Count {

    input {
        String sampleName
        String gexFastqName
        String atacFastqName
        Array[File] gexFastqFiles
        Array[File] atacFastqFiles
        String reference
    }

    String cellRangerVersion = "1.0.0"
    String dockerImage = "hisplan/cellranger-arc:" + cellRangerVersion
    Float inputSize = size(gexFastqFiles, "GiB") + size(atacFastqFiles, "GiB") + 20

    # ~{sampleName} : the top-level output directory containing pipeline metadata
    # ~{sampleName}/outs/ : contains the final pipeline output files.
    String outBase = sampleName + "/outs"

    command <<<
        set -euo pipefail

        export MRO_DISK_SPACE_CHECK=disable

        # download reference
        # curl -OL https://cf.10xgenomics.com/supp/cell-arc/refdata-cellranger-arc-GRCh38-2020-A.tar.gz
        # mv refdata-cellranger-arc-GRCh38-2020-A.tar.gz /opt/
        # tar xvzf /opt/refdata-cellranger-arc-GRCh38-2020-A.tar.gz
        # rm -rf /opt/refdata-cellranger-arc-GRCh38-2020-A.tar.gz

        curl -L --silent -o reference.tgz ~{reference}
        mkdir -p reference
        tar xvzf reference.tgz -C reference --strip-components=1
        chmod -R +r reference
        rm -rf reference.tgz

        find .

        mkdir -p fastq-gex
        mkdir -p fastq-atac

        # aggregate all the GEX fastq files into a single directory
        for file in "~{sep=' ' gexFastqFiles}"
        do
            mv -v ${file} ./fastq-gex/
        done

        # aggregate all the ATAC fastq files into a single directory
        for file in "~{sep=' ' atacFastqFiles}"
        do
            mv -v ${file} ./fastq-atac/
        done

        # generate libraries.csv
        echo "fastqs,sample,library_type" > libraries.csv
        echo "./fastq-gex,~{gexFastqName},Gene Expression" >> libraries.csv
        echo "./fastq-atac,~{atacFastqName},Chromatin Accessibility" >> libraries.csv
        cat libraries.csv

        # run the count pipeline
        cellranger-arc count \
            --id=~{sampleName} \
            --reference=./reference/ \
            --libraries=./libraries.csv \
            --localcores=16 \
            --localmem=115

        # targz the analysis folder and pipestance metadata if successful
        if [ $? -eq 0 ]
        then
            tar czf ~{outBase}/analysis.tgz ~{outBase}/analysis/*
            tar czf debug.tgz ./~{sampleName}/_*
        fi

        find .
    >>>

    output {
        File webSummary = outBase + "/web_summary.html"

        File metricsSummary = outBase + "/metrics_summary.csv"

        File gexBam = outBase + "/gex_possorted_bam.bam"
        File gexBai = outBase + "/gex_possorted_bam.bam.bai"

        File atacBam = outBase + "/atac_possorted_bam.bam"
        File atacBai = outBase + "/atac_possorted_bam.bam.bai"

        Array[File] hdf5 = glob(outBase + "/*.h5")

        File atacFragments = outBase + "/atac_fragments.tsv.gz"
        File atacFragmentsIndex = outBase + "/atac_fragments.tsv.gz.tbi"

        Array[File] rawFeatureBCMatrix = glob(outBase + "/raw_feature_bc_matrix/*")
        Array[File] filteredFeatureBCMatrix = glob(outBase + "/filtered_feature_bc_matrix/*")

        File? outAnalysis = outBase + "/analysis.tgz"

        File perBarcodeMetrics = outBase + "/per_barcode_metrics.csv"
        File peaks = outBase + "/atac_peaks.bed"
        File cutSites = outBase + "/atac_cut_sites.bigwig"
        File peakAnnotation = outBase + "/atac_peak_annotation.tsv"

        File cloupe = outBase + "/cloupe.cloupe"

        File pipestance = sampleName + "/" + sampleName + ".mri.tgz"

        File debugFile = "debug.tgz"
        # ./${sample-name}/_invocation
        # ./${sample-name}/_jobmode
        # ./${sample-name}/_mrosource
        # ./${sample-name}/_versions
        # ./${sample-name}/_tags
        # ./${sample-name}/_uuid
        # ./${sample-name}/_timestamp
        # ./${sample-name}/_log
        # ./${sample-name}/_vdrkill
        # ./${sample-name}/_perf
        # ./${sample-name}/_finalstate
        # ./${sample-name}/_cmdline
        # ./${sample-name}/_sitecheck
        # ./${sample-name}/_filelist
    }

    runtime {
        docker: dockerImage
        # disks: "local-disk 1500 SSD"
        cpu: 16
        memory: "128 GB"
    }
}

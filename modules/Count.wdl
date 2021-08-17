version 1.0

task Count {

    input {
        String sampleName
        String gexFastqName
        String atacFastqName
        Array[File] gexFastqFiles
        Array[File] atacFastqFiles
        String reference

        # docker-related
        String dockerRegistry
    }

    String cellRangerVersion = "2.0.0"
    String dockerImage = dockerRegistry + "/cromwell-cellranger-arc:" + cellRangerVersion
    Float inputSize = size(gexFastqFiles, "GiB") + size(atacFastqFiles, "GiB") + 20
    Int cores = 32
    Int memoryGB = 256

    # ~{sampleName} : the top-level output directory containing pipeline metadata
    # ~{sampleName}/outs/ : contains the final pipeline output files.
    String outBase = sampleName + "/outs"

    command <<<
        set -euo pipefail

        export MRO_DISK_SPACE_CHECK=disable

        # download reference
        curl -L --silent -o reference.tgz ~{reference}
        mkdir -p reference
        tar xvzf reference.tgz -C reference --strip-components=1
        chmod -R +r reference
        rm -rf reference.tgz

        # aggregate all the GEX fastq files into a single directory
        mkdir -p fastq-gex
        mv -v ~{sep=' ' gexFastqFiles} ./fastq-gex/

        # aggregate all the ATAC fastq files into a single directory
        mkdir -p fastq-atac
        mv -v ~{sep=' ' atacFastqFiles} ./fastq-atac/

        # generate libraries.csv
        # fastq folder must be an absolute path
        echo "fastqs,sample,library_type" > libraries.csv
        echo "$(pwd)/fastq-gex,~{gexFastqName},Gene Expression" >> libraries.csv
        echo "$(pwd)/fastq-atac,~{atacFastqName},Chromatin Accessibility" >> libraries.csv
        cat libraries.csv

        # run the count pipeline
        cellranger-arc count \
            --id=~{sampleName} \
            --reference=./reference/ \
            --libraries=./libraries.csv \
            --localcores=~{cores - 1} \
            --localmem=~{memoryGB - 5}

        # targz the analysis folder if successful
        if [ $? -eq 0 ]
        then
            tar czf ~{outBase}/analysis.tgz ~{outBase}/analysis/*
        fi

        find ~{outBase}
    >>>

    output {
        File libraries = "libraries.csv"

        File webSummary = outBase + "/web_summary.html"
        File metricsSummary = outBase + "/summary.csv"
        File gexPerMoleculeInfo = outBase + "/gex_molecule_info.h5"

        File gexBam = outBase + "/gex_possorted_bam.bam"
        File gexBai = outBase + "/gex_possorted_bam.bam.bai"

        File atacBam = outBase + "/atac_possorted_bam.bam"
        File atacBai = outBase + "/atac_possorted_bam.bam.bai"

        File atacFragments = outBase + "/atac_fragments.tsv.gz"
        File atacFragmentsIndex = outBase + "/atac_fragments.tsv.gz.tbi"

        Array[File] rawFeatureBCMatrix = glob(outBase + "/raw_feature_bc_matrix/*")
        File rawFeatureBCMatrixH5 = outBase + "/raw_feature_bc_matrix.h5"

        Array[File] filteredFeatureBCMatrix = glob(outBase + "/filtered_feature_bc_matrix/*")
        File filteredFeatureBCMatrixH5 = outBase + "/filtered_feature_bc_matrix.h5"

        File? secondaryAnalysis = outBase + "/analysis.tgz"

        File perBarcodeMetrics = outBase + "/per_barcode_metrics.csv"
        File peaks = outBase + "/atac_peaks.bed"
        File cutSites = outBase + "/atac_cut_sites.bigwig"
        File peakAnnotation = outBase + "/atac_peak_annotation.tsv"

        File cloupe = outBase + "/cloupe.cloupe"

        File pipestanceMeta = sampleName + "/" + sampleName + ".mri.tgz"
    }

    runtime {
        docker: dockerImage
        disks: "local-disk " + ceil(2 * (if inputSize < 1 then 100 else inputSize )) + " HDD"
        cpu: cores
        memory: memoryGB + " GB"
    }
}

version 1.0

import "modules/Count.wdl" as Count

workflow Arc {

    input {
        String sampleName
        String gexFastqName
        String atacFastqName
        Array[File] gexFastqFiles
        Array[File] atacFastqFiles
        String reference
    }

    call Count.Count {
        input:
            sampleName = sampleName,
            gexFastqName = gexFastqName,
            atacFastqName = atacFastqName,
            gexFastqFiles = gexFastqFiles,
            atacFastqFiles = atacFastqFiles,
            reference = reference
    }

    output {
        File webSummary = Count.webSummary

        File metricsSummary = Count.metricsSummary

        File gexBam = Count.gexBam
        File gexBai = Count.gexBai

        File atacBam = Count.atacBam
        File atacBai = Count.atacBai

        Array[File] hdf5 = Count.hdf5

        File atacFragments = Count.atacFragments
        File atacFragmentsIndex = Count.atacFragmentsIndex

        Array[File] rawFeatureBCMatrix = Count.rawFeatureBCMatrix
        Array[File] filteredFeatureBCMatrix = Count.filteredFeatureBCMatrix

        File? outAnalysis = Count.outAnalysis

        File perBarcodeMetrics = Count.perBarcodeMetrics
        File peaks = Count.peaks
        File cutSites = Count.cutSites
        File peakAnnotation = Count.peakAnnotation

        File cloupe = Count.cloupe

        File pipestance = Count.pipestance

        File debugFile = Count.debugFile
    }
}

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

        # docker-related
        String dockerRegistry
    }

    call Count.Count {
        input:
            sampleName = sampleName,
            gexFastqName = gexFastqName,
            atacFastqName = atacFastqName,
            gexFastqFiles = gexFastqFiles,
            atacFastqFiles = atacFastqFiles,
            reference = reference,
            dockerRegistry = dockerRegistry
    }

    output {
        File libraries = Count.libraries

        File webSummary = Count.webSummary
        File metricsSummary = Count.metricsSummary
        File gexPerMoleculeInfo = Count.gexPerMoleculeInfo

        File gexBam = Count.gexBam
        File gexBai = Count.gexBai

        File atacBam = Count.atacBam
        File atacBai = Count.atacBai

        File atacFragments = Count.atacFragments
        File atacFragmentsIndex = Count.atacFragmentsIndex

        Array[File] rawFeatureBCMatrix = Count.rawFeatureBCMatrix
        File rawFeatureBCMatrixH5 = Count.rawFeatureBCMatrixH5

        Array[File] filteredFeatureBCMatrix = Count.filteredFeatureBCMatrix
        File filteredFeatureBCMatrixH5 = Count.filteredFeatureBCMatrixH5

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

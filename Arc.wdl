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

}

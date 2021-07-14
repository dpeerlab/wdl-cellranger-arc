# Cell Ranger ARC

- https://support.10xgenomics.com/single-cell-multiome-atac-gex/software/pipelines/latest/using/count
- https://support.10xgenomics.com/single-cell-multiome-atac-gex/software/downloads/latest

## Submit

```
./submit.sh \
    -k ~/keys/secrets-aws.json \
    -i configs/PDAC-DACE437LUNG.inputs.json \
    -l configs/PDAC-DACE437LUNG.labels.aws.json \
    -o Arc.options.aws.json
```

## Genome

- GRCh38 Reference - 2020-A-2.0.0 (May 3, 2021): `https://cf.10xgenomics.com/supp/cell-arc/refdata-cellranger-arc-GRCh38-2020-A-2.0.0.tar.gz`
- mm10 Reference - 2020-A-2.0.0 (May 3, 2021): `https://cf.10xgenomics.com/supp/cell-arc/refdata-cellranger-arc-mm10-2020-A-2.0.0.tar.gz`

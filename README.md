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

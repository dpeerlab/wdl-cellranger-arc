#!/usr/bin/env bash

java -jar ~/Applications/womtool.jar \
    validate \
    CellRangerArc.wdl \
    --inputs ./configs/dev.inputs.json

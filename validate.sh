#!/usr/bin/env bash

java -jar ~/Applications/womtool.jar \
    validate \
    Arc.wdl \
    --inputs ./configs/dev.inputs.json

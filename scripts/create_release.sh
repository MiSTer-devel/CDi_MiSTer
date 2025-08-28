#!/bin/bash

set -e
cd "$(dirname "$0")/.."
release_filename=CDi_$(date '+%Y%m%d').rbf
cp output_files/CDi.rbf releases/$release_filename
echo "Copied build to releases/$release_filename"


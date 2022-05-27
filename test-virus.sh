#!/bin/bash

aws s3 cp fixtures/test-virus.txt s3://clamav-quarantine-bucket
aws s3 cp fixtures/test-file.txt s3://clamav-quarantine-bucket

sleep 30

VIRUS_TEST=$(aws s3api get-object-tagging --key test-virus.txt --bucket clamav-quarantine-bucket --output text)
CLEAN_TEST=$(aws s3api get-object-tagging --key test-file.txt --bucket clamav-clean-bucket --output text)

echo "Dirty tag: ${VIRUS_TEST}"
echo "Clean tag: ${CLEAN_TEST}"
#!/usr/bin/bash
USAGE=:' \
__LabGrades
 |_ grader.sh 
 |_ submissions.zip
 |_ lab#_tester.sh

usage: grader.sh EXECNAME TESTSCRIPTNAME

This script will automatically unzip all the submissions, run the test script 
$2 on them, and zip them back in a directory named GradedLab.
'
TERMWIDTH=`stty size | awk '{print $2}'`
EXECNAME=$1
TESTSCRIPT=$2

# Cleanup previous run
rm -rf submissions GradedLab.zip

# Unzip
printf "*%.0s" $(seq 1 $TERMWIDTH)
printf "\nUnzipping submissions"
unzip -qqo submissions.zip -d submissions
find submissions -name '*.zip' -exec sh -c 'unzip -qqo -d "${1%.*}" "$1"' _ {} \;
find submissions -name '*.zip' ! -name 'submissions.zip' -exec rm -rf {} \;

# Grade
printf "\nGrading submissions\n" 
find submissions -type f \( -name 'Makefile' \) \
    -exec bash -c ' \
    cp '${TESTSCRIPT}' "$(dirname "{}")" && \
    cd "$(dirname "{}")" && \
    basename $PWD && \
    rm -f '${EXECNAME}' && \
    make > OUTPUTLOG 2>&1 || true && \
    # timeout 5 '${EXECNAME}' >> OUTPUTLOG 2>&1 |: && \
    printf "=%.0s" $(seq 1 80) >> OUTPUTLOG && \
    sh '${TESTSCRIPT}' >> OUTPUTLOG 2>&1 || true'  \;
    # rm -f '${TESTSCRIPT}'' \;

# Move graded directories
printf "\nZipping graded submissions"

# Make zip with graded submissions
zip -qq -r GradedLab submissions

printf "\nDone.\n"
printf "*%.0s" $(seq 1 $TERMWIDTH)

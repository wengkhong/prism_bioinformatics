#!/bin/bash

REFERENCE="/data/share/refs/hs37d5.fa"
MANTA="/data/apps/manta/install/bin"
curdir=`pwd`

bamfile=$1
#echo $bamfile

filebname=`basename ${1%%.*}`

#echo $filebname

mkdir -p $curdir/MantaSV/$filebname

cd $curdir/MantaSV/$filebname

$MANTA/configManta.py --bam $bamfile --referenceFasta $REFERENCE --runDir $curdir/MantaSV/$filebname
$curdir/MantaSV/$filebname/runWorkflow.py -m local -j 8



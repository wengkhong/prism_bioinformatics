#!/bin/bash

#REFERENCE="/data/share/refs/hg19/hg19.fa"
REFERENCE="/data/share/refs/hs37d5.fa"
TARGET_REGIONS="/data/share/SureSelect_V6_hs37d5.bed"
STRELKA="/data/apps/strelka_workflow-1.0.15"
config="/data/share/Joanne_Novogene_Nov2016/STRELKA/config.ini"
FreeC="/data/apps/Control-freeC/FREEC-10.3"
bedtools="/usr/bin/bedtools"
samtools="/data/apps/samtools-1.3.1/samtools"
curdir=`pwd`

normalinput=$1
tumorinput=$2
normalbname=`basename ${1%%.*}`
tumorbname=`basename ${2%%.*}`
normallongbname=`basename $1`
tumorlongbname=`basename $2`
echo $a
echo "./$normalbname$tumorbname"

##----------------STRELKA------------------------

$STRELKA/bin/configureStrelkaWorkflow.pl --normal=$normalinput --tumor=$tumorinput --ref=$REFERENCE --config=$config --output-dir="$normalbname$tumorbname"
#make -C "./$normalbname$tumorbname" -j 32
#!/bin/bash

#WK: Minor change to annovar
#REFERENCE="/data/share/refs/hg19/hg19.fa"
REFERENCE="/data/share/refs/hs37d5.fa"
TARGET_REGIONS="/data/share/SureSelect_V6_hs37d5.bed"
STRELKA="/data/apps/strelka_workflow-1.0.15"
config="/data/share/Joanne_Novogene_Nov2016/STRELKA/config.ini"
FreeC="/data/apps/Control-freeC/FREEC-10.3"
bedtools="/data/apps/bedtools/bedtools2/bin/bedtools"
samtools="/data/apps/samtools-1.3.1/samtools"
pigz="/data/apps/pigz-2.4/pigz"
curdir=`pwd`

normalinput=$1
tumorinput=$2
normalbname=`basename ${1%%.*}`
tumorbname=`basename ${2%%.*}`
normallongbname=`basename $1`
tumorlongbname=`basename $2`
#echo $a
echo "./$normalbname$tumorbname"

## ------------------- Annotation with refseq bed file -------------------

cd $curdir/ControfreeC/"$normalbname$tumorbname"

tail -n +2 $tumorlongbname.pileup.gz_CNVs.p.value.txt | $bedtools intersect -loj -a - -b /data/share/resources/refseq.sorted.uniq.nochr.bed > "$normalbname$tumorbname"_CNVs_annotated.txt

head -n1 $tumorlongbname.pileup.gz_CNVs.p.value.txt | cat - "$normalbname$tumorbname"_CNVs_annotated.txt > "$normalbname$tumorbname"_CNVs_annotated.wtheader.txt

rm "$normalbname$tumorbname"_CNVs_annotated.txt
mv "$normalbname$tumorbname"_CNVs_annotated.wtheader.txt "$normalbname$tumorbname"_CNVs_annotated.txt

cat "$normalbname$tumorbname"_CNVs_annotated.txt | cut -f13,14 --complement | uniq > "$normalbname$tumorbname"_CNVs_annotated_final.txt
rm "$normalbname$tumorbname"_CNVs_annotated.txt
mv "$normalbname$tumorbname"_CNVs_annotated_final.txt "$normalbname$tumorbname"_CNVs_annotated.txt

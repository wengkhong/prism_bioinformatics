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

##----------------Control FreeC------------------------------------------
#mkdir -p $curdir/ControfreeC/"$normalbname$tumorbname"



## ----------------- Mpileup create pileup input file to controlfreec --------------------------
#$samtools mpileup -f $REFERENCE $normalinput | $pigz -p 20 > $curdir/ControfreeC/"$normalbname$tumorbname"/$normallongbname.pileup.gz
#$samtools mpileup -f $REFERENCE $tumorinput | $pigz -p 20 > $curdir/ControfreeC/"$normalbname$tumorbname"/$tumorlongbname.pileup.gz



##---------------create config file------------------
cd $curdir/ControfreeC/"$normalbname$tumorbname"

cat >config_exome_$normalbname$tumorbname.txt <<EOL
###For more options see: http://boevalab.com/FREEC/tutorial.html#CONFIG ###

[general]
chrLenFile = /data/share/refs/hs37d5.len
window = 0
ploidy = 2
outputDir = $curdir/ControfreeC/$normalbname$tumorbname
samtools = /usr/bin/samtools
sambamba = /data/apps/sambamba
bedtools = /data/apps/bedtools/bedtools2/bin/bedtools

breakPointType=4
chrFiles = /data/share/refs/hs37d5_fasplit
maxThreads=20

breakPointThreshold=1.5
noisyData=TRUE
printNA=FALSE

readCountThreshold=50

[sample]

mateFile = $curdir/ControfreeC/$normalbname$tumorbname/$tumorlongbname.pileup.gz
inputFormat = pileup
mateOrientation=FR

[control]

mateFile = $curdir/ControfreeC/$normalbname$tumorbname/$normallongbname.pileup.gz
inputFormat = pileup
mateOrientation=FR

[BAF]

SNPfile = /data/share/resources/hg19_snp131.SingleDiNucl.1based.txt2

[target]

captureRegions = /data/share/SureSelect_V6_hs37d5.bed

EOL




## ------------------- control freec -----------------------
/data/apps/Control-freeC/FREEC-10.3/src/freec -conf config_exome_$normalbname$tumorbname.txt


cat $FreeC/scripts/assess_significance.R | R --slave --args $tumorlongbname.pileup.gz_CNVs $tumorlongbname.pileup.gz_ratio.txt

cat $FreeC/scripts/makeGraph.R|R --slave --args 2 $tumorlongbname.pileup.gz_ratio.txt $tumorlongbname.pileup.gz_BAF.txt

## ------------------- Annotation with refseq bed file -------------------

tail -n +2 $tumorlongbname.pileup.gz_CNVs.p.value.txt | $bedtools intersect -loj -a - -b /data/resources/refseq.sorted.uniq.nochr.bed > "$normalbname$tumorbname"_CNVs_annotated.txt

head -n1 $tumorlongbname.pileup.gz_CNVs.p.value.txt | cat - "$normalbname$tumorbname"_CNVs_annotated.txt > "$normalbname$tumorbname"_CNVs_annotated.wtheader.txt

rm "$normalbname$tumorbname"_CNVs_annotated.txt
mv "$normalbname$tumorbname"_CNVs_annotated.wtheader.txt "$normalbname$tumorbname"_CNVs_annotated.txt

cat "$normalbname$tumorbname"_CNVs_annotated.txt | cut -f13,14 --complement | uniq > "$normalbname$tumorbname"_CNVs_annotated_final.txt
rm "$normalbname$tumorbname"_CNVs_annotated.txt
mv "$normalbname$tumorbname"_CNVs_annotated_final.txt "$normalbname$tumorbname"_CNVs_annotated.txt

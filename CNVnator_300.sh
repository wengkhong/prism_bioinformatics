#!/bin/bash

REFERENCE="/data/share/refs/hs37d5_fasplit"
CNVNATOR="/data/apps/CNVnator/CNVnator_v0.3.2/src/./cnvnator"
curdir=`pwd`

bamfile=$1
#echo $bamfile

filebname=`basename ${1%%.*}`

#echo $filebname

#mkdir -p CNVnator

cd $curdir/CNVnator

source /data/apps/root/root-6.06.08/bin/thisroot.sh
#export ROOTSYS=/data/apps/root/root-6.06.08
#export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${ROOTSYS}/lib

$CNVNATOR -unique -root $filebname.root -tree $bamfile
$CNVNATOR -root $filebname.root -his 300 -d $REFERENCE
$CNVNATOR -root $filebname.root -stat 300
$CNVNATOR -root $filebname.root -partition 300
$CNVNATOR -root $filebname.root -call 300 > $filebname.300.cnvnator.OUT



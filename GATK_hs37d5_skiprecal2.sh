#!/bin/bash

REFERENCE="/data/share/refs/hs37d5.fa"
DBSNP="/data/share/GATK_Bundle/b37/dbsnp_138.b37.vcf"
HAPMAP="/data/share/GATK_Bundle/b37/hapmap_3.3.b37.vcf"
OMNI="/data/share/GATK_Bundle/b37/1000G_omni2.5.b37.vcf"
ONET="/data/share/GATK_Bundle/b37/1000G_phase3_v4_20130502.sites.vcf"
MILLS_GOLDSTD="/data/share/GATK_Bundle/b37/Mills_and_1000G_gold_standard.indels.b37.vcf"
GATK="/data/apps/gatk-3.7/GenomeAnalysisTK.jar"
samtools="/data/apps/samtools-1.3.1/samtools"
#curdir=`pwd`
#echo $curdir

inputbam=$1
#echo $inputbam
inputbname=`basename ${1%%.*}`
#echo $inputbname

### ------------------------ PRINTREADS ------------------------------
#mkdir -p printreads

#cat /data/share/MalayGenomes/chromosomes.txt | xargs -n1 -P6 '-I{}' java -Xmx8192m -jar $GATK -nct 6 -T PrintReads -R $REFERENCE -I $inputbname.bam -BQSR $inputbname.recal.22.table -o 'printreads/recalibrated.{}.bam' -L '{}'

#cd printreads

#$samtools cat -o ../$inputbname.recalibrated.bam $(cat /data/share/MalayGenomes/chromosomes.txt | awk '{print "recalibrated." $0 ".bam"}' | paste -sd " ")
#cd ..
#$samtools index $inputbname.recalibrated.bam
#rm -r printreads

### -------------------------- HAPLOTYPECALLER ------------------------------

mkdir -p haplotypecaller

cat /data/share/PRISM_WGS/chromosomes.txt | xargs -n1 -P5 '-I{}' java -jar $GATK -T HaplotypeCaller -R $REFERENCE -D $DBSNP -I $inputbname.rmdup.bam -ERC GVCF --variant_index_type LINEAR --variant_index_parameter 128000 -o 'haplotypecaller/{}.vcf' -L '{}' -nct 6

cd haplotypecaller
#ls

java -cp $GATK org.broadinstitute.gatk.tools.CatVariants -R $REFERENCE $(cat /data/share/PRISM_WGS/chromosomes.txt | awk '{print "-V " $0 ".vcf"}'| paste -sd " ") -assumeSorted -out ../$inputbname.haplotype.g.vcf
cd ..
rm -r haplotypecaller

/data/apps/bgzip $inputbname.haplotype.g.vcf -@40 

/data/apps/tabix -p vcf $inputbname.haplotype.g.vcf.gz 

### ---------------------------- GENOTYPEGVCF --------------------------------

mkdir -p genotypegvcf

cat /data/share/PRISM_WGS/chromosomes.txt | xargs -n1 -P5 -I{} java -jar $GATK -T GenotypeGVCFs -R $REFERENCE -D $DBSNP -V $inputbname.haplotype.g.vcf.gz -o 'genotypegvcf/{}.vcf' -L '{}' -nt 4

cd genotypegvcf

java -cp $GATK org.broadinstitute.gatk.tools.CatVariants -R $REFERENCE $(cat /data/share/PRISM_WGS/chromosomes.txt | awk '{print "-V " $0 ".vcf"}' | paste -sd " ") -assumeSorted -out ../$inputbname.vcf 
cd ..
rm -r genotypegvcf

/data/apps/bgzip $inputbname.vcf -@40

/data/apps/tabix -p vcf $inputbname.vcf.gz




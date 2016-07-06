#!/usr/bin/env bash
 
# Module load
module load java
module load gatk

# SAM to BAM conversion
#samtools view -b -S "${outprefix}.sam" > "$outprefix.bam"
#rm "${outprefix}.sam"
#samtools sort "${outprefix}.bam" "${outprefix}.sorted"
#mv "${outprefix}.sorted.bam" "{$outprefix}.bam"
#samtools index "${outprefix}.bam"
 
# GATK
# To run it on BRAZOS: ${GATK_ROOT}/*.jar
# To run it on GREENFIELD: *.jar

# Local realignment around indels
java -d64 -Xms512m -Xmx4g -jar GenomeAnalysisTK.jar -T RealignerTargetCreator -R $reference -o $outprefix.bam.list \
    -I $outprefix.bam 2>$outprefix.indel.log

java -d64 -Xms512m -Xmx4g -jar GenomeAnalysisTK.jar -I $outprefix.bam -R $reference -T IndelRealigner \
    -targetIntervals $outprefix.bam.list -o $outprefix.realigned.bam 2>$outprefix.indel2.log
 
# Quality score recalibration
java -d64 -Xms512m -Xmx4g -jar GenomeAnalysisTK.jar -l INFO -R $reference -knownSites $dbsnp -I $outprefix.realigned.bam \
    -T CountCovariates -cov ReadGroupCovariate -cov QualityScoreCovariate -cov CycleCovariate -cov DinucCovariate \
    -recalFile $outprefix.recal_data.csv 2>$outprefix.recal.log
 
java -d64 -Xms512m -Xmx4g -jar GenomeAnalysisTK.jar -l INFO -R $reference -I $outprefix.realigned.bam -T TableRecalibration \
    -o $outprefix.realigned.recal.bam -recalFile $outprefix.recal_data.csv 2>$outprefix.recal2.log
 
# Produce SNP calls
java -d64 -Xms512m -Xmx4g -jar GenomeAnalysisTK.jar -glm BOTH -R $reference -T UnifiedGenotyper -I $outprefix.realigned.recal.bam \
    --dbsnp $dbsnp -o $outprefix.snps.vcf -metrics snps.metrics -stand_call_conf 50.0 \
    -stand_emit_conf 10.0 -dcov 1000 -A DepthOfCoverage -A AlleleBalance
 
# Filter SNPs (according to seqanswers exome guide)
java -d64 -Xms512m -Xmx4g -jar GenomeAnalysisTK.jar -R $reference -T VariantFiltration -B:variant,VCF snp.vcf.recalibrated \
    -o $outprefix.snp.filtered.vcf --clusterWindowSize 10 --filterExpression "MQ0 >= 4 && ((MQ0 / (1.0 * DP)) > 0.1)" \
    --filterName "HARD_TO_VALIDATE" --filterExpression "DP < 5 " --filterName "LowCoverage" --filterExpression "QUAL < 30.0 " \
    --filterName "VeryLowQual" --filterExpression "QUAL > 30.0 && QUAL < 50.0 " --filterName "LowQual" --filterExpression "QD < 1.5 " \
    --filterName "LowQD" --filterExpression "SB > -10.0 " --filterName "StrandBias"

#!/bin/bash
set -e

# script by ellisrichardj
# This will perform minor variant analysis of all samples within a directory
# Requires BWA and samtools

# Version 0.1.1 12/09/17	Initial Version
# Version 0.1.2 22/01/18	Combined bam sorting and filtering into a single step

# check for mandatory positional parameters
if [ $# -lt 2 ]; then
  echo "
Usage: $0 <path to reference> <path to Data Folder> "
exit 1
fi

Start=$(date +%s)

Ref=$1
DataFolder="$2"
Count=0
threads=$(grep -c ^processor /proc/cpuinfo)

	ref=$(basename "$Ref")
	refname=${ref%%.*}

homedir=$(pwd)
cp "$Ref" "$homedir"
bwa index "$ref"

for file in "$DataFolder"/*R1*.gz
do
	((Count=Count+1))
	fname=$(basename "$file")
	samplename=${fname%%_*}
	mkdir "$samplename"_mapto_"$refname"
	cd "$samplename"_mapto_"$refname"	
	echo "Mapping sample "$Count": "$samplename" to "$ref""
	
	bwa mem -t "$threads" "$homedir"/"$ref" "$DataFolder"/"$samplename"*R1*.gz "$DataFolder"/"$samplename"*R2*.gz | samtools view -@ "$threads" -F4 -Su - | samtools sort -@ "$threads" -o "$samplename"-"$refname"_mapOnly_sorted.bam

#	samtools view -@ "$threads" -bF4 -o "$samplename"-"$refname"_mapOnly.bam "$samplename"-"$refname"_map_sorted.bam
	samtools index "$samplename"-"$refname"_mapOnly_sorted.bam

	samtools mpileup -Os -f "$homedir"/"$ref" "$samplename"-"$refname"_mapOnly_sorted.bam | awk -F'\t' -v OFS='\t' '{ gsub("\\^.","",$5); gsub("\\$","",$5); gsub("\\-[0-9]*[ACGTNacgtn]*","",$5); gsub("\\+[0-9]*[ACGTNacgtn]*","",$5); print }' - > "$samplename"-"$refname".pileup


python ~/MyScripts/MinorVar/pileupCount.py $PWD "$samplename"-"$refname"."pileup" 20 50

cd "$homedir"

done

End=$(date +%s)
TimeTaken=$((End-Start))

echo  | awk -v D=$TimeTaken '{printf "Mapped '$Count' samples in: %02d'h':%02d'm':%02d's'\n",D/(60*60),D%(60*60)/60,D%60}'

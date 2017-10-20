#!/bin/bash

CHR=$1
STEP=$2
THRESS=$3
query_name=$4

PWD=`pwd`
WD=$PWD/INPUT
HCES_DB_coords=$WD/HCE_DB_coords
HCE_DB=$WD/HCE_DB
BIN=$PWD/bin
TMP=$PWD/OUTPUT_$query_name/tmp_$query_name


if [ ! -d $HCE_DB/NoSplit ]
then
        mkdir $HCE_DB/NoSplit
        mv $HCE_DB/*.fa $HCE_DB/NoSplit 2>/dev/null
fi

#[ ! -d $HCE_DB/NoSplit ] && mkdir -p $HCE_DB/NoSplit
#mv $HCE_DB/*.fa $HCE_DB/NoSplit 2>/dev/null

	$BIN/splitTheBed.pl $HCES_DB_coords/most_conserved_chr${CHR}.bed $STEP $THRESS > $HCES_DB_coords/most_conserved_chr${CHR}.split.txt
	sleep 3

	sed '/^$/d' $HCES_DB_coords/most_conserved_chr${CHR}.split.txt > $HCES_DB_coords/most_conserved_chr${CHR}.split.cl.txt

	sort -k2,2 -n $HCES_DB_coords/most_conserved_chr${CHR}.split.cl.txt > $HCES_DB_coords/most_conserved_chr${CHR}.split.cl.sorted.txt
	sleep 3

	$BIN/after_Splitting.pl $HCES_DB_coords/most_conserved_chr${CHR}.split.cl.sorted.txt > $HCES_DB_coords/most_conserved_chr${CHR}.split.cl.sorted.bed

	$BIN/putRefCoords.pl $HCES_DB_coords/most_conserved_chr${CHR}.split.cl.sorted.bed > $HCES_DB_coords/most_conserved_chr${CHR}.split.cl.sorted.Rcoords.bed

	$BIN/fastaFromBed -fi $TMP/chr${CHR}.fa -bed $HCES_DB_coords/most_conserved_chr${CHR}.split.cl.sorted.Rcoords.bed -fo $HCE_DB/most_conserved_chr${CHR}.fa -name

	sleep 5
	rm $HCES_DB_coords/*.txt $HCES_DB_coords/*.sorted.bed $HCES_DB_coords/*.sorted.Rcoords.bed



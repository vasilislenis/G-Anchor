#!/bin/bash
CHR=$1
HCE=$2
TARGET=$3
QUERY=$4
PAR_F=$5
NCORES=$6
OOC_F=$7
FM_F=$8
SPLIT_F=$9
STP=${10}
THRESS=${11}
BLATTHRESS=${12}
PSLRESTHRESS=${13}

PWD=`pwd`
TOOLS=$PWD/bin

target=$(basename "$TARGET")
target_ext="${target##*.}"
target_name="${target%.*}"

query=$(basename "$QUERY")
query_ext="${query##*.}"
query_name="${query%.*}"

[ ! -d $PWD/OUTPUT_$query_name ] && mkdir -p $PWD/OUTPUT_$query_name
WD=$PWD/OUTPUT_$query_name

[ ! -d $WD/tmp_$query_name ] && mkdir -p $WD/tmp_$query_name
[ ! -d $WD/BLAT_output_$query_name ] && mkdir -p $WD/BLAT_output_$query_name
[ ! -d $WD/psl_best_$query_name ] && mkdir -p $WD/psl_best_$query_name
[ ! -d $WD/ps_files_$query_name ] && mkdir -p $WD/ps_files_$query_name
[ ! -d $WD/psl_score_$query_name ] && mkdir -p $WD/psl_score_$query_name
[ ! -d $WD/psl_score_byname_$query_name ] && mkdir -p $WD/psl_score_byname_$query_name
[ ! -d $WD/unique_hces_$query_name ] && mkdir -p $WD/unique_hces_$query_name
[ ! -d $WD/double_hces_$query_name ] && mkdir -p $WD/double_hces_$query_name
[ ! -d $WD/unique_hces_sorted_P1_$query_name ] && mkdir -p $WD/unique_hces_sorted_P1_$query_name
[ ! -d $WD/unique_hces_sorted_P2_$query_name ] && mkdir -p $WD/unique_hces_sorted_P2_$query_name
[ ! -d $WD/unique_hces_final_$query_name ] && mkdir -p $WD/unique_hces_final_$query_name
[ ! -d $WD/unique_hces_count_$query_name ] && mkdir -p $WD/unique_hces_count_$query_name
[ ! -d $WD/psl_raw_$query_name ] && mkdir -p $WD/psl_raw_$query_name
[ ! -d $WD/psl_swap_$query_name ] && mkdir -p $WD/psl_swap_$query_name
[ ! -d $WD/psl_final_$query_name ] && mkdir -p $WD/psl_final_$query_name
[ ! -d $WD/chains_$query_name ] && mkdir -p $WD/chains_$query_name
[ ! -d $WD/nets_$query_name ] && mkdir -p $WD/nets_$query_name

TMP=$WD/tmp_$query_name
BLAT=$WD/BLAT_output_$query_name
PBEST=$WD/psl_best_$query_name
PS=$WD/ps_files_$query_name
PSLSCORE=$WD/psl_score_$query_name
PSLSCOREN=$WD/psl_score_byname_$query_name
UNIQUE=$WD/unique_hces_$query_name
DOUBLE=$WD/double_hces_$query_name
US_P1=$WD/unique_hces_sorted_P1_$query_name
US_P2=$WD/unique_hces_sorted_P2_$query_name
FINAL_HCES=$WD/unique_hces_final_$query_name
HCE_COUNT=$WD/unique_hces_count_$query_name
PSL_RAW=$WD/psl_raw_$query_name
PSL_SWAP=$WD/psl_swap_$query_name
PSL_FINAL=$WD/psl_final_$query_name
CHAINS=$WD/chains_$query_name
NETS=$WD/nets_$query_name


echo "Converting the target genome from 2bit format into fasta..."
$TOOLS/twoBitToFa $TARGET $TMP/$target_name.fa

####Headers check
tregex='^>chr[0-9]+$'
theader=`grep ">" $TMP/$target_name.fa`
if [[ ! $theader =~ $tregex ]]
then
        echo "Invalid fasta header in ga-reference. Check the G-Anchor manual for the headers format"
        exit 1
else
        echo "Done!!!"
fi
hceregex='^>chr[0-9]+(\.[0-9]+){4}$'
grep ">" $HCE > $TMP/$CHR.HCE.headers
file="$TMP/$CHR.HCE.headers"
while  read -r line
do
        if [[ ! $line =~ $hceregex ]]
        then
                echo "Invalid fasta header in HCE sequence. Check the G-Anchor manual for the headers format"
                exit 1
        fi
done < $file
#########

echo "Done!!!"

echo "Calculating the target size..."
$TOOLS/faSize -detailed $TMP/$target_name.fa > $TMP/$CHR.size
echo "Done!!!"

if [ ! -f $TMP/$query_name.fa ];
then
	echo "Converting the query genome from 2bit format into fasta..."
	echo "It will take a little bit longer..."
	$TOOLS/twoBitToFa $QUERY $TMP/$query_name.fa
	echo "Done!!!"
else
	echo "Query genome is ok, doesn't have to convert it..."
fi

if [ ! -f $TMP/$query_name.sizes ];
then
	echo "Calculating the query size..."
	$TOOLS/faSize -detailed $TMP/$query_name.fa > $TMP/$query_name.sizes
	echo "Done!!!"
else
	echo "We have the sizes of the query, so we don't have to recalculate them..."
fi
if [ $OOC_F -eq 1 ]
then
if [ ! -f $TOOLS/$query_name.11.ooc ]
then
        echo "Lets generate an 11.ooc file..."
	RSIZE=`$TOOLS/faSize $TMP/$query_name.fa | awk 'NR==1{print $5}'`
	#echo "$RSIZE"
	HgRATIO=`awk 'BEGIN{printf "%.6f\n", '"$RSIZE"' / 2897310462 * 1024}'`
	#echo "$HgRATIO"
	INTNUM=`awk 'BEGIN{printf "%.0f\n", '"$HgRATIO"'}'`
	#echo "$INTNUM"
	ROUND1=`awk 'BEGIN{printf "%.0f\n", '"$INTNUM"' / 50}'`
	#echo "$ROUND1"
	ROUND2=`awk 'BEGIN{printf "%.0f\n", '"$ROUND1"' * 50}'`	
	#echo "$ROUND2"
        $TOOLS/blat $QUERY /dev/null /dev/null -tileSize=11 -makeOoc=$TOOLS/$query_name.11.ooc -repMatch=$ROUND2 -minIdentity=$BLATTHRESS
         echo "Done!!!"
fi
fi

if [ ! -z $9 ] && [ "$SPLIT_F" -eq "1" ] 
then
echo "Splitting the large HCEs..."
	#CHR_NUM=$(grep -o "[0-9]" <<<"$CHR")
	CHR_NUM=$(tr -cd 0-9 <<<"$CHR")
	$TOOLS/HCEs_splitting.sh $CHR_NUM $STP $THRESS $query_name
else
echo "No splitting the large HCEs..."
fi


echo "Running BLAT....."
if [ $BLATTHRESS -ne 90 ]
then
	echo "You chose $BLATTHRESS % as a minimal mapping thresshold"
fi
if [ $PAR_F -eq 1 ] && [ $OOC_F -eq 1 ] && [ $FM_F -eq 1 ]
then
	echo "On $NCORES threads with -ooc and -fastMap flags"
	$TOOLS/pblat -threads=$NCORES -ooc=$TOOLS/$query_name.11.ooc -fastMap $TMP/$query_name.fa $HCE $BLAT/$CHR.psl -minIdentity=$BLATTHRESS
fi
if [ $PAR_F -eq 1 ] && [ $OOC_F -eq 0 ] && [ $FM_F -eq 1 ] 
then
	echo "On $NCORES threads with -fastMap flag"
	$TOOLS/pblat -threads=$NCORES -fastMap $TMP/$query_name.fa $HCE $BLAT/$CHR.psl -minIdentity=$BLATTHRESS
fi
if [ $PAR_F -eq 1 ] && [ $OOC_F -eq 1 ] && [ $FM_F -eq 0 ] 
then
	echo "On $NCORES threads with -ooc flag"
	$TOOLS/pblat -threads=$NCORES -ooc=$TOOLS/$query_name.11.ooc $TMP/$query_name.fa $HCE $BLAT/$CHR.psl -minIdentity=$BLATTHRESS
fi
if [ $PAR_F -eq 1 ] && [ $OOC_F -eq 0 ] && [ $FM_F -eq 0 ]
then
	echo "On $NCORES threads"
         $TOOLS/pblat -threads=$NCORES  $TMP/$query_name.fa $HCE $BLAT/$CHR.psl -minIdentity=$BLATTHRESS
fi
if [ $PAR_F -eq 0 ] && [ $OOC_F -eq 1 ] && [ $FM_F -eq 1 ]
then
	echo "On a single core with -ooc and -fastMap flags"
	$TOOLS/pblat -ooc=$TOOLS/$query_name.11.ooc -fastMap $TMP/$query_name.fa $HCE $BLAT/$CHR.psl -minIdentity=$BLATTHRESS
fi
if [ $PAR_F -eq 0 ] && [ $OOC_F -eq 0 ] && [ $FM_F -eq 1 ]
then
	echo "On a single core with -fastMap flag"
        $TOOLS/pblat -fastMap $TMP/$query_name.fa $HCE $BLAT/$CHR.psl -minIdentity=$BLATTHRESS
fi
if [ $PAR_F -eq 0 ] && [ $OOC_F -eq 1 ] && [ $FM_F -eq 0 ]
then
	 echo "On a single core with -ooc flag"
        $TOOLS/pblat -ooc=$TOOLS/$query_name.11.ooc $TMP/$query_name.fa $HCE $BLAT/$CHR.psl -minIdentity=$BLATTHRESS
fi
if [ $PAR_F -eq 0 ] && [ $OOC_F -eq 0 ] && [ $FM_F -eq 0 ]
then
	echo "On a single core without any flag. It will take alot..."
        $TOOLS/pblat $TMP/$query_name.fa $HCE $BLAT/$CHR.psl -minIdentity=$BLATTHRESS
fi
echo "Done!!!"

echo "Filtering BLAT results with pslReps....."
if [ $PSLRESTHRESS != 0.93 ]
then
        echo "You chose $PSLRESTHRESS  as filtering ratio"
fi
$TOOLS/pslReps -nohead -minAli=$PSLRESTHRESS $BLAT/$CHR.psl $PBEST/$CHR.psl $PS/$CHR.ps
echo "Done!!!"

echo "Calculating the score of the alignments....."
$TOOLS/pslScore $PBEST/$CHR.psl > $PSLSCORE/$CHR.table
echo "Done!!!"

echo "Cut the coordinates of the hce's names....."
$TOOLS/keepTheName.pl $PSLSCORE/$CHR.table > $PSLSCOREN/$CHR.table
echo "Done!!!"

echo "Clustering unique and doudle elements....."
$TOOLS/KeepTheUnique.pl $CHR $query_name
echo "Done!!!"

echo "Sorting the elements: Phase 1 (making gaps)....."
$TOOLS/uniqueSorting.pl $UNIQUE/$CHR.txt > $US_P1/$CHR.txt
echo "Done!!!"

echo "Sorting the elements: Phase 2 (sorting)....."
sort -n -k5,5 -k6,6 $US_P1/$CHR.txt > $US_P2/$CHR.txt
echo "Done!!!"

echo "Merging the sorted elements' names...."
$TOOLS/mergingAgain.pl $US_P2/$CHR.txt > $FINAL_HCES/$CHR.txt
echo "Done!!!"

echo "Counting the elements that are up to each scaffold...."
$TOOLS/grepScaffUnique.pl $CHR $query_name > $HCE_COUNT/$CHR.txt
echo "Done!!!"

echo "Filter the psls by using the unique elements...."
$TOOLS/pslRaw_new_version.pl $CHR $query_name
echo "Done!!!"

echo "Swapping the psls...."
$TOOLS/pslSwap $PSL_RAW/$CHR.psl $PSL_SWAP/$CHR.psl
echo "Done!!!"

echo "Annotating the reference coordinates...."
$TOOLS/pslChangeCoords.pl $CHR $PSL_SWAP/$CHR.psl $TMP/$CHR.size > $PSL_FINAL/$CHR.psl
echo "Done!!!"

echo "Making Chains...."
$TOOLS/axtChain -psl $PSL_FINAL/$CHR.psl -verbose=0 -linearGap=loose -minScore=3000  $TARGET -faQ $TMP/$query_name.fa $CHAINS/$CHR.chain 
echo "Done!!!"

echo "Making Nets...."
$TOOLS/chainNet $CHAINS/$CHR.chain -minSpace=1 $TMP/$CHR.size $TMP/$query_name.sizes stdout /dev/null | $TOOLS/netSyntenic stdin $NETS/$CHR.syn.net
echo "Done!!!"
echo "#####################################################################################################################"
echo "#################################################### FINISH!!!! #####################################################"
echo "########### The final results are in 'OUTPUT_target_genome/chains' and 'OUTPUT_target_genome/nets' folders ##########"
echo "############################################### ENJOY THE RESULTS!!! ################################################"
echo "#####################################################################################################################"

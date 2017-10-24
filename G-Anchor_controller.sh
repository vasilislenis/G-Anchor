#!/bin/bash

PWD=`pwd`
IN=$PWD/INPUT

if [ $# -lt 1 ]
then
	echo "Wellcome to G-Anchor: A whole genome alignment approach with hces anchor points...."
	echo "Use -h or --help option to see G-Anchors' features..."
	exit 1
fi

####################
#Interactive mode function
function interactive {
 echo "Give the first number of the range of the chromosomes that you want to align: "
        read CHR1
        echo "Give the second number of the range of the chromosomes that you want to align: "
        read CHR2

        if [ $CHR2 -lt $CHR1 ]
        then
                echo "The second number that you gave for the chromosome range should be greater than the first one (or equal if you want to align only one chromosome)"
                exit
        fi

        echo "Give the name of the genome that you want to align: "
        read GENOME
        echo "Do you want to run the alignment part in parallel? (y/n)"
        read PARAL


        if [ $PARAL == "y"  ]
        then
                FLAGP=1
        else
                FLAGP=0
        fi

        if [ $PARAL == "y"  ]
        then
                echo "Give the number of the threads"
                read CORES
                R=$CORES
        else
                R=1
        fi	
if [ $CORES -eq $CORES 2>/dev/null ]
        then
                C=$CORES
                else
                echo "Wrong input. It should be an int"
                exit
        fi

        echo "Do you want to use the -ooc parameter? (y/n)"
        read OOC
        if [ $OOC == "y"  ]
        then
                FLAGOOC=1
        else
                FLAGOOC=0
        fi

        echo "Do you want to use the -fastMap parameter? (y/n)"
        read FM
        if [ $FM == "y"  ]
        then
                FM=1
		SP=1
                ST=1000
                TH=5000
        else
                FM=0
        fi

        echo "Do you want to split the large HCEs? (y/n)"
        read SP
        if [ $SP == "y"  ]
        then
                SP=1
                echo "Give the step for splitting"
                read ST
                echo "Give the thresshold for splitting"
                read TH
        else
		if [ $FM != 1 ] && [ $SP == "n" ]
		then
                	SP=0
                	ST=0
                	TH=0
		fi
        fi
	 if [ $FM == 1  ] && [ $SP == "n" ]
        then
                FM=1
                SP=1
                ST=1000
                TH=5000
        else
                FM=0
        fi
	echo "Do you want to set the minimum sequence identity in the HCE mapping stage? (y/n) (recommended in divergent species)"
	read MI
	if [ $MI == "y" ]
	then
		
		echo "Give the Identity thresshold (persent)"
		read MI_NUM
		MI_V=$MI_NUM
	else
		MI_V=90
	fi
	echo "Do you want to set the minimum filtering in the HCE anchors definition? (y/n) (0.93 default)"
        read MA
        if [ $MA == "y" ]
        then
                echo "Give the filtering thresshold (decimal)"
                read MA_NUM
                MA_V=$MA_NUM
                else
                  	MA_V=0.93
        fi
        for i in $(seq $CHR1 $CHR2)
        do
		echo "Mapping the ga-reference chromosome $i:"
                ./G-Anchor.sh chr$i $IN/HCE_DB/most_conserved_chr$i.fa $IN/GENOMES_DB/REFERENCE/chr$i.2bit $IN/GENOMES_DB/TARGET/$GENOME.2bit $FLAGP $R $FLAGOOC $FM $SP $ST $TH $MI_V $MA_V >>logFile_$GENOME 2>&1
	echo "chromosome $i is finished!"
 	sleep 10
        done
echo \#chr$'\t'Mapped_HCEs$'\t'Max_gap$'\t'Mean_gap$'\t'Gaps_less_than: 100bp$'\t'1000bp$'\t'10000bp$'\t'100000bp$'\t'more than 100000bp >> OUTPUT_$GENOME/gap_distribution.txt
echo ----------------------------------------------------------------------------------------------------------------------------------- >> OUTPUT_$GENOME/gap_distribution.txt
        for i in $(seq $CHR1 $CHR2)
        do
                cat OUTPUT_$GENOME/unique_hces_count_$GENOME/chr$i.txt >> OUTPUT_$GENOME/unique_hces_count_$GENOME/all.txt
		./bin/gapDist.pl $i OUTPUT_$GENOME/psl_final_$GENOME/chr$i.psl >> OUTPUT_$GENOME/gap_distribution.txt
        done
        ./bin/putTheScaffoldsInRightChromosome.pl $GENOME > OUTPUT_$GENOME/chromosomes_blueprint.txt
        sleep 5
        rm -r OUTPUT_$GENOME/BL* OUTPUT_$GENOME/unique_* OUTPUT_$GENOME/tmp_* OUTPUT_$GENOME/double_* OUTPUT_$GENOME/ps_* OUTPUT_$GENOME/psl_s* OUTPUT_$GENOME/psl_r* OUTPUT_$GENOME/psl_b*
	echo "G-Anchor's mapping is finished. You can find the results at the OUTPUT/ folder and check the logfile if everything went well."
	exit 1
}
#EOF
##################
###################
while test $# -gt 0; do
        case "$1" in
                -h|--help)
			echo "---------------------------------------------------------------------------------------------------------------------------------"
                        echo "G-Anchor: A whole genome alignment approach with hces anchor points"
                        echo " "
                        echo "-h, --help			Show brief help"
			echo "Basic parameteres:"
                        echo "-s				Starting chromosome (based on ref. genome)"
			echo "-e				Ending chromosome (based on ref. genome)"
                        echo "-t, --target=<string>		Name of the genome that you want to align (as it is in your GENOME/QUERY folder)"
			echo " "
			echo "options:"
			echo "-p <int>			Number of threads for multicore run"
			echo "--fastMap			Use fastMap option"
			echo "--ooc				Use ooc option"
			echo "--split_step=<int>		Splitting the large HCEs into chunks with <int> length (must used with --split_thresshold)"
			echo "--split_thresshold=<int>	Splitting the large HCEs into chunks that are more than <int> in length (must used with --split_step)" 
			echo "--minIdentity=N			Sets minimum sequence identity (in percent).  Default is 90"
			echo "--minAli=0.N			Minimum alignment ratio.  Default is 0.95"			  			
			echo "-r				Run G-Anchor in interactive mode"
                        echo " "
			echo "Command sample:"
			echo "./G-Anchor_controller.sh -s 1 -e 29 -t yak -p 8 --ooc"
			echo "---------------------------------------------------------------------------------------------------------------------------------"
			echo "Testing G-Anchor"
			echo "-----------------"
			echo "G-Anchor package has an INPUT sample dataset in order to test it. Just run the following command:"
			echo "./G-Anchor_controller.sh -s 28 -e 28 -t yak"
			echo "---------------------------------------------------------------------------------------------------------------------------------"
			exit 0
                        ;;
		-s)
			shift
			if test $# -gt 0; then
				export START=$1
				#echo $START
			else
                                echo "no start chromosome specified"
                                exit 1
                        fi
                        shift
                        ;;
		-e) 
			shift
                        if test $# -gt 0; then
                                export END=$1
                                #echo $END
                        else
                                echo "no end chromosome specified"
                                exit 1
                        fi
                        shift
                        ;;
		-t)
			shift
                        if test $# -gt 0; then
                                export TARGET=$1
                                #echo $TARGET
                        else
                                echo "no target genome specified"
                                exit 1
                        fi
                        shift
                        ;;
		--target*)
                        export TARGET=`echo $1 | sed -e 's/^[^=]*=//g'`
                        echo $TARGET
                        shift
                        ;;
		 -p)
                        shift
                        if test $# -gt 0; then
                                export CPU=$1
                                #echo $CPU
			fi
                        shift
                        ;;
		--split_step*)
                        export STEP=`echo $1 | sed -e 's/^[^=]*=//g'`
                        #echo $PROCESS
                        shift
                        ;;
		--split_thresshold*)
                        export THRESS=`echo $1 | sed -e 's/^[^=]*=//g'`
                        #echo $PROCESS
                        shift
                        ;;
		 --fastMap*)
			FM=1
			shift
                        ;;
		--ooc*)
			OOC=1
                        shift
                        ;;
		--minIdentity*)
			export MI=`echo $1 | sed -e 's/^[^=]*=//g'`
                        #echo $MI
			shift
			;;
		--minAli*)
			export MA=`echo $1 | sed -e 's/^[^=]*=//g'`
                        #echo $MA
			shift
			;;
		-r)
			if [ "$1" == "-r" ]; then
  				interactive;
			fi
                        shift
                        ;;
		 -v)
                        if [ "$1" == "-v" ]; then
                                conf;
                        fi
                        shift
                        ;;
		-*)	
                        if test $# -gt 0; then
                	echo "Unrecognized argument"
			exit 1
			fi
			shift
			;;
                *)
                        break
                        ;;
        esac
done


if [ -z "$START" ]; then
 	echo "no start chromosome specified"
  	exit 1
else
	CHR1=$START 
fi
if [ -z "$END" ]; then
        echo "no end chromosome specified"
        exit 1
else
	CHR2=$END
fi
if [ -z "$TARGET" ]; then
        echo "no target genome specified"
        exit 1
else 
	GENOME=$TARGET
fi

if [ -n "$STEP" ] && [ -z "$THRESS" ]; then
	echo "If you want to split your HCEs you need to give a thresshold value"
	exit 1
fi

if [ -z "$STEP" ] && [ -n "$THRESS" ]; then
       echo "If you want to split your HCEs you need to give a splitting step value"
       exit 1
fi

if [ -z "$CPU" ]; then
        CORES=1
	PARAL=0
else
	PARAL=1
	CORES=$CPU
fi
if [ -z "$FM" ]; then
	FASTMAP=0
else 
	FASTMAP=1
fi
if [ -z "$OOC" ]; then
        OOC1=0
else
	OOC1=1
fi

if [ -z "$STEP" ] || [ -z "$THRESS" ]; then
        SPLIT=0
	STEP1=0
	THRESS1=0
else
	SPLIT=1
        STEP1=$STEP
        THRESS1=$THRESS
fi

if [ $FASTMAP != 1 ]; then
	SPLIT=0
        STEP1=0
        THRESS1=0
else
	SPLIT=1
        STEP1=1000
        THRESS1=5000
fi

if [ $FASTMAP=1 ] &&  [ -n "$STEP" ] && [ -n "$THRESS" ]; then
	SPLIT=1
        STEP1=$STEP
        THRESS1=$THRESS
fi

if [ -z "$MI" ]; then
        BLAT_MI=90
else
        BLAT_MI=$MI
fi
if [ -z "$MA" ]; then
        PSLRES_MA=0.93
else
        PSLRES_MA=$MA
fi

#echo $CPU $START $END $FM $OOC $STEP $BLAT_MI $PSLRES_MA
######

#############
for i in $(seq $CHR1 $CHR2)
                do
		echo "Mapping the ga-reference chromosome $i:"
                ./G-Anchor.sh chr$i $IN/HCE_DB/most_conserved_chr$i.fa $IN/GENOMES_DB/REFERENCE/chr$i.2bit $IN/GENOMES_DB/TARGET/$GENOME.2bit $PARAL $CORES $OOC1 $FASTMAP $SPLIT $STEP1 $THRESS1 $BLAT_MI $PSLRES_MA >>logFile_$GENOME 2>&1
 echo "chromosome $i is finished!"
                sleep 10
                done
echo \#chr$'\t'Mapped_HCEs$'\t'Max_gap$'\t'Mean_gap$'\t'Gaps_less_than: 100bp$'\t'1000bp$'\t'10000bp$'\t'100000bp$'\t'more than 100000bp >> OUTPUT_$GENOME/gap_distribution.txt
echo ----------------------------------------------------------------------------------------------------------------------------------- >> OUTPUT_$GENOME/gap_distribution.txt
        for i in $(seq $CHR1 $CHR2)
        do
                cat OUTPUT_$GENOME/unique_hces_count_$GENOME/chr$i.txt >> OUTPUT_$GENOME/unique_hces_count_$GENOME/all.txt
		./bin/gapDist.pl $i OUTPUT_$GENOME/psl_final_$GENOME/chr$i.psl >> OUTPUT_$GENOME/gap_distribution.txt
        done
        ./bin/putTheScaffoldsInRightChromosome.pl $GENOME  > OUTPUT_$GENOME/chromosomes_blueprint.txt
        sleep 5
        rm -r OUTPUT_$GENOME/BL* OUTPUT_$GENOME/unique_* OUTPUT_$GENOME/tmp_* OUTPUT_$GENOME/double_* OUTPUT_$GENOME/ps_* OUTPUT_$GENOME/psl_s* OUTPUT_$GENOME/psl_r* OUTPUT_$GENOME/psl_b*
 echo "G-Anchor's mapping is finished. You can find the results at the OUTPUT/ folder and check the logfile if everything went well."

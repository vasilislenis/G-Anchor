#!/usr/bin/perl
use strict;
#use warnings;
use POSIX;

#It calculates the length of the desert areas from the final psl files with the unique elements

my $chrom = $ARGV[0];
my $psl_file = $ARGV[1];

my @chrgaps;
my @gaparray;
my $count = 2;
my $chrom_size = 0;

open my $psl, '<', $psl_file or die "Could not open $psl_file: $!";

@chrgaps = <$psl>;
my $numHCEs = scalar(@chrgaps);
#foreach my $h (@chrgaps){
#	print "$h";
#}
#print "$numHCEs\n";
#Calculates the coordinates of the desert regions between the elements
#my $arrSize = @array;
my $firstElement = $chrgaps[0];
my @data = split('\t', $firstElement);
my $start = $data[15];
my $chrom_start = 0;
my $gap = 0;
if ($start == 0) {
	$gap = 0;
}
else {
	$gap = $start - $chrom_start;
}
push (@gaparray, $gap);

	my $i = 0;
	my $j = 1;
        for ($i; $i < @chrgaps -1; $i++) {
                my @lines1 = split('\t', $chrgaps[$i]);
		#print "$array[$i]\n";
		#last;
		my $start1 = $lines1[15];
		my $end1 = $lines1[16];
                #my @lines2 = split('\t', $array[$i+1]);
                for ( my $j = $i+1 ; $j < $i+2; $j++) {
                        my @lines2 = split('\t', $chrgaps[$j]);
			#print "$array[$j]\n";
			#last;
                        my $start2 = $lines2[15];
                	my $end2 = $lines2[16];
        		my $gap2 = $start2 - $end1;
			#print "$chrom\_Gap_$count \t $gap2\n"; 
			push (@gaparray, $gap2);	            	
			$count = $count + 1; 
		}
	#last;
	}	
my @lastLine = split('\t', $chrgaps[-1]);
my $lastGap = $lastLine[14] - $lastLine[16];
#print "$chrom\_Gap_$count \t $lastGap\n";
push (@gaparray, $lastGap);
my @gaparray_sorted = sort { $a <=> $b } @gaparray;
my $min = $gaparray_sorted[0];
my $max = $gaparray_sorted[-1];
my $total = 0;
my $count1 = 0;
my $c100 = 0;
my $c1000 = 0;
my $c10000 = 0;
my $c100000 = 0;
my $c100000more = 0;
foreach my $k (@gaparray_sorted) {
	$total +=$k;
        $count1++;	
	#print "$k\n";
	if ($k <= 100) {
		$c100++;
	}
	if (($k > 100) && ($k <= 1000)){
                $c1000++;
        }
	if (($k > 1000) && ($k <= 10000)){
                $c10000++;
        }
	if (($k > 10000) && ($k <= 100000)){
                $c100000++;
        }
	if ($k > 100000) {
                $c100000more++;
        }
}
my $ave = $total / $count1;
$ave = sprintf "%.3f", $ave;
#print $chrom.":"."\t"."No of mapped HCEs: "."\t".$numHCEs."\t"."Min: "."\t".$min."\t"."Max: "."\t".$max."\t"."Ave: "."\t".$ave."\n";
print $chrom.": "."\t".$numHCEs."\t".$max."\t".$ave."\t".$c100."\t".$c1000."\t".$c10000."\t".$c100000."\t".$c100000more."\n";


#!/usr/bin/perl

use strict;
use warnings;

my $chrom = $ARGV[0];
my $pslSwap_file = $ARGV[1];
my $padding_thress = $ARGV[2];
my $padding = $ARGV[3];
# This script calculates the right coordinates of the target. Projects the coordinates of the hces up to the genome

open my $pslSwap_info, $pslSwap_file or die "Could not open $pslSwap_file: $!";


while( my $line = <$pslSwap_info>)  {
        chomp $line;
################################################# PSL data
	my @psltoken = split('\t', $line);
	my $matches = $psltoken[0];
	my $misMatches = $psltoken[1];
	my $repMatches = $psltoken[2];
	my $nCount = $psltoken[3];
	my $qNumInsert = $psltoken[4];
	my $qBaseInsert = $psltoken[5];
	my $tNumInsert = $psltoken[6];
	my $tBaseInsert = $psltoken[7];
	my $strand = $psltoken[8];
	my $qName = $psltoken[9];
	my $qSize = $psltoken[10];
	my $qStart = $psltoken[11];
	my $qEnd = $psltoken[12];
	my $tName =  $psltoken[13];
	my $tSize = $psltoken[14];
	my $tStart = $psltoken[15];
	my $tEnd = $psltoken[16];
	my $blockCount = $psltoken[17];
	my $blockSizes = $psltoken[18];
	my $qStarts = $psltoken[19];
	my $tStarts = $psltoken[20];
	my $qStart_new = 0;
	my $qEnd_new = 0;
	my $tStart_new = 0;
	my $tEnd_new = 0;
####################################################### Calculations of the new coords in the target fields
######################New coordinates calculation
	my $length_block = $matches + $misMatches;
	if ($length_block < $padding_thress) {
		#$matches = $matches + 
		$qNumInsert = 0;
		$qBaseInsert = 0;
		$tNumInsert = 0;
		$tBaseInsert = 0;
		$blockCount = 1;
		$blockSizes = $length_block;
		my $matches_new = $matches + (2 * $padding);
                my $blockSizes_new = $matches_new + $misMatches;
		my $qlimit = $qSize - $blockSizes_new;
		my $tlimit = $tSize - $padding;
		if ((($qStart - $padding) < 0) || ($qEnd > $qlimit) || (($tStart - $padding) < 0) || ($tEnd > $tlimit)) {
			print "$line\n";
			}
		else {
			$qStart_new = $qStart - $padding;
			$qEnd_new = $qStart_new + $blockSizes_new;
                        $tStart_new = $tStart - $padding;
			$tEnd_new = $tStart_new + $blockSizes_new;
##################################Blocks column construction
			if ($strand eq "+") {
				$qStarts = $qStart_new . ",";
				$tStarts = $tStart_new . ",";
  			}
			else {
				my $qIntermediate = $qSize - $qEnd_new;
				$qStarts = $qIntermediate . ",";
				$tStarts = $tStart_new . ",";
		}
		print $matches_new ."\t". $misMatches ."\t". $repMatches ."\t". $nCount ."\t". $qNumInsert ."\t". $qBaseInsert ."\t". $tNumInsert ."\t". $tBaseInsert ."\t". $strand ."\t". $qName ."\t".$qSize ."\t". $qStart_new ."\t". $qEnd_new ."\t". $tName ."\t". $tSize ."\t". $tStart_new ."\t". $tEnd_new ."\t". $blockCount ."\t". $blockSizes_new ."\t". $qStarts ."\t". $tStarts ."\n";
		}
	}
	else {
		print " $line\n";
		}
}	

#!/usr/bin/perl

use strict;
use warnings;

my $chrom = $ARGV[0];
my $pslSwap_file = $ARGV[1];
my $target_sizes = $ARGV[2];
# This script calculates the right coordinates of the target. Projects the coordinates of the hces up to the genome

open my $target_info, $target_sizes or die "Could not open $target_sizes: $!";

my $target = "";
while( my $sline = <$target_info>)  {
        chomp $sline;
        my @data = split('\t', $sline);
        my $chr = $data[0];
        my $chr_length = $data[1];
        if ($chrom eq $chr) {
                $target = $chr_length;  #length of the ref. chromosome.
        }
}

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
####################################################### Calculations of the new coords in the target fields
        my @chrdata = split('\.', $tName);
	my $tName_new = $chrdata[0];
	my $tStart_new = $tStart + $chrdata[3];
	my $tSize_new = $target;
	my $tOffset = $tEnd - $tStart;
	my $tEnd_new = $tStart_new + $tOffset;
	#$blockSizes =~ s/\D//g;
	
	#print "$blockSizes\n";
	#print "$blockCount\n";
	if ($blockCount == 1) {  #If we have one block, the tstarts is the same withe the tstart_new
		$tStarts = $tStart_new . ",";
		#print "$tStarts\n";
		}
	else {   #If we have more than one blocks, we have to recalculate the tstarts for each block
		my @tStartsToken = split(',', $tStarts);
		my $tStartsSize = scalar(@tStartsToken);
		my @superstring = ();
		my @tStartsToken_new = ();
		for (my $i = 0; $i < $tStartsSize; $i++) {
			$tStartsToken_new[$i] = $tStart_new + $tStartsToken[$i];
			push (@superstring, $tStartsToken_new[$i]);	
		}
		my $tStartsSize_new = scalar(@tStartsToken_new);
		$tStarts =  join( ',', @superstring) . "," ;
	} #Just print the fu*** psls!!!!!
print $matches ."\t". $misMatches ."\t". $repMatches ."\t". $nCount ."\t". $qNumInsert ."\t". $qBaseInsert ."\t". $tNumInsert ."\t". $tBaseInsert ."\t". $strand ."\t". $qName ."\t".$qSize ."\t". $qStart ."\t". $qEnd ."\t". $tName_new ."\t". $tSize_new ."\t". $tStart_new ."\t". $tEnd_new ."\t". $blockCount ."\t". $blockSizes ."\t". $qStarts ."\t". $tStarts ."\n";

}

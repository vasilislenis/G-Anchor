#!/usr/bin/perl

use strict;
use warnings;

my $pslBest_file = $ARGV[0];

#It cuts the coordinates of the best alignents in table format

open my $best_info, $pslBest_file or die "Could not open $pslBest_file: $!";


while( my $sline = <$best_info>)  {
        chomp $sline;
	my @sdata = split('\t', $sline);
        my @chrdata = split('\:', $sdata[3]);
	my $hce = $chrdata[0];
	#my $newName = join (' ', @data);
	print $sdata[0] ."\t" .  $sdata[1] . "\t" . $sdata[2] . "\t" .$hce. "\t" . $sdata[4] . "\t" . $sdata[5] ."\n";
	#print "$newName\n";
}

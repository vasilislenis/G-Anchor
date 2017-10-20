#!/usr/bin/perl

use strict;
use warnings;

my $pslBest_file = $ARGV[0];

#It cuts the coordinates of the best alignents in table format

open my $best_info, $pslBest_file or die "Could not open $pslBest_file: $!";

my @total_array = ();
my @alignment_array = ();
my $count = 0;
my $sum1 = 0;
my $sum2 = 0;

while( my $sline = <$best_info>)  {
	 my @total_array = ();
	my @sdata = split('\t', $sline);
	my $start = $sdata[1];
	my $end = $sdata[2];
	my $ali_length = $sdata[4];
	my $length = $end - $start;
	$sum1 = $sum1 + $length;
	$sum2 = $sum2 + $ali_length;
	$count = $count + 1;
}
	print $count ."\t" .  $sum1 . "\t" . $sum2 ."\n";

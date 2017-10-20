#!/usr/bin/perl

use strict;
use warnings;

my $unique_file = $ARGV[0];

#First step for the numerical sorting
#The second step are unix commands in the wrapper script

open my $unique_info, $unique_file or die "Could not open $unique_file: $!";


while( my $sline = <$unique_info>)  {
        chomp $sline;
	my @sdata = split('\t', $sline);
        my @data = split('\.', $sdata[3]);
	my $newName = join (' ', @data);
	print $sdata[0] ."\t" .  $sdata[1] . "\t" . $sdata[2] . "\t" . $newName . "\t" . $sdata[4] . "\t" . $sdata[5] . "\n";	
}

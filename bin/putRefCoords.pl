#!/usr/bin/perl

use strict;
use warnings;

my $hces_file = $ARGV[0];


open my $hces_info, $hces_file or die "Could not open $hces_file: $!";


while( my $sline = <$hces_info>)  {
        chomp $sline;
        my @data = split('\t', $sline);
	my $start = $data[1];
	my $end = $data[2];
	my $hce = $data[3];
	my $coord_name = $hce.".".$start.".".$end;
	print $data[0] . "\t" . $start . "\t" . $end . "\t" . $coord_name. "\t" . $data[4] . "\t" . $data[5] ."\n";
}

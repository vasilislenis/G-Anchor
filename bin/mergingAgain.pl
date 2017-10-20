#!/usr/bin/perl

use strict;
use warnings;

my $unique_file = $ARGV[0];

#Third step of the sorting. Merging again the hce name

open my $unique_info, $unique_file or die "Could not open $unique_file: $!";


while( my $sline = <$unique_info>)  {
        chomp $sline;
        my @data = split('\t', $sline);
	my @names = split(' ', $data[3]);
	my $newName = join ('.', @names);
	print $data[0] . "\t" . $data[1] . "\t" . $data[2] . "\t" . $newName. "\t" . $data[4] . "\t" . $data[5] ."\n";
}

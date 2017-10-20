#!/usr/bin/perl
use strict;
use warnings;
use POSIX;

my $bed = $ARGV[0];
open my $bed_file, '<', $bed or die "Could not open $bed: $!";

while( my $line = <$bed_file>)  {
	chomp $line;
	my @tok_line = split ('\t',$line);
	#my @tok_line = split (' ',$line);
	my $chrom =  $tok_line[0];
	my $start = $tok_line[1];
        my $end = $tok_line[2];
	my $name = $tok_line[3];
	my $zero = $tok_line[4];
	my $orientation = $tok_line[5];
	my $length = $end - $start;
	#print $chrom."\t".$length."\n";
	print $name."\t".$length."\n";
}

#!/usr/bin/perl
use strict;
#use warnings;
use POSIX;

my $bed_file = $ARGV[0];

#Changes the names of the HCEs after the splitting

open my $bed_info, $bed_file or die "Could not open $bed_file: $!";

my $count = 1;
my $count2 = 1;
while( my $sline = <$bed_info>)  {
	chomp $sline;
          my @data = split("\t", $sline);
	  
	  my $new_name = $data[0]. "." .$count2.".".$count;
	print $data[0]."\t".$data[1]."\t".$data[2]."\t".$new_name."\t".$data[4]."\t".$data[5]."\n";
	$count++;
	}

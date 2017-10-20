#!/usr/bin/perl
use strict;
use warnings;
use POSIX;

my $bed = $ARGV[0];
my $step = $ARGV[1];
my $thress = $ARGV[2];

open my $bed_file, '<', $bed or die "Could not open $bed: $!";

my @full_arr = "";
while( my $line = <$bed_file>)  {
	chomp $line;
	my @tok_line = split ('\t',$line);
	my $chrom =  $tok_line[0];
	my $start = $tok_line[1];
        my $end = $tok_line[2];
	my $name = $tok_line[3];
	my $zero = $tok_line[4];
	my $orientation = $tok_line[5];
	#print "$start\n";
	my $length = ($end - $start) +1;
	my $abs_length = $end - $start;
	if ($abs_length <= $thress) {
		push(@full_arr, $line);
####
	}
	else {
		my $parts = int($length/$step);
		if (($parts == 0) || ($parts == 1)){
			push (@full_arr, $line);
			}
		else {
			my $i;
			my @start_arr = "";
			my @end_arr = "";
			$start_arr[0] = $start;
			for ($i =0; $i < $parts; $i ++) {
				$end_arr[$i] = $start_arr[$i] + $step;
				$start_arr[$i+1] = $end_arr[$i] + 1;
			}
		#print "$i\n";
		#print "$end_arr[$i]\n";
			$end_arr[$i-1] = $end;
			for (my $j = 0; $j < $parts; $j++) {
				my $new_name = $name."_".$j;
				my $new_line = $chrom."\t".$start_arr[$j]."\t".$end_arr[$j]."\t".$new_name."\t".$zero."\t".$orientation;
				push (@full_arr, $new_line);
			}
		}
	}
}
		my $full_arr_size = scalar(@full_arr);
		for (my $k = 0; $k < $full_arr_size; $k++) {
			print "$full_arr[$k]\n";
		}


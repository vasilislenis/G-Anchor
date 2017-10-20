#!/usr/bin/perl
use strict;
use warnings;
use 5.010;
use autodie;

#Filters the psl best files by using the hces that are up to each chromosome



my ($chromosome, $target) = @ARGV;
if (not defined $chromosome) {
	die "Need chromosome\n";
}
if (not defined $target) {
	die "Need target name\n";
} 
#my ($target) = @ARGV or die "Usage: $1 <chromosome>\n";
my $scaff_file = "OUTPUT_$target/unique_hces_final_$target/$chromosome.txt";
my $best_file  = "OUTPUT_$target/psl_best_$target/$chromosome.psl";
my $raw_file   = "OUTPUT_$target/psl_raw_$target/$chromosome.psl";

open my $scaff_fh, '<', $scaff_file;
my %hces_hash;
while ( <$scaff_fh> ) {
  chomp;
  my @fields = split /\t/;
  my $key = join "\t", @fields[0,3];
  ++$hces_hash{$key};
}
close $scaff_fh;

open my $best_fh, '<', $best_file;
open my $raw_fh,  '>', $raw_file;
while ( <$best_fh> ) {
  chomp;
  my @fields = split /\t/;
  #say scalar @fields;
  my $key = join "\t", @fields[13,9];
  print $raw_fh "$_\n" if $hces_hash{$key};
}
close $raw_fh;
close $best_fh;

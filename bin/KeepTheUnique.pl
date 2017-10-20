#!/usr/bin/perl
use strict;
use warnings;

#This script takes the best hits output and finds the unique elements that up to only one scaffold.

my $chromosome = $ARGV[0];
my $target = $ARGV[1];

my $file = "OUTPUT_$target/psl_score_byname_$target/$chromosome.table";
open my $fh, '<', $file or die "Can't open $file: $!";

my (%seen, %dupe);
while (<$fh>) 
{
    my $patt = (split)[3]; 

    if (exists $seen{$patt}) {
        $dupe{ $seen{$patt} } = 1;  # the first one that was seen
        $dupe{$.} = 1;              # this line as well
    } 
    else { $seen{$patt} = $. }      # add it the first time it's seen
}

# Now we know all lines which carry duplicate fourth field
# Return to the beginning and print others
my $outfile = "OUTPUT_$target/unique_hces_$target/$chromosome.txt";
open my $fh_out, '>', $outfile  or die "Can't open $outfile: $!";

seek $fh, 0, 0;
$. = 0;           # seek doesn't reset $.
while (<$fh>) {
    print $fh_out $_  if not exists $dupe{$.}
}
close $fh_out;



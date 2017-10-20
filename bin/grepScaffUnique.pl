#!/usr/bin/perl
use strict;
use warnings;

#With this script you can print the ammount of the elements that are up to each scaffold for every chromosome or to print the elements (if you change the comments)

 
my $chromosome = $ARGV[0];
my $target = $ARGV[1];
my @mykeys = `cat OUTPUT_$target/unique_hces_final_$target/$chromosome.txt| awk '{print \$1}'| sort -u`;

foreach (@mykeys)
{
        my $key = $_;
        chomp($key);
        my $command = "cat OUTPUT_$target/unique_hces_final_$target/$chromosome.txt|grep -w $key";
        my @belongs= `$command`;
        chomp(@belongs);
        my $count = scalar(@belongs);
        my $final_line = $belongs[0];
     #   if ($count == 1)
       	print "$key\t$chromosome\t$count\n"; 
 	#print "$key\n";                   #if you want to print the scaffold with the elements
	#print join("\n", @belongs), "\n";
}

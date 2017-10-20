#!/usr/bin/perl
use strict;
use warnings;
use POSIX;

#Filter out the really small elements by using the size files. (FUCK, some of the elements are 1bp....)

my $size = $ARGV[0];
open my $size_file, '<', $size or die "Could not open $size: $!";
while( my $line = <$size_file>)  {
        chomp $line;
        my @tok_line = split ('\t',$line);
        my $start = $tok_line[1];
        my $end = $tok_line[2];
        #my $size = $tok_line[1];
        my $size = abs ($end - $start);
        if($size >= 40) {
        print "$line\n";
        }
}

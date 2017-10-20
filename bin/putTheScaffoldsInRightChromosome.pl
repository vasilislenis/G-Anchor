#!/usr/bin/perl
use strict;
use warnings;

#This script show us the number of the elements that are in each scaffold on each ref. chromosome
#IT DOES THE MAGIC!!!!!!!!!!!!
#It gives you the scaffolds in each chromosomes.
#It finds the chromosome that its scaffold has the maximum number of elements.
#If a scaffold has elements in different chromosomes it checks them:
#If it has one element in a different chromosome and more than a threshold, we keep it as a partial (p) alignment
#If it has more than one elements, it checks if that elements are consensus. If they are, we keep them again as partia alignment (v).

#Enjoy :)


############UPDATED VERSION! Includes a threshold for the length of the "p" cases!######################
my $target = $ARGV[0];
my @mykeys = `cat OUTPUT_$target/unique_hces_count_$target/all.txt| awk '{print \$1}'| sort -u`;  #open the file with the number of the hces in all chromoso and keep the scaffolds

#my $count;
my $count2 = 0;
#my $max = 0;
#my $min = 0;
my @array = ();
my $total = scalar(@mykeys);
foreach (@mykeys)
{
        my $key = $_;
        chomp($key);

        my $command = "cat OUTPUT_$target/unique_hces_count_$target/all.txt|grep -w $key"; 
        my @belongs= `$command`;   #put all the elements that belongs to each scaffold in an array
        #print "@belongs\n";
        chomp(@belongs);
        my $count = scalar(@belongs);
        if ($count == 1) {      #If a scaffold has elements only in one chromosome, keep it.
                my $clean_line = $belongs[0];
                push(@array, $clean_line);
                #print "@belongs\n";
                #$count1++;
        }
#}
#foreach my$a (@array) {
#	print "$a\n";
#}
elsif ($count > 1)  #If it has more than one we have to examine it.
        {
                #my @array = ();
                my $max = 0;
                my $min = 0;
                my $max_index = 0;
                my $min_index = 0;
                my $line_one;
                my $line_max;
                my $chromosome_name;
                my $comple_line;
                my @rest;
		my @ar;
		my $line_r;
                for ( my $line = 0; $line < $count; $line++) {
                        chomp($line);
                        my @tokens = split ('\t', $belongs[$line]);
                        if ($tokens[2] >= $max) {
                                $max = $tokens[2];
                                $max_index = $line;
                                $line_max = $belongs[$max_index]
                        }
                }
                for ( my $i = 0; $i < $count; $i++) {     #keep the chromosome that has the maximum number of hces for each scaffold.
                        if ($belongs[$i] eq $line_max) {
                                push (@array, $belongs[$i]);
                        }
                        else {
                                push (@rest, $belongs[$i]);
                        }
                }
                foreach my $a (@rest) {   #Check the rest hits.
                        chomp($a);
                        my @rest_tokens = split ('\t', $a);
                        if ($rest_tokens[2] == 1) {  #If there is only one element in another chromosome, check if the maximum is above of a threshold (20 for now).
                                my $diff = $max - 1;
				my $total_one = 0;
				$chromosome_name = $rest_tokens[1];
				my $run = "cat OUTPUT_$target/unique_hces_final_$target/$chromosome_name.txt|grep -w $key";
				my $oneElement = `$run`;
				my @oneElementPart = split('\.',$oneElement);
				my $oneStart = $oneElementPart[3];
				chomp ($oneStart);
				my @oneElementPart_2 = split('\t', $oneElementPart[4]);
				my $oneEnd = $oneElementPart_2[0];
				chomp ($oneEnd);
				my $one_length = $oneEnd - $oneStart;
				$total_one = $total_one + $one_length;
				
                                if (($diff <= 20) && ($total_one > 100)) { #Threshold for the length of the one hce in a different chromosome.
                                       $line_one = $a . "\t". "p";
                                        push (@array, $line_one);
                                }
			 }
			if ($rest_tokens[2] >=2) {     #If there are more than 2 hces, we have to check if they are consensus.
				my @consensus;
				my $line_two;
				#$line_r = $a . "\t". "p";
				$chromosome_name = $rest_tokens[1];
				chomp($chromosome_name);
				#push (@ar, $chromosome_name);
				my $second_command = "cat OUTPUT_$target/unique_hces_final_$target/$chromosome_name.txt|grep -w $key"; #Open the file of the elements in the specific chromosome.
				my @hces = `$second_command`;
				my $hces_count = scalar(@hces);
				for (my $i = 1; $i < $hces_count; $i++) {
				 	my @toks1 = split('\t',$hces[$i-1]);
					my @toks2 = split('\t',$hces[$i]);
				        chomp($toks1[3]);
					chomp($toks2[3]);	
					#print "$toks1[0]\n";
					#print "$toks2[0]\n";
					
					my @hname1 = split('\.',$toks1[3]);
					my @hname2 = split('\.',$toks2[3]);
					if ($toks1[3] ne $toks2[3]) {
					#print "$toks1[0]\n";
					#print "$toks2[0]\n";
						if ($hname1[1] == $hname2[1]) {
							if ((abs($hname1[2] - $hname2[2])) <= 10) {  #A threshold (10) for the next element
								push (@consensus, $hces[$i]);
							}  
						}
						if ((abs($hname1[1] - $hname2[1])) == 1) { # The elements have two id numbers (we had split the mafs into chunks for the prediction.
							if ((abs($hname1[2] - $hname2[2])) <= 10) {
							push (@consensus, $hces[$i]);
							}
						}
					}
					#else {
					#print "check\n";
					}	
					my $ln = scalar(@consensus);
					my $total_length = 0;
					for (my $k = 0; $k < $hces_count; $k++) {
						my @elements = split('\.',$hces[$k]);
						my $start = $elements[3];
						chomp ($start);
						my @second_part = split('\t',$elements[4]);
               					 my $end = $second_part[0];
               					 chomp ($end);
               					 #print "$end\n";
               					 my $el_length = $end - $start;
               					 $total_length = $total_length + $el_length;
					
					}
					if (($ln != 0) && ($total_length > 600)) { #The total length threshold. Is a down threshold for the coverage of the consensus hces on the
											#scaffold
						$line_two = $a . "\t" . "v";	
						push (@array, $line_two);
					}			
				}		
			}

		}

}
foreach my $b (@array) {
       print "$b\n";
}

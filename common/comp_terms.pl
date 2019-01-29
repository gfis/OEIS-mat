#!perl

# Compare pairs of lines with terms and check whether the shorter is contained in the longer
# @(#) $Id$
# 2019-01-28, Georg Fischer
#
# usage:
#	perl comp_terms.pl < input > output
#---------------------------------
use strict;
my $line0 = "";
while (<>) {
	s/\s+\Z//; # chompr
	my $line1 = $_;
	if (substr($line0, 0, 7) eq substr($line1, 0, 7)) { # pair found
		my $len0 = length($line0);	
		my $len1 = length($line1);	
		if ($len0 < $len1) {
			if ($line0 ne substr($line1, 0, $len0)) {
				print "$line0\n$line1\n";
			}
		} else {
			if ($line1 ne substr($line0, 0, $len1)) {
				print "$line0\n$line1\n";
			}
		}
	} # pair
	$line0 = $line1;
} # while <>

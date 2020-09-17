#!perl

# A038219_diff.pl - difference: count(ones) - count(zeroes)
# 2019-05-23, Georg Fischer
use strict;
use integer;


# read from a file which just contains the zeroes and ones, or a b-file
my $from_b = 0;
my $index  = 1;
my @counts = (0, 0);
my $digit  = 0;
while (<>) {
	next if m{\A\s*\#}; # skip comments
	next if m{\A\s*\Z}; # skip empty lines
	if ($from_b) {
		m{\A\s*(\d+)\s*(\d+)};
		$digit = $2;
	} else {
		m{\A\s*(\d+)};
		$digit = $1;
	}
	$counts[$digit] ++;
	print "$index " . ($counts[1] - $counts[0]) . "\n";
	$index ++;
} # while

__DATA__
# A038219.pl from Remy Sigrist:
$| = 1;

# Ehrenfeucht-Mycielski sequence in reverse order
my $sequence = "";

foreach my $n (1..10000000) {
	my $ext;
	if ($n==1) {
		$ext = "0";
	} elsif ($n==2) {
		$ext = "1";
	} elsif ($n==3) {
		$ext = "0";
	} else {
		foreach my $w (1..length($sequence)) {
			if (index($sequence, substr($sequence, 0, $w+1), 1)<0) {
				my $suffix = substr($sequence, 0, $w);
				my $last = index($sequence, $suffix, 1);
				if (substr($sequence, $last-1, 1) eq "0") {
					$ext = "1";
				} else {
					$ext = "0";
				}
				last;
			}
		}
	}
	print "$ext\n";
	$sequence = $ext . $sequence;
}

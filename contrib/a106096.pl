#!perl

use strict;
use integer;

my $n = 0;
while (<>) {
	next if m{\A\s*\#};
	# m{(\d+)\s+(\d+)};
	m{(\d+)};
	my $prime = $1;
	if ($prime =~ m{\A[0-6]+\Z}) {
		if ($prime =~ m{6}) {
			$n ++;
			print "$n $prime\n";
		}
	}
} # _Georg Fischer_ Feb 18 2020

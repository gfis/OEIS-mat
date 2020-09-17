#!perl

use strict;
use integer;

for (my $m = 1; $m <= 30000; $m ++) {
	&output(3*$m -2, 3*$m*$m - 3*$m + 1);
	&output(3*$m -1, 3*$m*$m           );
	&output(3*$m -0, 3*$m*$m           );
} 
sub output {
	my ($n, $an) = @_;
	print "$n $an\n";
} # _Georg Fischer_ Feb 18 2020
__DATA__
my @a = (1); for (my $n = 1; $n <= 90000; $n ++) {
  $a[$n] = $a[$n - 1] + ($a[$n - 1] % $n != 0 ? $n : 0);
  print "$n $a[$n]\n";
} # _Georg Fischer_ Feb 18 2020

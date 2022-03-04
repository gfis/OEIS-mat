#!perl

# a024916, test hypothesis for A010766
# 2022-03-04, Georg Fischer
use strict;
use integer;
use warnings;

my @terms = (0, split(/\, ?/, shift(@ARGV)));
my $n = scalar(@terms);
my $sum = 0;
for (my $k = 1; $k <= $n; $k  ++) {
	$sum += $terms[$k]*$k;
}
print "Sum_{k=1..$n} [" . join(",", @terms) . "][k] * k = $sum\n";
__DATA__
12,  6, 4, 3, 2, 2, 1, 1, 1, 1, 1, 1
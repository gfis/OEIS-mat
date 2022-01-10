#!perl

# A053880 ff.: Squares with 3 digits
# 2022-01-09, Georg Fischer

use strict;
use integer;

my $sample = shift(@ARGV);
for (my $n = 0; $n < 10000000; $n ++) {
    my $n2 = $n * $n;
    if ($n2 =~ m{\A[$sample]+\Z}o) {
        print "$n $n2\n";
    }
}

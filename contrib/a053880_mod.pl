#!perl

# A053880 ff.: Square mod length contains with 3 digits only
# 2022-01-09, Georg Fischer

use strict;
use integer;

my $sample = shift(@ARGV);
for (my $n = 0; $n < 10000000; $n ++) {
    my $n2 = $n * $n;
    my $sub = substr($n2, -length($n));
    if ($sub =~ m{\A[$sample]+\Z}o) {
        print "$n\t$sub\t$n2\n";
    }
}

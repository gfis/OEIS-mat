#!perl

# Module for power series
# 2020-01-03, Georg Fischer

use strict;
use integer;
use warnings;
use PowerSeries;

my $ps = PowerSeries->new(0, [1,2,3]);

print "ps=" . $ps->toString() . "\n";
__DATA__


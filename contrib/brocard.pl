#!perl

# Search for minimal k such that n! + k^2 = m^2, or -1 if no such k exists.
# 2020-11-26, Georg Fischer
#
#:# Usage:
#:#   perl brocard.pl
#--------------------------------------------------------
use strict;
use integer;
use warnings;

my $line = "";
my $debug = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt


my $n = 1;
my $fact = 1;
while ($fact < 0x7fffffff) {
    $fact *= $n;
    my $m = 1;
    while ($m <= (1 + $fact) / 2) {
        my $k = 1;
        my $m2 = $m * $m;
        while ($k < $m) {
            if ($fact + $k*$k == $m2) {
                print "$n $k\n";
                $k = $m; # only first k
                $m = $fact; # break loop
            }
            ++$k;
        } # while k
        ++$m;
    } # while m
    ++$n;
} # while 

#================================
__DATA__


#!perl

# Squares summing up to a number -> binomial formula
# @(#) $Id$
# 2022-02-16, Georg Fischer
# A159355 2..100 Number of n X n arrays of squares of integers summing to 4.
# Partitions of a number into squares

use strict;
use warnings;
use integer;

my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
if (0 && scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
my $debug  = 0;
my $sumMax = 14;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{n}) {
        $sumMax    = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my $newList;
print "# OEIS-mat/contrib/rh/partition3.pl $timestamp "
#   . &isqrt(14)
    . "\n";
if ($debug >= 2) {
    for (my $num = 2; $num <= $sumMax; $num ++) {
        my $parts = &partition($num, &isqrt($num));
        print "# $num: $parts\n";
    } # for my $num
} else {
    while (<>) {
        s/\s+\Z//; # chompr
        my ($aseqno, $callcode, $offset, @parms) = split(/\t/);
        my $num = shift(@parms);
        my $parts = &partition($num, &isqrt($num));
        print "# $aseqno\t$num = $parts\n";
        print join("\t", $aseqno, $callcode, $offset, $num, $parts, @parms) . "\n";
    } # while <>
}
# end main
#----
sub partition () { # recursively generate the partitions for $num, with no sqrt(term) > $high
    my ($num, $high) = @_;
    my $term = $num;
    my $result = "";
    for (my $isq = $high; $isq >= 1; $isq --) {
        my $sq = $isq*$isq;
        my $factor = $term / $sq;
        my $busy = 1;
        while ($busy && $factor >= 1) {
            $result .= "$factor*$sq";
            my $rest = $term - $factor * $sq;
            if ($rest > 0) {
                $result .= " + (part($rest," . ($isq-1)**2 .")" . &partition($rest, $isq - 1);
            } else {
                $busy = 0;
            }
            $factor --;
            if ($isq > 1) {
               $result .= " = ";
            }
        } # while
        if ($isq > 1) {
            $result .= " = ";
        }
    } # for $isq
    return $result;
} # partition

sub isqrt() { # determine $result**2 <= $n
    my ($n) = @_;
    my $result = 0;
    while (($result + 1)**2 <= $n) {
        $result ++;
    }
    return $result;
} # isqrt
__DATA__
A159355 binom   0   4
A159359 binom   0   5
A159363 binom   0   6
A159367 binom   0   7


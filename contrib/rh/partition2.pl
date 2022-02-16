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
    } elsif ($opt  =~ m{m}) {
        $sumMax    = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

print "# OEIS-mat/contrib/rh/partition2.pl $timestamp\n";
my @partList; # of $n
my $times = "x";
my $eq    = " = ";
my $plus  = ", ";

if ($debug >= 2) {
    for (my $sum = 2; $sum <= $sumMax; $sum ++) {
        my $parts = &partition($sum);
        print "# $sum$eq$parts\n";
    } # for my $sum
} else {
    while (<>) {
        s/\s+\Z//; # chompr
        my ($aseqno, $callcode, $offset, @parms) = split(/\t/);
        my $num = shift(@parms);
        my $parts = &partition($num);
        print "# $aseqno\t$num = $parts\n";
        print join("\t", $aseqno, $callcode, $offset, $num, $parts, @parms) . "\n";
    } # while <>
}
# end main
#----
sub partition () { # recursively generate the partitions for $summax
    my ($sumMax) = @_;
    $partList[0] = "";
    $partList[1] = "1$times" . "1";
    my $parts;
    for (my $sum = 2; $sum <= $sumMax; $sum ++) {
        $parts = &partition1($sum);
        $partList[$sum] = $parts;
    } # for $sum
    $parts = $partList[$sumMax];
    $parts =~ s{$times}{\*}g;
    $parts =~ s{$plus} { \+ }g;
    $parts =~ s{ \+ 0\*\d+}{}g;
    return $parts;
} # for $sum

sub partition1 {
    my ($sum) = @_;
    my $oldList = $partList[$sum - 1];
    my $newList = "";
    my $sepEq = "";
    foreach my $parts (split(/$eq/, $oldList)) { # a partition of $sum
        my $sepPlus = "";
        my $newParts = "";
        foreach my $part (split(/$plus/, $parts)) { # occurrences of summand
            my ($occ, $summand) = split(/$times/, $part);
            if ($summand == 1) {
                $occ ++;
                $part = "$occ$times$summand";
            }
            $newParts .= "$sepPlus$part";
            $sepPlus = $plus;
        } # foreach $part
        $newList .= "$sepEq$newParts";
        $sepEq = $eq;
    } # foreach $parts
    my $busy = 1;
    my $isq = 2;
    my $sq = $isq**2;
    while ($busy && $sq <= $sum) {
        my $factor = $sum / $sq;
        my $rest   = $sum % $sq;
        if ($rest == 0) {
            $newList .= "$sepEq$factor$times$sq$plus" . "0$times" . "1";
            $sepEq = $eq;
        }
        $isq ++;
        $sq = $isq**2;
    } # while
    return $newList;
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
A159355	binom	0	4
A159359	binom	0	5
A159363	binom	0	6
A159367	binom	0	7


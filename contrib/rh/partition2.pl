#!perl

# Squares summing up to a number -> binomial formula
# @(#) $Id$
# 2022-02-16, Georg Fischer
# A159355 2..100 Number of n X n arrays of squares of integers summing to 4.
# Partitions of a number into squares

use strict;
use warnings;
use integer;

my $debug = 1;
my $summax = scalar(@ARGV) == 0 ? 40 : shift(@ARGV);
my @partList; # of $n
my $times = "x";
my $eq = " = ";
my $plus = ", ";
$partList[0] = "";
$partList[1] = "1$times" . "1";
print "# 1 = $partList[1]\n";

for (my $sum = 2; $sum <= $summax; $sum ++) {
    my $parts = &partition($sum);
    $partList[$sum] = $parts;
    if (1) {
        $parts =~ s{$times}{\*}g;
        $parts =~ s{$plus} { \+ }g;
        $parts =~ s{ \+ 0\*1}{}g;
    }
    print "# $sum$eq$parts\n";
} # for $sum

sub partition {
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

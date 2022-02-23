#!perl

# Squares summing up to a number -> partition equations
# @(#) $Id$
# 2022-02-17, Georg Fischer: copied from partition2.pl
# A159355 Number of n X n arrays of squares of integers summing to 4.
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

# separators
my $comma = "c";
my $eq    = "H";
my $tim   = "x";
my $plus  = "t";
my $most  = "m";
my $one   = "1";

print "# OEIS-mat/contrib/rh/partition4.pl $timestamp\n";
my @queue = ();
my %hash = (); # maps n -> partitions(n) = string of numbers with = * + operators

if ($debug > 0) {
    my $num = $sumMax;
    print "# $num: " . &partitions($num) . "\n";
} else {
    while (<>) {
        s/\s+\Z//; # chompr
        my ($aseqno, $callcode, $offset, @parms) = split(/\t/);
        my $num = shift(@parms);
        my $parts = &partitions($num);
        $parts =~ s{\d+\>}{}g;
        # print "# $aseqno\t$num$parts\n";
        print join("\t", $aseqno, $callcode, $offset, $num, $parts, @parms) . "\n";
    } # while <>
}
# end main
#----
sub partitions {
    my ($maxNum) = @_;
    %hash = ();
    $hash{1} = "$one$most$one$tim$one";
    my $level = 0;
    for (my $num = 2; $num <= $maxNum; $num ++) { 
        # expand $num
        # all partitions for numbers below $num are already expanded in %hash
        if ($debug >= 2) {
            print "start with $num\n";
        }
        @queue = (join($comma, $level, $num, &isqrt($num)));
        &exhaust_queue();
    } # for $num
    my $result = $hash{$maxNum};
    $result =~ s{$eq}{ = }g;
    $result =~ tr{cHxtm}{\,\=\*\+\>};
    return $result;
} # partitions

sub exhaust_queue {
    while (scalar(@queue) > 0) { # queue not empty
        my ($level, $oldRest, $hisq) = split(/$comma/, shift(@queue));
        if ($debug >= 2) {
            print "dequeue level=$level, rest=$oldRest, hisq=$hisq\n";
        }
        my $parts = "";
        my $sep = "";
        if ($hisq <= 1) {
            $parts .= "$sep$one$most$oldRest$tim$hisq";
            $sep = $eq;
        } else {
            for (my $isq = $hisq; $isq >= 1; $isq --) { # all squares down to 1
                my $sq = $isq**2;
                my $factor = $oldRest / $sq;
                while ($factor >= 1) {
                    my $newPart = "$factor$tim$sq";
                    my $newRest = $oldRest - $factor * $sq;
                    if ($newRest > 0) {
                        if ($debug >= 2) {
                            print "newRest=$newRest, isq=$isq, factor=$factor, newPart=\"$newPart\"\n";
                        }
                        foreach my $key (split(/$eq/, $hash{$newRest})) {
                            my ($imost, $part1) = split(/$most/, $key);
                            if ($imost < $sq) {
                                $parts .= "$sep$sq$most$newPart$plus$part1";
                                $sep = $eq;
                                if ($debug >= 2) {
                                    print "oldRest=$oldRest, isq=$isq, factor=$factor, parts=\"$parts\"\n";
                                }
                            } # if $imost
                        } # for $key
                        # $newRest > 0
                    } else { # $newRest == 0
                        $parts .= "$sep$sq$most$newPart";
                        $sep = $eq;
                    }
                    if ($debug >= 2) {
                        print "factor=$factor, newRest=$newRest, isq=$isq, newPart=$newPart, parts=$parts\n";
                    }
                    $factor --;
                } # while $factor
            } # for $isq
        } # if $isq > 1
        $hash{$oldRest} = $parts;
        &dump_hash();
    } # while queue not empty
} # exhaust_queue

sub dump_hash() {
        if ($debug >= 2) {
            foreach my $key(sort(keys(%hash))) {
                my $result = $hash{$key};
                $result =~ s{$eq}{ = }g;
                $result =~ tr{cHxtm}{\,\=\*\+\>};
                print "$key -> $result\n";
            }
        }
} # dump_hash
#----
sub isqrt() { # determine $result**2 <= $n
    my ($n) = @_;
    my $result = 0;
    while (($result + 1)**2 <= $n) {
        $result ++;
    }
    return $result;
} # isqrt
#--------
__DATA__
A159355 binom   0   4
A159359 binom   0   5
A159363 binom   0   6
A159367 binom   0   7


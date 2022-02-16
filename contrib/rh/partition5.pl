#!perl

# Squares summing up to a number -> partition equations
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
my $num;
my $factor;
my $isq;
my $sq;
my $parts;
my $rest;
my @queue = ();
my $comma = "/";
print "# OEIS-mat/contrib/rh/partition5.pl $timestamp\n";

if ($debug > 0) {
    for ($num = 2; $num <= $sumMax; $num ++) {
        print "# $num" . &partitions($num) . "\n";
    } # for my $num
} else {
    while (<>) {
        s/\s+\Z//; # chompr
        my ($aseqno, $callcode, $offset, @parms) = split(/\t/);
        $num = shift(@parms);
        my $parts = &partitions($num);
        print "# $aseqno\t$num$parts\n";
        print join("\t", $aseqno, $callcode, $offset, $num, $parts, @parms) . "\n";
    } # while <>
}
# end main
#----
sub partitions {
	my ($num) = @_;
    @queue = ();
    $isq   = &isqrt($num);
    $sq    = $isq**2;
    while ($isq >= 1) { # queue all (num, starting square indexes)+
        $factor = $num / $sq;
        while ($factor >= 1) {
           $rest   = $num - $factor *$sq;
           $parts = " = $factor*$sq";
            if ($debug >= 2) {
                print "    push1 rest=$rest, factor=$factor, isq=" . ($isq - 1) . ", parts= \"$parts\"\n";
            }
            push(@queue, join($comma, $rest, $factor, $isq - 1, $parts));
            if ($isq == 1) {
                $factor = 0;
            } else {
                $factor --;
            }
        } # while $factor
        $isq --;
        $sq = $isq**2;
    } # while pushing
    $newList = "";
    while (scalar(@queue) > 0) { # not empty
        my $elem = shift(@queue); # pop
        ($rest, $factor, $isq, $parts) = split(/$comma/, $elem);
        $newList .= &partition($rest, $factor, $isq, $parts);
    } # while not empty
    return $newList;
}

sub partition () { # append the partition of $rest, with parts <= $isq**2
    my ($num, $factor, $isq, $parts) = @_;
    if ($debug >= 2) {
        print "      pop num =$num, factor=$factor, isq=$isq, parts= \"$parts\"\n";
    }
    while ($num > 0 && $isq >= 1) { # queue all (num, starting square indexes)+
        $sq = $isq**2;
        $factor = $num / $sq;
        while ($factor >= 1) {
            $parts .= " + $factor*$sq";
            if ($isq <= 1) {
                $factor = 0; # break loop
            } else {
                my $rest   = $num - $factor *$sq;
                if ($debug >= 2) {
                    print "    push2 rest=$rest, factor=$factor, isq=" . ($isq - 1) . ", parts= \"$parts\"\n";
                }
                push(@queue, join($comma, $rest, $factor, $isq - 1, $parts));
            }
            $factor --;
        }
        $isq --;
    } 
    return $parts;
} # partition
#----
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


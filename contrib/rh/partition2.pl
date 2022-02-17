#!perl

# Squares summing up to a number -> partition equations
# @(#) $Id$
# 2022-02-17, Georg Fischer: copied from partition5.pl
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

my $comma = "/";
print "# OEIS-mat/contrib/rh/partition2.pl $timestamp\n";
my @queue = ();
my $top = 0;

if ($debug > 0) {
    my $num = $sumMax;
    print "# $num" . &partitions($num) . "\n";
} else {
    while (<>) {
        s/\s+\Z//; # chompr
        my ($aseqno, $callcode, $offset, @parms) = split(/\t/);
        my $num = shift(@parms);
        my $parts = &partitions($num);
        # print "# $aseqno\t$num$parts\n";
        print join("\t", $aseqno, $callcode, $offset, $num, $parts, @parms) . "\n";
    } # while <>
}
# end main
#----
sub partitions {
    my ($num) = @_;
    @queue = ();
    $top = 0;
    my $parts;
    my $isq   = &isqrt($num);
    my $sq    = $isq**2;
    while ($isq >= 1) { # queue all (num, starting square indexes)+
        my $factor = $num / $sq;
        while ($factor >= 1) {
            my $rest   = $num - $factor *$sq;
            if ($rest >= 0) {
                $parts = " = $factor*$sq";
                if ($debug >= 2) {
                    print "    push1 rest=$rest, level=" . ($top + 1) . ", isq=" 
                        . ($isq - 1) . ", parts= \"$parts\"\n";
                }
                push(@queue, join($comma, $rest, $top + 1, $isq - 1, $parts));
            } # $rest > 0
            if ($isq == 1) {
                $factor = 0;
            } else {
                $factor --;
            }
        } # while $factor
        $isq --;
        $sq = $isq**2;
    } # while pushing
    my $newList = "";
    while (scalar(@queue) > 0) { # not empty
        my $elem = shift(@queue); # pop
        my ($rest, $level, $isq2, $parts) = split(/$comma/, $elem);
        $newList .= &partition($rest, $level, $isq2, $parts);
        if ($debug >= 3) {
            print "        level=$level, newList = \"$newList\"\n";
        }
    } # while not empty
    return $newList;
} # partitions

sub partition () { # append the partitions of $rest, with parts <= $isq**2
    my ($num, $level, $isq, $parts) = @_;
    if ($debug >= 2) {
        print "      pop num =$num, level=$level, isq=$isq, parts= \"$parts\"\n";
    }
    $level ++;
    while ($num > 0 && $isq >= 1) { # queue all (num, starting square indexes)+
        my $sq = $isq**2;
        my $factor = $num / $sq;
        while ($factor >= 1) {
            if ($isq <= 1) {
                $parts .= " + $factor*$sq";
                $factor = 0; # break loop
            } else {
                my $rest   = $num - $factor *$sq;
                if ($rest >= 0) {
                    $parts .= " + $factor*$sq";
                    if ($debug >= 2) {
                        print "    push2 rest=$rest, level=$level, isq=" 
                            . ($isq - 1) . ", parts= \"$parts\"\n";
                    }
                    push(@queue, join($comma, $rest, $level, $isq - 1, $parts));
                } # $rest > 0
            }
            $factor --;
        }
        $isq --;
        $sq = $isq**2;
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


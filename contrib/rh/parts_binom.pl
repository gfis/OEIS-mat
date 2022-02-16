#!perl

# Convert partions into counting formulas with binomials
# @(#) $Id$
# 2022-02-16, Georg Fischer
# to be used in conjunction with partition2.pl

use strict;
use warnings;
use integer;

my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
if (0 && scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
my $debug = 0;
my $sumMax = 40;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
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

print "# OEIS-mat/contrib/rh/parts_binom.pl $timestamp\n";
my @partList; # of $n

while (<>) {
    s/\s+\Z//; # chompr
    if (m{\AA\d+\t}) {
        my ($aseqno, $callcode, $offset, @parms) = split(/\t/);
        my $num   = shift(@parms);
        my $parts = shift(@parms);
        my $newParts = &generate($num, $parts);
        print join("\t", $aseqno, $callcode, $offset, $num, $newParts, $parts, @parms) . "\n";
    } else {
        print "$_\n";
    }
} # while <>

sub generate () { # recursively generate the partitions for $summax
    my ($num, $parts) = @_;
    my $oldList = $parts;
    my $newList = "";
    my $sepPlus = "";
    foreach my $parts (split(/ \= /, $oldList)) { # a single partition
        my $sepTim = "";
        my $newParts = "";
        my $count = 0;
        foreach my $part (split(/ \+ /, $parts)) { # occurrences of summand
            my ($occ, $summand) = split(/\*/, $part);
            $newParts .= "$sepTim" . "binomial(n\^2" . ($count > 0 ? "-$count" : "") . ", $occ)";
            $count += $occ;
            $sepTim = "*";
        } # foreach $part
        $newList .= "$sepPlus$newParts";
        $sepPlus = " + ";
    } # foreach $parts
    return $newList;
} # generate

__DATA__
# A159355   4 = 4*1 = 1*4
A159355 binom   0   4   4*1 = 1*4
# A159359   5 = 5*1 = 1*4 + 1*1
A159359 binom   0   5   5*1 = 1*4 + 1*1
# binomin(A159359, 2, proc(n) binomial(n^2,1)*binomial(n^2-1,1) + binomial(n^2,5) end, [12]);

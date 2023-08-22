#!perl

# Print a sorted list of all values to be substituted
# @(#) $Id$
# 2023-08-21, Georg Fischer
#
#:# Usage:
#:#   perl subst_list.pl input.seq4 > output.seq4
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
$timestamp = sprintf ("%04d-%02d-%02d", $year + 1900, $mon + 1, $mday);

my $debug = 0;
if (0 && scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my ($aseqno, $callcode, $offset1, $expr, $list, @parms);
my $line;
while (<>) {
    $line = $_;
    next if $line !~ m{^A\d+};
    $line =~ s/\s+\Z//; # chompr
    ($aseqno, $callcode, @parms) = split(/\t/, $line);
    $offset1 = $parms[0];
    $expr    = $parms[1];
    $list    = $parms[2];
    foreach my $pair (split(/\;/, $list)) {
        my ($name, $value) = split(/\=/, $pair);
        print "$value\n";
    } # foreach
} # while <>
#--------------------------------------------
__DATA__
A343549	lamexpr	0	n.multiply(Integers.SINGLETON.sumdiv(n, d -> Binomial.binomial(V1V, V2V).divide(d)))	V1V=d+n-1;V2V=n;	 a(n) = n*sumdiv(n, d, binom(d+n-1, n)/d);	0
A343547	lamexpr	0	n.multiply(Integers.SINGLETON.sumdiv(n, d -> Binomial.binomial(V1V, V2V).divide(d)))	V1V=d+n-2;V2V=n-1;	 a(n) = n*sumdiv(n, d, binom(d+n-2, n-1)/d);	0
A095338	lamexpr	0	n.multiply(Z.valueOf(V3V)).multiply(Z.TWO.pow(Binomial.binomial(V1V, V2V)))	V1V=n-1;V2V=2;V3V=n-1;	 a(n) = n*(n-1)*2^binom(n-1,2); \\ _Joerg Arndt_, Mar 12 2014	0
A309255	lamexpr	0	n.add(Z.ONE).subtract(Integers.SINGLETON.sum(V3V, V4V, V5V -> Stirling.firstKind(V1V, V2V).mod(Z.TWO)))	V1V=n;V2V=k;V3V=0;V4V=n;V5V=k;	 a(n) = n + 1 - sum(k=0, n, stirl(n, k, 1) % 2); \\ _Michel Marcus_, Jul 19 2019	0

#!perl

# Postprocess: substitute variable list (parm2) into expression (parm1)
# @(#) $Id$
# 2023-08-21, Georg Fischer
#
#:# Usage:
#:#   perl expr_post.pl input.seq4 > output.seq4
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

my %znames = (0, "Z.ZERO", 1, "Z.ONE", 2, "Z.TWO"  , 3, "Z.THREE", 4, "Z.FOUR"
             ,5, "Z.FIVE", 6, "Z.SIX", 7, "Z.SEVEN", 8, "Z.EIGHT", 9, "Z.NINE", 10, "Z.TEN", -1
             , "Z.NEG_ONE");
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
    foreach my $pair (split(/\;/, $list)) { # substitute the variables
        my ($name, $value) = split(/\=/, $pair, 2); # ",2" is essential, value may contain "="
        if ($debug >= 2) {
            print "# aseqno=$aseqno name=$name value=$value expr=$expr list=$list\n";
        }
        #           1         1  2                    2
        $value =~ s{([a-z]|\d+)\^([a-z]|\d+|\([^\)]+\))}{Z\.valueOf\($1\).pow\($2\)}g; # (n-1)^(k-1) -> Z.valueOf(n-1).pow(k-1)
        
        $expr =~ s{$name}{"$value"}eg;
    } # foreach substituion
    #----
    # patches
    #          1           (2      2 )1
    $expr =~ s{(Z\.valueOf\((\-?\d+)\))}    {defined($znames{$2}) ? $znames{$2} : "$1"}eg;   # Z.valueOf(4)  -> Z.FOUR
    $expr =~ s{\.pow\(2\)}                  {\.square\(\\)}g; # .pow(2) -> .square()
    $expr =~ s{Z\.valueOf\(Z\.}             {\(Z\.}g; # bad patch of translation error
    $expr =~ s{\,(\S)}                      {\, $1}g; # force space behind ","
    
    # The following code fails for k=0:                              ----vvvvvvvvv
    # super(0, n -> Integers.SINGLETON.sum(0,n,k -> Z.valueOf(-2*n+2*k+1).pow(k-1).multiply(Z.valueOf(2*k).pow(n-k)).multiply(Binomial.binomial(n,k))));
    if ($expr =~ m{\.pow\(\w\-1\)\.multiply}) {
        my @parts = split(/ *\-\> */, $expr);
    }
    #----
    $parms[1] = $expr; # write it back
    $parms[2] = "";
    print join("\t", $aseqno, $callcode, @parms) . "\n";
} # while <>
#--------------------------------------------
__DATA__
A343549	lamexpr	0	n.multiply(Integers.SINGLETON.sumdiv(n, d -> Binomial.binomial(V1V, V2V).divide(d)))	V1V=d+n-1;V2V=n;	 a(n) = n*sumdiv(n, d, binom(d+n-1, n)/d);	0
A343547	lamexpr	0	n.multiply(Integers.SINGLETON.sumdiv(n, d -> Binomial.binomial(V1V, V2V).divide(d)))	V1V=d+n-2;V2V=n-1;	 a(n) = n*sumdiv(n, d, binom(d+n-2, n-1)/d);	0
A095338	lamexpr	0	n.multiply(Z.valueOf(V3V)).multiply(Z.TWO.pow(Binomial.binomial(V1V, V2V)))	V1V=n-1;V2V=2;V3V=n-1;	 a(n) = n*(n-1)*2^binom(n-1,2); \\ _Joerg Arndt_, Mar 12 2014	0
A309255	lamexpr	0	n.add(Z.ONE).subtract(Integers.SINGLETON.sum(V3V, V4V, V5V -> Stirling.firstKind(V1V, V2V).mod(Z.TWO)))	V1V=n;V2V=k;V3V=0;V4V=n;V5V=k;	 a(n) = n + 1 - sum(k=0, n, stirl(n, k, 1) % 2); \\ _Michel Marcus_, Jul 19 2019	0

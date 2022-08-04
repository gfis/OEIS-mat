#!perl

# Extract hypergeometric functions from cat25.txt file
# @(#) $Id$
# 2019-12-27, Georg Fischer: copied from extract_recur.pl
#
#:# Usage:
#:#   perl extract_hypergeom.pl [-d debug] cat25.txt > outfile
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

my $line;
my $aseqno;
my $oseqno   = ""; # old $aseqno
my $offset1  = "";
my $form     = "";
my $code;
my $comt     = "";
my $content;
my $conj;
my @dens;
while (<>) {
    $line = $_;
    if ($line =~ m{[Hh]yper[Gg]eom|\dF\d[\(\[\{]}) {
        $line =~ s/\s+\Z//; # chompr
        $line =~ m{^(.\w) (A\d+)\s+(.*)}; # may be "%" or "#"
        $code    = $1 || "";
        $aseqno  = $2 || "";
        $content = $3 || "";
        print join("\t", $aseqno, "$code $content") . "\n";
    } else {
        # ignore
    }
} # while <>
#--------------------------------------------
__DATA__
%C A000003 It seems that 2*a(n) gives the degree of the minimal polynomial of (k_n)^2 where k_n is the n-th singular value, i.e., K(sqrt/K(k_n)==sqrt(n) (and K is the elliptic integral of the first kind: K(x) := hypergeom([1/2,1/2],[1], x^2)).
%C A000003 Also, when setting K3(x)=hypergeom([1/3,2/3],[1], x^3) and solving for x such that K3((1-x^3)^(1/3))/K3(x)==sqrt(n), then the the minimal polynomial of x^3 is every third term of this sequence, or so it seems. (End)
%t A000005 a[ n_] := SeriesCoefficient[ q/(1 - q)^2 QHypergeometricPFQ[ {q, q}, {q^2, q^2}, q, q^2], {q, 0, Abs@n}]; (* _Michael Somos_,14 *)
%t A000005 a[n_] := SeriesCoefficient[q/(1 - q) QHypergeometricPFQ[{q, q}, {q^2}, q, q], {q, 0, Abs@n}] (* _Mats Granvik_, Apr 15 2015 *
%t A000009 a[ n_] := SeriesCoefficient[ Series[ QHypergeometricPFQ[ {q}, {q x}, q, - q x], {q, 0, n}] /. x -> 1, {q, 0, n}]; (* _Michaelar 04 2014 *)
%t A000009 a[ n_] := SeriesCoefficient[ QHypergeometricPFQ[{}, {}, q, -1] / 2, {q, 0, n}]; (* _Michael Somos_, Mar 04 2014 *)
%F A000023 G.f.: hypergeom([1,k],[],x/(1+2*x))/(1+2*x) with k=1,2,3 is the generating function for A000023, A087981, and A052124. - _Marj_, Nov 08 2011
%F A000023 a(n) = Sum_{k=0..n} (-1)^(n+k)*binomial(n, k)*!k, where !k is the subfactorial A000166. a(n) = (-2)^n*hypergeom([1, -n], [],ladimir Reshetnikov_, Oct 18 2015

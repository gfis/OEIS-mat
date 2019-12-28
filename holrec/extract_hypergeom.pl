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
if (scalar(@ARGV) == 0) {
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
    $line =~ s/\s+\Z//; # chompr
    $line =~ m{^\%(\w) (A\d+)\s+(.*)};
    $code    = $1 || "";
    $aseqno  = $2 || "";
    $content = $3 || "";
    if (0) {
    } elsif ($code eq "S") { # DATA
        $comt = "";
    } elsif ($code eq "O") { # OFFSET
        $content =~ m{(\-?\d+)(\,\d*)?};
        $offset1 = $1 || "0";
        my $form2 = $form;
        if (length($comt) > 0) {
            print join("\t", $aseqno, $comt, $offset1, $form) . "\n";
        }
        $oseqno = $aseqno;
        $form = "";
    } elsif ($code =~ m{[FNpto]}) { # FORMULA, NAME, Maple, Mathematica, PROG
        if ($content =~ m{[Hh]yper[Gg]eom|\dF\d[\(\[\{]}) {
            $form = $content;
            # $form =~ s{\s}{}g;
            # $form =~ s{\*\*}{\^}g; # exponentiation
            # $form =~ tr{\[\]\{\}}{\(\)\(\)}; # square or curly brackets -> round brackets
            $comt = "hyper";
        }    
    } else {
        # ignore
    }
} # while <>
#--------------------------------------------
__DATA__
%C A000003 It seems that 2*a(n) gives the degree of the minimal polynomial of (k_n)^2 where k_n is the n-th singular value, i.e., K(sqrt
/K(k_n)==sqrt(n) (and K is the elliptic integral of the first kind: K(x) := hypergeom([1/2,1/2],[1], x^2)).
%C A000003 Also, when setting K3(x)=hypergeom([1/3,2/3],[1], x^3) and solving for x such that K3((1-x^3)^(1/3))/K3(x)==sqrt(n), then the
 the minimal polynomial of x^3 is every third term of this sequence, or so it seems. (End)
%t A000005 a[ n_] := SeriesCoefficient[ q/(1 - q)^2 QHypergeometricPFQ[ {q, q}, {q^2, q^2}, q, q^2], {q, 0, Abs@n}]; (* _Michael Somos_,
14 *)
%t A000005 a[n_] := SeriesCoefficient[q/(1 - q) QHypergeometricPFQ[{q, q}, {q^2}, q, q], {q, 0, Abs@n}] (* _Mats Granvik_, Apr 15 2015 *
%t A000009 a[ n_] := SeriesCoefficient[ Series[ QHypergeometricPFQ[ {q}, {q x}, q, - q x], {q, 0, n}] /. x -> 1, {q, 0, n}]; (* _Michael
ar 04 2014 *)
%t A000009 a[ n_] := SeriesCoefficient[ QHypergeometricPFQ[{}, {}, q, -1] / 2, {q, 0, n}]; (* _Michael Somos_, Mar 04 2014 *)
%F A000023 G.f.: hypergeom([1,k],[],x/(1+2*x))/(1+2*x) with k=1,2,3 is the generating function for A000023, A087981, and A052124. - _Mar
j_, Nov 08 2011
%F A000023 a(n) = Sum_{k=0..n} (-1)^(n+k)*binomial(n, k)*!k, where !k is the subfactorial A000166. a(n) = (-2)^n*hypergeom([1, -n], [],
ladimir Reshetnikov_, Oct 18 2015
%H A000025 N. J. Fine, <a href="http://www.ams.org/bookstore?fn=20&amp;arg1=survseries&amp;ikey=SURV-27">Basic Hypergeometric Series and
ons</a>, Amer. Math. Soc., 1988; p. 55, Eq. (26.11), (26.24).
%D A000041 N. J. Fine, Basic Hypergeometric Series and Applications, Amer. Math. Soc., 1988; p. 37, Eq. (22.13).
%F A000045 a(n) = hypergeometric([-n/2+1/2, -n/2+1], [-n+1], -4) for n >= 2. - _Peter Luschny_, Sep 19 2014
%F A000079 a(n) = Hypergeometric([-n],[],-1). - _Peter Luschny_, Nov 01 2011
%t A000085 a[ n_] := If[ n < 0, 0, HypergeometricU[ -n/2, 1/2, -1/2] / (-1/2)^(n/2)]; (* _Michael Somos_, Jun 01 2013 *)
%o A000085 (Sage) A000085 = lambda n: hypergeometric([-n/2,(1-n)/2], [], 2)
%H A000108 George E. Andrews, <a href="https://doi.org/10.1016/0097-3165(87)90033-1">Catalan numbers, q-Catalan numbers and hypergeometr
/a>, Journal of Combinatorial Theory, Series A, Vol. 44, No. 2 (1987), 267-273.
%F A000108 E.g.f.: Hypergeometric([1/2],[2],4*x) which coincides with the e.g.f. given just above, and also by _Karol A. Penson_ further
_Wolfdieter Lang_, Jan 13 2012
%F A000108 G.f.: hypergeom([1/2,1],[2],4*x). - _Joerg Arndt_, Apr 06 2013
%F A000108 a(n) = (2*n)!*[x^(2*n)]hypergeom([],[2],x^2). - _Peter Luschny_, Jan 31 2015
%F A000108 a(n) = 4^(n-1)*hypergeom([3/2, 1-n], [3], 1). - _Peter Luschny_, Feb 03 2015
%p A000108 seq((2*n)!*coeff(series(hypergeom([],[2],x^2),x,2*n+2),x,2*n),n=0..30); # _Peter Luschny_, Jan 31 2015
%t A000108 A000108[n_] := Hypergeometric2F1[1 - n, -n, 2, 1] (* Richard L. Ollerton, Sep 13 2006 *)
%H A000110 Feng Qi, <a href="http://arxiv.org/abs/1402.2361">An Explicit Formula for Bell Numbers in Terms of Stirling Numbers and Hyper
Functions</a>, arXiv:1402.2361 [math.CO], 2014.
%H A000110 Feng Qi, <a href="https://www.researchgate.net/profile/Feng_Qi/publication/279750659">On sum of the Lah numbers and zeros of
 confluent hypergeometric function</a>, 2015.
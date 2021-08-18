#!perl

# Extract the numerators and denominators of generating functions from a cat25 file
# @(#) $Id$
# 2019-06-07: remove author
# 2019-05-10, Georg Fischer
#
#:# Usage:
#:#   perl extract_catgf.pl [-d debug] cat25.txt > outfile
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
my $fraction = "";
my $code;
my $comt     = "";
my $content;
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
        my $nvars = "";
        if (length($fraction) > 0) { 
            if (length($comt) > 0) {
                $comt = "# $aseqno $comt";
            } else {
                $comt = "$aseqno";
                my %hash = ();
                map { $hash{$_} = 1; } $fraction =~ m{[a-z]}g;
                $nvars = scalar(keys(%hash));
                my $uvar = $nvars <= 3 ? "X" : chr(ord("X" - ($nvars - 3)));
                foreach my $key (sort(keys(%hash))) {
                    $fraction =~ s{$key}{$uvar}g;
                    $uvar = chr(ord($uvar) + 1);
                } # foreach $key
                $fraction = lc($fraction);
            }
            print join("\t", $comt, "fract$nvars", $offset1, $fraction) . "\n";
            $oseqno = $aseqno;
        }
        $fraction = "";
    } elsif ( ($code eq 'F' or $code eq 'N') 
              and # FORMULA and NAME
              (   ($content =~ m{^(O\.|Expansion\s+of\s+|)\s*[Gg]\.\s*[Ff]\.\s*(for\s+\w\([a-z\,]*\)\s*)?([\=\:]\s*)?(.*)}i)
              or  ($content =~ m{^(Expansion\s+of)\s*(.*)}i)
              )
            ) {
        $fraction = $4 || "";
        $fraction =~ s{^[A-Z]\([a-z]\) *[\=\:] *}{};
        $fraction =~ s{[\.\;\,\=].*}{}; # remove all behind first dot or semicolon
        $fraction =~ s{[\(\[]?(From |Correc|Amdended |_).*}{}i; # author etc.
        $fraction =~ s{\s}{}g;
        $fraction =~ s{a\(n\)\Z}{}; # following recurrence
        $fraction =~ s{\*\*}{\^}g; # exponentiation
        $fraction =~ tr{\[\]\{\}}{\(\)\(\)}; # square or curly brackets -> round brackets
        $fraction =~ s{\s+\Z}{}; # remove trailing spaces
        $fraction =~ s{(\d+)([a-z]|\()}{$1\*$2}g; # insert "*" 
        $fraction =~ s{([a-z]|\))(\d+)}{$1\*$2}g; # insert "*" 
        $fraction =~ s{\)\(}{\)\*\(}g; # insert "*" 
        $fraction =~ s{([a-z])\(}{$1\*\(}g; # insert "*" 
        $comt = "";
        if ($oseqno eq $aseqno) {
            $comt = "?multi?";
        }
        if ($fraction !~ m{\/}) {
            $comt = "?nodiv?";
        }
        if (&nesting_diff($fraction) != 0) {
            $comt = "?unbal?";
        }
        if ($fraction =~ m{[a-hA-Z\<\>\=]}) { 
            $comt = "?letrs?";
        }
        if ($fraction =~ m{[a-zA-Z]\([a-z]\)}) { # A(x)
            $comt = "?funct?";
        }
        if ($fraction =~ m{[a-zA-Z][a-zA-Z]}) { # at least 2 letters, sqrt ...
            $comt = "?stdf?";
        }
        if ($fraction =~ m[\d{16}]) {
            $comt = "?digt16?";
        }
        if ($fraction =~ m[\^\d{4}]) {
            $comt = "?powg4?";
        }
        if ($fraction =~ m{\^\(}) {
            $comt = "?popen?";
        }
        if ($fraction =~ m{[\+\-\*\/\^\(]\Z}) { # trailing "+" etc.
            $comt = "?ellips?";
        }
    } else {
        # ignore
    }
} # while <>
#----
sub nesting_diff {
    my ($parm) = @_;
    if (! defined($parm)) {
        $parm = "";
    }
    my $op = ($parm =~ s/\(/\{/g);
    my $cp = ($parm =~ s/\)/\}/g);
    return $op - $cp;
} # nesting_diff
#--------------------------------------------
__DATA__
# OEIS as of February 28 14:44 EST 2019

%I A000001 M0098 N0035
%S A000001 0,1,1,1,2,1,2,1,5,2,2,1,5,1,2,1,14,1,5,1,5,2,2,1,15,2,2,5,4,1,4,1,51,
%T A000001 1,2,1,14,1,2,2,14,1,6,1,4,2,2,1,52,2,5,1,5,1,15,2,13,2,2,1,13,1,2,4,
%U A000001 267,1,4,1,5,1,4,1,50,1,2,3,4,1,6,1,52,15,2,1,15,1,2,1,12,1,10,1,4,2
%N A000001 Number of groups of order n.
%C A000001 Also, number of nonisomorphic subgroups of order n in symmetric group S_n. - _Lekraj Beedassy_, Dec 16 2004
%C A000001 Also, number of nonisomorphic primitives of the combinatorial species Lin[n-1]. - _Nicolae Boicu_, Apr 29 2011
%C A000001 The record values are (A046058): 1, 2, 5, 14, 15, 51, 52, 267, 2328, 56092, 10494213, 49487365422, ..., and they appear at positions (A046059): 1, 4, 8, 16, 24, 32, 48, 64, 128, 256, 512, 1024, .... _Robert G. Wilson v_, Oct 12 2012
%C A000001 In (J. H. Conway, Heiko Dietrich and E. A. O'Brien, 2008), a(n) is called the "group number of n", denoted by gnu(n), and the first occurrence of k is called the "minimal order attaining k", denoted by moa(k) (see A046057). - _Daniel Forgues_, Feb 15 2017
%C A000001 It is conjectured in (J. H. Conway, Heiko Dietrich and E. A. O'Brien, 2008) that the sequence n -> a(n) -> a(a(n)) = a^2(n) -> a(a(a(n))) = a^3(n) -> ... -> consists ultimately of 1s, where a(n), denoted by gnu(n), is called the "group number of n". - _Muniru A Asiru_, Nov 19 2017
%D A000001 L. Comtet, Advanced Combinatorics, Reidel, 1974, p. 302, #35.
%D A000001 J. H. Conway et al., The Symmetries of Things, Peters, 2008, p. 209.
%D A000001 H. S. M. Coxeter and W. O. J. Moser, Generators and Relations for Discrete Groups, 4th ed., Springer-Verlag, NY, reprinted 1984, p. 134.
%D A000001 CRC Standard Mathematical Tables and Formulae, 30th ed. 1996, p. 150.
%D A000001 R. L. Graham, D. E. Knuth and O. Patashnik, Concrete Mathematics, A Foundation for Computer Science, Addison-Wesley Publ. Co., Reading, MA, 1989, Section 6.6 'Fibonacci Numbers' pp. 281-283.
%D A000001 M. Hall, Jr. and J. K. Senior, The Groups of Order 2^n (n <= 6). Macmillan, NY, 1964.
%D A000001 D. Joyner, 'Adventures in Group Theory', Johns Hopkins Press. Pp. 169-172 has table of groups of orders < 26.
%D A000001 D. S. Mitrinovic et al., Handbook of Number Theory, Kluwer, Section XIII.24, p. 481.
%D A000001 M. F. Newman and E. A. O'Brien, A CAYLEY library for the groups of order dividing 128. Group theory (Singapore, 1987), 437-442, de Gruyter, Berlin-New York, 1989.
%D A000001 N. J. A. Sloane, A Handbook of Integer Sequences, Academic Press, 1973 (includes this sequence).
%D A000001 N. J. A. Sloane and Simon Plouffe, The Encyclopedia of Integer Sequences, Academic Press, 1995 (includes this sequence).
%H A000001 H.-U. Besche and Ivan Panchenko, <a href="/A000001/b000001.txt">Table of n, a(n) for n = 0..2047</a> [Terms 1 through 2015 copied from Small Groups Library mentioned below. Terms 2016 - 2047 added by Ivan Panchenko, Aug 29 2009. 0 prepended by _Ray Chandler_, Sep 16 2015.]
%H A000001 H. A. Bender, <a href="http://www.jstor.org/stable/1967981">A determination of the groups of order p^5</a>, Ann. of Math. (2) 29, pp. 61-72 (1927).
%H A000001 Hans Ulrich Besche and Bettina Eick, <a href="http://dx.doi.org/10.1006/jsco.1998.0258">Construction of finite groups</a>, Journal of Symbolic Computation, Vol. 27, No. 4, Apr 15 1999, pp. 387-404.
%H A000001 Hans Ulrich Besche and Bettina Eick, <a href="http://dx.doi.org/10.1006/jsco.1998.0259">The groups of order at most 1000 except 512 and 768</a>, Journal of Symbolic Computation, Vol. 27, No. 4, Apr 15 1999, pp. 405-413.
%H A000001 H. U. Besche, B. Eick and E. A. O'Brien, <a href="http://www.ams.org/era/2001-07-01/S1079-6762-01-00087-7/home.html">The groups of order at most 2000</a>, Electron. Res. Announc. Amer. Math. Soc. 7 (2001), 1-4.
%H A000001 H. U. Besche, B. Eick and E. A. O'Brien, <a href="http://www.icm.tu-bs.de/ag_algebra/software/small/">The Small Groups Library</a>
%H A000001 H. U. Besche, B. Eick and E. A. O'Brien, <a href="http://www.icm.tu-bs.de/ag_algebra/software/small/number.html">Number of isomorphism types of finite groups of given order</a>
%H A000001 H.-U. Besche, B. Eick and E. A. O'Brien, <a href="http://dx.doi.org/10.1142/S0218196702001115">A Millennium Project: Constructing Small Groups</a>, Internat. J. Algebra and Computation, 12 (2002), 623-644.
%H A000001 H. Bottomley, <a href="/A000001/a000001.gif">Illustration of initial terms</a>
%H A000001 J. H. Conway, Heiko Dietrich and E. A. O'Brien, <a href="http://www.math.auckland.ac.nz/~obrien/research/gnu.pdf">Counting groups: gnus, moas and other exotica</a>, Math. Intell., Vol. 30, No. 2, Spring 2008.
%H A000001 Otto Hölder, <a href="http://dx.doi.org/10.1007/BF01443651">Die Gruppen der Ordnungen p^3, pq^2, pqr, p^4</a>, Math. Ann. 43 pp. 301-412 (1893).
%H A000001 Rodney James, <a href="http://dx.doi.org/10.1090/S0025-5718-1980-0559207-0">The groups of order p^6 (p an odd prime)</a>, Math. Comp. 34 (1980), 613-637.
%H A000001 Rodney James and John Cannon, <a href="http://dx.doi.org/10.1090/S0025-5718-1969-0238953-8">Computation of isomorphism classes of p-groups</a>, Mathematics of Computation 23.105 (1969): 135-140.
%H A000001 G. A. Miller, <a href="http://www.jstor.org/stable/2370630">Determination of all the groups of order 64</a>, Amer. J. Math., 52 (1930), 617-634.
%H A000001 Ed Pegg, Jr., <a href="http://www.mathpuzzle.com/MAA/07-Sequence%20Pictures/mathgames_12_08_03.html">Sequence Pictures</a>, Math Games column, Dec 08 2003.
%H A000001 Ed Pegg, Jr., <a href="/A000043/a000043_2.pdf">Sequence Pictures</a>, Math Games column, Dec 08 2003 [Cached copy, with permission (pdf only)]
%H A000001 D. S. Rajan, <a href="http://dx.doi.org/10.1016/0012-365X(93)90061-W">The equations D^kY=X^n in combinatorial species</a>, Discrete Mathematics 118 (1993) 197-206 North-Holland.
%H A000001 E. Rodemich, <a href="http://dx.doi.org/10.1016/0021-8693(90)90244-I">The groups of order 128</a>, J. Algebra 67 (1980), no. 1, 129-142.
%H A000001 Gordon Royle, <a href="http://staffhome.ecm.uwa.edu.au/~00013890/data.html">Combinatorial Catalogues</a>. See subpage "Generators of small groups" for explicit generators for most groups of even order < 1000.
%H A000001 D. Rusin, <a href="/A000001/a000001.txt">Asymptotics</a> [Cached copy of lost web page]
%H A000001 Eric Weisstein's World of Mathematics, <a href="http://mathworld.wolfram.com/FiniteGroup.html">Finite Group</a>
%H A000001 Wikipedia, <a href="http://en.wikipedia.org/wiki/Finite_group">Finite group</a>
%H A000001 M. Wild, <a href="http://www.jstor.org/stable/30037381">The groups of order sixteen made easy</a>, Amer. Math. Monthly, 112 (No. 1, 2005), 20-31.
%H A000001 Gang Xiao, <a href="http://wims.unice.fr/~wims/wims.cgi?module=tool/algebra/smallgroup">SmallGroup</a>
%H A000001 <a href="/index/Gre#groups">Index entries for sequences related to groups</a>
%H A000001 <a href="/index/Cor#core">Index entries for "core" sequences</a>
%F A000001 From _Mitch Harris_, Oct 25 2006: (Start)
%F A000001 For p, q, r primes:
%F A000001 a(p) = 1, a(p^2) = 2, a(p^3) = 5, a(p^4) = 14, if p = 2, otherwise 15.
%F A000001 a(p^5) = 61 + 2p + 2gcd(p-1,3) + gcd(p-1,4), p>=5, a(2^5)=51, a(3^5)=67.
%F A000001 a(p^e) ~ p^((2/27)e^3 + O(e^(8/3)))
%F A000001 a(pq) = 1 if gcd(p,q-1) = 1, 2 if gcd(p,q-1) = p. (p < q)
%F A000001 a(pq^2) = one of the following:
%F A000001 * 5, p=2, q odd,
%F A000001 * (p+9)/2, q=1 mod p, p odd,
%F A000001 * 5, p=3, q=2,
%F A000001 * 3, q = -1 mod p, p and q odd.
%F A000001 * 4, p=1 mod q, p > 3, p != 1 mod q^2
%F A000001 * 5, p=1 mod q^2
%F A000001 * 2, q != +/-1 mod p and p != 1 mod q,
%F A000001 a(pqr) (p < q < r) = one of the following:
%F A000001 * q==1 mod p r==1 mod p r==1 mod q a(pqr)
%F A000001 * No..........No..........No..........1
%F A000001 * No..........No..........Yes.........2
%F A000001 * No..........Yes.........No..........2
%F A000001 * No..........Yes.........Yes.........4
%F A000001 * Yes.........No..........No..........2
%F A000001 * Yes.........No..........Yes.........3
%F A000001 * Yes.........Yes.........No..........p+2
%F A000001 * Yes.........Yes.........Yes.........p+4 (table from Derek Holt) (End)
%F A000001 a(n) = A000688(n) + A060689(n). - _R. J. Mathar_, Mar 14 2015
%e A000001 Groups of orders 1 through 10 (C_n = cyclic, D_n = dihedral of order n, Q_8 = quaternion, S_n = symmetric):
%e A000001 1: C_1
%e A000001 2: C_2
%e A000001 3: C_3
%e A000001 4: C_4, C_2 X C_2
%e A000001 5: C_5
%e A000001 6: C_6, S_3=D_6
%e A000001 7: C_7
%e A000001 8: C_8, C_4 X C_2, C_2 X C_2 X C_2, D_8, Q_8
%e A000001 9: C_9, C_3 X C_3
%e A000001 10: C_10, D_10
%p A000001 GroupTheory:-NumGroups(n); # with(GroupTheory); loads this command - _N. J. A. Sloane_, Dec 28 2017
%t A000001 FiniteGroupCount[Range[100]] (* _Harvey P. Dale_, Jan 29 2013 *)
%t A000001 a[ n_] := If[ n < 1, 0, FiniteGroupCount @ n]; (* _Michael Somos_, May 28 2014 *)
%o A000001 (MAGMA) D:=SmallGroupDatabase(); [ NumberOfSmallGroups(D, n) : n in [1..1000] ]; // _John Cannon_, Dec 23 2006
%o A000001 (GAP) A000001 := Concatenation([0], List([1..500], n -> NumberSmallGroups(n))); # _Muniru A Asiru_, Oct 15 2017
%Y A000001 The main sequences concerned with group theory are A000001 (this one), A000679, A001034, A001228, A005180, A000019, A000637, A000638, A002106, A005432, A000688, A060689, A051532.
%Y A000001 Cf. A046058, A023675, A023676. A003277 gives n for which A000001(n) = 1, A063756 (partial sums).
%Y A000001 A046057 gives first occurrence of each k.
%K A000001 nonn,core,nice,hard
%O A000001 0,5
%A A000001 _N. J. A. Sloane_
%E A000001 More terms from _Michael Somos_
%E A000001 Typo in b-file description fixed by _David Applegate_, Sep 05 2009

%I A000002 M0190 N0070
%S A000002 1,2,2,1,1,2,1,2,2,1,2,2,1,1,2,1,1,2,2,1,2,1,1,2,1,2,2,1,1,2,1,1,2,1,
%T A000002 2,2,1,2,2,1,1,2,1,2,2,1,2,1,1,2,1,1,2,2,1,2,2,1,1,2,1,2,2,1,2,2,1,1,


        ($num, @dens) = split(/\//, $fraction);
        $comt = "";
        $den  = "";
        if ($oseqno eq $aseqno) {
            $comt = "?=id?";
        }
        if (! defined($num)) {
            $comt = "???";
            $num = "";
        }
    #   if (($num !~ m{\)\Z}) && ($num =~ m{[\+\-]})) {
    #       $comt = "?/(?";
    #       $den  = "";
    #   }
        if (0) {
        } elsif (scalar(@dens) == 0) {
            $comt = "?/?";
            $den = "";
        } elsif (scalar(@dens) > 1) {
            $comt = "?//? ";
            $den = "(" . join("/", @dens) . ")";
        } else {
            $den = $dens[0];
        }
        if (&nesting_diff($num) == 1 and &nesting_diff($den) == -1 and ($num =~ m{^\-})) {
            $num .= ")";
            $den =~ s{\)\Z}{};
        }
        if ($fraction =~ m{[a-mA-Z]}) {
            $comt = "?let? ";
        }
        if ($fraction =~ m[\d{8}]) {
            $comt = "?d8? ";
        }
        if ($fraction =~ m{\^\(}) {
            $comt = "?^(? ";
        }
        if (&nesting_diff($num) != 0 or &nesting_diff($den) != 0) {
            $comt = "?()? ";
        }

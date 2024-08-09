#!perl

# Prepare parameters for HypergeometricSequence
# @(#) $Id$
# 2022-08-03, Georg Fischer: copied from extract_hypergeom.pl; HH=*84+1
#
#:# Usage:
#:#   perl extract_hypergeom.pl jcat25.txt \
#:#   | perl prep_hypergeom.pl [-d debug] [-m] > outfile.seq4
#:#       -m generate with multiplier (for hygeom.jpat)
#--------------------------------------------------------
use strict;
use integer;
use warnings;
use English;

my $debug = 0;
my $m = "";
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{m}) {
        $m         = "m";
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my $line;
my $aseqno;
my $offset1  = "0";
my $type;
my $code;
my $expr;
my $content;
my $name;
my $callcode = "hygeo";
my ($p, $q); # of pFq
my $nok;
while (<>) {
    s/\r?\n//; # chompr
    m{\A(A\d+)\s+(\S\S)\s+(.*)};
    $content = "";
    ($aseqno, $type, $name) = ($1, $2, $3);
    $nok = "";
    next if $name =~ m{n_?\, *k_?}; # skip triangles, arrays
    next if $name =~ m{Bessel|GAMMA|exp|RealDigits|CoefficientList}i;
    if (0) {
    #                                 1           1  2      2
    } elsif ($name =~ m{Hyper[a-zA_Z]*(\d+F\d+|PFQ)\[([^\]]+)\]}i ) { # MMA
        $code = $1;
        $content = $2;
        $expr = $PREMATCH;
    #                                 1           1  2      2
    } elsif ($name =~ m{Hypergeometric(\d+F\d+|PFQ)\(([^\]]+)\)}i ) { # round brackets
        $code = $1;
        $content = $2;
        $expr = $PREMATCH;
    #                            1     1   2      2
    } elsif ($name =~ m{hypergeom(etric)?\(([^\)]+)\)}i) { # Maple
        $code = "[]";
        $content = $2;
        $expr = $PREMATCH;
    } else {
        # ignore
    }
    &analyze();
    if (($content =~ m{n}) && ($content !~ m{k})) {
        $nok = "no n,k";
    }
    if ($nok eq "") {
        print        join("\t", $aseqno, "$callcode$m", $offset1, "$p, $q", "\"$content\"", $expr, ""                       ) . "\n";
    } else {                                                                                     
        print STDERR join("\t", $aseqno, $nok,          $offset1, "$p, $q", "\"$content\"", $expr, "", substr($name, 0,1024)) . "\n";
    }
} # while <>
#----
sub analyze {
    my @parts;
    ($p, $q) = (1, 0);
    $content =~ s{ }{}g;
    # print join("\t", "# $aseqno", $content) . "\n";
    if (0) {
    } elsif ($code =~ m{(\d+)F(\d+)}) {
        ($p, $q) = ($1, $2);
    } else {
        if (0) {
        } elsif ($code =~ m{PFQ}) { # MMA
            #               1      1      2      2    3  3  
            $content =~ m{\{([^\}]*)\}\,\{([^\}]*)\}\,(.*)};
            @parts = ($1 || "", $2 || "", $3 || "");
        } elsif ($code eq  "[]") {
        	#               1      1      2      2    3  3  
            $content =~ m{\[([^\]]*)\]\,\[([^\]]*)\]\,(.*)};
            @parts = ($1 || "", $2 || "", $3 || "");
        }
        $p = (length($parts[0]) > 0) ? scalar(split(/\,/, $parts[0])) : 0;
        $q = (length($parts[1]) > 0) ? scalar(split(/\,/, $parts[1])) : 0;
        $content = join(",", @parts);
    }
    if (1) { # modern
        @parts = split(/\,/, $content);
        my $exp = scalar(@parts);
        my $ope = join("+", map {
            "($_)*A^" . (-- $exp)
            } @parts);
        # print "# ope = $ope, content=$content\n";
        print "\n# $name\n";
        $content = &ope2matrix($ope);
        $content =~ s{\s}{}g; # chompr...
        # print "# ope2matrix -> \"$content\"\n";
        $content =~ s{\A\[\[0\]\,}{\[}; # remove leading "[0]" for hypergeometric fractions
    } else { # old-fashioned
        $content =~ s{[^n\-\+\,\d\/\*]}{}g; # remove all brackets
        $content =~ s{\,}{\]\,\[}g;
        $content = "[[$content]]";
        $content =~ s{\[(\-|)n\]}{\[0,${1}1\]}g;
        $content =~ s{\[\-(\d+(\/\d+)?)\*?n\]}{\[0,-$1\]}g;
        $content =~ s{\[n([\+\-])(\d+(\/\d+)?)\]}{\[$1$2,1\]}g;
        $content =~ s{\[(\-?\d+(\/\d+)?)\+n\]}{\[$1,1\]}g;
        $content =~ s{\[(\-?\d+(\/\d+)?)\*n\]}{\[0,$1\]}g;
        $content =~ s{\[(\d+(\/\d+)?)([\-\+])n\]}{\[$1,${3}1\]}g;
        $content =~ s{(\[|\,)\+}{$1}g;
    }
    $expr    =~ s{ }{}g;
    $expr    =~ s{\A\w_?+\:?\=}{};
    $expr    =~ s{\A\w\(\w\):?\=}{};
    $expr    =~ s{\A\w\[\w_?\]:?\=}{};
    $expr    =~ s{\*}{\)\.multiply\(}g;
    $expr    =~ s{\^}{\)\.pow\(}g;
    $expr    =~ s{\An}{Z\.valueOf\(n};
    $expr    =~ s{\bn\b}{mN}g;
    if ($expr =~ m{([a-z])}) {
      $nok = "var $1";
    }
} # sub analyze
#----
sub ope2matrix {
    my ($ope) = @_; # operator, e.g. "1/2*A^4+( n+3/2)*A^3+ 3/2*A^2 +1/3*A+A^0"
    my $tempname = "ope2matrix.tmp";
    open(GP, ">", $tempname) || die "cannot write \"$tempname\"\n";
    print GP <<"GFis";
read("ope2matrix.gpi");
iferr(ope2matrix($ope), E, quit());
quit;
GFis
    close(GP);
    my $result = `gp -fq $tempname`;
    $result =~ s{\, }{\,}g; # not s{\s}{}g !
    return $result;
} # ope2matrix
#--------------------------------------------
__DATA__
A051103	%t a[n_] := Numerator[2^n*3/((n + 1)^2*(2*n + 1)*(4*n + 3)) * HypergeometricPFQ[{-n, 1, 1}, {n + 2, 1/2 - n}, 1/4]]; Array[a, 20] (* _Amiram Eldar_, Jul 05 2021 *)
A051104	%t a[n_] := Denominator[2^n*3/((n + 1)^2*(2*n + 1)*(4*n + 3)) * HypergeometricPFQ[{-n, 1, 1}, {n + 2, 1/2 - n}, 1/4]]; Array[a, 20] (* _Amiram Eldar_, Jul 05 2021 *)
A059114	%F T(n, k) = n!*binomial(n-1, k-1)*Hypergeometric1F1([k-n], [k], -1) with T(n, 0) = Hypergeometric2F0([1-n, -n], [], 1). (End)
A059346	%F T(n, k) = (-1)^(n-k)*binomial(2*k,k)/(k+1)*hypergeometric([k-n, k+1/2],[k+2], 4). - _Peter Luschny_, Aug 16 2012
A059346	%p T := (n,k) -> (-1)^(n-k)*binomial(2*k,k)*hypergeom([k-n,k+1/2], [k+2], 4)/(k+1): seq(seq(simplify(T(n,k)), k=0..n), n=0..10);
A059576	%F U(n,k) = binomial(n,k) * 2^(n-1) * hypergeom([-k,-k], [n+1-k], 2) if n >= k >= 0 with (n,k) <> (0,0). - _Robert Israel_, Jun 15 2011 [Corrected by _Petros Hadjicostas_, Jul 16 2020]
A059576	%t t[0, 0] = 1; t[n_, k_] := 2^(n-k-1)*n!*Hypergeometric2F1[ -k, -k, -n, -1 ] / (k!*(n-k)!); Flatten[ Table[ t[n, k], {n, 0, 9}, {k, 0, n}]] (* _Jean-François Alcover_, Feb 01 2012, after _Robert Israel_ *)
A059728	%t b[n_] := If[n < 0, 0, 3^n Hypergeometric2F1[1/2, -n, 1, 4/3]];  Table[b[n + 1] + Fibonacci[n - 1]*(1 + Fibonacci[n - 1]), {n, 0,50}] (* _G. C. Greubel_, Feb 27 2017 *)
A059760	%t a[n_] = If[n==0, 0, (n*n!/2)*(HypergeometricPFQ[{1, 1, 1-n}, {2}, -1]-1)]; Table[a[n], {n, 0, 20}] (* _Jean-François Alcover_, Feb 19 2017 *)
A061018	%F T(n, k) = n!*(1 - hypergeom([-k], [-n], -1) for 1 <= k < n and T(n, n) = n! -Gamma(n+1, -1)/exp(1). - _Peter Luschny_, Oct 03 2017
A061018	%p T := (n, k) -> `if`(n=k,n!-GAMMA(n+1,-1)/exp(1),n!*(1-hypergeom([-k],[-n],-1))):
A061401	%t InverseSeries[z/Exp[6 z HypergeometricPFQ[{1, 1, 4/3, 5/3}, {2, 2, 2}, -27 z]] + O[z]^20, q] // CoefficientList[#, q]& // Rest (* _Jean-François Alcover_, Feb 18 2019 *)
A062995	%F Hypergeometric generating function for a(n), in Maple notation: exp(exp(BesselI(0, 2*sqrt(z))-1)-1)=sum(a(n)*z^n/((n!)^2), n=0..infinity)
A064280	%t d[n_] := (-1)^n HypergeometricPFQ[{1/2, -n}, {}, 2];
A064334	%F T(n, k) = hypergeometric([1-n+k, n-k], [-n+k], -k) if k<n else 1. - _Peter Luschny_, Nov 30 2014
A064334	%o return hypergeometric([1-n, n], [-n], -k) if n>0 else 1

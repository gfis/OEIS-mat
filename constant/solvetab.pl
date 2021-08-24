#!perl
# Extract parameters from Clark Kimberling's guides (overview tables)
# @(#) $Id$
# 2021-08-01: renamed from solv_tabs, -a 45
# 2021-07-29: -a 3
# 2021-07-27, Georg Fischer
#
#:# Usage:
#:#   perl solvetab.pl [-d debug] [-a sel] > output.tmp
#
# =1=   https://oeis.org/A197133
# =2=   https://oeis.org/A197476
# =3=   https://oeis.org/A336043
# =4=   https://oeis.org/A198414
# =5=   https://oeis.org/A198866
# =6=   A201741
# =7=   A201280
# =8=   A199170
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
my $asel = "0-9a-z"; # select all possible TAB codes
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{a}) {
        $asel      = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my $offset = 0;
my ($opt, $b, $c, @ans);
my $rsave;
my $hsave;
while (<DATA>) {
    my $line = $_;
    next if $line !~ m{\A\=};
    $line =~ s/\s+\Z//; # chompr
    $line =~ s{[ \.]}{}g; # remove spaces and dots
    $line =~ s{pi}{Pi}g;
    $line =~ s{r\'(\d+)}{sqrt\($1\)}g;
    ($opt, $b, $c, @ans) = map { s{nnnn}{}; $_ } split(/\t/, $line);
    my ($A);
    if ($opt !~ m{\A\=[$asel]\=\Z}) {
        # no desired code, ignore

    } elsif ($opt eq "=1=") { # A197133 ff. sin = sin^2
        $A = "sin($b*x)-(sin($c*x))^2";
        &outstd($ans[0], "decsolv", $A, "");

    } elsif ($opt eq "=2=") { # A197476 ff. cos = cos^2
        $A = "cos($b*x)-(cos($c*x))^2";
        &outstd($ans[0], "decsolv", $A, "");

    } elsif ($opt eq "=3=") { # A336043 ff.
        # t = t /.FindRoot[t == b * Sqrt[2 - 2 * Cos[t]], {t, 4}, WorkingPrecision -> 200]
        # c = t/b
        $A = "x-$b*sqrt(2-2*cos(x))";
        &outstd($ans[0], "decsolv", $A, "");
        &outstd($ans[1], "decsolv", $A, ".divide(CR.valueOf($b))");
        &outerr($ans[1], $ans[0]);

    } elsif ($opt eq "=4=") { # A198414 ff.
        ($opt, $a, $b, $c, @ans) = map { s{nnnn}{}; $_ } split(/\t/, $line);
        # For many choices of a,b,c, there is a unique nonzero number x satisfying a*x^2 + b*x = c*sin(x).
        # Specifically, for a>0 and many choices of b and c, the curves y=ax^2+bx and y=c*sin(x) meet in a single point
        # If b<c, the curves meet in quadrant 1; if b>c, they meet in quadrant 2.
        $A = ($a != 0 ? "$a*" : "") . "x^2"
           . ($b > 0 ? "+$b*x" : ($b < 0 ? "$b*x" : "")) . "-"
           . ($c != 1 ? "$c*" : "") . "sin(x)";
        &outstd($ans[0], "decsolv" . ($b > $c ? "n" : ""), $A, "");

    } elsif ($opt eq "=5=") { # A198866 ff.
        ($opt, $a, $b, $c, @ans) = map { s{nnnn}{}; $_ } split(/\t/, $line);
        push(@ans, "", ""); # ensure 3 A-numbers
        # For many choices of a,b,c, there are exactly two numbers x having a*x^2 + b*sin(x) = c.
        $A = (($a != 1 ? "$a*" : "") . "x^2"
           . ($b == 0 ? "" : ($b == 1 ? "+sin(x)" : "+$b*sin(x)"))
           . ($c > 0 ? "-$c" : ($c < 0 ? "+" . (-$c) : "")));
        &outstd($ans[0], "decsolvn", $A, "");
        if ( length($ans[1]) > 0) {
            &outstd($ans[1], "decsolv", $A, "");
        }

    } elsif ($opt eq "=6=") { # A201741 ff.
        ($opt, $a, $b, $c, @ans) = map { s{nnnn}{}; $_ } split(/\t/, $line, -7);
        push(@ans, "", ""); # ensure 3 A-numbers
        # For some choices of a, b, c, there is a unique value of x satisfying a*x^2 + b*x+c = e^x,
        # for other choices, there are two solutions, and for others, three.
        $A = (($a != 1 ? "$a*" : "") . "x^2"
           . ($b == 0 ? "" : ($b == 1 ? "+x" : "+$b*x"))
           . ($c > 0 ? "+$c" : ($c < 0 ? $c : ""))
           . "-exp(x)");
        &outstd($ans[0], "decsolv" . (length($ans[1]) > 0 ? "n" : ""), $A, "");
        if ( length($ans[1]) > 0) {
            &outstd($ans[1], "decsolv" . (length($ans[2]) > 0 ? "n" : ""), $A, "");
        }
        if ( length($ans[2]) > 0) {
            &outstd($ans[2], "decsolv", $A, "");
        }

    } elsif ($opt eq "=7=") { # A201280 ff.
        ($opt, $a, $c, @ans) = map { s{nnnn}{}; $_ } split(/\t/, $line, -4);
        # For many choices of a and c, there is exactly one x satisfying a*x^2 + c = cot(x) and 0 < x < Pi.
        $A = ("$a*x^2"
           . ($c > 0 ? "+$c" : ($c < 0 ? "$c" : "")) . "-cot(x)");
        $A =~s{(\D|\A)1\*}{$1}g;
        &outstd($ans[0], "decsolv", $A, "");

    } elsif ($opt eq "=8=") { # A199170 ff.
        ($opt, $a, $b, $c, @ans) = map { s{nnnn}{}; $_ } split(/\t/, $line, -6);
        # For many choices of a,b,c, there are exactly two numbers x satisfying a*x^2 + b*x*cos(x) = c.
        $A = (($a != 1 ? "$a*" : "") . "x^2"
           . ($b == 0 ? "" : ($b == 1 ? "+" : "+$b*") . "x*cos(x)-$c"));
        $A =~s{(\D|\A)1\*}{$1}g;
        &outstd($ans[0], "decsolvn", $A, "");
        &outstd($ans[1], "decsolv",  $A, "");

    } elsif ($opt eq "=9=") { # A199949 ff.
        ($opt, $a, $b, $c, @ans) = map { s{nnnn}{}; $_ } split(/\t/, $line, -6);
        my $cn = - $c;
        # For many choices of a,b,c, there are exactly two numbers x>0 satisfying a*x^2 + b*cos(x) = c*sin(x).
        $A = ("$a*x^2"
           . ($b  == 0 ? "" : (($b  > 0 ? "+" : "") .  "$b*cos(x)"))
           . ($cn == 0 ? "" : (($cn > 0 ? "+" : "") . "$cn*sin(x)")));
        $A =~s{(\D|\A)1\*}{$1}g;
        &outstd($ans[0], "decsolv" . ($b < 0 ? "n" : ""),  $A, "");
        &outstd($ans[1], "decsolv",  $A, "");

    } elsif ($opt eq "=a=") { # A201564 ff.
        ($opt, $a, $c, @ans) = map { s{nnnn}{}; $_ } split(/\t/, $line, -5);
        # For many choices of a and c, there are exactly two values of x satisfying a*x^2 + c = csc(x) and 0 < x < Pi.
        $A = ("$a*x^2"
           . ($c  == 0 ? "" :  ($c  > 0 ? "+" : "") . $c) . "-csc(x)");
        $A =~s{(\D|\A)1\*}{$1}g;
        &outstd($ans[0], "decsolv",  $A, "");
        &outstd($ans[1], "decsolv",  $A, "");

    } elsif ($opt eq "=b=") { # A202320 ff.
        ($opt, $a, $b, @ans) = map { s{nnnn}{}; $_ } split(/\t/, $line, -5);
        # For many choices of a and b, there is just one x < 0 and one x > 0 satisfying a*x + b = exp(x).
        $A = ("$a*x"
           . (($b eq 0) ? "" :  (($b !~ m{\A\-}) ? "+" : "") . $b) . "-exp(x)");
        $A =~s{(\D|\A)1\*}{$1}g;
        &outstd($ans[0], "decsolvn", $A, "");
        &outstd($ans[1], "decsolv",  $A, "");

    } elsif ($opt eq "=c=") { # A199597 ff.
        ($opt, $a, $b, $c, @ans) = map { s{nnnn}{}; $_ } split(/\t/, $line, -6);
        my $cn = - $c;
        # For many choices of a,b,c, there is exactly one x>0 satisfying a*x^2+b*x*sin(x)=c*cos(x).
        $A = ("$a*x^2"
           . ($b  == 0 ? "" : (($b  > 0 ? "+" : "") . "$b*x*cos(x)"))
           . ($cn == 0 ? "" : (($cn > 0 ? "+" : "") . "$cn*sin(x)")));
        $A =~s{(\D|\A)1\*}{$1}g;
        if ( defined($ans[1])) {
            &outstd($ans[0], "decsolvn", $A, "");
            &outstd($ans[1], "decsolv",  $A, "");
        } else {
            &outstd($ans[0], "decsolv",  $A, "");
        }

    } elsif ($opt eq "=d=") { # A197737
        ($opt, $a, $b, $c, @ans) = map { s{nnnn}{}; $_ } split(/\t/, $line, -6);
        my $cn = - $c;
        # For many choices of a,b,c, there are exactly two numbers x having a*x^2 + b*x = c*cos(x).
        $A = ("$a*x^2"
           . ($b  == 0 ? "" : (($b  > 0 ? "+" : "") . "$b*x"))
           . ($cn == 0 ? "" : (($cn > 0 ? "+" : "") . "$cn*cos(x)")));
        $A =~s{(\D|\A)1\*}{$1}g;
        if ( defined($ans[1])) {
            &outstd($ans[0], "decsolvn", $A, "");
            &outstd($ans[1], "decsolv",  $A, "");
        } else {
            &outstd($ans[0], "decsolv",  $A, "");
        }

    } elsif ($opt eq "=e=") { # A198755
        ($opt, $a, $b, $c, @ans) = map { s{nnnn}{}; $_ } split(/\t/, $line, -6);
        my $cn = - $c;
        # For many choices of a,b,c, there is a unique x>0 satisfying a*x^2 + b*cos(x) = c.
        $A = ("$a*x^2"
           . ($b  == 0 ? "" : (($b  > 0 ? "+" : "") . "$b*cos(x)"))
           . ($cn == 0 ? "" : (($cn > 0 ? "+" : "") . "$cn")));
        $A =~s{(\D|\A)1\*}{$1}g;
        if ( defined($ans[1])) {
            &outstd($ans[0], "decsolvn", $A, "");
            &outstd($ans[1], "decsolv",  $A, "");
        } else {
            &outstd($ans[0], "decsolv",  $A, "");
        }

    } elsif ($opt eq "=f=") { # A200338
        ($opt, $a, $b, $c, @ans) = map { s{nnnn}{}; $_ } split(/\t/, $line, -6);
        my $cn = - $c;
        # For many choices of a,b,c, there is exactly one x satisfying a*x^2 + b*x + c = tan(x) and 0 < x < Pi/2.
        $A = ("$a*x^2"
           . ($b  == 0 ? "" : (($b  > 0 ? "+" : "") . "$b*x"))
           . ($c  == 0 ? "" : (($c  > 0 ? "+" : "") . "$c")) . "-tan(x)");
        $A =~s{(\D|\A)1\*}{$1}g;
        if ( defined($ans[1])) {
            &outstd($ans[0], "decsolvn", $A, "");
            &outstd($ans[1], "decsolv",  $A, "");
        } else {
            &outstd($ans[0], "decsolv",  $A, "");
        }

    } elsif ($opt eq "=g=") { # A200614
        ($opt, $a, $c, @ans) = map { s{nnnn}{}; $_ } split(/\t/, $line, -5);
        my $cn = - $c;
        # For many choices of a and c, there are exactly two values of x satisfying a*x^2 - c = tan(x) and 0 < x < Pi/2;
        # for other choices, there is exactly once such value.
        $A = ("$a*x^2"
           . ($cn == 0 ? "" : (($cn > 0 ? "+" : "") . "$cn")) . "-tan(x)");
        $A =~s{(\D|\A)1\*}{$1}g;
        &outstd($ans[0], "decsolv",  $A, "");

    } elsif ($opt eq "=h=") { # A201397
        ($opt, $a, $c, @ans) = map { s{nnnn}{}; $_ } split(/\t/, $line, -5);
        my $cn = - $c;
        # For many choices of a and c, there are exactly two values of x satisfying a*x^2 + c = sec(x) and 0 < x < Pi.
        $A = ("$a*x^2"
           . ($c  == 0 ? "" : (($c  > 0 ? "+" : "") . "$c")) . "-sec(x)");
        $A =~s{(\D|\A)1\*}{$1}g;
        &outstd($ans[0], "decsolv",  $A, "");

    } elsif ($opt eq "=i=") { # A201939
        ($opt, $a, $c, @ans) = map { s{nnnn}{}; $_ } split(/\t/, $line, -5);
        my $cn = - $c;
        # For many choices of u and v, there is exactly one x>0 satisfying x*cosh(u*x) = v.
        $A =  "x*cosh($a*x) - $c";
        $A =~s{(\D|\A)1\*}{$1}g;
        &outstd($ans[0], "decsolv",  $A, "");

    } elsif ($opt eq "=j=") { # A197739
        ($opt, $b, $c, @ans) = map { s{nnnn}{}; $_ } split(/\t/, $line, -10);
        my $cn = - $c;
        # nyi
        &outstd($ans[0], "decsolv",  $A, "");

    } elsif ($opt eq "=k=") { # A305328
        my ($v, $w, $d);
        ($opt, $v, $w, $d, $A, @ans) = map { s{nnnn}{}; $_ } split(/\t/, $line, -8);
        &outstd($ans[0], "decsolv",  $A, "");
        &outstd($ans[1], "decsolv",  $A, "");
        &outstd($ans[2], "decsolv",  $A, "");

    } elsif ($opt eq "=A=") { # A329825
        my ($t, $r);
        ($opt, $t, $ans[0], $ans[1], $r) = map { s{nnnn}{}; $_ } split(/\t/, $line, -5);
        my $b1 = "n*($r)";
        my $b2 = "n*($r+($t))";
        &outstd($ans[0], "floor", $b1, $b1);
        &outstd($ans[1], "floor", $b2, $b2);

    } elsif ($opt eq "=B=" && length($line) > 3) { # Beatty sequences A184618 etc.
        # r=2^(3/2)-1; h=-1/2; s=r/(r-1);
        # Table[Floor[n*r+h], {n, 1, 120}]  (* A184736 *)
        # Table[Floor[n*s+h-h*s], {n, 1, 120}] (* A184737 *)
        my ($h, $r);
        ($opt, $h, $r, @ans) = map { s{nnnn}{}; $_ } split(/\t/, $line, -5);
        my $b1 = &polish("n*($r)+$h");
        my $b2 = &polish("(n-$h)*($r)/($r-1)+$h");
        &outstd($ans[0], "floor", $b1, $ans[1]);
        &outstd($ans[1], "floor", $b2, $ans[0]);

    } elsif ($opt eq "=C=" && length($line) > 3) { # s(n)-Wythoff A184618 etc.
        # k=3; r=-1; d=sqrt(4+$k^2);
        # a[n_]:=Floor[(1/2)(d+2-k)(n+r/(d+2))]; (* A184478 *)
        # b[n_]:=Floor[(1/2)(d+2+k)(n-r/(d+2))]; (* A184479 *)
        my ($k, $r);
        ($opt, $k, $r, @ans) = map { s{nnnn}{}; $_ } split(/\t/, $line, -5);
        # $r = - $r; # invert the sign in the MMAs?
        my $b1 = &polish("(sqrt(4+$k^2)+2-$k)*(n-$r/(sqrt(4+$k^2)+2))/2");
        my $b2 = &polish("(sqrt(4+$k^2)+2+$k)*(n+$r/(sqrt(4+$k^2)+2))/2");
        &outstd($ans[0], "floor", $b1, $ans[1]);
        &outstd($ans[1], "floor", $b2, $ans[0]);

    }
} # while <DATA>
print STDERR "COMMIT;\n";
#----
sub polish {
    my ($expr) = @_;
    $expr =~ s{\+\-}{\-}g;
    $expr =~ s{\-\-}{\+}g;
    return $expr;
} # sub polish
#----
sub outstd {
    my ($aseqno, $callcode, $expr1, $expr2) = @_;
    $expr1 =~ s{ }{}g;
    $expr2 =~ s{ }{}g;
    if ($aseqno =~ m{\AA[0-9]}) {
        print join("\t", $aseqno, $callcode, 0, "~~$expr1", $expr2, 0, 0, $expr1) . "\n";
    }
} # outstd
#----
sub outerr {
    my ($aseqn1, $aseqn0) = @_;
    print STDERR "UPDATE seq4 s1 SET s1.parm3 = (SELECT s0.parm3  FROM seq4 s0 WHERE s0.aseqno = \'$aseqn0\') "
     .                           ", s1.offset = (SELECT s0.offset FROM seq4 s0 WHERE s0.aseqno = \'$aseqn0\') "
     . " WHERE s1.aseqno = \'$aseqn1\';\n";
} # outerr
__DATA__
#--------------------------------
    k    r
=C=	1	 1 	A026273	A026274
=C=	1	 0 	A000201	A001950
=C=	2	 1	A184117	A184118
=C=	2	 0	A001951	A001952
=C=	2	-1	A136119	A184119
=C=	3	 1	A184478	A184479
=C=	3	 0	A184480	A001956
=C=	3	-1	A184482	A184483
=C=	3	-2	A184484	A184485
=C=	4	 1	A184486	A184487
=C=	4	 0	A001961	A001962
=C=	4	-1	A184514	A184515
=C=	4	-2	A184516	A184517
=C=	4	-3	A184518	A184519
=C=	5	 1	A184520	A184521
=C=	5	 0	A184522	A184523
=C=	5	-1	A184524	A184525
=C=	5	-2	A184526	A184527
=C=	5	-3	A184528	A184529
=C=	5	-4	A184530	A184531
#--------------------------------
# Caution, the following guide B is generated by ck_guide_B.pl!

# r=2^(3/2)-1; h=-1/2; s=r/(r-1);
# Table[Floor[n*r+h], {n, 1, 120}]  (* A184736 *)
# Table[Floor[n*s+h-h*s], {n, 1, 120}] (* A184737 *)
#    h         r            Beattyr Beattys
=B=	1/3   	sqrt(2)     	A184618	A184619
=B=	1/4   	sqrt(2)     	A184620	A184621
=B=	-1/3  	sqrt(2)     	A184622	A184623
=B=	-1/4  	sqrt(2)     	A184624	A184625
=B=	1/4   	sqrt(3)     	A184626	A184627
=B=	-1/2  	sqrt(3)     	A184638	A184653
=B=	-2/3  	sqrt(3)     	A184654	A184655
=B=	-1/2  	phi         	A184656	A184657
=B=	-1/3  	phi         	A184658	A184659
=B=	-1/4  	phi         	A184732	A184733
=B=	1/3   	phi         	A184734	A184735
=B=	-1/2  	-1+2*sqrt(2)	A184736	A184737
=B=	1/2   	-1+sqrt(5)  	A184738	A184739
=B=	-1/2  	e-1         	A184740	A184741
=B=	-1/2  	sqrt(Pi)    	A184742	A184743
=B=	1/2   	1+1/e       	A184744	A184745
=B=	1/2   	1+1/sqrt(5) 	A184746	A184747
=B=	-1/2  	4-sqrt(5)   	A184748	A184749
#--------------------------------
A329825		Beatty sequence for (3+sqrt(17))/4.
More generally, suppose that t > 0.
There exists an irrational number r such that (floor(n*r)) and (floor(n(r+t)) are a pair of Beatty sequences.
Specifically, r = (2 - t + sqrt(t^2 + 4))/2, as in the Mathematica code below.  See Comments at A182760.
************
Guide to related sequences:
=A=	1	A000201	A001950	(sqrt(  5)+1)/2
=A=	1/2	A329825	A329826	(sqrt( 17)+3)/4
=A=	1/3	A329827	A329828	(sqrt( 37)+5)/6
=A=	2/3	A329829	A329830	(sqrt( 10)+2)/3
=A=	1/4	A329831	A329832	(sqrt( 65)+7)/8
=A=	3/4	A329833	A329834	(sqrt( 73)+5)/8
=A=	1/5	A329835	A329836	(sqrt(101)+9)/10
=A=	2/5	A329837	A329838	(sqrt( 26)+4)/5
=A=	5/2	A329839	A329840	(sqrt( 41)-1)/4
=A=	3/5	A329841	A329842	(sqrt(109)+7)/10
=A=	5/3	A329843	A329844	(sqrt( 61)+1)/6
=A=	5/4	A329847	A329848	(sqrt( 89)+3)/8		exchange 46/48
=A=	4/5	A329845	A329846	(sqrt( 29)+3)/5		exchange 45/47
=A=	6/5	A329923	A329924	(sqrt( 34)+2)/5
=A=	8/5	A329925	A329926	(sqrt( 41)+1)/5
=A=	2	A001951	A001952	(sqrt(  2)  )
=A=	3	A001961	A004976	(sqrt(  5)-1)		was A188480	A001956
=A=	4	A001961	A001962	(sqrt(  5)-1)
=A=	5	A184522	A184523	(sqrt( 29)-3)/2
=A=	6	A187396	A187395	(sqrt( 10)-2)
#--------------------------------
A198745		Decimal expansion of the absolute minimum of f(x)+f(2x), where f(x)=sin(x)-cos(x).		10
Let f(x)=sin(x)+cos(x) and g(x)=f(x)+f(2x)+...+f(nx), where n>=2.  Then f(x) attains an absolute minimum at some x between 0 and 2*pi.  Guide to related sequences (including graphs in Mathematica programs):
n....x.........minimum of f(x)
=r=	2	A198745	A198746
=r=	3	A198747	A198748
=r=	4	A198749	A198750
=r=	5	A198751	A198752
=r=	6	A198753	A198754
#--------------------------------
A198735		Decimal expansion of the absolute minimum of f(x)+f(2x), where f(x)=sin(x)+cos(x).		10
Let f(x)=sin(x)+cos(x) and g(x)=f(x)+f(2x)+...+f(nx), where n>=2.  Then f(x) attains an absolute minimum at some x between 0 and 2*pi.  Guide to related sequences (including graphs in Mathematica programs):
n....x.........minimum of f(x)
=q=	2	A198735	A198736
=q=	3	A198737	A198738
=q=	4	A198739	A198740
=q=	5	A198741	A198742
=q=	6	A198743	A198744
#--------------------------------
A198677		Decimal expansion of the absolute minimum of sin(x)+sin(2x).		10
The function f(x)=sin(x)+sin(2x)+...+sin(nx), where n>=2, attains an absolute minimum, m, at some c between 0 and 2*pi.  The absolute maximum, -m, occurs at 2*pi-c. Guide to related sequences (including graphs in Mathematica programs):
n....x.........minimum of f(x)
=p=	2	A198677	A198678
=p=	3	A198679	A198728
=p=	4	A198729	A198730
=p=	5	A198731	A198732
=p=	6	A198733	A198734
#--------------------------------
A196361
    n      x     min(f(x))
=o=	2	A140244	nnnn   	 -9/8
=o=	3	A198670	A198361
=o=	4	A198672	A198671
=o=	5	A198674	A198673
=o=	6	A198676	A198675
#--------------------------------
A197008
    h...k...........d
=n=	1	2....	A197008
=n=	1	3....	A197012
=n=	1	4....	A197013
=n=	2	3....	A196014
=n=	1	e....	A196015
=n=	1	sqrt(2)	A196031
#--------------------------------
A195304
    a....   b...    c.......(A).....(B).....(C)...  Philo(ABC,G)
=m=	3....	4....	5...	A195304	A195305	A105306	A195411
=m=	5....	12...	13..	A195412	A195413	A195414	A195424
=m=	7....	24...	25..	A195425	A195426	A195427	A195428
=m=	8....	15...	17..	A195429	A195430	A195431	A195432
=m=	1....	1....	r'2.	A195433	nnnn	A195433	A195436
=m=	1....	2....	r'5.	A195434	A195435	A195444	A195445
=m=	1....	3....	r'10	A195446	A195447	A195448	A195449
=m=	2....	3....	r'13	A195450	A195451	A195452	A195453
=m=	r'2..	r'3..	r'5.	A195454	A195455	A195456	A195457
=m=	1....	r'2..	r'3.	A195471	A195472	A195473	A195474
=m=	1....	r'3..	2...	A195475	A195476	A195477	A195478
=m=	2....	r'5..	3...	A195479	A195480	A195481	A195482
=m=	r'2..	r'5..	r'7.	A195483	A195484	A195485	A195486
=m=	r'7..	3....	4...	A195487	A195488	A195489	A195490
=m=	1....	r't..	t...	A195491	A195492	A195493	A195494
=m=	phi-1	phi 	r'3 	A195495	A195496	A195497	A195498
#--------------------------------
A193010 ???
=l=	exp(x)       	A193010	A098689
=l=	exp(-x)..    	A193026	A099935
=l=	exp(2*x).    	A193027	A193028
=l=	exp(x/2).    	A193029	A193030
=l=	sin(x)...    	A193011	A193012
=l=	cos(x....    	A193013	A193014
=l=	sinh(x)..    	A193015	A193016
=l=	cosh(x)..    	A193017	A193025
=l=	2^x......    	A193031	A193032
=l=	2^(-x)...    	A193009	A193035
=l=	3^x......    	A193083	A193084
=l=	phi^x....    	A193075	A193076
=l=	phi^(-x).    	A193077	A193078
=l=	sinh(2*x)    	A193079	A193080
=l=	cosh(2*x)    	A193081	A193082
=l=	exp(x)*cos(x)	A193083	A193084
=l=	exp(x)*sin(x)	A193085	A193086
=l=	cos(x)^2     	A193087	A193088
=l=	sin(x)^2     	A193089	A193088
#--------------------------------
A305328
the roots of the following cubic polynomial: p(u,v,w,d) = d x^3 + (d v + d w - 3) x^2 + (d v w - 2 v - 2 w) x - v w.
    v   w   d   p(u,v,w,d)              least   middle  greatest
=k=	1	2	1	x^3-4*x-2           	A305328	A305327	A305326
=k=	1	3	1	x^3+x^2-5*x-3       	A316131	A316132	A316133
=k=	2	3	1	x^3+2*x^2-4*x-6     	A316134	A316135	A316136
=k=	2	4	1	x^3+3*x^2-4*x-8     	A316137	A316138	A316139
=k=	1	2	2	2*x^3+3*x^2-2*x-2   	A316161	A316162	A316163	2*x^3 + 3*x^2 - 2*x - 2
=k=	1	3	2	2*x^3+5*x^2-2*x-3   	A316164	A316165	A316166
=k=	2	4	2	2*x^3+9*x^2+4*x-8   	A316167	A316168	A316169	was 2*x^3+9*x^2-4*x-3
=k=	1	2	3	3*x^3+6*x^2-2       	A316246	A316247	A316248
=k=	1	3	3	3*x^3+9*x^2+x-3     	A316249	A316250	A316251
=k=	2	3	3	3*x^3+12*x^2+8*x-6  	A316252	A316253	A316254
=k=	2	4	3	3*x^3+15*x^2+12*x-8 	A316255	A316256	A316257
=k=	3	4	3	3*x^3+18*x^2+22*x-12	A316258	A316259	A316260
#--------------------------------
A197739
    b   c
=j=	1	2   	A195700	nnnn	A197589	A197591	A019670	A197592
=j=	1	3   	A197739	A197588	A197590	A197755	A003881	A197488
=j=	1	4   	A197758	A197759	A197760	A197761	nnnn	A003881
=j=	1	Pi  	A197821	A197822	A197823	A197824	A197726	A197826
=j=	1	2*Pi	A197827	A197828	A197829	A197830	A197700	A197832
=j=	1	3*Pi	A197833	A197834	A197835	A197836	A197837	A197838
#--------------------------------
For many choices of u and v, there is exactly one x>0 satisfying x*cosh(u*x)=v.
A201939
    u.. v.... x
=i=	1	1	A069814
=i=	1	2	A201939
=i=	1	3	A201943
=i=	2	1	A201944
=i=	3	1	A201945
=i=	2	2	A202283
#--------------------------------
A201397
For many choices of a and c, there are exactly two values of x satisfying a*x^2 + c = sec(x) and 0 < x < Pi.
    a. . c.... x
=h=	1.	 1.	A196816
=h=	1.	 2.	A201397
=h=	1.	 3.	A201398
=h=	1.	 4.	A201399
=h=	1.	 5.	A201400
=h=	1.	 6.	A201401
=h=	1.	 7.	A201402
=h=	1.	 8.	A201403
=h=	1.	 9.	A201404
=h=	1.	 10	A201405
=h=	2.	 0.	A201406	A201407
=h=	3.	 0.	A201408	A201409
=h=	4.	 0.	A201410	A201411
=h=	5.	 0.	A201412	A201413
=h=	6.	 0.	A201414	A201415
=h=	7.	 0.	A201416	A201417
=h=	8.	 0.	A201418	A201419
=h=	9.	 0.	A201420	A201421
=h=	10	 0.	A201422	A201423
=h=	3.	-1.	A201515	A201516
=h=	4.	-1.	A201517	A201518
=h=	5.	-1.	A201519	A201520
=h=	6.	-1.	A201521	A201522
=h=	7.	-1.	A201523	A201524
=h=	8.	-1.	A201525	A201526
=h=	9.	-1.	A201527	A201528
=h=	10	-1.	A201529	A201530
=h=	2.	 3.	A201531
=h=	3.	 2.	A200619
#--------------------------------
For many choices of a and c, there are exactly two values of x satisfying a*x^2 - c = tan(x) and 0 < x < Pi/2; for other choices, there is exactly once such value.
A200614
    a... c.... x
=g=	3.	 1.	A200614	A200615
=g=	4.	 1.	A200616	A200617
=g=	5.	 1.	A200620	A200621
=g=	5.	 2.	A200622	A200623
=g=	5.	 3.	A200624	A200625
=g=	5.	 4.	A200626	A200627
=g=	5.	-1.	A200628
=g=	5.	-2.	A200629
=g=	5.	-3.	A200630
=g=	5.	-4.	A200631
=g=	6.	 1.	A200633	A200634
=g=	6.	 5.	A200635	A200636
=g=	6.	-1.	A200637
=g=	6.	-5.	A200638
=g=	1.	-5.	A200239
=g=	2.	-5.	A200240
=g=	3.	-5.	A200241
=g=	4.	-5.	A200242
=g=	2.	 0.	A200679	A200680
=g=	3.	 0.	A200681	A200682
=g=	4.	 0.	A200683	A200684
=g=	5.	 0.	A200618
=g=	6.	 0.	A200632
=g=	7.	 0.	A200643
=g=	8.	 0.	A200644
=g=	9.	 0.	A200645
=g=	10	 0.	A200646
=g=	-1	 1.	A200685
=g=	-1	 2.	A200686
=g=	-1	 3.	A200687
=g=	-1	-4.	A200688		was -1,4
=g=	-1	 5.	A200689
=g=	-1	 6.	A200690
=g=	-1	-7.	A200691		was -1,7
=g=	-1	 8.	A200692
=g=	-1	 9.	A200693
=g=	-1	 10	A200694
=g=	-2	 1.	A200695
=g=	-2	 3.	A200696
=g=	-3	 1.	A200697
=g=	-3	 2.	A200698
=g=	-4	 1.	A200699
=g=	-5	 1.	A200700
=g=	-6	 1.	A200701
=g=	-7	 1.	A200702
=g=	-8	 1.	A200703
=g=	-9	 1.	A200704
=g=	-1	 1.	A200705
#--------------------------------
A200338
For many choices of a,b,c, there is exactly one x satisfying a*x^2 + b*x + c = tan(x) and 0 < x < Pi/2.
    a.... b..c.... x
=f=	1	. 0	 1	A200338
=f=	1	. 0	 2	A200339
=f=	1	. 0	 3	A200340
=f=	1	. 0	 4	A200341
=f=	1	. 1	 1	A200342
=f=	1	. 1	 2	A200343
=f=	1	. 1	 3	A200344
=f=	1	. 1	 4	A200345
=f=	1	. 2	 1	A200346
=f=	1	. 2	 2	A200347
=f=	1	. 2	 3	A200348
=f=	1	. 2	 4	A200349
=f=	1	. 3	 1	A200350
=f=	1	. 3	 2	A200351
=f=	1	. 3	 3	A200352
=f=	1	. 3	 4	A200353
=f=	1	. 4	 1	A200354
=f=	1	. 4	 2	A200355
=f=	1	. 4	 3	A200356
=f=	1	. 4	 4	A200357
=f=	2	. 0	 1	A200358
=f=	2	. 0	 3	A200359
=f=	2	. 1	 1	A200360
=f=	2	. 1	 2	A200361
=f=	2	. 1	 3	A200362
=f=	2	. 1	 4	A200363
=f=	2	. 2	 1	A200364
=f=	2	. 2	 3	A200365
=f=	2	. 3	 1	A200366
=f=	2	. 3	 2	A200367
=f=	2	. 3	 3	A200368
=f=	2	. 3	 4	A200369
=f=	2	. 4	 1	A200382
=f=	2	. 4	 3	A200383
=f=	3	. 0	 1	A200384
=f=	3	. 0	 2	A200385
=f=	3	. 0	 4	A200386
=f=	3	. 1	 1	A200387
=f=	3	. 1	 2	A200388
=f=	3	. 1	 3	A200389
=f=	3	. 1	 4	A200390
=f=	3	. 2	 1	A200391
=f=	3	. 2	 2	A200392
=f=	3	. 2	 3	A200393
=f=	3	. 2	 4	A200394
=f=	3	. 3	 1	A200395
=f=	3	. 3	 2	A200396
=f=	3	. 3	 4	A200397
=f=	3	. 4	 1	A200398
=f=	3	. 4	 2	A200399
=f=	3	. 4	 3	A200400
=f=	3	. 4	 4	A200401
=f=	4	. 0	 1	A200410
=f=	4	. 0	 3	A200411
=f=	4	. 1	 1	A200412
=f=	4	. 1	 2	A200413
=f=	4	. 1	 3	A200414
=f=	4	. 1	 4	A200415
=f=	4	. 2	 1	A200416
=f=	4	. 2	 3	A200417
=f=	4	. 3	 1	A200418
=f=	4	. 3	 2	A200419
=f=	4	. 3	 3	A200420
=f=	4	. 3	 4	A200421
=f=	4	. 4	 1	A200422
=f=	4	. 4	 3	A200423
=f=	1	 -1	 1	A200477
=f=	1	 -1	 2	A200478
=f=	1	 -1	 3	A200479
=f=	1	 -1	 4	A200480
=f=	1	 -2	 1	A200481
=f=	1	 -2	 2	A200482
=f=	1	 -2	 3	A200483
=f=	1	 -2	 4	A200484
=f=	1	 -3	 1	A200485
=f=	1	 -3	 2	A200486
=f=	1	 -3	 3	A200487
=f=	1	 -3	 4	A200488
=f=	1	 -4	 1	A200489
=f=	1	 -4	 2	A200490
=f=	1	 -4	 3	A200491
=f=	1	 -4	 4	A200492
=f=	2	 -1	 1	A200493
=f=	2	 -1	 2	A200494
=f=	2	 -1	 3	A200495
=f=	2	 -1	 4	A200496
=f=	2	 -2	 1	A200497
=f=	2	 -2	 3	A200498
=f=	2	 -3	 1	A200499
=f=	2	 -3	 2	A200500
=f=	2	 -3	 3	A200501
=f=	2	 -3	 4	A200502
=f=	2	 -4	 1	A200584
=f=	2	 -4	 3	A200585
=f=	2	 -1	 2	A200586
=f=	2	 -1	 3	A200587
=f=	2	 -1	 4	A200588
=f=	3	 -2	 1	A200589
=f=	3	 -2	 2	A200590
=f=	3	 -2	 3	A200591
=f=	3	 -2	 4	A200592
=f=	3	 -3	 1	A200593
=f=	3	 -3	 2	A200594
=f=	3	 -3	 4	A200595
=f=	3	 -4	 1	A200596
=f=	3	 -4	 2	A200597
=f=	3	 -4	 3	A200598
=f=	3	 -4	 4	A200599
=f=	4	 -1	 1	A200600
=f=	4	 -1	 2	A200601
=f=	4	 -1	 3	A200602
=f=	4	 -1	 4	A200603
=f=	4	 -2	 1	A200604
=f=	4	 -2	 3	A200605
=f=	4	 -3	 1	A200606
=f=	4	 -3	 2	A200607
=f=	4	 -3	 3	A200608
=f=	4	 -3	 4	A200609
=f=	4	 -4	 1	A200610
=f=	4	 -4	 3	A200611
#--------------------------------
A198755
For many choices of a,b,c, there is a unique x>0 satisfying a*x^2+b*cos(x)=c.
    a... b.. c..... x
=e=	1	 1	 2	A198755
=e=	1	 1	 3	A198756
=e=	1	 1	 4	A198757
=e=	1	 2	 3	A198758
=e=	1	 2	 4	A198811
=e=	1	 3	 3	A198812
=e=	1	 3	 4	A198813
=e=	1	 4	 3	A198814
=e=	1	 4	 4	A198815
=e=	1	 1	 0	A125578
=e=	1	-1	 1	A198816
=e=	1	-1	 2	A198817
=e=	1	-1	 3	A198818
=e=	1	-1	 4	A198819
=e=	1	-2	 1	A198821
=e=	1	-2	 2	A198822
=e=	1	-2	 3	A198823
=e=	1	-2	 4	A198824
=e=	1	-2	-1	A198825
=e=	1	-3	 0	A197807
=e=	1	-3	 1	A198826
=e=	1	-3	 2	A198828
=e=	1	-3	 3	A198829
=e=	1	-3	 4	A198830
=e=	1	-3	-1	A198835
=e=	1	-3	-2	A198836
=e=	1	-4	 0	A197808
=e=	1	-4	 1	A198838
=e=	1	-4	 2	A198839
=e=	1	-4	 3	A198840
=e=	1	-4	 4	A198841
=e=	1	-4	-1	A198842
=e=	1	-4	-2	A198843
=e=	1	-4	-3	A198844
=e=	2	 0	 1	A010503
=e=	2	 0	 3	A115754
=e=	2	 1	 2	A198820
=e=	2	 1	 3	A198827
=e=	2	 1	 4	A198837
=e=	2	 2	 3	A198869
=e=	2	 3	 4	A198870
=e=	2	-1	 1	A198871
=e=	2	-1	 2	A198872
=e=	2	-1	 3	A198873
=e=	2	-1	 4	A198874
=e=	2	-2	-1	A198875
=e=	2	-2	 3	A198876
=e=	2	-3	-2	A198877
=e=	2	-3	-1	A198878
=e=	2	-3	 1	A198879
=e=	2	-3	 2	A198880
=e=	2	-3	 3	A198881
=e=	2	-3	 4	A198882
=e=	2	-4	-3	A198883
=e=	2	-4	-1	A198884
=e=	2	-4	 1	A198885
=e=	2	-4	 3	A198886
=e=	3	 0	 1	A020760
=e=	3	 1	 2	A198868
=e=	3	 1	 3	A198917
=e=	3	 1	 4	A198918
=e=	3	 2	 3	A198919
=e=	3	 2	 4	A198920
=e=	3	 3	 4	A198921
=e=	3	-1	 1	A198922
=e=	3	-1	 2	A198924
=e=	3	-1	 3	A198925
=e=	3	-1	 4	A198926
=e=	3	-2	-1	A198927
=e=	3	-2	 1	A198928
=e=	3	-2	 2	A198929
=e=	3	-2	 3	A198930
=e=	3	-2	 4	A198931
=e=	3	-3	-1	A198932
=e=	3	-3	 1	A198933
=e=	3	-3	 2	A198934
=e=	3	-3	 4	A198935
=e=	3	-4	-3	A198936
=e=	3	-4	-2	A198937
=e=	3	-4	-1	A198938
=e=	3	-4	 1	A198939
=e=	3	-4	 2	A198940
=e=	3	-4	 3	A198941
=e=	3	-4	 4	A198942
=e=	4	 1	 2	A198923
=e=	4	 1	 3	A198983
=e=	4	 1	 4	A198984
=e=	4	 2	 3	A198985
=e=	4	 3	 4	A198986
=e=	4	-1	 1	A198987
=e=	4	-1	 2	A198988
=e=	4	-1	 3	A198989
=e=	4	-1	 4	A198990
=e=	4	-2	-1	A198991
=e=	4	-2	 1	A198992
=e=	4	-2	-3	A198993
=e=	4	-3	-2	A198994
=e=	4	-3	-1	A198995
=e=	4	-2	 1	A198996
=e=	4	-3	 2	A198997
=e=	4	-3	 3	A198998
=e=	4	-3	 4	A198999
=e=	4	-4	-3	A199000
=e=	4	-4	-1	A199001
=e=	4	-4	 1	A199002
=e=	4	-4	 3	A199003
#--------------------------------
A197737
For many choices of a,b,c, there are exactly two numbers x having a*x^2+b*x=cos(x).
    a... b...c. x
=d=	1	 0	 1	A125578
=d=	1	 0	 2	A197806
=d=	1	 0	 3	A197807
=d=	1	 0	 4	A197808
=d=	1	 1	 1	A197737	A197738
=d=	1	 1	 2	A197809	A197810
=d=	1	 1	 3	A197811	A197812
=d=	1	 1	 4	A197813	A197814
=d=	1	-2	-1	A197815	A197820
=d=	1	-3	-1	A197825	A197831
=d=	1	-4	-1	A197839	A197840
=d=	1	 2	 1	A197841	A197842
=d=	1	 2	 2	A197843	A197844
=d=	1	 2	 3	A197845	A197846
=d=	1	 2	 4	A197847	A197848
=d=	1	-2	-2	A197849	A197850
=d=	1	-3	-2	A198098	A198099
=d=	1	-4	-2	A198100	A198101
=d=	1	 3	 1	A198102	A198103
=d=	1	 3	 2	A198104	A198105
=d=	1	 3	 3	A198106	A198107
=d=	1	 3	 4	A198108	A198109
=d=	1	-2	-3	A198140	A198141
=d=	1	-3	-3	A198142	A198143
=d=	1	-4	-3	A198144	A198145
=d=	2	 0	 1	A198110
=d=	2	 0	 3	A198111
=d=	2	 1	 1	A198112	A198113
=d=	2	 1	 2	A198114	A198115
=d=	2	 1	 3	A198116	A198117
=d=	2	 1	 4	A198118	A198119
=d=	2	 1	-1	A198120	A198121
=d=	2	-4	-1	A198122	A198123
=d=	2	 2	 1	A198124	A198125
=d=	2	 2	 3	A198126	A198127
=d=	2	 3	 1	A198128	A198129
=d=	2	 3	 2	A198130	A198131
=d=	2	 3	 3	A198132	A198133
=d=	2	 3	 4	A198134	A198135
=d=	2	-4	-3	A198136	A198137
=d=	3	 0	 1	A198211
=d=	3	 0	 2	A198212
=d=	3	 0	 4	A198213
=d=	3	 1	 1	A198214	A198215
=d=	3	 1	 2	A198216	A198217
=d=	3	 1	 3	A198218	A198219
=d=	3	 1	 4	A198220	A198221
=d=	3	 2	 1	A198222	A198223
=d=	3	 2	 2	A198224	A198225
=d=	3	 2	 3	A198226	A198227
=d=	3	 2	 4	A198228	A198229
=d=	3	 3	 1	A198230	A198231
=d=	3	 3	 2	A198232	A198233
=d=	3	 3	 4	A198234	A198235
=d=	3	 4	 1	A198236	A198237
=d=	3	 4	 2	A198238	A198239
=d=	3	 4	 3	A198240	A198241
=d=	3	 4	 4	A198138	A198139
=d=	3	-4	-1	A198345	A198346		was 3,-1,-1
=d=	4	 0	 1	A198347
=d=	4	 0	 3	A198348
=d=	4	 1	 1	A198349	A198350
=d=	4	 1	 2	A198351	A198352
=d=	4	 1	 3	A198353	A198354
=d=	4	 1	 4	A198355	A198356
=d=	4	 2	 1	A198357	A198358
=d=	4	 2	 3	A198359	A198360
=d=	4	 3	 1	A198361	A198362
=d=	4	 3	 2	A198363	A198364
=d=	4	 3	 3	A198365	A198366
=d=	4	 3	 4	A198367	A198368
=d=	4	 4	 1	A198369	A198370
=d=	4	 4	 3	A198371	A198372
=d=	4	-4	-1	A198373	A198374
#--------------------------------
A199597
For many choices of a,b,c, there is exactly one x>0 satisfying a*x^2+b*x*sin(x)=c*cos(x).
    a....b..c.... x
=c=	1	 1	2	A199597
#	had c=1
=c=	1	 1	3	A199598
#	had c=2
=c=	1	 1	4	A199599
# 	had c=3
=c=	1	 2	1	A199600
=c=	1	 2	3	A199601
=c=	1	 2	4	A199602
=c=	1	 3	0	A199603	A199604
=c=	1	 3	1	A199605	A199606
=c=	1	 3	2	A199607	A199608
=c=	1	 3	3	A199609	A199610
=c=	1	 4	0	A199611	A199612
=c=	1	 4	1	A199613	A199614
=c=	1	 4	2	A199615	A199616
=c=	1	 4	3	A199617	A199618
=c=	1	 4	4	A199619	A199620
=c=	2	 1	0	A199621
=c=	2	 1	2	A199622
=c=	2	 1	3	A199623
=c=	2	 1	4	A199624
=c=	2	 2	1	A199625
=c=	2	 2	3	A199661
=c=	3	 1	0	A199662
=c=	3	 1	2	A199663
=c=	3	 1	3	A199664
=c=	3	 1	4	A199665
=c=	3	 2	0	A199666
=c=	3	 2	1	A199667
=c=	3	 2	3	A199668
=c=	3	 2	4	A199669
=c=	1	-1	0	A003957
=c=	1	-1	1	A199722
=c=	1	-1	2	A199721
=c=	1	-1	3	A199720
=c=	1	-1	4	A199719
=c=	1	-2	1	A199726
=c=	1	-2	2	A199725
=c=	1	-2	3	A199724
=c=	1	-2	4	A199723
=c=	1	-3	1	A199730
=c=	1	-3	2	A199729
=c=	1	-3	3	A199728
=c=	1	-3	4	A199727
=c=	1	-4	1	A199737	A199738
# was A199838
=c=	1	-4	2	A199735	A199736
=c=	1	-4	3	A199733	A199734
=c=	1	-4	4	A199731	A199732
=c=	2	-1	1	A199742
=c=	2	-1	2	A199741
=c=	2	-1	3	A199740
=c=	2	-1	4	A199739
=c=	2	-2	1	A199776
=c=	2	-2	3	A199775
=c=	2	-3	1	A199780
=c=	2	-3	2	A199779
=c=	2	-3	3	A199778
=c=	2	-3	4	A199777
=c=	2	-4	1	A199782
=c=	2	-4	3	A199781
=c=	3	-4	1	A199786
=c=	3	-4	2	A199785
=c=	3	-4	3	A199784
=c=	3	-4	4	A199783
=c=	3	-3	1	A199789
=c=	3	-3	2	A199788
=c=	3	-3	4	A199787
=c=	3	-2	1	A199793
=c=	3	-2	2	A199792
=c=	3	-2	3	A199791
=c=	3	-2	4	A199790
=c=	3	-1	1	A199797
=c=	3	-1	2	A199796
=c=	3	-1	3	A199795
=c=	3	-1	4	A199794
=c=	4	-4	1	A199873
=c=	4	-4	3	A199872
=c=	4	-3	1	A199871
=c=	4	-3	2	A199870
=c=	4	-3	3	A199869
=c=	4	-3	4	A199868
=c=	4	-2	1	A199867
=c=	4	-2	3	A199866
=c=	4	-1	1	A199865
=c=	4	-1	2	A199864
=c=	4	-1	3	A199863
=c=	4	-1	4	A199862
#--------------------------------
A202320
For many choices of u and v, there is just one x < 0 and one x > 0 satisfying u*x + v = exp(x).
    u...v.. least x.greatest x
=b=	1	2	A202320	A202321
=b=	1	3	A202324	A202325
=b=	2	1	nnnn	A202343
=b=	3	1	nnnn	A202344
=b=	2	2	A202345	A202346
=b=	1	exp(1)	A202347	A104689
=b=	exp(1)	1	nnnn	A202350
=b=	3	0	A202351	A202352
#--------------------------------
A201564
For many choices of a and c, there are exactly two values of x satisfying a*x^2 + c = csc(x) and 0 < x < Pi.
    a... c .... x
=a=	1..	 1..	A196825	A201563		was A196725
=a=	1..	 2..	A201564	A201565
=a=	1..	 3..	A201566	A201567
=a=	1..	 4..	A201568	A201569
=a=	1..	 5..	A201570	A201571
=a=	1..	 6..	A201572	A201573
=a=	1..	 7..	A201574	A201575
=a=	1..	 8..	A201576	A201577
=a=	1..	 9..	A201579	A201580
=a=	1..	 10.	A201578	A201581
=a=	1..	 0..	A196617	A201582
=a=	2..	 0..	A201583	A201584
=a=	3..	 0..	A201585	A201586
=a=	4..	 0..	A201587	A201588
=a=	5..	 0..	A201589	A201590
=a=	6..	 0..	A201591	A201653
=a=	7..	 0..	A201654	A201655
=a=	8..	 0..	A201656	A201657
=a=	9..	 0..	A201658	A201659
=a=	10.	 0..	A201660	A201662
=a=	1..	-1..	A201661	A201663
=a=	2..	-1..	A201664	A201665
=a=	3..	-1..	A201666	A201667
=a=	4..	-1..	A201668	A201669
=a=	5..	-1..	A201670	A201671
=a=	6..	-1..	A201672	A201673
=a=	7..	-1..	A201674	A201675
=a=	8..	-1..	A201676	A201677
=a=	9..	-1..	A201678	A201679
=a=	10.	-1..	A201680	A201681
=a=	1..	-2..	A201682	A201683
=a=	1..	-3..	A201735	A201736
=a=	1..	-4..	A201737	A201738
#--------------------------------
A199949
For many choices of a,b,c, there are exactly two numbers x>0 satisfying a*x^2+b*cos(x)=c*sin(x).
    a..  b..  c.least x, greatest x
=9=	1	 1	. 2	A199949	A199950
=9=	1	 1	. 3	A199951	A199952
=9=	1	 1	. 4	A199953	A199954
=9=	1	 2	. 3	A199955	A199956
=9=	1	 2	. 4	A199957	A199958
=9=	1	 3	. 3	A199959	A199960
=9=	1	 3	. 4	A199961	A199962
=9=	1	 4	. 3	A199963	A199964
=9=	1	 4	. 4	A199965	A199966
=9=	2	 1	. 3	A199967	A200003
=9=	2	 1	. 4	A200004	A200005
=9=	3	 1	. 4	A200006	A200007
=9=	4	 1	. 4	A200008	A200009
=9=	1	-1	. 1	A200010	A200011
=9=	1	-1	. 2	A200012	A200013
=9=	1	-1	. 3	A200014	A200015
=9=	1	-1	. 4	A200016	A200017
=9=	1	-2	. 1	A200018	A200019
=9=	1	-2	. 2	A200020	A200021
=9=	1	-2	. 3	A200022	A200023
=9=	1	-2	. 4	A200024	A200025
=9=	1	-3	. 1	A200026	A200027
=9=	1	-3	. 2	A200093	A200094
=9=	1	-3	. 3	A200095	A200096
=9=	1	-3	. 4	A200097	A200098
=9=	1	-4	. 1	A200099	A200100
=9=	1	-4	. 2	A200101	A200102
=9=	1	-4	. 3	A200103	A200104
=9=	1	-4	. 4	A200105	A200106
=9=	2	-1	. 1	A200107	A200108
=9=	2	-1	. 2	A200109	A200110
=9=	2	-1	. 3	A200111	A200112
=9=	2	-1	. 4	A200114	A200115
=9=	2	-2	. 1	A200116	A200117
=9=	2	-2	. 3	A200118	A200119
=9=	2	-3	. 1	A200120	A200121
=9=	2	-3	. 2	A200122	A200123
=9=	2	-3	. 3	A200124	A200125
=9=	2	-3	. 4	A200126	A200127
=9=	2	-4	. 1	A200128	A200129
=9=	2	-4	. 3	A200130	A200131
=9=	3	-1	. 1	A200132	A200133
=9=	3	-1	. 2	A200223	A200224
=9=	3	-1	. 3	A200225	A200226
=9=	3	-1	. 4	A200227	A200228
=9=	3	-2	. 1	A200229	A200230
=9=	3	-2	. 2	A200231	A200232
=9=	3	-2	. 3	A200233	A200234
=9=	3	-2	. 4	A200235	A200236
=9=	3	-3	. 1	A200237	A200238
=9=	3	-3	. 2	A200239	A200240
=9=	3	-3	. 4	A200241	A200242
=9=	3	-4	. 1	A200277	A200278
=9=	3	-4	. 2	A200279	A200280
=9=	3	-4	. 3	A200281	A200282
=9=	3	-4	. 4	A200283	A200284
=9=	4	-1	. 1	A200285	A200286
=9=	4	-1	. 2	A200287	A200288
=9=	4	-1	. 3	A200289	A200290
=9=	4	-1	. 4	A200291	A200292
=9=	4	-2	. 1	A200293	A200294
=9=	4	-2	. 3	A200295	A200296
=9=	4	-3	. 1	A200299	A200300
=9=	4	-3	. 2	A200297	A200298
=9=	4	-3	. 3	A200301	A200302
=9=	4	-3	. 4	A200303	A200304
=9=	4	-4	. 1	A200305	A200306
=9=	4	-4	. 3	A200307	A200308
#--------------------------------
A199170
For many choices of a,b,c, there are exactly two numbers x satisfying a*x^2 + b*x*cos(x) = c.
    a.. b.. c.... x
=8=	1	1	1	A199170	A199171
=8=	1	1	2	A199172	A199173
=8=	1	1	3	A199174	A199175
=8=	1	2	1	A199176	A199177
=8=	1	2	2	A199178	A199179
=8=	1	2	3	A199180	A199181
=8=	1	3	1	A199182	A199183
=8=	1	3	2	A199184	A199185
=8=	1	3	3	A199186	A199187
=8=	2	1	1	A199188	A199189
=8=	2	1	2	A199265	A199266
=8=	2	1	3	A199267	A199268
=8=	2	2	1	A199269	A199270
=8=	2	2	3	A199271	A199272
=8=	2	3	1	A199273	A199274
=8=	2	3	2	A199275	A199276
=8=	2	3	3	A199277	A199278
=8=	3	1	1	A199279	A199280
=8=	3	1	2	A199281	A199282
=8=	3	1	3	A199283	A199284
=8=	3	2	1	A199285	A199286
=8=	3	2	2	A199287	A199288
=8=	3	2	3	A199289	A199290
=8=	3	3	1	A199291	A199292
=8=	3	3	2	A199293	A199294
#--------------------------------
A201280
For many choices of a and c, there is exactly one x satisfying a*x^2 + c = cot(x) and 0 < x < Pi.
    a.... c.... x
=7=	1.	. 1.	A201280
=7=	1.	. 2.	A201281
=7=	1.	. 3.	A201282
=7=	1.	. 4.	A201283
=7=	1.	. 5.	A201284
=7=	1.	. 6.	A201285
=7=	1.	. 7.	A201286
=7=	1.	. 8.	A201287
=7=	1.	. 9.	A201288
=7=	1.	. 10	A201289
=7=	1.	. 0.	A201294
=7=	1.	 -1.	A201295
=7=	1.	 -2.	A201296
=7=	1.	 -3.	A201297
=7=	1.	 -4.	A201298
=7=	1.	 -5.	A201299
=7=	1.	 -6.	A201315
=7=	1.	 -7.	A201316
=7=	1.	 -8.	A201317
=7=	1.	 -9.	A201318
=7=	1.	-10.	A201319
=7=	2.	. 0.	A201329
=7=	3.	. 0.	A201330
=7=	4.	. 0.	A201331
=7=	5.	. 0.	A201332
=7=	6.	. 0.	A201333
=7=	7.	. 0.	A201334
=7=	8.	. 0.	A201335
=7=	9.	. 0.	A201336
=7=	10	. 0.	A201337
=7=	2.	 -1.	A201320
=7=	3.	 -1.	A201321
=7=	4.	 -1.	A201322
=7=	5.	 -1.	A201323
=7=	6.	 -1.	A201324
=7=	7.	 -1.	A201325
=7=	8.	 -1.	A201326
=7=	9.	 -1.	A201327
=7=	10	 -1.	A201328
=7=	2.	. 1.	A201290
=7=	2.	. 3.	A201291
=7=	2.	 -3.	A201394		was A204394
=7=	3.	. 1.	A201292
=7=	3.	. 2.	A201293
=7=	3.	 -2.	A201395		was A201294
#--------------------------------
A201741
For some choices of a, b, c, there is a unique value of x satisfying a*x^2+b*x+c=e^x, for other choices, there are two solutions, and for others, three.  Guide to related sequences, with graphs included in Mathematica programs:
    a... b.... c.... x
=6=	1..	 0.	. 2..	A201741
=6=	1..	 0.	. 3..	A201742
=6=	1..	 0.	. 4..	A201743
=6=	1..	 0.	. 5..	A201744
=6=	1..	 0.	. 6..	A201745
=6=	1..	 0.	. 7..	A201746
=6=	1..	 0.	. 8..	A201747
=6=	1..	 0.	. 9..	A201748
=6=	1..	 0.	. 10.	A201749
=6=	-1.	 0.	. 1..	A201750	nnnn
=6=	-1.	 0.	. 2..	A201751	A201752
=6=	-1.	 0.	. 3..	A201753	A201754
=6=	-1.	 0.	. 4..	A201755	A201756
=6=	-1.	 0.	. 5..	A201757	A201758
=6=	-1.	 0.	. 6..	A201759	A201760
=6=	-1.	 0.	. 7..	A201761	A201762
=6=	-1.	 0.	. 8..	A201763	A201764
=6=	-1.	 0.	. 9..	A201765	A201766
=6=	-1.	 0.	. 10.	A201767	A201768
=6=	1..	 1.	. 0..	A201769
=6=	1..	 1.	. 1..	nnnn	A201770
=6=	1..	 1.	. 2..	A201396
=6=	1..	 1.	. 3..	A201562
=6=	1..	 1.	. 4..	A201772
=6=	1..	 1.	. 5..	A201889
=6=	1..	 2.	. 1..	nnnn	A201890
=6=	1..	 2.	. 2..	A201891
=6=	1..	 2.	. 3..	A201892
=6=	1..	 2.	. 4..	A201893
=6=	1..	 2.	. 5..	A201894
=6=	1..	 3.	. 1..	A201895	nnnn	A201896
=6=	1..	 3.	. 2..	A201897	A201898	A201899
=6=	1..	 3.	. 3..	A201900
=6=	1..	 3.	. 4..	A201901
=6=	1..	 3.	. 5..	A201902
=6=	1..	 4.	. 1..	A201903	A201904
=6=	1..	 4.	. 2..	A201905	A201906	A201907
=6=	1..	 4.	. 3..	A201924	A201925	A201926
=6=	1..	 4.	. 4..	A201927	A201928	A201929
=6=	1..	 4.	. 5..	A201930
=6=	1..	 5.	. 1..	A201931	A201932
=6=	1..	 5.	. 2..	A201933	A201934	A201935
#--------------------------------
For many choices of a,b,c, there are exactly two numbers x having a*x^2 + b*sin(x) = c.
	a	b	 c	x
# =5=	1	1	 1	A124597
=5=	1	1	 1	A198866	A198867
=5=	1	1	 2	A199046	A199047
=5=	1	1	 3	A199048	A199049
# =5=	1	2	 0	A198414
=5=	1	2	 1	A199080	A199081
=5=	1	2	 2	A199082	A199083
=5=	1	2	 3	A199050	A199051
# =5=	1	3	 0	A198415
=5=	1	3	-1	A199052	A199053
=5=	1	3	 1	A199054	A199055
=5=	1	3	 2	A199056	A199057
=5=	1	3	 3	A199058	A199059
# =5=	2	1	 0	A198583
=5=	2	1	 1	A199061	A199062
=5=	2	1	 2	A199063	A199064
=5=	2	1	 3	A199065	A199066
=5=	2	2	 1	A199067	A199068
=5=	2	2	 3	A199069	A199070
# =5=	2	3	 0	A198605
=5=	2	3	 1	A199071	A199072
=5=	2	3	 2	A199073	A199074
=5=	2	3	 3	A199075	A199076
# =5=	3	0	 1	A020760
=5=	3	1	 1	A199060	A199077
=5=	3	1	 2	A199078	A199079
=5=	3	1	 3	A199150	A199151
=5=	3	2	 1	A199152	A199153
=5=	3	2	 2	A199154	A199155
=5=	3	2	 3	A199156	A199157
=5=	3	3	 1	A199158	A199159
=5=	3	3	 2	A199160	A199161
#---------------------------------
COMMENTS
For many choices of a,b,c, there is a unique nonzero number x satisfying a*x^2+b*x=c*sin(x).
Specifically, for a>0 and many choices of b and c, the curves y=ax^2+bx and y=c*sin(x) meet in a single point if and only if b=c, in which case the curves have a common tangent line, y=c*x.  If b<c, the curves meet in quadrant 1; if b>c, they meet in quadrant 2.
Guide to related sequences (with graphs included in Mathematica programs):
	a	.b	.c	x
=4=	1	.0	.1	A124597
=4=	1	.0	.2	A198414
=4=	1	.0	.3	A198415
=4=	1	.0	.4	A198416
=4=	1	.1	.2	A198417
=4=	1	.1	.3	A198418	corr. was A197
=4=	1	.1	.4	A198419	corr. was A197
=4=	1	.2	.1	A198424	corr. was A197
=4=	1	.2	.3	A198425	corr. was A197
=4=	1	.2	.4	A198426	corr. was A197
=4=	1	-1	.1	A198420	corr. was A197
=4=	1	-1	.1	A198420	corr. was A197
=4=	1	-1	.2	A198421	corr. was A197
=4=	1	-1	.3	A198422	corr. was A197
=4=	1	-2	.1	A198427
=4=	1	-2	.2	A198428
=4=	1	-2	.3	A198429
=4=	1	-2	.4	A198430
=4=	1	-3	.1	A198431
=4=	1	-3	.2	A198432
=4=	1	-3	.3	A198433
=4=	1	-3	.4	A198488
=4=	1	-4	.1	A198489
=4=	1	-4	.2	A198490
=4=	1	-4	.3	A198491
=4=	1	-4	.4	A198492
=4=	2	.0	.1	A198583
=4=	2	.0	.3	A198605
=4=	2	.1	.2	A198493
=4=	2	.1	.3	A198494
=4=	2	.1	.4	A198495
=4=	2	.2	.1	A198496
=4=	2	.2	.3	A198497
=4=	2	.3	.1	A198608
=4=	2	.3	.2	A198609
=4=	2	.3	.4	A198610
=4=	2	.4	.1	A198611
=4=	2	.4	.3	A198612	corr. offset 1 -> 0
=4=	2	-1	.1	A198546
=4=	2	-1	.2	A198547
=4=	2	-1	.3	A198548
=4=	2	-1	.4	A198549
=4=	2	-2	.3	A198559
=4=	2	-3	.1	A198566
=4=	2	-3	.2	A198567
=4=	2	-3	.3	A198568
=4=	2	-3	.4	A198569
=4=	2	-4	.1	A198577
=4=	2	-4	.3	A198578
=4=	3	.0	.1	A198501
=4=	3	.0	.2	A198502
=4=	3	.1	.2	A198498
=4=	3	.1	.3	A198499
=4=	3	.1	.4	A198500
=4=	3	.2	.1	A198613	corr. offseet 1 -> 0
=4=	3	.2	.3	A198614
=4=	3	.2	.4	A198615
=4=	3	.3	.1	A198616
=4=	3	.3	.2	A198617
=4=	3	.3	.4	A198618
=4=	3	.4	.1	A198606
=4=	3	.4	.2	A198607
=4=	3	.4	.3	A198619
=4=	3	-1	.1	A198550
=4=	3	-1	.2	A198551
=4=	3	-1	.3	A198552
=4=	3	-1	.4	A198553
=4=	3	-2	.1	A198560	corr. offset 1 -> 0
=4=	3	-2	.2	A198561
=4=	3	-2	.3	A198562
=4=	3	-2	.4	A198563
=4=	3	-3	.1	A198570
=4=	3	-3	.2	A198571
=4=	3	-3	.4	A198572
=4=	3	-4	.1	A198579
=4=	3	-4	.2	A198580
=4=	3	-4	.3	A198581	corr. offset 0 -> 1
=4=	3	-4	.4	A198582
=4=	4	.0	.1	A198503
=4=	4	.0	.3	A198504
=4=	4	.1	.2	A198505
=4=	4	.1	.3	A198506
=4=	4	.1	.4	A198507
=4=	4	.2	.1	A198539
=4=	4	.2	.3	A198540
=4=	4	.3	.1	A198541
=4=	4	.3	.2	A198542
=4=	4	.3	.4	A198543
=4=	4	.4	.1	A198544
=4=	4	.4	.3	A198545
=4=	4	-1	.1	A198554
=4=	4	-1	.2	A198555
=4=	4	-1	.3	A198556
=4=	4	-1	.4	A198557
=4=	4	-1	.1	A198554
=4=	4	-2	.1	A198564
=4=	4	-2	.3	A198565
=4=	4	-3	.1	A198573
=4=	4	-3	.2	A198574
=4=	4	-3	.3	A198575
=4=	4	-3	.4	A198576
#--------------------------------
# A336043
ratio, s/c  arclength, s chord length, c
=3=	3/2   	0000	A336043	A336044
=3=	2     	0000	A336045	A199460
=3=	3     	0000	A336047	A336048
=3=	Pi    	0000	A336049	A336050
=3=	4     	0000	A336051	A336052
=3=	5     	0000	A336053	A336054
=3=	6     	0000	A336055	A336056
=3=	2*Pi  	0000	A336057	A336058
MATHEMATICA
t = t /.FindRoot[t == (3/2) Sqrt[2 - 2 Cos[t]], {t, 4}, WorkingPrecision -> 200]
c = 2 t/3
RealDigits[t][[1]]   (* A336043 *)
RealDigits[c][[1]]   (* A336044 *)
#---------------------------------
A197476
COMMENTS
The Mathematica program includes a graph.  Guide for least x>0 satisfying
cos(b*x)=(cos(c*x))^2, for selected b and c:
b.....c......x
=2=	1.....	2.....	A197476
=2=	1.....	3.....	A197477
=2=	1.....	4.....	A197478
=2=	2.....	1.....	A000796	, pi
=2=	2.....	3.....	A197479
=2=	2.....	4.....	A197480
=2=	3.....	1.....	A019669	, pi/2
=2=	3.....	2.....	A197482
=2=	3.....	4.....	A197483
=2=	4.....	1.....	A168229	, arctan(sqrt(7))
=2=	4.....	2.....	A019669	, pi/2
=2=	4.....	3.....	A019679
=2=	4.....	6.....	A197485
=2=	4.....	8.....	A197486
=2=	6.....	2.....	A003881
=2=	6.....	3.....	A019670	, pi/3, tangency point
=2=	6.....	4.....	A197488
=2=	6.....	8.....	A197489
=2=	1.....	4*pi..	A197334
=2=	1.....	3*pi..	A197335
=2=	1.....	2*pi..	A197490
=2=	1.....	3*pi/2	A197491
=2=	1.....	pi....	A197492
=2=	1.....	pi/2..	A197493
=2=	1.....	pi/3..	A197494
=2=	1.....	pi/4..	A197495
=2=	1.....	2*pi/3	A197506
=2=	2.....	3*pi..	A197507
=2=	2.....	3*pi/2	A197508
=2=	2.....	2*pi..	A197509
=2=	2.....	pi....	A197510
=2=	2.....	pi/2..	A197511
=2=	2.....	pi/3..	A197512
=2=	2.....	pi/4..	A197513
=2=	2.....	pi/6..	A197514
=2=	pi....	1.....	A197515
=2=	pi....	2.....	A197516
=2=	pi....	1/2...	A197517
=2=	2*pi..	1.....	A197518
=2=	2*pi..	2.....	A197519
=2=	2*pi..	3.....	A197520
=2=	pi/2..	pi/3..	A197521
** 3 x added from sin:
=2=	pi/3..	1.....	A197582
=2=	pi/3..	2.....	A197583
=2=	pi/3..	1/3...	A197584
...
See A197133 for a guide for least x>0 satisfying sin(b*x)=(sin(c*x))^2 for selected b and c.
LINKS
Table of n, a(n) for n=1..99.
EXAMPLE
x=1.137743932905455557789449860055008349584...
MATHEMATICA
b = 1; c = 2; f[x_] := Cos[x]
t = x /. FindRoot[f[b*x] == f[c*x]^2, {x, 1.1, 1.3}, WorkingPrecision -> 200]
RealDigits[t] (* A197476 *)
Plot[{f[b*x], f[c*x]^2}, {x, 0, 2}]
RealDigits[ ArcCos[ ((19 - 3*Sqrt[33])^(1/3) + (19 + 3*Sqrt[33])^(1/3) - 2)/6], 10, 99] // First (* Jean-François Alcover, Feb 19 2013 *)
#--------------------------------
# 78 sequences
Guide for least x>0 satisfying sin(b*x)=(sin(c*x))^2 for selected numbers b and c:
    b.....  c.....    x
=1=	1.....	2.....	A197133
=1=	1.....	3.....	A197134
=1=	1.....	4.....	A197135
=1=	1.....	5.....	A197251
=1=	1.....	6.....	A197252
=1=	1.....	7.....	A197253
=1=	1.....	8.....	A197254
=1=	2.....	1.....	A105199	, x=arctan(2)
=1=	2.....	3.....	A019679	, x=Pi/12
=1=	2.....	4.....	A197255
=1=	2.....	5.....	A197256
=1=	2.....	6.....	A197257
=1=	2.....	7.....	A197258
=1=	2.....	8.....	A197259
=1=	3.....	1.....	A197260
=1=	3.....	2.....	A197261
=1=	3.....	4.....	A197262
=1=	3.....	5.....	A197263
=1=	3.....	6.....	A197264
=1=	3.....	7.....	A197265
=1=	3.....	8.....	A197266
=1=	4.....	1.....	A197267
=1=	4.....	2.....	A195693	, x=arctan(1/(golden ratio)) ** corrected A195695 -> A195693
=1=	4.....	3.....	A197268
=1=	5     	1     	A197283	inserted 2021-08-11
=1=	6     	1     	A197290	inserted 2021-08-11
=1=	1.....	4*pi..	A197522
=1=	1.....	3*pi..	A197571
=1=	1.....	2*pi..	A197572
=1=	1.....	3*pi/2	A197573
=1=	1.....	pi....	A197574
=1=	1.....	pi/2..	A197575
=1=	1.....	pi/3..	A197326
=1=	1.....	pi/4..	A197327
=1=	1.....	pi/6..	A197328
=1=	2.....	pi/3..	A197329
=1=	2.....	pi/4..	A197330
=1=	2.....	pi/6..	A197331
=1=	3.....	pi/3..	A197332
=1=	3.....	pi/6..	A197375
=1=	3.....	pi/4..	A197333	** b corrected: 4 -> 3
=1=	1.....	1/2...	A197376
=1=	1.....	1/3...	A197377
=1=	1.....	2/3...	A197378
=1=	pi....	1.....	A197576
=1=	pi....	2.....	A197577
=1=	pi....	3.....	A197578
=1=	2*pi..	1.....	A197585
=1=	3*pi..	1.....	A197586
=1=	4*pi..	1.....	A197587
=1=	pi/2..	1.....	A197579
=1=	pi/2..	2.....	A197580
=1=	pi/2..	1/2...	A197581
** delete A197582-84 here, move to cos
=1=	pi/3..	pi/4..	A197379
=1=	pi/3..	pi/6..	A197380
=1=	pi/4..	pi/3..	A197381
=1=	pi/4..	pi/6..	A197382
=1=	pi/6..	pi/3..	A197383	** b corrected Pi/4 -> Pi/6
=1=	pi/3..	1.....	A197384
=1=	pi/3..	2.....	A197385
=1=	pi/3..	3.....	A197386
=1=	pi/3..	1/2...	A197387
=1=	pi/3..	1/3...	A197388
=1=	pi/3..	2/3...	A197389
=1=	pi/4..	1.....	A197390
=1=	pi/4..	2.....	A197391
=1=	pi/4..	3.....	A197392
=1=	pi/4..	1/2...	A197393
=1=	pi/4..	1/3...	A197394
=1=	pi/4..	2/3...	A197411
=1=	pi/4..	1/4...	A197412
=1=	pi/6..	1.....	A197413
=1=	pi/6..	2.....	A197414
=1=	pi/6..	3.....	A197415
=1=	pi/6..	1/2...	A197416
=1=	pi/6..	1/3...	A197417
=1=	pi/6..	2/3...	A197418
MATHEMATICA
b = 1; c = 2; f[x_] := Sin[x]
t = x /. FindRoot[f[b*x] == f[c*x]^2, {x, .1, .3}, WorkingPrecision -> 100]
RealDigits[t] (* A197133 *)
#--------------------------------
#--------------------------------
#--------------------------------

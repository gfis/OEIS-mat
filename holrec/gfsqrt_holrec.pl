#!perl

# Convert generating functions with 1/sqrt(1 - c1*x - c2*x^2 ... - ck*x^k) 
# and generate calls to HolonomicRecurrence
# @(#) $Id$
# 2020-01-01, Georg Fischer
# Cf. <https://cs.uwaterloo.ca/journals/JIS/VOL9/Noe/noe35.pdf>, Eq. 4
# <http://www.teherba.org/index.php?title=OEIS/Square_Root_Recurrences>
#
#:# Usage:
#:#   perl gfsqrt_holrec.pl gfsqrt2.tmp > outfile
#
# - keep so many initial terms as necessary for the order
# - compute the recurrence formula
# - generate the call for HolonomicRecurrence
#
# A318293 has Maple rectoproc and Mathematica DifferentialRoot calls
#---------------------------------
use strict;
use integer;
use warnings;

my $aseqno;
my $matrix;
my $line;

while(<>) {
    s{\s+\Z}{}; # chompr
    $line = $_;
    my ($aseqno, $callcode, $factor, $coeff_list, $den, $expnum, $expden) = split(/\t/, $line);
    my @coeffs = split(/\,\s*/, $coeff_list);
    my $order = scalar(@coeffs) - 1;
    if ($expnum == -1) { # currently only in the denominator
        # A101106   1, 3, 12, 57, 283, 1440, 7461, 39159, 207492, 1107549, 5946543, 32080032
        # A101106   gfsqrt  0   1,-6,3,-6,1        1,3,12,57,283,1440
        # 1/sqrt(1                - 6*x              - (-3)*x^2            - 6*x^3            - (-1)*x^4)
        #   0 =  1*(2*n-0)*a(n-0) - 6*(2*n-1)*a(n-1) - (-3)*(2*n-2)*a(n-2) - 6*(2*n-3)*a(n-3) - (-1)*(2n-4)*a(n-4)
        # A101106   holos   0   [[0],[4,-2],[-18,12],[6,-6],[-6,12],[0,-2]] [1,3,12,57] 0
        my $matrix  = "[[0]";
        my $formula = "";
        my $demi    = $expden - 1; # 2n-1, 3n-2, 4n-3 ...
        my $nind    = $order;
        while ($nind >= 0) {
            my $coeff = $coeffs[$nind];
            my $scoeff = $coeff < 0 ? "($coeff)" : $coeff;
            $matrix .= ",[" . ($coeff * $nind * $demi) . "," . ($coeff * (-$expden)) . "]";
            if ($nind == 0) {
                $formula = ($scoeff*0 == 1 ? "" : "$scoeff*") . "$expden*n*a(n)$formula";
            } else {
                $formula = " + $scoeff*($expden*n-" . ($nind*$demi) . ")*a(n-$nind)$formula";
            }
            $nind --;
        } # while $nind 
        $matrix .= "]";
        $formula .= " = 0;";
        
        # now the initial terms; self-starting from [$factor]; assume a(k<0) = 0
        # A095776 1,3,18,135,1053,8505,70470,594135,5073840,43761870,380433024,3328474032 
        # A095776	holos	0	[[0],[-162,81],[0,0],[-18,27],[0,-3]]	[1,3,18]	0	
        # 1*3*n*a(n) + (-9)*(3*n-2)*a(n-1) + 0*(3*n-4)*a(n-2) + (-27)*(3*n-6)*a(n-3) = 0;
        # a(0) = 1; 3*1*a(1) - (27*1 + 18) => a(1) = 3; 3*2*a(2) - 36*3 => a(2) = 18;
        # G.f. : (1-9x-27x^3)^(-1/3)
        # (PARI) a(n)=polcoeff(1/(1-9*x-27*x^3)^(1/3)+O(x^(n+1)),n)        
        my @initerms = ($factor);
        my $n = 1;
        while ($n < $order) { 
            my $factan = $expden * $n;
            my $sum = 0;
            for (my $j = 1; $j <= $n; $j ++) {
                $sum -= $coeffs[$j] * ($expden * $n - $demi * $j) * $initerms[$n - $j];
            } # for $j
            $initerms[$n] = $sum / $factan * $factor;
            $n ++;
        } # while $n
        print join("\t", $aseqno, "holos", 0 
            , $matrix
            , "[" . join(",", @initerms) . "]"
            , 0, $formula) . "\n";
    } # expnum == -1
} # while <>

__DATA__
A000407 gfsqrt  1   1,-4    1   -3  2
A001813 gfsqrt  1   1,-4    1   -1  2
A002422 gfsqrt  1   1,-4    1   5   2
A002423 gfsqrt  1   1,-4    1   7   2
A002424 gfsqrt  1   1,-4    1   9   2
A002426 gfsqrt  1   1,-2,-3 1   -1  2
A004981 gfsqrt  1   1,-8    1   -1  4
A004982 gfsqrt  1   1,-8    1   -3  4
A004983 gfsqrt  1   1,-8    1   3   4
A004984 gfsqrt  1   1,-8    1   1   4
A004985 gfsqrt  1   1,-8    1   -5  4
A004986 gfsqrt  1   1,-8    1   -7  4
A004987 gfsqrt  1   1,-9    1   -1  3
A004988 gfsqrt  1   1,-9    1   -2  3
A004989 gfsqrt  1   1,-9    1   2   3
A004990 gfsqrt  1   1,-9    1   1   3
A004991 gfsqrt  1   1,-9    1   -4  3
A004992 gfsqrt  1   1,-9    1   -5  3


A081207
G.f.: (1+x)/sqrt(1-2x-x^2-2x^3+x^4) - Paul Barry, Jun 04 2005
Conjecture: n*(n-2)*a(n) +(-2*n^2+5*n-1)*a(n-1) +(-n^2+3*n-4)*a(n-2) +(-2*n^2+7*n-4)*a(n-3) +(n-1)*(n-3)*a(n-4)=0. - R. J. Mathar, Nov 12 2012

A101106     1, 3, 12, 57, 283, 1440, 7461, 39159, 207492, 1107549, 5946543, 32080032
G.f.: 1/sqrt(1-6x+3x^2-6x^3+x^4); a(n)=sum{k=0..n, binomial(n-k, k)(-1)^k*A001850(n-2k)}.
Conjecture: n*a(n) +3*(-2*n+1)*a(n-1) +3*(n-1)*a(n-2) +3*(-2*n+3)*a(n-3) +(n-2)*a(n-4)=0.
1/sqrt(1- 6*x              - (-3)*x^2            - 6*x^3            - (-1)*x^4)
2n*a(n) = 6*(2*n-1)*a(n-1) + (-3)*(2*n-2)*a(n-2) + 6*(2*n-3)*a(n-3) + (-1)*(2n-4)*a(n-4).

A118650
G.f.: (1-x)/sqrt(1-8*x+12*x^2-4*x^3)  - Mark van Hoeij, Apr 16 2013
Conjecture: n*a(n) +3*(-3*n+2)*a(n-1) +4*(5*n-8)*a(n-2) +2*(-8*n+21)*a(n-3) +2*(2*n-7)*a(n-4)=0. - R. J. Mathar, Nov 10 2013
... Proof ...

A132310 1, 5, 21, 83, 319, 1209, 4551, 17085, 64125, 240995, 907741, 3428655, 12990121
G.f.: A(x) = 1/sqrt(1 - 10*x + 33*x^2 - 36*x^3).
Recurrence: n*a(n) = (7*n-2)*a(n-1) - 6*(2*n-1)*a(n-2) . - Vaclav Kotesovec, Oct 20 2012
??? only a(n-2) ??? ok up to 300, decrease order of g.f.?
1/sqrt(1 - 10*x - (-33)*x^2 - 36*x^3)
RecurrenceTable[{a[0]==1,a[1]==5,a[2]==21, 2*n*a[n] == 10*(2*n-1)*a[n-1] + (-33)*(2n-2)*a[n-2] + (36)*(2*n-3)*a[n-3]},a,{n,0,10}]


A191649 1, 3, 14, 71, 379, 2082, 11651, 66051, 378064, 2180037, 12644861, 73695358
G.f.: 1/sqrt(x^4 +2*x^3 -x^2 -6*x +1). - Mark van Hoeij, Apr 17 2013
Conjecture: n*a(n) +3*(-2*n+1)*a(n-1) +(-n+1)*a(n-2) +(2*n-3)*a(n-3) +(n-2)*a(n-4)=0. - R. J. Mathar, Oct 08 2016
RecurrenceTable[{a[0]==1,a[1]==3,a[2]==14,a[3]==71, 
  0==n*a[n]+ 3*(-2*n+1)*a[n-1] +(-n+1)*a[n-2]+(2*n-3)*a[n-3]+(n-2)*a[n-4]},a,{n,0,1000}] ok

n*a[n] == (6*n-3)*a[n-1] +(n-1)*a[n-2] -(2*n-3)*a[n-3] -(n-2)*a[n-4]
1/sqrt(1           - 6*x              - 1*x^2           - (-2)*x^3            - (-1)*x^4)
  (2*n - 0)*a[n-0] - 6*(2*n-1)*a[n-1] - 1*(2n-2)*a[n-2] - (-2)*(2*n-3)*a[n-3] - (-1)*(2*n-4)*a[n-4]} ,a,{n,0,10}]

RecurrenceTable[{a[0]==1,a[1]==3,a[2]==14,a[3]==71,

A285199 1,2,11,102,1329,22290,457155,11083590,310107105,9834291810
"E.g.f.: 1/sqrt(1 - 4*x + x^2). - _Ilya Gutkovskiy_, May 05 2017",  wrong
"a(n+2) = (4n+6) a(n+1) - (n+1)^2 a(n). - _Robert Israel_, May 05 2017", ok
m-2 = n;  a(m) = 2*(2m-1)*a(m-1) - (m^2-2*m+1) * a(m-2) 
A285199 holos   0   [[0],[-1,2,-1],[-2,4],[-1]] [1,2]   0                       Product of n! and the n-th Legendre polynomial evaluated at 2.

A098481 holos   0   [[0],[-36,24],[2,-2],[-2,4],[0,-2]] [1,1,1] 0                       Expansion of 1/sqrt((1-x)^2 - 12*x^3).   1 - 2*x + x^2 -12*x^3
1,1,1,7,19,37,115,361,937,2599,7777,22195,62701,182647,531829,1534903,4461571
n*a(n) = (2*n-1)*a(n-1) - (n-1)*a(n-2) + 6*(2*n-3)*a(n-3). - _Vaclav Kotesovec_, Jun 23 2014
-2n       4n-2            2n-2           24n-36   

A182827 1,-1,-1,21,-111,-345,14895,-143955,-760095,49774095,-699437025,-5221460475,458621111025,-8457966542025,-81662774418225,8999266227076125,-205480756062957375,-2434383666448358625
E.g.f. 1/sqrt(1+2x+4x^2)
Conjecture: a(n) +(2n-1)*a(n-1) +4*(n-1)^2*a(n-2)=0. - _R. J. Mathar_, Nov 17 2011
A182827 holos   0   [[0],[8,-8],[2,-4],[0,2]]   [1,-1]  0
g.f. is wrong

(1                        - c1*x              - c2*x^2    ...         - ck*x^k   )^(-1/2)
 1*(2*n-0)*a(n-0) - (2*n-1)*c1*a(n-1) - (2*n-2)*c2*a(n-2) ... - (2*n-k)*ck*a(n-k) = 0

A095776 1,3,18,135,1053,8505,70470,594135,5073840,43761870,380433024,3328474032 
A095776	holos	0	[[0],[-81,54],[0,0],[-9,18],[0,-2]]	[1,3,18]	0	1*3*n*a(n) + (-9)*(3*n-2)*a(n-1) + 0*(3*n-4)*a(n-2) + (-27)*(3*n-6)*a(n-3) = 0;
G.f. : (1-9x-27x^3)^(-1/3)
(PARI) a(n)=polcoeff(1/(1-9*x-27*x^3)^(1/3)+O(x^(n+1)),n)


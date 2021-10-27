#!perl

# Extract parameters for triangles
# @(#) $Id$
# 2021-10-02, Georg Fischer: copied from ck/ck_guides.pl
#
#:# Usage:
#:#   perl tri_guides.pl [-d debug] [-a sel] > target.tmp
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
my $asel = "0-9a-zA-Z"; # select all possible TAB codes
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
my @apowers = 
    ( "A000004" # all zeroes
    , "A000012" # all ones
    , "A000079" # 2^n
    , "A000244" # 3^n
    , "A000302" # 4^n
    , "A000351" # 5^n
    , "A000400" # 6^n
    );
my ($opt, $base, @ans, $callcode, $aseqno, $form, $expr, @parms);
my %hash = ();
while (<DATA>) {
    my $line = $_;
    $line =~ s/\s+\Z//; # chompr
    if ($line =~ m{\A\=(\w)\=}) {
        $opt = $1;
        # print "opt=$opt\n";
        if ($opt !~ m{[$asel]}) {
            # print "# no desired opt code $opt, ignore\n";
        } elsif ($opt =~ m{A}) { # A256890
            ($opt, @ans) = split(/\s+/, $line);
            $callcode = "pastrico";
            my $a = $ans[0];
            for (my $b = 1; $b < scalar(@ans); $b ++) {
                $aseqno = $ans[$b];
                my $fk   = "$a*k + $b"; 
                my $fn_1 = "$a*(n - 1) + $b";
                ($fk, $fn_1) = map { 
                    s{\A1\*}{};
                    $_
                    } ($fk, $fn_1);
                @parms = (0);
                push(@parms, "new $apowers[$b]()", "new $apowers[$b]()", "new A000004()", "", "~~    ~~return get(k).multiply($fk).add(get(k - 1).multiply($fn_1));");
                &output($aseqno, "pastrico", @parms);
            } # for
        } elsif ($opt =~ m{B}) { 
            # =B=	1...  A087062 A202672   new A000012()	0
            my ($skip, $rseqno, $bseq, $cseqno);
            ($opt, $form, $aseqno, $cseqno, $bseq   , $skip) = split(/\t/, $line);
            print join("\t", $aseqno, "trig_b1", 0, "rseqno", $bseq, $skip) . "\n";
            print join("\t", $cseqno, "trig_b2", 0, "rseqno", $aseqno) . "\n";
        } elsif ($opt =~ m{C}) { 
            ($opt, $form, @ans) = split(/\t/, $line);
            $form =~ s{\.}{}g;
            $expr = "$form";
            $expr =~ s{(\d+)([ij])}{$1\*$2}g;
            $expr =~ s{([ij])\(}{$1\*\(}g;
            $expr =~ s{\,([^ ])}{\, $1}g;
            $expr =~ s{mod}{\%}g;
            $expr =~ s{(min|max)}{Math\.$1}g;
            print join("\t", $ans[0], "triuple", 0, "Z.valueOf($expr)", $form)  . "\n";
            print join("\t", $ans[1], "parmof2"  , 0, "A203991", "new $ans[0]()") . "\n";
        } else { # unknown -a
        }
    } # line with =opt=
} # while <DATA>
#----
sub output {
    my ($aseqno, $callcode, @parms) = @_;
    if ($aseqno ne "nnnn") {
        print join("\t", $aseqno, $callcode, @parms) . "\n";
    }
} # out
__DATA__
A256890		Triangle T(n,k) = t(n-k, k); t(n,m) = f(m)*t(n-1,m) + f(n)*t(n,m-1), where f(x) = x + 2.		24
1, 2, 2, 4, 12, 4, 8, 52, 52, 8, 16, 196, 416, 196, 16, 32, 684, 2644, 2644, 684, 32, 64, 2276, 14680, 26440, 14680, 2276, 64, 128, 7340, 74652, 220280, 220280, 74652, 7340, 128, 256, 23172, 357328, 1623964, 2643360, 1623964, 357328, 23172, 256, 512, 72076, 1637860, 10978444, 27227908, 27227908, 10978444, 1637860, 72076, 512 

a\b     1.......2.......3.......4.......5.......6
=A=	-1  A144431
=A=	0   A007318 A038208 A038221
=A=	1   A008292 A256890 A257180 A257606 A257607
=A=	2   A060187 A257609 A257611 A257613 A257615
=A=	3   A142458 A257610 A257620 A257622 A257624 A257626
=A=	4   A142459 A257612 A257621
=A=	5   A142460 A257614 A257623
=A=	6   A142461 A257616 A257625
=A=	7   A142462 A257617 A257627
=A=	8   A167884 A257618
=A=	9   A257608 A257619
The row sums of these, and similarly constructed number triangles, are shown in the following table:
a\b 1.......2.......3.......4.......5.......6.......7.......8.......9
0   A000079 A000302 A000400
1   A000142 A001715 A001725 A049388 A049198
2   A000165 A002866 A002866 A051580 A051582
3   A008544 A051578 A037559 A051605 A051607 A051609
4   A001813 A047053 A000407 A034177 A051618 A051620 A051622
5   A047055 A008546 A008548 A034300 A034325 A051688 A051690
6   A047657 A049308 A047058 A034689 A034724 A034788 A053101 A053103
7   A084947 A144827 A049209 A045754 A034830 A034832 A034834 A053105
8   A084948 A144828 A147626 A051189 A034908 A034910 A034912 A034976 A053115
9   A084949 A144829 A147630 A049211 A045756 A035013 A035018 A035021 A035023
10                                  A051262 A035265 A035273         A035277
11                                  A254322
12                                          A145448
The formula can be further generalized to: t(n,m) = f(m+s)*t(n-1,m) + f(n-s)*t(n,m-1), where f(x) = a*x + b. The following table specifies triangles with nonzero values for s (given after the slash).
a\ b  0           1           2          3
-2    A130595/1
-1
0
1     A110555/-1  A120434/-1  A144697/1  A144699/2
With the absolute value, f(x) = |x|, one obtains A038221/3, A038234/4,, A038247/5, 


T(n,k) = t(n-k, k); t(n,m) = f(m)*t(n-1,m) + f(n)*t(n,m-1), where f(x) = x + 2

restart:
f := proc(x): 1*x+2 end:
t := proc(n,m) option remember: if n < 0 or m < 0 then 0 else if n=0 and m=0 then 1 else f(m)*t(n-1,m) + f(n)*t(n,m-1) fi fi end:
seq(seq(t(n-k,k),k=0..n), n=0..8);
================================================
From A202605
    f(n)...... .               symmetric matrix ch.poly base seq.       skip
=B=	1...............                 	A087062	A202672	new A000012()	0
=B=	n...............                 	A115262	A202673	new A000027()	0
=B=	n^2.............                 	A202670	A202671	new A000290()	1
=B=	2*n-1...........                 	A202674	A202675	new A005408()	0
=B=	3*n-2...........                 	A202676	A202677	new A016777()	0
=B=	n*(n+1)/2.......                 	A185957	A202678	new A000217()	1
=B=	2^n-1...........                 	A202873	A202767	new A126646()	0
=B=	2^(n-1).........                 	A115216	A202868	new A000079()	0
=B=	floor(n*tau)....                 	A202869	A202870	new A000201()	0
=B=	F(n)............                 	A202453	A202605	new A000045()	1
=B=	F(n+1)..........                 	A202874	A202875	new A000045()	2
=B=	Lucas(n)........                 	A202871	A202872	new A000032()	1
=B=	F(n+2)-1........                 	A202876	A202877	new A000071()	2
=B=	F(n+3)-2........                 	A202970	A202971	new A001911()	1
=B=	(F(n))^2........                 	A203001	A203002	new A007598()	1
=B=	(F(n+1))^2......                 	A203003	A203004	new A007598()	2
=B=	C(2n,n).........                 	A115255	A203005	new A000984()	0
=?=	(-1)^(n+1)......                 	A003983	A399911	new PeriodicSequence("1,-1")	0			was A076757
=B=	periodic 1,0....                 	A203905	A203906	new PeriodicSequence("1,0")	0	
=B=	periodic 1,0,0..                 	A203945	A203946	new PeriodicSequence("1,0,0")	0
=B=	periodic 1,0,1..                 	A203947	A203948	new PeriodicSequence("1,0,1")	0
=B=	periodic 1,1,0..                 	A203949	A203950	new PeriodicSequence("1,1,0")	0
=B=	periodic 1,0,0,0                 	A203951	A203952	new PeriodicSequence("1,0,0,0")	0
=B=	periodic 1,2....                 	A203953	A203954	new PeriodicSequence("1,2")	0	
=B=	periodic 1,2,3..                 	A203955	A203956	new PeriodicSequence("1,2,3")	0
=B=	Catalan numbers.                 	A115253	A999901	new A000108()	0
=B=	floor((n+2)/2).                  	A115263	A999902	new A008619()	0
=B=	floor((n+3)/3).                  	A115265	A999903	new A008620()	0
=B=	floor((n+4)/4).                  	A115268	A999904	new A008621()	0
=B=	2-0^n.                           	A115281	A999905	new PaddingSequence("1", "2")	0
=B=	3-2*0^n.                         	A115282	A999906	new PaddingSequence("1", "3")	0
=B=	4-C(1,n)-2*C(0,n) (A113311).     	A115284	A999907	new A113311()	0
=B=	(1+x)^3/(1-x).                   	A115292	A999908	new PaddingSequence("1,4,7", "8")	0
=B=	Fredholm-Rueppel sequence A036987	A115381	A999909	new A036987()	0
=B=	Thue-Morse sequence A010060(n+1).	A115382	A999910	new A010060()	1
#================================================
A204016 represents the matrix M given by f(i,j) = max{(j mod i), (i mod j)} for i >= 1 and j >= 1.  See A204017 for characteristic polynomials of principal submatrices of M, with interlacing zeros.
Guide to symmetric matrices M based on functions f(i,j) and characteristic polynomial sequences (c.p.s.) with interlaced zeros:
f(i,j).........        .................M.........c.p.s.
=C=	C(i+j,j)........................	A007318	A045912
=C=	min(i,j)........................	A003983	A202672
=C=	max(i,j)........................	A051125	A203989
=C=	(i+j)*min(i,j)..................	A203990	A203991
=C=	|i-j|...........................	A049581	A203993
=C=	max(i-j+1,j-i+1)................	A143182	A203992
=C=	min(i-j+1,j-i+1)................	A203994	A203995
=C=	min(i(j+1),j(i+1))..............	A203996	A203997
=C=	max(i(j+1)-1,j(i+1)-1)..........	A203998	A203999
=C=	min(i(j+1)-1,j(i+1)-1)..........	A204000	A204001
=C=	min(2i+j,i+2j)..................	A204002	A204003
=C=	max(2i+j-2,i+2j-2)..............	A204004	A204005
=C=	min(2i+j-2,i+2j-2)..............	A204006	A204007
=C=	max(3i+j-3,i+3j-3)..............	A204008	A204011
=C=	min(3i+j-3,i+3j-3)..............	A204012	A204013
=C=	min(3i-2,3j-2)..................	A204028	A204029
=C=	1+min(j mod i, i mod j).........	A204014	A204015
=C=	max(j mod i, i mod j)...........	A204016	A204017
=C=	1+max(j mod i, i mod j).........	A204018	A204019
=C=	min(i^2,j^2)....................	A106314	A204020
=C=	min(2i-1, 2j-1).................	A157454	A204021
=C=	max(2i-1, 2j-1).................	A204022	A204023
=C=	min(i(i+1)/2,j(j+1)/2)..........	A106255	A204024
=C=	gcd(i,j)........................	A003989	A204025
=C=	gcd(i+1,j+1)....................	A204030	A204111
=C=	min(F(i+1),F(j+1),F=A000045.....	A204026	A204027
=C=	gcd(F(i+1),F(j+1),F=A000045.....	A204112	A204113
=C=	gcd(L(i),L(j),L=A000032.........	A204114	A204115
=C=	gcd(2^i-1,2^j-1)................	A204116	A204117	was ... 2^j-2)
=C=	gcd(prime(i),prime(j))..........	A204118	A204119
=C=	gcd(prime(i+1),prime(j+1))......	A204120	A204121
=C=	gcd(2^(i-1),2^(j-1))............	A144464	A204122
=C=	max(floor(i/j),floor(j/i))......	A204123	A204124
=C=	min(ceiling(i/j),ceiling(j/i))..	A204143	A204144
=C=	Delannoy matrix.................	A008288	A204135
=C=	max(2i-j,2j-i)..................	A204154	A204155
=C=	-1+max(3i-j,3j-i)...............	A204156	A204157
=C=	max(3i-2j,3j-2i)................	A204158	A204159
=C=	floor((i+j)/2)..................	A204164	A204165	was floor((i+1)/2)
=C=	ceiling((i+j)/2)................	A204166	A204167	was ceiling((i+1)/2)
=C=	i+j.............................	A003057	A204168
=C=	i+j-1...........................	A002024	A204169
=C=	i*j.............................	A003991	A204170
=C=	AOE f(i,i)=i....................	A204125	A204126
=C=	AOE f(i,i)=A000045(i+1).........	A204127	A204128
=C=	AOE f(i,i)=A000032(i)...........	A204129	A204130
=C=	AOE f(i,i)=2i-1.................	A204131	A204132
=C=	AOE f(i,i)=2^(i-1)..............	A204133	A204134
=C=	AOE f(i,i)=3i-2.................	A204160	A204161
=C=	AOE f(i,i)=floor((i+1)/2).......	A204162	A204163
=C=	?                               	A204164	A204165
=C=	?                               	A204171	A204172
=C=	?                               	A204173	A204174
=C=	?                               	A204175	A204176
=C=	?                               	A204177	A204178
=C=	?                               	A204179	A204180
=C=	?                               	A204181	A204182
=C=	?                               	A204183	A204184
abbreviation above:  AOE means "all 1's except"
also:
A204171	null	Symmetric matrix based on f(i,j)=(1 if max(i,j) is odd, and 0 otherwise), by antidiagonals.	nonn,tabl,synth	99
A204172	null	Array:  row n shows the coefficients of the characteristic polynomial of the n-th principal submatrix of (f(i,j)), where f(i,j)=(1 if max(i,j) is odd, and 0 otherwise) as in A204171.	tabl,sign,synth	72
A204173	null	Symmetric matrix based on f(i,j)=(2i-1 if max(i,j) is odd, and 0 otherwise), by antidiagonals.	nonn,tabl,synth	99
A204174	null	Array: row n shows the coefficients of the characteristic polynomial of the n-th principal submatrix of (f(i,j)), where f(i,j)=(2i-1 if max(i,j) is odd, and 0 otherwise) as in A204173.	tabf,sign,synth	52
A204175	null	Symmetric matrix based on f(i,j)=(1 if max(i,j) is even, and 0 otherwise), by antidiagonals.	nonn,tabl,synth	99
A204176	null	Array:  row n shows the coefficients of the characteristic polynomial of the n-th principal submatrix of (f(i,j)), where f(i,j)=(1 if max(i,j) is even, and 0 otherwise) as in A204175.	tabf,sign,synth	72
A204177	null	Symmetric matrix based on f(i,j)=(1 if i=1 or j=1 or i=j, and 0 otherwise), by antidiagonals.	nonn,tabl,synth	99
A204178	null	Array:  row n shows the coefficients of the characteristic polynomial of the n-th principal submatrix of (f(i,j)), where f(i,j)=(1 if i=1 or j=1 or i=j, and 0 otherwise) as in A204177.	tabl,sign,synth	60
A204179	null	Symmetric matrix based on f(i,j) defined by f(i,1)=f(1,j)=1; f(i,i)= i; f(i,j)=0 otherwise; by antidiagonals.	nonn,tabl,synth	99
A204180	null	Array:  row n shows the coefficients of the characteristic polynomial of the n-th principal submatrix of (f(i,j)), where f(i,1)=f(1,j)=1, f(i,i)= i; f(i,j)=0 otherwise; as in A204179.	tabf,sign,	10010
A204181	null	Symmetric matrix based on f(i,j) defined by f(i,1)=f(1,j)=1; f(i,i)= 2i-1; f(i,j)=0 otherwise; by antidiagonals.	nonn,tabl,synth	98
A204182	null	Array:  row n shows the coefficients of the characteristic polynomial of the n-th principal submatrix of (f(i,j)), where f(i,1)=f(1,j)=1, f(i,i)=2i-1; f(i,j)=0 otherwise; as in A204181.	tabl,sign,synth	40
A204183	null	Symmetric matrix based on f(i,j) defined by f(i,1)=f(1,j)=1; f(i,i)= (-1)^(i-1); f(i,j)=0 otherwise; by antidiagonals.	sign,tabl,synth	93

#================

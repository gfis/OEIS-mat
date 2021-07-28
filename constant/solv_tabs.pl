#!perl
# Extract parameters from Clark Kimberling's tables
# @(#) $Id$
# 2021-07-27, Georg Fischer
#
#:# Usage:
#:#   perl solv_tabs.pl [-d debug] > sin2_tab.tmp
#
# =1=   https://oeis.org/A197133 
# =2=   https://oeis.org/A336043
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
my $ignore = 1;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{i}) {
        $ignore    = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
my $offset = 0;
while (<DATA>) {
    my $line = $_;
    next if $line !~ m{\A\=};
    $line =~ s/\s+\Z//; # chompr
    $line =~ s{ }{}g; # remove spaces
    $line =~ s{pi}{Pi}g; 
    my ($opt, $b, $c, @ans) = split(/\t/, $line);
    $b =~ s{\.}{}g;
    $c =~ s{\.}{}g;
    my ($A);
    if (0) {
    } elsif ($opt eq "=1=") { # sin = sin^2
        $b =~ s{\.}{}g;
        $c =~ s{\.}{}g;
        $A = "sin($b*x)-(sin($c*x))^2";
        &output($ans[0], $A);
    } elsif ($opt eq "=2=") { # cos = cos^2
        $b =~ s{\.}{}g;
        $c =~ s{\.}{}g;
        $A = "cos($b*x)-(cos($c*x))^2";
        &output($ans[0], $A);
    } elsif ($opt eq "=2=") { # 
    }
} # while <DATA>
#----
sub output {
    my ($aseqno, $expr) = @_;
    if ($aseqno =~ m{\AA[0-9]}) {
        print join("\t", $aseqno, "post", 0, "~~$expr", "", 0, 0, $expr) . "\n";
    }
} # output
__DATA__
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

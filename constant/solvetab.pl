#!perl
# Extract parameters from Clark Kimberling's overview tables
# @(#) $Id$
# 2021-08-01: renamed from solv_tabs, -a 45
# 2021-07-29: -a 3
# 2021-07-27, Georg Fischer
#
#:# Usage:
#:#   perl solvetab.pl [-d debug] [-a sel] > solv_tabs1.tmp
#
# =1=   https://oeis.org/A197133
# =2=   https://oeis.org/A197476
# =3=   https://oeis.org/A336043
# =4=   https://oeis.org/A198414
# =3=   https://oeis.org/A198866
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
my $asel = "123";
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
while (<DATA>) {
    my $line = $_;
    next if $line !~ m{\A\=};
    $line =~ s/\s+\Z//; # chompr
    $line =~ s{[ \.]}{}g; # remove spaces and dots
    $line =~ s{pi}{Pi}g;
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
        # For many choices of a,b,c, there is a unique nonzero number x satisfying a*x^2+b*x=c*sin(x).
        # Specifically, for a>0 and many choices of b and c, the curves y=ax^2+bx and y=c*sin(x) meet in a single point
        # if and only if b=c, in which case the curves have a common tangent line, y=c*x.
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
        # For some choices of a, b, c, there is a unique value of x satisfying a*x^2+b*x+c=e^x, 
        # for other choices, there are two solutions, and for others, three.
        $A = (($a != 1 ? "$a*" : "") . "x^2"
           . ($b == 0 ? "" : ($b == 1 ? "+x" : "+$b*x"))
           . ($c > 0 ? "+$c" : ($c < 0 ? $c : "")) 
           . "-exp(x)");
        &outstd($ans[0], "decsolv", $A, "");
        if ( length($ans[1]) > 0) {
            &outstd($ans[1], "decsolv" . (length($ans[2]) > 0 ? "n" : ""), $A, "");
        }
        if ( length($ans[2]) > 0) {
            &outstd($ans[2], "decsolv", $A, "");
        }

    } elsif ($opt eq "=7=") { # A201280 ff.
        ($opt, $a, $c, @ans) = map { s{nnnn}{}; $_ } split(/\t/, $line, -4);
        # For many choices of a and c, there is exactly one x satisfying a*x^2 + c = cot(x) and 0 < x < Pi.
        $A = (($a != 1 ? "$a*" : "") . "x^2"
           . ($c > 0 ? "+$c" : ($c < 0 ? "$c" : "")) . "-cot(x)");
        &outstd($ans[0], "decsolv", $A, "");
    }
} # while <DATA>
print STDERR "COMMIT;\n";
#----
sub outstd {
    my ($aseqno, $callcode, $expr1, $expr2) = @_;
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
#--------------------------------
#--------------------------------
#--------------------------------
#--------------------------------

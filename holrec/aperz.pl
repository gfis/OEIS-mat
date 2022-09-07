#!perl

# Generate recurrences from Zagier's article
# @(#) $Id$
# 2022-08-07, Georg Fischer
#
#:# Usage:
#:#   perl aperz.pl {-rec|-grep} >  outfile
#
# Cf. http://people.mpim-bonn.mpg.de/zagier/files/tex/AperylikeRecEqs/fulltext.pdf, page 3
#--------------------------------------------------------
use strict;
use integer;
use warnings;
use English;

my $debug = 0;
my $mode = "grep";
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{grep}) {
        $mode      = substr($opt, 1);
    } elsif ($opt  =~ m{rec}) {
        $mode      = substr($opt, 1);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
# mapping from Zagier's indexes to OEIS A-numbers
my %oeis = qw(
     1 A000007
     3 A000012
     5 A000172
     6 A005408
     7 A006077
     8 A002893
     9 A005258
    10 A081085
    11 A002894
    13 A093388
    14 A006480
    15 A003215
    19 A143583
    20 A000897
    21 A005902
    24 A008384
    29 A008386
    31 A008388
    33 A008390
    );
my $line;
my $aseqno;
my $offset1  = "0";
my $name;
my $callcode = "rectoproc";
my $cmd;
my @result;
my $termno;
my $data;
my $an_base = 10000;
my $comment;
while (<DATA>) {
    next if ! m{\A\d+ };
    s/\r?\n//; # chompr
    my $line = $_;
    if ($line =~ s{\#\s*(.*)}{}) {
        $comment = $1;
    }
    my @parms = split(/\s+/, $_);
    next if scalar(@parms) < 4;
    my ($index, $family, $A, $B, $lambda) = splice(@parms, 0, 5);
    print "# " . join(",". $index, $family, $A, $B, $lambda) . "\n";
    $A      = ($A      >= 0) ? "-$A"      : "+" . substr($A, 1);
    $B      = ($B      >= 0) ? "+$B"      : $B;
    $lambda = ($lambda >= 0) ? "-$lambda" : "+" . substr($lambda, 1);
    if (0) {
    } elsif ($mode eq "rec") {
        print join("\t", (defined($oeis{$index}) ? $oeis{$index} : "A0" . ($an_base + $index)), "rectoproc", 0
    #       , "(n+1)^2*a(n+1) $A*n*(n+1)*a(n) $B*n^2*a(n-1) - ($lambda*a(n))=0", +3)
            , "n^2*A^0 $A*(n-1)*n*A^1 $B*(n-1)^2*A^2 $lambda*A^1", 3)
            . "\n";
    } elsif ($mode eq "grep") {
        print "#--------\n";
        $cmd = "grep -P \"\\t" . join(",", @parms) . "\" ../common/asdata.txt";
        @result = split(/\r?\n/, `$cmd`);
        if (scalar(@result) >= 1) {
            $result[0] =~ s{\r?\n}{}; # chompr
            ($aseqno, $termno, $data) = split(/\t/, $result[0]);
            print "    $index $aseqno\n";
            if (scalar(@result) >= 2) {
                @result = splice(@result, 0, 4);
                print "#* " . join("\n#* ", @result) . "\n";
            }
        } else {
            print "#   $index: no data found\n";
        }
    } else {
        die "invalid mode \"$mode\"";
    }
} # while <DATA>
__DATA__
A  5 A000172	holos	0	[[0],[-8,16,-8],[-2,7,-7],[0,0,1]]	[1]	0	0					Franel number a(n) = Sum_{k = 0..n} binomial(n,k)^3.
B  7 A006077	holos	0	[[0],[27,-54,27],[-3,9,-9],[0,0,1]]	[1]	0	0					(n+1)^2*a(n+1) = (9n^2+9n+3)*a(n) - 27*n^2*a(n-1), with a(0) = 1 and a(1) = 3.
C  8 A002893	holos	0	[[0],[9,-18,9],[-3,10,-10],[0,0,1]]	[1]	0	0					a(n) = Sum_{k=0..n} binomial(n,k)^2 * binomial(2*k,k).
D  9 A005258	holos	0	[[0],[-1,2,-1],[-3,11,-11],[0,0,1]]	[1]	0	0					Ap√©ry numbers: a(n) = Sum_{k=0..n} binomial(n,k)^2 * binomial(n+k,k).
E 10 A081085	holos	0	[[0],[32,-64,32],[-4,12,-12],[0,0,1]]	[1]	0	0					Expansion of 1 / AGM(1, 1 - 8*x) in powers of x.
F 13 A093388	holos	0	[[0],[72,-144,72],[-6,17,-17],[0,0,1]]	[1]	0	0					(n+1)^2*a(n+1) = (17n^2+17n+6)*a(n) - 72*n^2*a(n-1).
K 19 A143583	holos	0	[[0],[256,-512,256],[-12,32,-32],[0,0,1]]	[1]	0	0					Ap√©ry-like numbers: a(n) = (1/C(2n,n))*Sum_{k=0..n} C(2k,k)*C(4k,2k)*C(2n-2k,n-k)*C(4n-4k,2n-2k).
K 25 A010025	holos	0	[[0],[729,-1458,729],[-21,54,-54],[0,0,1]]	[1]	0	0					???
K 26 A010026	holos	0	[[0],[256,-512,256],[-28,32,-32],[0,0,1]]	[1]	0	0					???

# Family H are rows of A063700
# index family A B λ    u0 u1 u2 u3 u4 u5 u6  # remark
#----------------------------------
1  H  -1   0  0    1 0 0 0 0 0 0                                  # A063700, row 0
2  G   0 -16  0    1 0 4 0 36 0 400                               # (A002894 interleaved with zeros)
3  L   2   1  1    1 1 1 1 1 1 1                                  # A000012
4  H  -1   0  2    1 2 0 0 0 0 0                                  # A063700, row 1
5  A   7  -8  2    1 2 10 56 346 2252 15184                       # A000172
6  L   2   1  3    1 3 5 7 9 11 13                                # A005408
7  B   9  27  3    1 3 9 21 9 -297 -2421                          # A006077
8  C  10   9  3    1 3 15 93 639 4653 35169                       # A002893
9  D  11  -1  3    1 3 19 147 1251 11253 104959                   # A005258
10 E  12  32  4    1 4 20 112 676 4304 28496                      # A081085
11 M  16   0  4    1 4 36 400 4900 63504 853776                   # A002894
12 H  -1   0  6    1 6 6 0 0 0 0                                  # A063700, row 2
13 F  17  72  6    1 6 42 312 2394 18756 149136                   # A093088
14 M  27   0  6    1 6 90 1680 34650 756756 17153136              # A006480
15 L   2   1  7    1 7 19 37 61 91 127                            # A003215
16 M -27   0 12    1 12 -126 2100 -40950 864864 -19171152
17 M -16   0 12    1 12 -60 560 -6300 77616 -1009008
18 H  -1   0 12    1 12 30 20 0 0 0                               # A063700, row 3
19 K  32 256 12    1 12 164 2352 34596 516912 7806224             # A143583
20 M  64   0 12    1 12 420 18480 900900 46558512 2498640144      # A000897
21 L   2   1 13    1 13 55 147 309 561 923                        # A005902
22 M -64   0 20    1 20 -540 21840 -1021020 51459408 -2715913200
23 H  -1   0 20    1 20 90 140 70 0 0                             # A063700, row 4
24 L   2   1 21    1 21 131 471 1251 2751 5321                    # A008384
25 K  54 729 21    1 21 495 12171 305919 7794171 200412801
26 K  32 256 28    1 28 580 10992 199524 3530352 61417616
27 M -27   0 30    1 30 -180 2640 -48510 989604 -21441420
28 H  -1   0 30    1 30 210 560 630 252 0                         # A063700, row 5
29 L   2   1 31    1 31 271 1281 4251 11253 25493                 # A008386
30 H  -1   0 42    1 42 420 1680 3150 2772 924                    # A063700, row 6
31 L   2   1 43    1 43 505 3067 12559 39733 104959               # A008388
32 H  -1   0 56    1 56 756 4200 11550 16632 12012                # A063700, row 1
33 L   2   1 57    1 57 869 6637 33111 124223 380731              # A008390
34 M -16   0 60    1 60 420 -1680 13860 -144144 1681680
35 M -64   0 84    1 84 -924 30800 -1316700 62990928 -3212537328
36 M -27   0 84    1 84 630 -5460 81900 -1493856 30126096
37 K  32 256 48    1  
38 K  32 256 76    1  
39 K  32 256 16    1  

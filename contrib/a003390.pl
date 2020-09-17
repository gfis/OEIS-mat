#!perl

# A003390: Numbers which are the sum of 12 nonzero 8th powers <= 100000
# @(#) $Id$
# 2020-08-02, Georg Fischer
#
#:# Usage:
#:#   perl a003390.pl
#--------------------------------------------------------
use strict;
use integer;
use warnings;

my $limit = 100000;
my @p8 = ();
my $pow = 0;
my $ind = 0;
while ($pow < $limit) {
	$pow = $ind ** 8;
	push(@p8, $pow);
	$ind ++;
} # while pow
# 0, 1, 256, 6561, 65536

my ($i0, $i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8);
$i0 = 0;
for ($i1 = 1; $
__DATA__
# Table of n, a(n) for n = 0..99
# Generated by Georg Fischer with jOEIS, Aug 01 2020
0 12
1 267
2 522
3 777
4 1032
5 1287
6 1542
7 1797
8 2052
9 2307
10 2562
11 2817
12 3072
13 6572
14 6827
15 7082
16 7337
17 7592
18 7847
19 8102
20 8357
21 8612
22 8867
23 9122
24 9377
25 13132
26 13387
27 13642
28 13897
29 14152
30 14407
31 14662
32 14917
33 15172
34 15427
35 15682
36 19692
37 19947
38 20202
39 20457
40 20712
41 20967
42 21222
43 21477
44 21732
45 21987
46 26252
47 26507
48 26762
49 27017
50 27272
51 27527
52 27782
53 28037
54 28292
55 32812
56 33067
57 33322
58 33577
59 33832
60 34087
61 34342
62 34597
63 39372
64 39627
65 39882
66 40137
67 40392
68 40647
69 40902
70 45932
71 46187
72 46442
73 46697
74 46952
75 47207
76 52492
77 52747
78 53002
79 53257
80 53512
81 59052
82 59307
83 59562
84 59817
85 65547
86 65612
87 65802
88 65867
89 66057
90 66122
91 66312
92 66567
93 66822
94 67077
95 67332
96 67587
97 67842
98 68097
99 68352


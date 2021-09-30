#!perl

# @(#) $Id$
# Prepare b-files for A051990 (ERD-type) etc.
# 2021-09-21, Georg Fischer

#
#:# Usage:
#:#   perl a051990.pl [-d debug] [-a sel] [-bf] > output.tmp
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
my $bf   = 0;
my $asel = "10"; # select A4(1) column 0
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{bf}) {
        $bf = 1;
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{a}) {
        $asel      = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my $ntab   = substr($asel, 0, 1); # 1, 2, 3
my @cols; # 3 columns
my $ncol   = substr($asel, 1); # current column: 0, 1, 2
my $active = 0; # inactive
my $ofs    = $ncol == 0 ? 0 : -1; # strange
while (<DATA>) {
    my $line = $_;
    $line =~ s/\s+\Z//; # chompr
    if (0) {
    } elsif ($line =~ m{\A\#\s*Table\s*\w+\s*\((\d+)\)}) { 
        my $subtab = $1;
        $active = $subtab == $ntab ? 1 : 0;
    } elsif ($line =~ m{\A([\d\-]+)\t([\d\-]+)\t([\d\-]+)\Z}) {
        my @cols = ($1, $2, $3);
        if ($active) {
            $ofs ++;
            if ($bf) {
                print "$ofs $cols[$ncol]\n";
            } else {
                print "$cols[$ncol], ";
            }
        }
    } elsif ($line =~ m{\A\d}) { 
        print STDERR "# error: $line\n";
    }
} # while DATA
print "\n\n"; # for APH
__DATA__
A051990	null	Discriminants of real quadratic fields of ERD-type with class groups of exponent 2 and discriminants of the form D = r^2*k^2+k, k odd.	nonn,fini,synth	1..48	nyi
A051991	null	Discriminants of real quadratic fields of ERD-type with class groups of exponent 2 and discriminants of the form D = r^2*k^2+2k, k odd.	nonn,fini,synth	1..47	nyi
A051992	null	Discriminants of real quadratic fields of ERD-type with class groups of exponent 2 and discriminants of the form D = r^2*k^2+4k, k odd.	nonn,fini,synth	1..42	nyi
A051993	null	Consider real quadratic fields of ERD-type with class groups of exponent 2 and discriminants of the form D = r^2*k^2+k, k odd; sequence gives values of r.	nonn,fini,synth	0..82	nyi
A051994	null	Consider real quadratic fields of ERD-type with class groups of exponent 2 and discriminants of the form D = r^2*k^2+2k, k odd; sequence gives values of r.	nonn,fini,synth	0..75	nyi
A051995	null	Consider real quadratic fields of ERD-type with class groups of exponent 2 and discriminants of the form D = r^2*k^2+4k, k odd; sequence gives values of r.	nonn,fini,synth	0..79	nyi
A051996	null	Consider real quadratic fields of ERD-type with class groups of exponent 2 and discriminants of the form D = r^2*k^2+k, k odd; sequence gives values of k.	sign,fini,synth	0..71	nyi
A051997	null	Consider real quadratic fields of ERD-type with class groups of exponent 2 and discriminants of the form D = r^2*k^2+2k, k odd; sequence gives values of k.	sign,fini,synth	0..75	nyi
A051998	null	Consider real quadratic fields of ERD-type with class groups of exponent 2 and discriminants of the form D = r^2*k^2+4k, k odd; sequence gives values of k.	sign,fini,synth	0..67	nyi


# Table A4(1)
# D = + k, k odd.
# It is interesting to note that, in Table A 4(l), all are such that < 8 except
# for D = 19635, D = 451605 and there are a total of 98 fundamental radicands D > 0
# in the table. Although some radicands in Table A4(l) may have the shape of the
# radicands in Table A4(2)-A4(3) we do not repeat them there.
# D r k
10	3	1
15	4	-1
26	5	1
30	1	5
35	6	-1
39	2	3
42	1	-7
65	8	1
78	3	-3
95	2	-5
105	2	5
110	1	-11
122	11	1
143	12	-1
170	13	1
182	1	13
195	14	-1
203	2	7
210	1	-15
222	5	-3
230	3	5
255	16	-1
290	17	1
327	6	3
362	19	1
# D	r	k
395	4	-5
462	1	21
483	22	-1
485	22	1
530	23	1
663	2	-13
885	2	-15
903	10	3
915	2	15
930	1	-31
962	31	1
1155	34	-1
1157	34	1
1173	2	17
1190	1	-35
1218	5	-7
1230	7	5
1295	36	-1
1370	37	1
1463	2	19
1482	1	-39
1518	13	-3
1595	8	-5
1605	8	5
1722	1	41
# D	r	k
1767	14	3
2030	9	5
2093	2	-23
2117	46	1
2210	47	1
2301	16	-3
2618	3	17
2717	4	13
3135	56	-1
3230	3	-19
3335	2	-29
3365	58	1
3597	20	-3
3605	12	5
3813	2	-31
3990	3	21
4389	2	33
4758	23	-3
4893	10	-7
4935	2	35
5187	24	3
5330	73	1
5610	5	-15
5757	4	-19
6045	2	-39
# D	r	k
6405	16	5
6765	2	41
7035	4	-21
7733	8	-11
7755	8	11
9030	19	5
9605	98	1
10005	20	5
12045	2	-55
12155	2	55
13485	4	29
14405	24	5
14630	11	-11
14885	122	1
19565	4	-35
19635	4	35
20165	142	1
33117	26	-7
41613	68	-3
58565	242	1
77285	278	1
108885	22	-15
451605	32	21

#-------
# Table	A4(2)
# D	r	k
34	6	-1
51	7	1
66	8	1
87	3	3
102	10	1
119	11	-1
123	11	1
138	4	-3
146	12	1
194	14	-1
215	3	-5
231	5	3
258	16	1
287	17	-1
318	6	-3
330	6	3
390	4	-5
402	20	1
410	4	5
# D	r	k
435	7	-3
447	7	3
455	3	7
482	22	-1
527	23	-1
570	8	-3
615	5	-5
623	25	-1
627	25	1
635	5	5
678	26	1
770	4	-7
782	28	-1
798	4	7
843	29	1
890	6	-5
902	30	1
1022	32	-1
1095	11	3
# D	r	k
1235	7	5
1298	36	1
1302	12	3
1515	13	-3
1547	3	13
1610	8	5
1770	14	3
1938	44	1
1995	3	-15
2015	9	-5
2310	16	3
2387	7	-7
2415	7	7
2595	17	-3
2607	17	3
2730	4	13
2910	18	-3
3003	5	-11
3255	19	3
# D	r	k
3570	4	-15
3723	61	1
3842	62	-1
3927	3	-21
4290	2	-33
5655	5	15
6090	26	3
6555	27	-3
7215	17	-5
10010	20	5
10370	6	-17
12558	16	7
13695	39	3
19610	28	5
21318	146	1
22490	30	-5
25935	23	7
33495	61	3
81770	22	-13

# Table	A4(3)
# D	=	+	4^,	k	odd.
# D	r	k
85	9	1
165	1	-15
205	3	-5
221	1	-17
285	1	-19
357	1	-21
365	19	1
429	7	-3
533	23	1
629	25	1
645	5	5
741	9	3
957	1	-33
965	31	1
1085	1	-35
1205	7	-5
1245	7	5
1365	1	-39
1469	3	-13
1517	1	-41
1533	13	3
# D	r	k
1685	41	1
1853	43	1
1965	3	-15
2013	15	-3
2037	15	3
2045	9	5
2085	3	15
2373	7	-7
2397	1	-51
2405	49	1
2613	17	3
2805	1	-55
2813	53	1
3005	11	-5
3045	11	5
3237	19	-3
3485	59	1
3885	3	-21
3965	1	-65
4245	13	5
4277	4	13
# D	r	k
4485	1	-69
4773	23	3
5565	5	-15
5645	15	5
5885	7	-11
5957	11	7
6573	27	3
7157	5	-17
7293	5	17
7565	1	-89
7685	3	29
7917	1	-91
8333	7	13
8645	1	-95
9005	19	-5
9933	3	33
10205	101	1
10965	7	-15
11165	3	35
13845	3	39
14685	11	11
# D	r	k
15645	25	5
16133	127	1
16653	43	3
17765	7	19
18245	27	5
20405	13	-11
21045	29	5
23205	3	-51
24045	31	5
25493	3	53
26565	1	-165
30597	25	-7
31317	59	-3
32045	179	1
35805	9	21
41093	7	-29
55205	47	-5
74613	13	21
# Table A4(999) EOD

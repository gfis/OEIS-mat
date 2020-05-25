#!perl

# Extract parameters from Galebach's letter-based notation (unmarked_codes.txt)
# @(#) $Id$
# 2020-05-17, Georg Fischer
#
#:# usage:
#:#   perl extract_letters.pl unmarked_codes.txt > extract_letters.tmp
#---------------------------------
use strict;
use integer;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday) = gmtime (time);
my $utc_stamp = sprintf ("%04d-%02d-%02dT%02d:%02d:%02d\z"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
my $debug = 0;
my $nmax = 16;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug = shift(@ARGV);
    } elsif ($opt  =~ m{n}) {
        $nmax = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

#--------
# constant structures
my $tiling6 = 1248; # all up to 6-uniform
my @tiling_counts = (0, 11, 20, 61, 151, 332, 673, 1472); # = A068599 Number of n-uniform tilings. "tiling #i of #m in k-uniform ..." 
# remember the vertex encodings    
my @incr_vtypes; # notation with ascending  polygones 
my @decr_vtypes; # notation with descending polygones 
my $vdef = <<'GFis';
A: 3.3.3.3.3.3
B: 3.3.3.3.6
C: 3.3.3.4.4
D: 3.3.4.3.4
E: 3.3.4.12
F: 3.3.6.6
G: 3.4.3.12
H: 3.4.4.6
I: 3.4.6.4
J: 3.6.3.6
K: 3.12.12
L: 4.4.4.4
M: 4.6.12
N: 4.8.8
O: 6.6.6
GFis
my $icode = 0;
foreach my $def(split(/\r?\n/, $vdef)) {
    if ($def =~ m{(\w)\:\s*([\d\.]+)}) { # ignore empty entries
        my $code = $1;
        my $incrid = $2;
        my $decrid = join(".", reverse(split(/\./, $incrid)));
        $incr_vtypes[$icode] = $incrid;
        $decr_vtypes[$icode] = $decrid;
        # print join("\t", $icode, $code, $incrid, $decrid) . "\n";
        $icode ++;
    } # if not empty
} # foreach $def

#--------
# read 
my $galu = 0; # uniform
my $galt = 1; # tile no.
my $galv = 1; # vertex type index
my $oldu = 0; # old $galu

my $itiling = 0;
my $block_offset = 0;
while (<DATA>) {
	$itiling ++;
	last if $itiling > $tiling6;
    s{\s+\Z}{}; # chompr
    s{\s}{}g; # remove all spaces
    next if m{\A\#}; # ignore comments
    my @parts = split(/\;/);
    my $ipart = 0;
    $galu = ord(shift(@parts)) - ord('A') + 1; # k-uniform tiling
    if ($oldu != $galu) {
        $oldu = $galu;
        $galt = $tiling_counts[$galu];
        $galv = $galu;
        $block_offset += $tiling_counts[$galu - 1];
        print "# galu=$galu, galt=$galt, block_offset =$block_offset\n";
    }
    my $vertex_letters = shift(@parts);
    my @vertices = map {
        ord($_) - ord('A')
        } split(//, $vertex_letters);
    foreach my $base_vertex(@vertices) {
        my $pxnames = shift(@parts);
        my $pxedges = shift(@parts);
        # A265035   Gal.2.1.1   3.4.6.4; 4.6.12 12.6.4  A 180';A 120';B 90  1,3,6,9,11,14,17,21,25,28,30,32,35,39,43,46,48,50,53,57,61,64,66,68,71,75,79,82,84,86,89,93,97,100,102,104,107,111,115,118,120,122,125,129,133,136,138,140,143,147  12  xnewnot A265035 xname
        print join("\t"
            , "aseqno"
            , "Gal.$galu.$galt.$galv"
            , join("; ", map { $incr_vtypes[$_] } @vertices)
            , $decr_vtypes[$base_vertex]
            , $pxedges
            , "sequence"
            , $block_offset + $galt
            ) . "\n";
        $galv --;
    } # foreach $base_vertex
    $galt --;
    $galv = $galu;
} # while <>
#-----
sub repeat {
    my ($sep) = @_;
    return join($sep, "a");
} # repeat
#--------------------------------
__DATA__
A;A;AAAAAA;AAAAAA
A;B;AAAAA;EBDCA
A;C;AAAAA;DBCAE
A;D;AAAAA;EBDCA
A;I;AAAA;BADC
A;J;AAAA;BABA
A;K;AAA;BAC
A;L;AAAA;AAAA
A;M;AAA;abc
A;N;AAA;BAC
A;O;AAA;AAA
B;AB;AABABB;BACDBD;BAAAB;EECFA
B;AB;BBBBBB;BDBDBD;BABAB;EACBA
B;AC;AAABBA;ABFBCC;BAABB;DDEAE
B;AC;ABBABB;ABCABC;BAABB;DBCAE
B;AD;BBBBBB;BBBBBB;BABBB;CAAED
B;AE;BBBBBB;BbBbBb;BABB;aAcd
B;AF;BBBBBB;BBBBBB;BABB;CAAD
B;BF;BABAB;CBBDA;AAAB;ECAD
B;CD;BABBA;CBBeE;BAABA;dCAad
B;CD;BBBBA;EBbeE;BABBA;aBDCA
B;CI;BAABA;BCBAE;AABB;DADC
B;CL;AAAAB;DBCAA;ABAB;EBEB
B;CL;AAAAB;DBCAA;ABBB;EDCB
B;DI;BABAA;BBAED;AABB;CADC
B;FJ;BABA;BBAD;AAAA;CACA
B;GK;BAAB;BCBA;AAB;DAC
B;HI;ABAA;aAcd;AABB;BbDC
B;HJ;BAAA;BbCd;AAAA;aAaA
B;HJ;BAAA;Bbcd;AAAA;aAaA
B;IM;AABB;BAbB;BAB;aDc
C;AAB;AABBCB;BAAECB;AACCAB;CFBDDF;CBABC;ECEDA
C;AAB;BCBCBC;ACACAC;ACCACC;ABDABD;CBABC;EBBCA
C;AAB;CBBCBB;CCFCCF;BBACCA;BABBDC;CBABC;EDAEA
C;AAC;AAABBA;ABFABC;AABCCB;DEFBCC;CBBCC;DDEAE
C;AAC;ABBABB;AABAAB;AABCCB;BCFBCC;CBBCC;DDEAE
C;ABB;BCCBCC;CBbCBb;CCACC;ECAce;CABCB;aBBDA

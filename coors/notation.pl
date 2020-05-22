#!perl

# Convert between Galebach's tiling notations
# - letter-based notation (unmarked_codes.txt) 
# - angle-based  notaatin (a250120.html)
# @(#) $Id$
# 2020-05-18, Georg Fischer
#
#:# usage:
#:#   perl notation.pl -l unmarked_codes.txt > notation.tmp
#:#   perl notation.pl -a a250120.tmp        > notation.tmp
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
my @tiling_counts = (0, 11, 20, 61, 151, 332, 673, 1472); 
    # = A068599 Number of n-uniform tilings. "tiling #i of #m in k-uniform ..." 
    
# remember the new base vertex encodings    
my @incr_vtcodes; # notation with ascending  polygones 
my @decr_vtcodes; # notation with descending polygones 
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
#              0    1    2    3    4    5    6    7    8    9   10   11   12
my @polian = (-1,  -1,  -1,  60,  90, 108, 120,  -1, 135, 140, 144,  -1, 150); # inner angles of regular polygons

foreach my $def(split(/\r?\n/, $vdef)) {
    if ($def =~ m{(\w)\:\s*([\d\.]+)}) { # ignore empty entries
        my $code = $1;
        my $incrid = $2;
        my $decrid = join(".", reverse(split(/\./, $incrid)));
        $incr_vtcodes[$icode] = $incrid;
        $decr_vtcodes[$icode] = $decrid;
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
my @vtnames = ();
my @vertices= ();
my @vtanges = ();
my @pxnotas = ();
my @pxnames = ();
my @pxedges = ();
my @specs   = ();

while (<DATA>) {
    $itiling ++;
    last if $itiling > $tiling6;
    s{\s+\Z}{}; # chompr
    s{\s}{}g; # remove all spaces
    next if m{\A\#}; # ignore comments
    my @parts = split(/\;/);
    my $ipart = 0;
    $galu = ord(shift(@parts)) - ord('A') + 1; # first letter: code for u-uniform tiling -> u=1..7
    if ($oldu != $galu) { # group change of u
        $oldu = $galu;
        $galt = $tiling_counts[$galu];
        $galv = $galu;
        $block_offset += $tiling_counts[$galu - 1];
        if ($debug >= 2) {
            print "# galu=$galu, galt=$galt, block_offset =$block_offset\n";
        }
    } # new group k
    my $nstdnot = shift(@parts); # codes for involved vertex types (standard notation)
    @vertices = map {
        &linx($_)
        } split(//, $nstdnot);
    my 
    $vtind = 0;
    foreach my $base_vertex(@vertices) { # for each involved vertex type
    #   @pxnames = map { s{([A-Z])}{chr(ord('A') + $galu - 1 - &linx($1))}ge ; $_ 
        @pxnames = map { $_
                          } split(//, shift(@parts)); # proxy names
        @pxedges = map { s{([A-Z])}{'+' . (&linx(uc($1)) + 1)}ge; 
                         s{([a-z])}{'-' . (&linx(uc($1)) + 1)}ge; 
                         $_
                       } split(//, shift(@parts)); # proxy edges
        my $iedge = 0;
        $pxnotas[$vtind] = join(",", map { $_ . $pxedges[$iedge ++] } @pxnames);
        $galv --;
        $vtind ++;
    } # foreach $base_vertex
    $vtind = 0;
    foreach my $base_vertex(@vertices) { # for each involved vertex type
        if ($debug >= 1) {
        	print "# pxnotas=[" . join("], [", @pxnotas) . "]\n";
        }
        @specs = map { 
            &insert_angle($_)
            } split(/\,/, $pxnotas[$vtind]);
        print join("\t"
            , "Ano"
            , "Gal.$galu.$galt.$galv"
            , join(";", map { $incr_vtcodes[$_] } @vertices)
            , chr(ord('A')         + $vtind    ) . "="
            , $incr_vtcodes[$base_vertex]
            , join(",", @specs)
            , "seq"
            , sprintf("%d", $block_offset + $galt)
            ) . "\n";
        # A265035   Gal.2.1.1   3.4.6.4; 4.6.12 12.6.4  A 180';A 120';B 90  1,3,6,9,11,14,17,21,25,28,30,32,35,39,43,46,48,50,53,57,61,64,66,68,71,75,79,82,84,86,89,93,97,100,102,104,107,111,115,118,120,122,125,129,133,136,138,140,143,147  12  xnewnot A265035 xname
        $vtind ++;
    } # foreach $base_vertex
    print "#----\n";
    $galt --;
    $galv = $galu;
} # while <>
#--------------------------------
# B=      3.4.6.4 B+2,B+1,A-2,A+2
# A=      4.6.12  A-1,B+4,A-3
sub insert_angle {
    my ($fospec) = @_; # e.g. "A-1"
    $fospec     =~ m{(\w)([\+\-])(\d+)};
    my ($focode, $fosign, $foedge) = ($1, $2, $3);
    if ($debug >= 1) {
    	print "# fospec=$fospec, focode=$focode, foedge=$foedge\n";
    }
    my @pxspecs = split(/\,/, $pxnotas[&linx($focode)]);
    my $pxspec  = $pxspecs[$foedge - 1];
    if ($debug >= 1) {
    	print "#     pxspecs=" . join(",", @pxspecs) . ", foedge=$foedge, pxspec=$pxspec\n";
    }
    $pxspec    =~ m{(\w)([\+\-])(\d+)};
    my ($pxcode, $pxsign, $pxedge) = ($1, $2, $3);
    my $orient  = ("${fosign}1") * ("${pxsign}1");
    if ($debug >= 1) {
    	print "#     $fospec -> $pxspec, orient=$orient\n";
    }
    my $angle   = 180 + &sweep_angle($focode, $foedge) - $orient * &sweep_angle($pxcode, $pxedge);
    if ($angle < 0) {
    	$angle += 360;
    }
    if ($angle >= 360) {
    	$angle -= 360;
    }
    $fospec     = $focode . $angle . $fosign . $foedge;
    if ($debug >= 1) {
    	print "#     -> new fospec=$fospec, angle=$angle\n";
    }
    return "$fospec";
} # insert_angle

sub get_spec {
	my ($code, $jedge) = @_; # letter, jedge starts at 1
	
	return
} # get_spec
#----
sub linx { # letter to index
    my ($letter) = @_;
    return ord($letter) - ord('A');
} # linx
#-----
sub sweep_angle {
    my ($code, $jedge) = @_;
    my $vertex = $code;
    if ($code =~ m{[A-Z]}) {
        $vertex = $incr_vtcodes[$vertices[&linx($code)]];
    }
    if ($debug >= 1) {
    	print "#       vertex=$vertex\n";
    }
    my @polys = split(/\./, $vertex); # 12.6.4  150,120,90
    my $sum = 0;
    my $kedge = 0;
    while ($kedge < $jedge - 1) {
        $sum += $polian[$polys[$kedge]];
        if ($debug >= 1) {
            print "#         kedge=$kedge, jedge=$jedge, polys=$polys[$kedge], polian=$polian[$polys[$kedge]], sum=$sum\n";
        }
        $kedge ++;
    } # while
    if ($debug >= 1) {
    	print "#       sweep_angle($code=$vertex, edge=$jedge) = $sum\n";
    }
    return $sum;
} # sweep_angle
#--------------------------------
__DATA__
# A;O;AAA;AAA
# B;AB;AABABB;BACDBD;BAAAB;EECFA
# B;AB;BBBBBB;BDBDBD;BABAB;EACBA
# B;AC;AAABBA;ABFBCC;BAABB;DDEAE
# B;AC;ABBABB;ABCABC;BAABB;DBCAE
# B;AD;BBBBBB;BBBBBB;BABBB;CAAED
# B;AE;BBBBBB;BbBbBb;BABB;aAcd
# B;AF;BBBBBB;BBBBBB;BABB;CAAD
# B;BF;BABAB;CBBDA;AAAB;ECAD
# B;CD;BABBA;CBBeE;BAABA;dCAad
# B;CD;BBBBA;EBbeE;BABBA;aBDCA
# B;CI;BAABA;BCBAE;AABB;DADC
# B;CL;AAAAB;DBCAA;ABAB;EBEB
# B;CL;AAAAB;DBCAA;ABBB;EDCB
# B;DI;BABAA;BBAED;AABB;CADC
# B;FJ;BABA;BBAD;AAAA;CACA
# B;GK;BAAB;BCBA;AAB;DAC
# B;HI;ABAA;aAcd;AABB;BbDC
# B;HJ;BAAA;BbCd;AAAA;aAaA
# B;HJ;BAAA;Bbcd;AAAA;aAaA
B;IM;AABB;BAbB;BAB;aDc
# C;AAB;AABBCB;BAAECB;AACCAB;CFBDDF;CBABC;ECEDA

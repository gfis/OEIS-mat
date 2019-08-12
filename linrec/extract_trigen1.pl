#!perl

# Extract triangles with main diagonal == 1
# @(#) $Id$
# 2019-07-08, Georg Fischer
#
#:# Usage:
#:#   perl extract_trigen1.pl [-d debug] trigen.tmp > trigen1.tmp
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
$timestamp = sprintf ("%04d-%02d-%02d", $year + 1900, $mon + 1, $mday);

my $debug = 0;
if (scalar(@ARGV) < 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my @t; # triangular matrix
my $line;
my $aseqno;
while (<>) {
    $line = $_;
    $line =~ s/\s+\Z//; # chompr
    if ($line =~ m{^(A\d+)\s+(.*)}) { # with A-number
        $aseqno  = $1;
        my $data = $2;
        my @terms = split(/\,/, $data);
        # now test the main diagonal for "1"
        my $nterm = scalar(@terms);
        my $ind = 0;
        my $n = 0;
        my $k;
        my $busy = 1;
        while ($busy > 0 and $ind < $nterm) {
            for ($k = 0; $k <= $n and $ind < $nterm; $k ++) {
                # print "t[$n][$k] = $terms[$ind]\n";
                $t[$n][$k] = $terms[$ind ++];
            } # for $k
            if ($k == $n and &get($n, $n) != 1) {
                $busy = 0;
            }
            $n ++;
            # $ind += $rowlen;
        } # while $ind
        if ($busy == 1) {
            # print join("\t", $aseqno, "tabl", $data) . "\n";
        }
        my $nmax = $n;
        my $busy2 = 1;
        my @s = (); # 2nd coefficents
        for ($n = 0; $n < $nmax; $n ++) {
            for ($k = 0; $k < $n; $k ++) {
                if (&get($n-1, $k) != 0) {
                    my $rest = (&get($n, $k) - &get($n-1, $k-1)) % &get($n-1, $k);
                    if ($rest == 0) {
                        push(@s, (&get($n, $k) - &get($n-1, $k-1)) / &get($n-1, $k));
                    } else {
                        $busy2 = 0;
                        # push(@s, sprintf("%.1f", (&get($n, $k) - &get($n-1, $k-1)) / &get($n-1, $k)));
                    }
                } else {
                	push(@s, 0);
                }
            } # for $k
        } # for $n
        if ($busy == 1 and $busy2 == 1) {
            print join("\t", $aseqno, "tabl", $data) . "\n";
            print join("\t", $aseqno, "sk  ", join(",", @s)) . "\n";
        }
    } # with A-number
} # while <>
#----
sub get {
    my ($n, $k) = @_;
    return ($k >= 0 and $k <= $n) ? ($t[$n][$k] || 0) : 0;
} # get
#--------------------------------------------
__DATA__
A000369 1,3,1,21,9,1,231,111,18,1,3465,1785,345,30,1,65835,35595,7650,825,45,1,1514205,848925,196245,24150,1680,63,1,40883535,23586255,5755050,775845,62790,3066,84,1,1267389585,748471185,190482705,27478710
A001263 1,1,1,1,3,1,1,6,6,1,1,10,20,10,1,1,15,50,50,15,1,1,21,105,175,105,21,1,1,28,196,490,490,196,28,1,1,36,336,1176,1764,1176,336,36,1,1,45,540,2520,5292,5292,2520,540,45,1,1,55,825,4950,13860,19404,13860,4950,825

A216916     Triangle read by rows, T(n,k) for 0<=k<=n, generalizing A098742.        1
%I
%S 1,1,1,3,3,1,9,12,6,1,33,51,34,10,1,135,237,193,79,15,1,609,1188,1132,
%T 584,160,21,1,2985,6381,6920,4268,1510,293,28,1,15747,36507,44213,
%U 31542,13576,3464,497,36,1,88761,221400,295314,238261,120206,37839,7231,794
%N Triangle read by rows, T(n,k) for 0<=k<=n, generalizing A098742.
%C Full concordance with A098742 would require two zero rows at the top of the triangle which we omitted for simplicity.
%C Matrix inverse is A137338. - _Peter Luschny_, Sep 21 2012
%F Recurrence: T(0,0)=1, T(0,k)=0 for k>0 and for n>=1 T(n,k) = T(n-1,k-1) + (k+1)*T(n-1,k) + (k+2)*T(n-1,k+1).
%e [0] [1]
%e [1] [1, 1]
%e [2] [3, 3, 1]
%e [3] [9, 12, 6, 1]
%e [4] [33, 51, 34, 10, 1]
%e [5] [135, 237, 193, 79, 15, 1]
%e [6] [609, 1188, 1132, 584, 160, 21, 1]
%e [7] [2985, 6381, 6920, 4268, 1510, 293, 28, 1]
%e [8] [15747, 36507, 44213, 31542, 13576, 3464, 497, 36, 1]
%o (Sage)
%o def A216916_triangle(dim):
%o T = matrix(SR,dim,dim)
%o for n in range(dim): T[n,n] = 1
%o for n in (1..dim-1):
%o for k in (0..n-1):
%o T[n,k] = T[n-1,k-1]+(k+1)*T[n-1,k]+(k+2)*T[n-1,k+1]
%o return T
%o A216916_triangle(9)
%K nonn,tabl
%O 0,4
%A _Peter Luschny_, Sep 20 2012
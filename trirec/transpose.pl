#!perl

# Transpose bfdata of "tabl" triangles
# @(#) $Id$
# 2021-11-10, Georg Fischer
#
#:# Usage:
#:#   cat $(COMMON)/bfdata.txt \
#:#   | perl transpose.pl [-s split] [-d debug] > outfile
#:#       -s split first 1, 3 ... terms (default: initial_terms are empty)
#:#       outfile has the tab-separated format: aseqno, "original|transpose" termno initial_terms remaining_terms
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
$timestamp = sprintf ("%04d-%02d-%02d", $year + 1900, $mon + 1, $mday);

if (scalar(@ARGV) < 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
my $split = 0;
my $debug = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{s}) {
        $split     = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

# while (<DATA>) {
while (<>) {
    s/\s+\Z//; # chompr;
    my ($aseqno, $termno, $list) = split(/\t/);
    my @buffer = ();
    my @terms = split(/\,/, $list);
    my $nterm = scalar(@terms);
    my $ind = 0;
    my $n = 0;
    my $k;
    my $busy = 1;
    while ($busy && $ind < $nterm) { # build an array T(n,k) with the triangle
        if ($ind + $n + 1 < $nterm) { # complete row still available
            my @t = (); # 1 row of triangular matrix
            for ($k = 0; $k <= $n; $k ++) {
                push(@t, $terms[$ind ++]);
            } # for $k
            @t = reverse(@t);
            push(@buffer, @t);
            $n ++;
        } else { # incomplete row
            $busy = 0;
        }
    } # while $ind
    if ($ind != scalar(@buffer)) {
        print STDERR "assertion: $ind != " . scalar(@buffer) . "\n";
    }
    if ($ind > 10 && (join(",", @terms) ne join(",", @buffer))) { # long enough and not symmetrical
        print join("\t", $aseqno, "original" , $ind, join(",", splice(@terms , 0, $split)), join(",", splice(@terms, 0, $ind  - $split) )) . "\n"; 
        print join("\t", $aseqno, "transpose", $ind, join(",", splice(@buffer, 0, $split)), join(",", @buffer)) . "\n"; 
    }
} # while <>
#--------------------------------------------
__DATA__
A007318	259	1,1,1,1,2,1,1,3,3,1,1,4,6,4,1,1,5,10,10,5,1,1,6,15,20,15,6,1,1,7,21,35,35,21,7,1,1,8,28,56,70,56,28,8,1,1,9,36,84,126,126,84,36,9,1,1,10,45,120,210,252,210,120,45,10,1,1,11,55,165,330,462,462,330,165,55,11,1,1,12,66,220,495,792,924,792,495,220,66,12,1,1,13,78,286,715,1287,1716,1716,1287,715,286,78,13,1,1,14,91,364,1001,2002,3003,3432,3003,2002,1001,364,91,14,1,1,15,105,455,1365,3003,5005,6435,6435,5005,3003,1365,455,105,15,1,1,16,120,560,1820,4368,8008,11440,12870,11440,8008,4368,1820,560,120,16,1,1,17,136,680,2380,6188,12376,19448,24310,24310,19448,12376,6188,2380,680,136,17,1,1,18,153,816,3060,8568,18564,31824,43758,48620,43758,31824,18564,8568,3060,816,153,18,1,1,19,171,969,3876,11628,27132,50388,75582,92378,92378,75582,50388,27132,11628,3876,969,171,19,1,1,20,190,1140,4845,15504,38760,77520,125970,167960,184756,167960,125970,77520,38760,15504,4845,1140,190,20,1,1,21,210,1330,5985,20349,54264,116280,203490,293930,352716,352716,293930,203490,116280,54264,20349,5985,1330,210,21,1,1,22,231,1540,7315,26334
A054445	59	1,2,1,5,3,1,14,9,4,1,42,28,14,5,1,132,90,48,20,6,1,429,297,165,75,27,7,1,1430,1001,572,275,110,35,8,1,4862,3432,2002,1001,429,154,44,9,1,16796,11934,7072,3640,1638,637,208,54,10,1,58786,41990,25194,13260

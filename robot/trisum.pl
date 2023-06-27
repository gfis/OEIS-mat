#!perl

# Extract formulas for sums of triangles (G.A.)
# @(#) $Id$
# 2023-06-06, Georg Fischer; RH=77
#
#:# Usage:
#:#   perl nyi.pl -q trisum 
#:#   | perl trisum.pl [-d debug] > trisum.gen
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
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my $line;
while (<>) {
    $line = $_;
    $line =~ s/\s+\Z//; # chompr
    my ($aseqno, $callcode, $offset, $name) = split(/\t/, $line);
    my @factors = ();
    my @rseqnos = ();
    $name =~ s{A000012(\^\(\-1\)| *\(signed)}{A097807}g;
    $name =~ s{A007318(\^\(\-1\)| *\(signed)}{A130595}g;
    $name =~ s{\bI\b}{A023531}g;
    if(0) { 
    #                   12         2      1 3    3  4     4  56   6      5 7    7  8         10           11      12        14           15
    } elsif ($name =~ m{(([-\+]?\d*) *\* *)?(A\d+) *([-\+]) *((\d+) *\* *)?(A\d+) *([-\+]) *((\d+) *\* *)?(A\d+) *([-\+]) *((\d+) *\* *)?(A\d+)}) { 
        @factors = ($2 || 1, $4 . ($6 || 1), $8 . ($10 || 1), $12 . ($14 || 1));
        @rseqnos = ($3, $7, $11, $15);
    #                   12         2      1 3    3  4     4  56   6      5 7    7
    } elsif ($name =~ m{(([-\+]?\d*) *\* *)?(A\d+) *([-\+]) *((\d+) *\* *)?(A\d+) *([-\+]) *((\d+) *\* *)?(A\d+)}) { 
        @factors = ($2 || 1, $4 . ($6 || 1), $8 . ($10 || 1));
        @rseqnos = ($3, $7, $11);
    #                   12         2      1 3    3  4     4  56   6      5 7    7
    } elsif ($name =~ m{(([-\+]?\d*) *\* *)?(A\d+) *([-\+]) *((\d+) *\* *)?(A\d+)}) { 
        @factors = ($2 || 1, $4 . ($6 || 1));
        @rseqnos = ($3, $7);
    }
    my $rcount = scalar(@rseqnos);
    if ($rcount >= 2) {
        print join("\t", $aseqno, "trisum$rcount", 0, @factors, @rseqnos) . "\n";
    }
} # while <>
#--------------------------------------------
__DATA__
A131305 trisum  0   2*A122288 - A000012.    nonn,tabl   0..54   nyi _Gary W. Adamson_
A131324 trisum  0   2*A049310 - A000012(signed).    nonn,tabl,more  0..54   nyi _Gary W. Adamson_
A131350 trisum  0   2*A007318 - A049310 as infinite lower triangular matrices.  nonn,tabl   0..54   nyi _Gary W. Adamson_
A131373 trisum  0   A046854 + A065941 - A000012.    nonn,tabl   0..54   nyi _Gary W. Adamson_
A131374 trisum  0   A046854 + A065941 - A049310.    nonn,tabl   0..54   nyi _Gary W. Adamson_
A131375 trisum  0   A007318 + A046854 - A049310.    nonn,tabl   0..54   nyi _Gary W. Adamson_

#!perl

# Evaluate b-file links and create a tab-separated list
# @(#) $Id$
# 2019-01-06, Georg Fischer
#
# usage:
#   perl bflink.pl ../broken_link/bigout1 > bflink.txt 2> bflink_strange.txt
#---------------------------------
use strict;
use integer;
my ($aseqno, $author, $rest, $var, $sname, $range, $imin, $between, $imax, $comment1, $comment2);
my $count = 0;
while (<>) {
    s/\s+\Z//; # chompr
    my $line = $_;
    if ($line =~ m{\A\%H A(\d+) ([^\<]*)\<a href\=\"\/A\1\/b\1\.txt\"\>\s*(.*)}) {
        (             $aseqno,  $author,                                  $rest) 
            = (       $1,       $2,                                       $3);
        $author =~ s{\,\s*\Z}{}; # remove trailing 
        $var = "";
        $sname = "";
        $between = "";
        if (0) {
        } elsif ($rest =~ m{Table\s+of\s+([a-z])\,\s*(\w+)\s*\(\1\)\s*(\,\s*|for\s*)?\1\s*\=\s*(\-?\d+)\s*(\-|to|[\:\.\,]+)\s*(\-?\d+)}i) {
            (                            $var,       $sname,                                   $imin,     $between,           $imax)
                = (                      $1,         $2,                                       $4,        $5,                 $6);
                $sname .= "($var)";
#        } elsif ($rest =~ m{Table\s+of\s+(the\s+)?(first\s+)?(\d+)\s+rows}i) {
#            (                                                $imax)
#                = (                                          $3);
#            $imin = 1;
#            $sname = "first";
        } elsif ($rest =~ m{first\s*(\d+)\s*term}i) {
            (                       $imax)
                = (                 $3);
            $imin = 1;
            $sname = "first";
        } elsif (($rest =~ m{flatten}i) or ($author =~ m{Alois|Luschny})) {
            if (0) {
            } elsif ($rest =~ m{(\-?\d+)\s*(\-|[\:\.\,]+)\s*(\-?\d+)}) { # range found
                (               $imin,     $between,        $imax)
                    = (         $1,        $2,              $3);
                if (0) {
                } elsif ($rest =~ m{(row|antidiag)}i) {
                    $sname = lc($1);
                    my $len = $imax - $imin + 1;
                    $imin = 1;
                    $imax = $len / 2 * ($len + 1);
                } else {
                    $sname = "";
                }
            } elsif ($rest =~ m{first\s*(\-?\d+)}i) { 
                (                       $imax)
                    = (                 $1);
                if (0) {
                } elsif ($rest =~ m{(row|adiag)}i) {
                    $sname = lc($1);
                  	$imin = 1;
                    my $len = $imax - $imin + 1;
                    $imax = $len / 2 * ($len + 1);
                } elsif ($rest =~ m{\d\s+term}i) {
                    $sname = "term";
                  	$imin = 1;
                } else {
                    $sname = "";
                }
            } else {
                $imin = 0;
                $imax = -1;
                $sname = "unspec";
            } # no range found  
            # flatten
        } else {
            print STDERR "# uncommon: $line\n";
        }
        print join("\t", ("b$aseqno.txt", $imin, $imax, $sname, $between, $author)) . "\n"; 
        $count ++;
    } elsif ($line =~ m{\"\/A\d+\/b\d+\.txt\"\>}) {
        print STDERR "# foreign: $line\n";
    } else { # other link, ignore
    }
} # while <>
print STDERR sprintf("# $count b-file parameters written\n", $count);
__DATA__
%H A000001 H.-U. Besche and Ivan Panchenko, <a href="/A000001/b000001.txt">Table of n, a(n) for n = 0..2047</a> [Terms 1 through 2015 copied from Small Groups Library mentioned below. Terms 2016 - 2047 added by Ivan Panchenko, Aug 29 2009. 0 prepended by _Ray Chandler_, Sep 16 2015.]
%H A000002 N. J. A. Sloane, <a href="/A000002/b000002.txt">Table of n, a(n) for n = 1..10502</a>
%H A000003 N. J. A. Sloane, <a href="/A000003/b000003.txt">Table of n, a(n) for n = 1..20000</a>
%H A000004 N. J. A. Sloane, <a href="/A000004/b000004.txt">Table of n, a(n) for n = 0..1000</a> [Useful when plotting one sequence against another. See Swayne link.]
%H A000005 Daniel Forgues, <a href="/A000005/b000005.txt">Table of n, a(n) for n = 1..100000</a> (first 10000 terms from N. J. A. Sloane)
%H A000005 Wikipedia, <a href="http://www.wikipedia.org/wiki/Table_of_divisors">Table of divisors</a>.
%H A000006 T. D. Noe, <a href="/A000006/b000006.txt">Table of n, a(n) for n = 1..10000</a>
%H A000007 David Wasserman, <a href="/A000007/b000007.txt">Table of n, a(n) for n = 0..1000</a>
%H A000008 William Boyles, <a href="/A000008/b000008.txt">Table of n, a(n) for n = 0..10000</a> (Terms 0...1000 from T. D. Noe)
%H A000009 R. Zumkeller, <a href="/A000009/b000009.txt">Table of n, a(n) for n = 0..5000</a>, First 2000 terms from N. J. A. Sloane
%H A000010 Daniel Forgues, <a href="/A000010/b000010.txt">Table of n, phi(n) for n = 1..100000</a> (first 10000 terms from N. J. A. Sloane)
%H A000010 M. Lal and P. Gillard, <a href="http://dx.doi.org/10.1090/S0025-5718-69-99858-5">Table of Euler's phi function, n < 10^5</a>, Math. Comp., 23 (1969), 682-683.
%H A000011 Seiichi Manyama, <a href="/A000011/b000011.txt">Table of n, a(n) for n = 0..3335</a> (first 201 terms from T. D. Noe)
%H A000012 Charles R Greathouse IV, <a href="/A000012/b000012.txt">Table of n, a(n) for n = 0..10000</a> [Useful when plotting one sequence against another. See Swayne link.]
%H A000013 T. D. Noe and Seiichi Manyama, <a href="/A000013/b000013.txt">Table of n, a(n) for n = 0..3334</a> (first 201 terms from T. D. Noe)
%H A000014 Christian G. Bower, <a href="/A000014/b000014.txt">Table of n, a(n) for n = 0..500</a>
%H A000015 David W. Wilson, <a href="/A000015/b000015.txt">Table of n, a(n) for n = 1..10000</a>
%H A000016 T. D. Noe and Seiichi Manyama, <a href="/A000016/b000016.txt">Table of n, a(n) for n = 0..3334</a> (first 201 terms from T. D. Noe)
%H A000019 N. J. A. Sloane, <a href="/A000019/b000019.txt">Table of n, a(n) for n=1..2499</a> [Computed using the GAP command shown below, which uses the results of Colva M. Roney-Dougal]
%H A000020 David W. Wilson, <a href="/A000020/b000020.txt">Table of n, a(n) for n = 1..400</a>
%H A000022 N. J. A. Sloane, <a href="/A000022/b000022.txt">Table of n, a(n) for n = 0..60</a>
%H A000023 Simon Plouffe, <a href="/A000023/b000023.txt">Table of n, a(n) for n = 0..250</a>
%H A000025 T. D. Noe, <a href="/A000025/b000025.txt">Table of n, a(n) for n = 0..1000</a>
%H A000026 T. D. Noe, <a href="/A000026/b000026.txt">Table of n, a(n) for n = 1..10000</a>
%H A000027 N. J. A. Sloane, <a href="/A000027/b000027.txt">Table of n, a(n) for n = 1..500000</a> [a large file]
%H A000028 N. J. A. Sloane, <a href="/A000028/b000028.txt">Table of n, a(n) for n = 1..10000</a>

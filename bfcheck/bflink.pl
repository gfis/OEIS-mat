#!perl

# Evaluate b-file links and create a tab-separated list
# @(#) $Id$
# 2019-01-15: .c|-x; A.number; Werner=72
# 2019-01-06, Georg Fischer
#
# usage:
#   perl bflink.pl -x ../broken_link/bigout1 > bflink.txt 2> bflink_strange.txt
#       extract range information and buthor
#   perl bflink.pl -c > bflink.create.sql
#       CREATE SQL
#---------------------------------
use strict;
use integer;
use warnings;

my $TIMESTAMP = &iso_time(time());
my $debug      = 0;

my ($aseqno, $buthor, $rest, $var, $sname, $imin, $irange, $imax, $maxllen, $fsize, $status);
my $count = 0;
my $action = shift(@ARGV);
my $tabname = "bflink";
if (0) {
} elsif ($action =~ m{c}) {
   print <<"GFis";
-- Table for OEIS b-file checking
-- @(#) \$Id\$
-- $TIMESTAMP - generated by bfdata.pl -c $tabname, do not edit here!
DROP    TABLE  IF EXISTS $tabname;
CREATE  TABLE            $tabname
    ( aseqno  VARCHAR(10)
    , imin    BIGINT          
    , imax    BIGINT  
    , sname   VARCHAR(16)
    , irange  VARCHAR(64)
    , buthor  VARCHAR(128)
    , maxllen INT
    , fsize   INT
    , status  VARCHAR(32)
    , PRIMARY KEY(aseqno)
    );
COMMIT;
GFis
} elsif ($action =~ m{x}) {
    $maxllen = 0;
    $status  = "href";
    while (<>) {
        s/\s+\Z//; # chompr
        my $line = $_;
        $count ++;
        if ($line =~ m{\A\%H A(\d+) ([^\<]*)\<a href\=\"\/A\1\/b\1\.txt\"\>\s*(.*)}) {
            (             $aseqno,  $buthor,                                  $rest) 
                = (       $1,       $2,                                       $3);
            $aseqno  = "A$aseqno";
            $buthor  =~ s{\,\s*\Z}{}; # remove trailing comma
            $var     = "?";
            $sname   = "?";
            $irange  = "?";
            $fsize   = -1;
            $maxllen = -1;
            $imin    = 1;
            $imax    = -1;
            if (0) {
            } elsif ($rest =~ m{Table\s+(of|for|)\s*([a-z])\,\s*(\w+)\s*\(\2\)\s*(\,\s*|for\s*)?\2\s*\=\s*(\-?\d+)\s*(\-|to|[\:\.\,]+)\s*(\-?\d+)}i) {
                (                                   $var,       $sname,                                   $imin,     $irange,           $imax)
                    = (                             $2,         $3,                                       $5,        $6,                 $7);
                    $sname .= "($var)";
            } elsif ($rest =~ m{first\s*(\d+)\s*term}i) {
                (                       $imax)
                    = (                 $3);
                $imin = 1;
                $sname = "first";
            } elsif (($rest =~ m{flatten}i) or ($buthor =~ m{Alois|Luschny})) {
                if (0) {
                } elsif ($rest =~ m{(\-?\d+)\s*(\-|[\:\.\,]+)\s*(\-?\d+)}) { # range found
                    (               $imin,     $irange,         $imax)
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
                    $sname = "unspec";
                } # no range found  
                # flatten
            } else {
                $rest =~ s/Table\s+of//;
                $irange = substr($rest, 0, 32);
                print STDERR "# uncommon: $line\n";
            }
            if ($imin eq '') {
            	$imin = 1;
            }
            if ($imax eq '') {
            	$imax = -1;
            }
            print join("\t"
                , ($aseqno, $imin, $imax, $sname, $irange, $buthor, $maxllen, $fsize, $status)
                ) . "\n"; 
        } elsif ($line =~ m{\"\/A\d+\/b\d+\.txt\"\>}) {
            print STDERR "# foreign: $line\n";
        } else { # other link, ignore
        }
    } # while <>
    print STDERR sprintf("# %d b-file parameters written\n", $count);
} else {
    die "invalid action \"$action\"\n";
}
#----
sub iso_time {
    my ($unix_time) = @_;
    my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
    return sprintf ("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
} # iso_time
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

b000001.txt 0   2047    a(n)    ..  H.-U. Besche and Ivan Panchenko
b000002.txt 1   10502   a(n)    ..  N. J. A. Sloane
b000003.txt 1   20000   a(n)    ..  N. J. A. Sloane
b000004.txt 0   1000    a(n)    ..  N. J. A. Sloane
b000005.txt 1   100000  a(n)    ..  Daniel Forgues
b000006.txt 1   10000   a(n)    ..  T. D. Noe
b000007.txt 0   1000    a(n)    ..  David Wasserman
b000008.txt 0   10000   a(n)    ..  William Boyles
b000009.txt 0   5000    a(n)    ..  R. Zumkeller
b000010.txt 1   100000  phi(n)  ..  Daniel Forgues
b000011.txt 0   3335    a(n)    ..  Seiichi Manyama
b000012.txt 0   10000   a(n)    ..  Charles R Greathouse IV
b000013.txt 0   3334    a(n)    ..  T. D. Noe and Seiichi Manyama

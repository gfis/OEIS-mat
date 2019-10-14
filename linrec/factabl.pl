#!perl

# Get 'tabl' sequences with right edge = factorials from stripped
# @(#) $Id$
# 2019-08-12, Georg Fischer
#
#:# Usage:
#:#   perl factabl.pl stripped > outfile
#---------------------------------
use strict;
use integer;
use warnings;
my $version = "V1.1";
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);

my $stripped  = "../common/stripped";
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{s}) {
        $stripped  = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my ($aseqno, $data);
while (<>) {
    s/\s+\Z//; # chompr
    ($aseqno, $data) = split(/\s+/);
    my @terms = split(/\,/, $data);
    if ($terms[ 5] ==   2 and
        $terms[ 9] ==   6 and 
        $terms[14] ==  24 and 
        $terms[20] == 120 ) 
    { 
        print join("\t", $aseqno, $data) . "\n";
    }
} # while <>
#--------------------
sub output {
} # output
#--------------------
__DATA__
A118980 Triangle read by rows: rows = inverse binomial transforms of A118979 columns.
1, 2, 1, 6, 5, 2, 14, 22, 18, 6, 34, 85, 118, 84, 24, 82, 311, 660, 780, 480, 120
0  1  2  3  4  5   6   7   8  9  10  11   12  13  14  15   16   17   18   19   20
First few rows of the triangle are:
1;
2, 1;
6, 5, 2;
14, 22, 18, 6;
34, 85, 118, 84, 24;
82, 311, 660, 780, 480, 120;

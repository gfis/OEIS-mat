#!perl

# Extract hypergeometric paramters from holref.txt
# @(#) $Id$
# 2022-07-14, Georg Fischer; CKZ=70
#
#:# Usage:
#:#   grep "holon" holref.txt \
#:#   | perl hyperext.pl > output.seq4
#---------------------------------
use strict;
use integer;
use warnings;
my $version = "V1.1";
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);

my $debug  = 0;
my $num    = 16; # generate from -num to +num
my $seqno = 500000;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{n}) {
        $num    = shift(@ARGV);
    } elsif ($opt  =~ m{d}) {
        $debug  = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

while (<>) {
    s/\s+\Z//;
    my ($aseqno, $callcode, $offset1, $matrix, $init, $dist, $gftype, $keyword) = split(/\t/);
    $init =~ s{[\[\] ]}{}g;
    if ($init =~ m{\A1(\,|\Z)}) {
        my @parts = split(/\] *\, *\[/, $matrix);
        if ($parts[0] eq "[[0") {
            if (scalar(@parts) == 3) {
                print join("\t", ($aseqno, $callcode, $offset1, $matrix, $init, $dist, $gftype, $keyword)) . "\n";
            }
        }
    }
} # while <>
__DATA__
A000407 holos   0   [[0],[4,8],[-2]]    [1] 0   1*2*a(n) + (-4)*(2*n-1)*a(n-1) = 0;
A001147 holos   0   [[0],[-2,4],[-2]]   [1] 0   1*2*a(n) + (-2)*(2*n+1)*a(n-1) = 0;
A001813 holos   0   [[0],[-4,8],[-2]]   [1] 0   1*2*a(n) + (-4)*(2*n+1)*a(n-1) = 0;
A001850 holos   0   [[0],[2,-2],[-6,12],[0,-2]] [1,3]   0   1*2*n*a(n) + (-6)*(2*n+1)*a(n-1) + 1*(2*n+2)*a(n-2) = 0;

CREATE TABLE holref
        ( aseqno        VARCHAR(10) NOT NULL
        , callcode      VARCHAR(32) NOT NULL
        , offset1       INT
        , matrix        VARCHAR(8192)
        , init          VARCHAR(4096)
        , dist          INT
        , gftype        INT
        , keyword       VARCHAR(128)
        , CONSTRAINT PK29 PRIMARY KEY (aseqno, callcode)
        );
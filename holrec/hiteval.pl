#!perl

# Evaluate output file of HolonomicRecurrenceTest:holos 
# @(#) $Id$
# 2020-02-24, Georg Fischer
#
#:# Usage:
#:#   perl hiteval.pl input > output
#---------------------------------
use strict;
use integer;
use warnings;
my $version = "V1.1";
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);

my $maxlen = 200;
my $asdata = "../common/asdata.txt";
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
    s{\s+\Z}{};
    my ($sseqno, $callcode, $offset, $termlist, $matrix) = split(/\t/);
    if (length($termlist) > $maxlen) { # too long
        $termlist = substr($termlist, 0, $maxlen);
        $termlist =~ s{\,\d*\Z}{}; # last term might have been broken - remove it
    } # too long
    print "# $sseqno\n";
    my $result = `grep -E \"$termlist\" $asdata`;
    if ($result =~ m{\A(A\d+)}) { # found
        my $aseqno = $1;
        print join("\t", $aseqno, "hiter3", 0, $matrix) .  "\n";
    } # if found
} # while
__DATA__
A641603 holos1  0   1,2,6,24,120,720,5040,40320,362880,3628800,39916800,479001600,6227020800,87178291200,1307674368000,20922789888000   [[0],[0,1,1],[0,-1]]
A641668 holos1  0   1,3,12,60,360,2520,20160,181440,1814400,19958400,239500800,3113510400,43589145600,653837184000,10461394944000,177843714048000   [[0],[0,2,1],[0,-1]]
A641669 holos1  0   1,4,18,96,600,4320,35280,322560,3265920,36288000,439084800,5748019200,80951270400,1220496076800,19615115520000,334764638208000  [[0],[1,2,1],[0,-1]]

#!perl

# Generate input file for HolonomicRecurrenceTest 
# @(#) $Id$
# 2020-02-24, Georg Fischer
#
#:# Usage:
#:#   perl hiterate.pl [-n 100] > hiterate.tmp
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

for (my $ind6 =     1; $ind6 <= $num; $ind6 ++) {
for (my $ind5 = -$num; $ind5 <= $num; $ind5 ++) {
for (my $ind4 = -$num; $ind4 <= $num; $ind4 ++) {
for (my $ind3 = -$num; $ind3 <= $num; $ind3 ++) {
for (my $ind2 = -$num; $ind2 <= $num; $ind2 ++) {
for (my $ind1 = -$num; $ind1 <= $num; $ind1 ++) {
for (my $ind0 = -$num; $ind0 <= $num; $ind0 ++) {
    $seqno ++;
    print join("\t", "A$seqno", "holos", 0, "[[0],[$ind0],[$ind1,$ind2,$ind3],[$ind4,$ind5,$ind6]]", "[1]", 0) . "\n";
} # for $ind0
} # for $ind1
} # for $ind2
} # for $ind3
} # for $ind4
} # for $ind5
} # for $ind6
__DATA__
A000407 holos   0   [[0],[4,8],[-2]]    [1] 0   1*2*a(n) + (-4)*(2*n-1)*a(n-1) = 0;
A001147 holos   0   [[0],[-2,4],[-2]]   [1] 0   1*2*a(n) + (-2)*(2*n+1)*a(n-1) = 0;
A001813 holos   0   [[0],[-4,8],[-2]]   [1] 0   1*2*a(n) + (-4)*(2*n+1)*a(n-1) = 0;
A001850 holos   0   [[0],[2,-2],[-6,12],[0,-2]] [1,3]   0   1*2*n*a(n) + (-6)*(2*n+1)*a(n-1) + 1*(2*n+2)*a(n-2) = 0;

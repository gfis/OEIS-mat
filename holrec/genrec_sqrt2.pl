#!perl

# Generate recurrence calls from generating functions with sqrt
# @(#) $Id$
# 2020-01-01, Georg Fischer
#
#:# Usage:
#:#   perl genrec_sqrt2.pl [-m|-h] -v vector -i initerms 
#:#       vector a,b,c,d  for 1/sqrt(1-a*x-b*x^2-c*x^3-d*x^4)
#---------------------------------
use strict;
use integer;
use warnings;

my $aseqno;
my @vector;
my @initerms;
my $line;
my $mode = "mma";
my $opt;
while (scalar(@ARGV) > 0) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt eq "-m"}) {
        $mode = "mma";
    } elsif ($opt eq "-h") {
        $mode = "holos"
    } elsif ($opt eq "-i") {
        $opt =~ s{[\s\{\[\]\}\(\)]}{}g;
        @initerms = split(/\,/, $opt);
    } elsif ($opt eq "-v") {
        $opt =~ s{[\s\{\[\]\}\(\)]}{}g;
        @vector = split(/\,/, $opt);
    } else {
        die "invalide option \"$opt\"\n";
    }
} # while $opt

my $inits:
my $ind = 0;
if (0) {
} elsif ($mode =~ m{mma}) {
    $inits = join(",", map {
        my $part = "a[$ind]==$_"
        $ind ++;
        $part;
        } @initerms;
} elsif ($mode =~ m{hol}) {
    $inits = "[" . join(",", @initerms) . "]";
}   
__DATA__

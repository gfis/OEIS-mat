#!perl

# Reverse and negate a signature in a column
# @(#) $Id$
# 2019-12-16: -i colno; do not print if length >= 1000
# 2019-12-11, Georg Fischer
#
#:# Usage:
#:#   perl reverse_signature.pl [-d debug] [-c colno] infile > outfile
#:#       -i colno reverse field in this column (counted from 0)
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
$timestamp = sprintf ("%04d-%02d-%02d", $year + 1900, $mon + 1, $mday);

my $colno = 4;
my $debug = 0;
my $holonomic = 0;
if (scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{i}) {
        $colno     = shift(@ARGV);
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{h}) { # enclose in "[0," and ",1]" for HolonomicRecurrence.java
        $holonomic = 1;
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my $line;

while (<>) {
    $line = $_;
    $line =~ s/\s+\Z//; # chompr
    my @columns = split(/\t/, $line);
    my $signature = $columns[$colno];
    $signature =~ s{[\[\]\s]}{}g; # remove [] and whitespace
    my @signatures = map {
        my $term = $_;
        ($term =~ m{\A\-}) ? substr($term, 1) : (($term eq "0") ? $term : "-$term") # return value of map
    } reverse(split(/\,/, $signature));
    $signature = join(",", @signatures);
    if ($holonomic == 1) {
        $signature = "[0,$signature,1]";
    }
    $columns[$colno] = $signature;
    if (length($signature) < 1000) {
        print join("\t", @columns) . "\n";
    }
} # while <>
__DATA__
A000002 -1,1,0,0,0,-1,1 null    null
A000008 -1,1,1,-1,0,1,-1,-1,1   1,1,-1,0,1,-1,-1,1,0,1,-1,-1,1,0,-1,1,1,-1      Sequence
A000012 -1,1    1       Sequence
A000027 1,-2,1  2,-1    Sequence
A000030 -1,1    null    null
A000032 -1,-1,1 1,1     Sequence
A000034 -1,0,1  0,1     Sequence
A000035 -1,0,1  0,1     Sequence
wc -l    raeval_joeis.tmp
42190 raeval_joeis.tmp
#!perl

# Combine several strings that are prefixes auf each other, and accumulate their counts
# @(#) $Id$
# 2021-10-19, Georg Fischer
#
#:# Usage:
#:#   sort | uniq -c | perl accumulate_sides.pl > output
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);

my $debug   = 0;

while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my $oldlist = "";
my $newlist = "";
my $oldcount = 0;
my $newcount = 0;
# while (<DATA>) {
while (<>) {
    s/\s+\Z//; # chompr;
    s/\A\s+//; # remove leading spaces
    ($newcount, $newlist) = split(/\s+/);
    next if ! defined($newlist) or length($newlist) == 0;
    if (index($newlist, $oldlist) == 0) { # $oldlist is a prefix
        $oldcount += $newcount
    } else {
        print join("\t", $oldcount, $oldlist) . "\n";
        $oldcount = $newcount;
    }
    $oldlist = $newlist;
} # while <>
print join("\t", $oldcount, $oldlist) . "\n";
#----------------
__DATA__
      2 -9,-9,-9,-9,-9,-9,-9
      5 0,-1,1,-1,0,0,1
      1 0,0,0,0
      4 0,0,0,0,0
      1 0,0,0,0,0,0
      6 0,0,0,0,0,0,0
      5 0,0,0,0,0,0,0,0
      6 0,0,0,0,0,0,0,0,0
      6 0,0,0,0,0,0,0,0,0,0
     17 0,0,0,0,0,0,0,0,0,0,0
      1 0,0,0,0,0,0,0,0,0,0,0,0
      1 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
     22 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
      1 0,0,1,0,0,0,1,0,0,0
      2 0,0,1,1,0,0,1,1,0,0
      2 0,0,1,1,0,0,1,1,0,0,1,1

#!perl

# Generate a list of A-Numbers with 6 digits from the arguments X9, A9, J123456 etc.
# @(#) $Id$
# 2024-05-19, Georg Fischer
#
#:# Usage:
#:#   perl Anumber.pl [-s] num1, num2 ...
#:#       -s: prepend subdirectories, "asss/Asssnnn"
# 
# Does not write a trailing newline in order to be usable with backticks
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my $first = 0;
my $with_subdir = 0;
foreach my $arg (@ARGV) {
    if (0) {
    } elsif ($arg eq "-s") {
        $with_subdir = 1;
    } elsif ($arg =~ m{\A[A-Z]?(\d+)}) {
        my $num = $1;
        if ($first > 0) {
          print " ";
        }
        my $seq = sprintf("%06d", $num);
        if ($with_subdir > 0) {
            print "a" . substr($seq, 0, 3) . "/";
        }
        print "A$seq";
        $first ++;
    } else {
        # ignore other arguments
    }
} # foreach $arg


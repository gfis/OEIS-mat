#!perl

# Poor translation of OEIS formulas into jOEIS
# @(#) $Id$
# 2024-05-19, Georg Fischer
#
#:# Usage:
#:#   perl nest_count.pl jcat25-format > seq4-format
#:#       -s: prepend subdirecties, "asss/Asssnnn"
#
# Does not write a trailing newline in order to be usable with backticks
#--------------------------------------------------------
use strict;
use integer;
use warnings;

while (<>) {
    s/\s+\Z//; # chompr;
    #     1      1               2      2
    if (m{(A\d{6})\([\+\-\*0-9n]*(A\d{6})\(}) {
    	print join("\t", substr($_, 3, 7), $1, $2) ."\n";
    }
} # while

#!perl

# @(#) $Id$
# 2024-11-14, Georg Fischer
#
#:# Transform records into seq4 format with aseqno, callcode, offset1, parm1, parm2 ...
#:# Usage:
#:#   perl movinits.pl infile.seq4 > outfile.seq4
#--------------------------------------------------------
use strict;
use integer;
use warnings;

#while (<DATA>) {
while (<>) {
    s/\s*\Z//; 
    next if !m{\A(A\d+) (.*)}; 
    #                                  parm1 ini ali comment 
    print join("\t", $1, "lambdan", 0, $2,   "", "", $2) . "\n";
} # while
__DATA__
# test data
A000619 a(n) = A000617(n) - A000617(n-1)
A000637 a(n) = A000638(n) - A000638(n-1)

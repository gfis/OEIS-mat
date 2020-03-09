#!perl

# Grep (differential) equations of the form "satisfies (\w*) ."
# @(#) $Id$
# 2020-01-08, Georg Fischer
#
#:# Usage:
#:#   perl gfsqrt_grep.pl $(COMMON)/cat25.txt > gfsqrt1.tmp
#:#   $(RAMATH).sequence.JoeisPreparer -f        gfsqrt1.tmp
#---------------------------------
use strict;
use integer;
use warnings;

my $aseqno;
my $poly;
my $line;
my $expr; 

while(<>) {
    s{\s+\Z}{}; # chompr
    $line = $_;
    if (0) {
    } elsif ($line =~ m{\A\%[NF]\s+(A\d+)\s+.*satisfies ([^\.]+)\.}) { 
        $aseqno = $1;
        $expr   = $2;
        print join("\t", $aseqno, "satis", 0, $expr) . "\n";
    }
} # while <>
__DATA__

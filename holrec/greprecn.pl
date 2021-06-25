#!perl

# Grep (holonomic) recurrences from jcat25.txt
# @(#) $Id$
# 2021-05-23, Georg Fischer
#
#:# Usage:
#:#   grep -E "^%[NF]" $(COMMON)/jcat25.txt \
#:#   | perl greprec.pl > output.tmp
#---------------------------------
use strict;
use integer;
use warnings;

while(<>) {
    s{\s+\Z}{}; # chompr
    my $line = $_;
    my ($aseqno, $callcode, $offset, $rec, $inits, $cond, $empir, @rest) = split(/\t/, $line);
    $rec =~ s{ }{}g;
    my $nok = 0;
    if (0) {
    } elsif ($rec !~ m{\=}) {
        $rec = "a(n)=$rec";
    }
    if (0) {
#   } elsif ($rec =~ m{\!}) {
#       $nok = 1;
    } elsif ($cond =~ m{\d\d\d}) { # ignore if condition >= 1000 ...
        $nok = 2;
    } elsif (length($empir) > 0) { # ignore # Empirical, Conjecture
        $nok = 3;
    } elsif ($rec =~ m{a\(([a0-9\-\(]|\w+^)}) {
        $nok = 4;
    } elsif ($rec =~ m{n\^[^\d]}) { # ignore n^n, n^( ...
        $nok = 5;
    } elsif ($rec =~ m{[\+\-\*\/\^]\Z}) { # formula not finished
        $nok = 6;
    } elsif ($rec =~ m{\Aa\(n\)\=\d+\Z}) { # only a number
        $nok = 7;
    } elsif (length($rec) <= 6) { # too short
        $nok = 8;
    } elsif ($rec =~ m{[^n\)]\^}) { # not "n^"
        $nok = 9;
    } elsif ($rec =~ m{a\(n[^\+\-\)]}) { # not "a(n+-\d)"
        $nok = "a";
    }
    if ($nok eq "0") {
        $rec =~ s{([0-9]|\))(\(|[an])}{$1\*$2}g;
        $rec =~ s{(\d)([an])}         {$1\*$2}g;
        $rec =~ s{(\!)(\w|\()}        {$1\*$2}g;
        print        join("\t", $aseqno, "holos"  , 0, $rec, $inits, 0) . "\n";
    } else {
        print STDERR join("\t", $aseqno, "rec$nok", 0, $rec, $inits, 0) . "\n";
    }
} # while <>
__DATA__
A048634 rec 0   a(n)=a(n-1)*a(n-3)+a(n-2)               a(n)=a(n-1)*a(n-3)+a(n-2)
A048673 rec 0   a(2n)=3*a(n)-1              a(2n) = 3*a(n) - 1
A048673 rec 0   a(3n)=5*a(n)-2              a(3n) = 5*a(n) - 2
A048673 rec 0   a(4n)=9*a(n)-4              a(4n) = 9*a(n) - 4
A048673 rec 0   a(5n)=7*a(n)-3              a(5n) = 7*a(n) - 3
A048673 rec 0   a(6n)=15*a(n)-7             a(6n) = 15*a(n) - 7
A048673 rec 0   a(7n)=11*a(n)-5             a(7n) = 11*a(n) - 5
A048673 rec 0   a(8n)=27*a(n)-13                a(8n) = 27*a(n) - 13
A048673 rec 0   a(9n)=25*a(n)-12                a(9n) = 25*a(n) - 12
A048861 rec 0   a(n)=n^n-1              a(n) = n^n - 1

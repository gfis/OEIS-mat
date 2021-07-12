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

my $aseqno;
my $poly;
my $line;
my $expr; 
my $rest;
my $rec;
my $empir;
my $cond;
my $inits;

while(<>) {
    s{\s+\Z}{}; # chompr
    $line = $_;
    if (0) {
    #} elsif ($line =~ m{\.\.\.}) { # ignore ellipsis
    #                              1        2                  3
    } elsif ($line =~ m{\A\%[NF]\s+(A\d+)\s+([^\.\,]*)}) { # aseqno, formula, dot, author
        $aseqno = $1;
        $rec    = $2 || "";
        $empir  = "";
        $cond   = "";
        $inits  = "";
        my $name = $rec;
        # $rec    =~ s{ \- [A-Z][\.a-zA-Z0-9\,\- ]+\Z}{}; # remove author and date
        while ($rec =~ s{(\, *a\(\d+\) *\= *\d+)}{}) { # remove initial terms
            $inits .= $1;
            $inits =~ s{ }{}g;
        }
        if ($rec =~ s{(\,|for |with |if )([n\=\>0-9 ]+)\Z}{}) { # extract condition
            $cond = $2;
            $cond =~ s{ }{}g;
        }
        if ($rec =~ m{\:}) { # separate "Empirical" etc.
            ($empir, $rec) = split(/\:/, $rec, 2);
        }
        $rec =~ s{ }{}g;
        if ($rec =~ m{\A[an\d\+\-\*\/\!\^\(\)\=]+\Z}) {
            if ($rec =~ m{a\(n\)}) {
                print join("\t", $aseqno, "rec", 0, $rec, $inits, $cond, $empir, $name) . "\n";
            }
        }
    }
} # while <>
__DATA__
read "C://Users/User/work/gits/OEIS-mat/software/SCHUTZENBERGER-gfis.txt";
algtorecV(A- 1 + x*A + x^2*A^4,A,x,n,N,a);

-1+(1+x)*A+x^2*A^4 = 0
``
`Then they satisfy the linear recurrence equation `
``
3*n*(3*n-2)*(3*n+2)*a(n)+(54*n^3+81*n^2-165*n+45)*a(n-1)+(229*n^3-201*n^2-499*n+441)*a(n-2)-2*(2*n-5)*(155*n
^2-775*n+657)*a(n-3)+(229*n^3-3234*n^2+14666*n-21546)*a(n-4)+(54*n^3-891*n^2+4695*n-7995)*a(n-5)+3*(3*n-13)*
(3*n-17)*(n-5)*a(n-6) = 0
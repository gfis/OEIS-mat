#!perl

# Grep (holonomic) recurrences from jcat25.txt
# @(#) $Id$
# Grep section recurrences (2, 3, 4)
# 2021-12-17, Georg Fischer
#
#:# Usage:
#:#   grep -E "^%[NF]" $(COMMON)/jcat25.txt \
#:#   | perl sectrec.pl > output.tmp
#---------------------------------
use strict;
use integer;
use warnings;

my $type;
my $aseqno;
my $poly;
my $line;
my $expr; 
my $rest;
my $rec;
my $sectno;
my $empir;
my $cond;
my $inits;

while(<>) {
    s{\s+\Z}{}; # chompr
    $line = $_;
    if (0) {
    } elsif ($line =~ m{\.\.\.}) { # ignore ellipsis
    #                       1    1   2    2   3  3
    } elsif ($line =~ m{\A\%([NF])\s+(A\d+)\s+(.*)}) { # aseqno, name
        $type   = $1;
        $aseqno = $2;
        $rec    = $3 || "";
        $empir  = "";
        $cond   = "";
        $inits  = "";
        $sectno = 0;
        my $name = $rec;
        if ($name =~ m{prime|digit|composite|omega|sum|prod}) {
        } elsif ($name =~ m{a\(\d+\*?n\)}) {
            if ($type eq "F") {
                $rec    =~ s{\- *[\_A-Z][\.\,\-\w ]+\Z}{}; # remove author and date
            }
            $rec =~ s{\(End\) *\Z}{};
            $rec =~ s{ *\. *\Z}{};
            #                12    2 3              3    14    4
            while ($rec =~ s{((\, ?)?(a\(\d+\) *\= *)+\-?\d+)(\, *)?}{}) { # remove initial terms
                my $init = $1;
                $init =~ s{ }{}g;
                my @parts = split(/\=/,$init);
                for (my $ipart = 0; $ipart < scalar(@parts) - 1; $ipart ++) {
                  $inits .= "$parts[$ipart]=$parts[scalar(@parts) - 1];"
                }
            }
            if ($rec =~ s{(\,|for |with |if |when )([n\=\>0-9 ]+)\Z}{}) { # extract condition
                $cond = $2;
                $cond =~ s{ }{}g;
            }
            if ($rec =~ m{\:}) { # separate "Empirical" etc.
                ($empir, $rec) = split(/\:/, $rec, 2);
            }
            $rec =~ s{\A(\; *)+}{};
            $rec =~ s{\;}{\,}g;
            $rec =~ s{\(3\(n\+1\)\)}{\(3\*n\+3\)}g;
            $rec =~ s{(\d+)([an])}{$1\*$2}g;
            $rec =~ s{(\W\d+)\(}{$1\*\(}g;
            $rec =~ tr{\[\]}{\(\)};
            if (0) {
            } elsif ($rec  =~ m{a\(a}) {
                $sectno = "a(a";
                print STDERR join("\t", $aseqno, "sectrec", 0, $sectno, $rec, $inits, $cond, $empir, $name) . "\n";
            } elsif ($rec  =~ m{\=\=}) {
                $sectno = "==";
                print STDERR join("\t", $aseqno, "sectrec", 0, $sectno, $rec, $inits, $cond, $empir, $name) . "\n";
            } elsif ($rec  =~ m{([^Aan0123456789\(\)\=\,\;\. \+\-\*\/\^])}) {
                $sectno = "\"$1\"";
                print STDERR join("\t", $aseqno, "sectrec", 0, $sectno, $rec, $inits, $cond, $empir, $name) . "\n";
            } else { # possible section
                $rec =~ s{ }{}g;
                if (($rec =~ m{a\(2\*?n\) *\=}) 
                      && ($rec =~ m{a\(2\*?n *[\+\-] *1\) *\=})) {
                    $sectno = 2;
                    print join("\t", $aseqno, "sectrec", 0, $sectno, $rec, $inits, $cond, $empir, $name) . "\n";
                } elsif (($rec =~ m{a\(3\*?n\) *\=}) 
                      && ($rec =~ m{a\(3\*?n *[\+\-] *1\) *\=}) 
                      && ($rec =~ m{a\(3\*?n *[\+\-] *2\) *\=})) {
                    $sectno = 3;
                    print join("\t", $aseqno, "sectrec", 0, $sectno, $rec, $inits, $cond, $empir, $name) . "\n";
                } elsif (($rec =~ m{a\(4\*?n\) *\=}) 
                      && ($rec =~ m{a\(4\*?n *[\+\-] *1\) *\=}) 
                      && ($rec =~ m{a\(4\*?n *[\+\-] *2\) *\=}) 
                      && ($rec =~ m{a\(4\*?n *[\+\-] *3\) *\=})) {
                    $sectno = 4;
                    print join("\t", $aseqno, "sectrec", 0, $sectno, $rec, $inits, $cond, $empir, $name) . "\n";
                } elsif (($rec =~ m{a\(5\*?n\) *\=}) 
                      && ($rec =~ m{a\(5\*?n *[\+\-] *1\) *\=}) 
                      && ($rec =~ m{a\(5\*?n *[\+\-] *2\) *\=}) 
                      && ($rec =~ m{a\(5\*?n *[\+\-] *3\) *\=}) 
                      && ($rec =~ m{a\(5\*?n *[\+\-] *4\) *\=})) {
                    $sectno = 5;
                    print join("\t", $aseqno, "sectrec", 0, $sectno, $rec, $inits, $cond, $empir, $name) . "\n";
                } elsif (($rec =~ m{a\(6\*?n\) *\=}) 
                      && ($rec =~ m{a\(6\*?n *[\+\-] *1\) *\=}) 
                      && ($rec =~ m{a\(6\*?n *[\+\-] *2\) *\=}) 
                      && ($rec =~ m{a\(6\*?n *[\+\-] *3\) *\=}) 
                      && ($rec =~ m{a\(6\*?n *[\+\-] *4\) *\=}) 
                      && ($rec =~ m{a\(6\*?n *[\+\-] *5\) *\=})) {
                    $sectno = 6;
                    print join("\t", $aseqno, "sectrec", 0, $sectno, $rec, $inits, $cond, $empir, $name) . "\n";
                }
            } # possible section
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
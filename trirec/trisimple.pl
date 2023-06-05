#!perl

# Extract parameters for "inverse binomail transform of" 
# 2021-10-14, Georg Fischer: copied from divpow.pl
#
#:# Usage:
#:#   perl invbinom.pl [-d debug] $(COMMON)/joeis_names.txt > output.seq4
#:#     -d  debugging level (0=none (default), 1=some, 2=more)
#--------------------------------------------------------
use strict;
use integer;
use warnings;

my $line = "";
my ($aseqno, $superclass, $callcode, $name, $keyword, $bfims, @rest, $offset);

while (<>) {
    s/\s+\Z//; # chompr
    my $line = $_;
    #                               1     1    2     2          34                     4 5     6                     6 5 37                        7
    if ($line =~ m{\s[ATsta] *[\(\[]([a-z])\, *([a-z])[\)\]] *\=(([\d\+\-\*\/\^ \!\(\)])*([a-z]([\d\+\-\*\/\^ \!\(\)])+)+)([\,\.\<\=\>\;]|for|with|where|if)}) {
        my ($n, $k, $expr) = ($1, $2, $3);
        $expr =~ s{ }{}g;
        $expr =~ s{\b$n\b}{\#n}g; # normalize to (n,k)
        $expr =~ s{\b$k\b}{\#k}g;
        $expr =~ s{\#}{}g;
        ($aseqno, $superclass, $name, $keyword, $bfims, @rest, $offset) = split(/\t/, $line);
        if (0) { # excludes:
        } elsif ($superclass !~ m{\Anyi}) { # already in jOEIS
        } elsif ($keyword    !~ m{tabl}) { # no keyword tabl
        } elsif ($expr       =~ m{[\+\-\+\/\^\(]\Z}) { # incomplete
        } else {
            my $ok = 1;
            if ($ok == 1) { # only $n and $k - normalize them to "n" and "k"
                my $old_expr = $expr;
                $expr =~ s{\(\-1\)\^([nk]|\([^\)]+\))}{\(\(\($1 \& 1\) == 0\) \? 1 \: \-1\)}g;
                $expr =~ s{(\+|\-)}{ $1 }g;
                $expr =~ s{\^2}{\.square\(\)}g;
                $expr =~ s{\^}{\.pow}g;
                $expr =~ s{\b([a-z0-9])([a-z])\b}{$1\*$2}g;
            #   $expr =~ s{\*}{\.multiply}g;
                $expr =~ s{\/2}{\.divide2()}g;
                $expr =~ s{\/}{\.divide(}g;
                $expr =~ s{\bC\(}{binomial\(}g;
                $expr =~ s{\bF(ib)?\(}{fibonacci\(}g;
                $expr =~ s{binomial}{Binomial.binomial}g;
                $expr =~ s{fibonacci}{Fibonacci.fibonacci}g;
                $expr =~ s{\b([nk])\!}{MemoryFactorial.SINGLETON.factorial\($1\)}g;
                $expr =~ s{\bpow([nk])}{pow\($1\)}g;
                $callcode = "trisimple";
                if ($keyword =~ m{tard}) {
                    $callcode = "trisimard";
                } 
                if ($keyword =~ m{tara}) {
                    $callcode = "trisimara";
                }
                $bfims =~ m{\A(\-?\d+)};
                $offset = $1;
                print join("\t", "#", "", "", "", $old_expr) . "\n";
                print join("\t", "#$aseqno", $callcode, $offset, "Z.valueOf($expr)", $name, $keyword, $bfims, @rest). "\n\n";
            }
        }
    } # if line
} # while
__DATA__
A141402	trisimple	0	Z.valueOf(n.pow(2 + (2.multiply(k.multiply((n - k)).pow(2)	Triangle T(n, k) = n^2 + (2*k*(n-k))^2, read by rows.	nonn,easy,tabl,changed,	0..1325	nyi
A143814	trisimple	0	Z.valueOf(n.pow(2 - (k + 1).pow(2)	Triangle T(n,m) read along rows: T(n,m) = n^2 - (m+1)^2 for 1<=m<n-1, T(n,n-1) = n^2-1.	nonn,easy,tabl,synth	2..67	nyi
A215630	trisimple	0	Z.valueOf(n.pow(2 - n.multiply(k + k.pow(2)	Triangle read by rows: T(n,k) = n^2 - n*k + k^2, 1 <= k <= n.	nonn,tabl,	1..7260	nyi
A215631	trisimple	0	Z.valueOf(n.pow(2 + n.multiply(k + k.pow(2)	Triangle read by rows: T(n,k) = n^2 + n*k + k^2, 1 <= k <= n.	nonn,tabl,	1..7260	nyi

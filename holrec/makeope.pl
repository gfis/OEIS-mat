#!perl

# Convert a(n-k) into A^k for holdfin.mpat
# @(#) $Id$
# 2021-06-16: Georg Fischer
#
#:# Usage:
#:#   perl makeope.pl input > output
#---------------------------------
use strict;
use integer;
use warnings;

while (<>) {
    next if ! m{\AA\d};
    s{\s+\Z}{}; # chompr
    my ($aseqno, $callcode, $offset, $annihil, @rest) = split(/\t/, $_);
    $annihil =~ s{a\(n(\+0)?\)}{a\(n\-0\)}g;
    if ($annihil !~ m{a\(n\+\d+\)}) {
        $annihil =~ s{a\(n\-(\d+)\)}{A\^$1}g;
        print join("\t", $aseqno, "holos", $offset, $annihil, @rest) . "\n";
    } else {
        print STDERR "error: n+k in $aseqno\n";
    }
} # while <>
__DATA__
# A277436	holos	0	-(n*(n-1)*(a(n-1)-(n-2)^2*a(n-2)+1)+a(n+1))+n^2*a(n-0)+1	1,2,5	0	0	n*(n-1)(a(n-1)-(n-2)^2*a(n-2)+1)+a(n+1)=n^2*a(n+0)+1
# A277345	holos	0	-(n*(a(n-0)+a(n-1)))+(n+3)*a(n+1)-a(n+2)	2,3,9	0	0	n*(a(n+0)+a(n-1))=(n+3)*a(n+1)-a(n+2)
# A217703	holos	0	-(a(n+1))+2*n*(n+1)*a(n-0)-n^4*a(n-1)	1,0	0	0	a(n+1)=2*n*(n+1)*a(n+0)-n^4*a(n-1)
# A297670	holos	0	-(-(-1+n)*n*(1+n)+(4+2*(-1+n))*a(n-0)+(-6-2*(-1+n))*a(n+1)+2*a(n+2))+0	0,0	0	0	-(-1+n)*n*(1+n)+(4+2*(-1+n))*a(n+0)+(-6-2*(-1+n))*a(n+1)+2*a(n+2)=0
# A301476	holos	0	-((32*n+64)*a(n-0))+((24*n+56)*a(n+1)-(8*n+22)*a(n+2)+(n+3)*a(n+3))	1,6,26	0	0	(32*n+64)*a(n+0)=((24*n+56)*a(n+1)-(8*n+22)*a(n+2)+(n+3)*a(n+3))
# A279619	holos	0	-((n+1)^2*a(n+1))+((26*n^2+13*n+2)*a(n-0)+3*(3*n-1)*(3*n-2)*a(n-1))	0,1	0	0	(n+1)^2*a(n+1)=((26*n^2+13*n+2)*a(n+0)+3*(3*n-1)*(3*n-2)*a(n-1))

A277436	holos	0	-(n-1)*(n-2)*(a(n-2)-(n-3)^2*a(n-3)+1)-a(n)+(n-1)^2*a(n-1)+1	1,2,5	0	0	n*(n-1)(a(n-1)-(n-2)^2*a(n-2)+1)+a(n+1)=n^2*a(n+0)+1
A277345	holos	0	-(n-2)*(a(n-2)+a(n-3))+(n+1)*a(n-1)-a(n)	2,3,9	0	0	n*(a(n+0)+a(n-1))=(n+3)*a(n+1)-a(n+2)
A217703	holos	0	-a(n)+2*(n-1)*n*a(n-1)-(n-1)^4*a(n-2)	1,0	0	0	a(n+1)=2*n*(n+1)*a(n+0)-n^4*a(n-1)
A297670	holos	0	(n-3)*(n-2)*(n-1)-(2*n-2)*a(n-2)+2*n*a(n-1)-2*a(n)	0,0	0	0	-(-1+n)*n*(1+n)+(4+2*(-1+n))*a(n+0)+(-6-2*(-1+n))*a(n+1)+2*a(n+2)=0
A301476	holos	0	-(32*n-32)*a(n-3)+(24*n-16)*a(n-2)-(8*n-2)*a(n-1)+n*a(n)	1,6,26	0	0	(32*n+64)*a(n+0)=((24*n+56)*a(n+1)-(8*n+22)*a(n+2)+(n+3)*a(n+3))
A279619	holos	0	-n^2*a(n)+(26*(n-1)^2+13*n-11)*a(n-1)+3*(3*n-4)*(3*n-5)*a(n-2)	0,1	0	0	(n+1)^2*a(n+1)=((26*n^2+13*n+2)*a(n+0)+3*(3*n-1)*(3*n-2)*a(n-1))

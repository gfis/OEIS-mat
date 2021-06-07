#!perl

# Extract generating functions with sqrt
# @(#) $Id$
# 2021-06-05, Georg Fischer: copied from gfsqrt_grep.pl
#
#:# Usage:
#:#   perl sqrtext.pl $(COMMON)/jcat25.txt > sqrtext.tmp
#---------------------------------
use strict;
use integer;
use warnings;

my $aseqno;
my $poly;
my $line;
my $gftype; # "e" if e.g.f, "o" otherwise
my $callcode;

while(<>) {
    s{\s+\Z}{}; # chompr
    $line   = $_;
    $poly   = "";
    $gftype = "o";
    $callcode = "holos";
    #                         1        2                 345                      6                    7
    if ($line =~ m{\A\%[NF]\s+(A\d+)\s+(Expansion of\s*)?((([EO])\.)?G\.f\.\:?\s*)(A\([t-z]\)\s*\=\s*)?([^\.\=\;]+)}i) {
        $aseqno  = $1;
        $poly    = $7;
        $gftype  = lc($5 || "o");
        $poly    =~ s{ }{}g;
        $gftype  =~ tr{eo}{10};
        $poly    =~ s{sqrt}{x_}ig; # shield sqrt
        $poly    =~ tr{qstz\[\]}{xxxx\(\)};
        $poly    =~ s{(\d|\))(x|\()}{$1*$2}g;
        $poly    =~ s{\)(\w)}{\)\*$1}g;
        if (($poly =~ m{x_}) and ($poly !~ m{[A-Za-wyz]})) {
            $poly  =~ s{x_}{sqrt}g; # unshield sqrt
            print join("\t", $aseqno, $callcode, 0, $poly, 1, 0, $gftype) . "\n";
        } else {
            print STDERR "# " . join("\t", $aseqno, $callcode, 0, $poly, 1, 0, $gftype, $line) . "\n";
        }
    } 
} # while <>
__DATA__
%F A069721 G.f.: 32*x^3/(sqrt(1-8*x)*(1+sqrt(1-8*x))^3).
%F A060693 G.f.: (1 - t*y - sqrt((1-y*t)^2 - 4*y)) / 2.
%F A064189 G.f.: 2 / (1 - x + sqrt(1 - 2*x - 3*x^2) - 2*x*y) = Sum_{n >= k >= 0} T(n, k) * x^n * y^k.
%F A051292 G.f.: (1 - t^2 + sqrt(1 - 2*t - t^2 - 2*t^3 + t^4))/sqrt(1 - 2*t - t^2 - 2*t^3 + t^4).
%F A048287 E.g.f.: 1-2*(1-exp(-x))/(1-sqrt(4*exp(-x)-3)).
%F A054114 G.f.: (-1+3*x+5*x^2-4*x^3+sqrt(1-4*x))/(x*(1-x)*(1-4*x)). - _Ralf Stephan_

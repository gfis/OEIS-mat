#!perl

# Grep generating functions with 1/sqrt(1 - c1*x - c2*x^2 ... - ck*x^k) 
# and prepare them for JoeisPreparer (which parses the polynomials)
# @(#) $Id$
# 2019-01-01, Georg Fischer
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

while(<>) {
    s{\s+\Z}{}; # chompr
    $line = $_;
    if (0) {
    #                              1        2                 34                      5                6               7                          8
    } elsif ($line =~ m{\A\%[NF]\s+(A\d+)\s+(Expansion of\s*)?(([EO]\.)?G\.f\.\:?\s*)?(A\(x\)\s*\=\s*)?(\d+)\/\s*sqrt(\([^\.\;]+)}i) { 
        $aseqno = $1;
        $poly   = $7;
        $poly =~ s{\s}{}g;
        $poly =~ s{\A\(}{};
        $poly =~ s{\)\Z}{};
        if (($poly !~ m{[a-z][a-z]}) and ($poly !~ m{[\=\/]}) and ($poly !~ m{[A-Z]})) {
            print join("\t", $aseqno, "fract1", 0, $poly) . "\n";
        } 
    } # if
} # while <>
__DATA__
A002426 fract1  0       1-2*x-3*x^2
A006438 fract1  0       1-8x+x^2
A006442 fract1  0       1-10*x+x^2
A006442 fract1  0       1-10*x+x^2
A006453 fract1  0       1-12x+x^2
A008459 fract1  0       1-2*x-2*x*y+x^2-2*x^2*y+x^2*y^2
A012000 fract1  0       1-4*x+16*x^2
A012000 fract1  0       1-4*x+16*x^2
A026375 fract1  0       1-6*x+5*x^2
A028329 fract1  0       1-4*x
A051286 fract1  0       1-2*x-x^2-2*x^3+x^4
A059345 fract1  0       (1+z-z^2)*(1-3*z-z^2)
A081671 fract1  0       (1-2*x)*(1-6*x)
A084768 fract1  0       1-14*x+x^2
A084769 fract1  0       1-18*x+x^2
A085881 fract1  0       1-2*x-2*x*y
A097801 fract1  0       1-2*x
A098269 fract1  0       1-16x+4x^2
A098270 fract1  0       1-20x+4x^2
A098331 fract1  0       1-2x+5x^2
A098332 fract1  0       1-2*x+9*x^2
A098333 fract1  0       1-2x+13x^2
A098334 fract1  0       1-2x+17x^2
A098335 fract1  0       1-4x+8x^2
A098336 fract1  0       1-4*x+12*x^2
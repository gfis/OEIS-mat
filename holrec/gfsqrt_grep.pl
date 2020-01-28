#!perl

# Grep generating functions with 1/sqrt(1 - c1*x - c2*x^2 ... - ck*x^k) 
# and prepare them for JoeisPreparer (which parses the polynomials)
# @(#) $Id$
# 2020-01-05: $factor
# 2020-01-01, Georg Fischer
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
my $factor; # $factor/sqrt()
my ($expnum, $expden); # numerator (-1) and denominator (2) of exponent
my $gftype; # "e" if e.g.f, "o" otherwise
my $callcode;

while(<>) {
    s{\s+\Z}{}; # chompr
    $line   = $_;
    $factor = "";
    $poly   = "";
    $gftype = "o";
    $callcode = "fract1";
    if (0) {
    #                              1        2                 34                      5                6             7                          8
    } elsif ($line =~ m{\A\%[NF]\s+(A\d+)\s+(Expansion of\s*)?(([EO]\.)?G\.f\.\:?\s*)?(A\([t-z]\)\s*\=\s*)?(\d+)\s*\/\s*sqrt(\([^\.\;]+)}i) { 
        $aseqno  = $1;
        $gftype  = $4 || "o";
        $factor  = $6;
        $poly    = $7;
        $expnum  = -1;
        $expden  = 2;
        $callcode = "fract1";
        # sqrt 
        
    # A106188 ?stdf?	fract	0	1/((1-x^2)*sqrt(1-4*x))
    } elsif ($line =~ m{\A\%[NF]\s+(A\d+)\s+(Expansion of\s*)?(([EO]\.)?G\.f\.\:?\s*)?(A\([t-z]\)\s*\=\s*)?(\d+)\s*\/\s*\((\([^\.\;\)]+\))\s*\*?\s*sqrt(\([^\.\;\)]+\))\)[ \.\;\w]}i) { 
        $aseqno  = $1;
        $gftype  = $4 || "o";
        $factor  = $6;
        my $qoly = $7;
        $poly    = $8;
        $poly    = "($qoly^2*$poly)";
        $expnum  = -1;
        $expden  = 2;
        $callcode = "fract2";
        # 1/((Q)*sqrt(P))
    #                              1        2                 34                      5                  67                                8         9
    } elsif ($line =~ m{\A\%[NF]\s+(A\d+)\s+(Expansion of\s*)?(([EO]\.)?G\.f\.\:?\s*)?(A\([t-z]\)\s*\=\s*)?\((([a-z]|[\(\)\^\+\- \*\d])+)\)\^\((\-?\d+)\/(\d+)\)\s*[\.\;]}i) { 
        $aseqno  = $1;
        $gftype  = $4 || "o";
        $factor  = 1;
        $poly    = $6;
        $expnum  = $8;
        $expden  = $9;
        $callcode = "fract4";
        # ^(-3/2)
        
    } 
    $poly =~ s{\s}{}g;
    $poly =~ s{\A\(}{};
    $poly =~ s{\)\Z}{}g;
    $gftype = ($gftype =~ m{E}i) ? "e" : "o"; 
    my %letters = ();
    foreach my $letter($poly =~ m{([a-z])}g) {
        $letters{$letter} = 1;
    } # foreach letter
    if (length($factor) > 0 
            and scalar(keys(%letters)) <= 1
            and ($poly !~ m{[a-z][a-z]}) 
            and ($poly !~ m{[\=\/]}) 
            and ($poly !~ m{[A-Z]})) {
        print join("\t", $aseqno, $callcode, $factor, $poly, $expnum, $expden, $gftype) . "\n";
    }
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
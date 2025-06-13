#!perl

# Polish the postfix for PolynomialFieldSequence.java
# @(#) $Id$
# 2025-06-08, Georg Fischer; *FP=11
#
#:# Usage:
#:#     perl polysh.pl [-d mode] input.seq4 > output.seq4
#--------------------------------------------------------
use strict;
use integer;
use warnings;

my $debug = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my  ($aseqno, $callcode, $offset, $polys, $postfix, @rest);
my  (@parts, %hash, $pn);
%hash = qw(
    arctan		atan
    arcsin		asin
    arcsinh		asinh
    lambertw	lambertW
    reverse		rev
);
while (<>) {
#while (<DATA>) {
    s/\s+\Z//; # chompr
    my $line = $_;
    my $nok = "";
    (                $aseqno, $callcode, $offset, $polys, $postfix, @rest) = split(/\t/, $line);
    my $sep = quotemeta(substr($postfix, 0, 1));
    @parts = split(/$sep/, $postfix);
    shift(@parts); # skip first, empty element
    for (my $ip = 0; $ip < scalar(@parts); $ip ++) { # polish 1 element
        my $pf = $parts[$ip];
        if (0) {
        } elsif($pf =~ m{\(\Z}) { # start of method call
            $parts[$ip] = ""; # void
        } elsif($pf =~ s{\)\Z}{}) { # end   of method call
            $parts[$ip] = $pf; # without ")"
        }
        if (defined($hash{$pf})) {
            $parts[$ip] = $hash{$pf};
        }
        $postfix = join(",", @parts);
        $postfix =~ s{\,\,+}{\,}g; # delete empty parts
    } # for $ip - 1 element
    $postfix =~ s{\A\,+}{}g; # delete empty parts
    $postfix =~ s{\,(\d+)\,\^}{\,\^$1}g; # ,3,^ -> ,^3
    $postfix =~ s{\,\^(\,|\Z)}{\,pow$1}g; # ,a,b,^ -> a,b,pow
    $postfix =~ s{\,(\d+)\,(\d+)\,\/\,\^}{\,\^$1/$2}g; # ,1,3,/,^ -> ,^1/3  
    if (($postfix =~ m{\A0\,}) && ($postfix =~ m{\-\Z})) {
        $postfix = substr($postfix, 2);
        $postfix =~ s{\-\z}{neg};
    }
    if (length($postfix) <= 3) {
        $nok = "?short";
    }
    if ($nok ne "") {
        print STDERR join("\t", $aseqno, "$callcode$nok", $offset, $polys, "\"$postfix\"", @rest) . "\n";
    } else {
        print        join("\t", $aseqno, "$callcode$nok", $offset, $polys, "\"$postfix\"", @rest) . "\n";
    }
} # while <>
#--------------------------------------------
__DATA__
263185	poly	0	"[1]"	,reverse(,2,x,*,arctan(,x,arctan),-,reverse)	0	1	 	 	 	 * E.g.f.: reverse(2*x-arctan(x)).					0
A088789	poly	0	"[1]"	,reverse(,2,x,*,1,exp(,x,exp),+,/,reverse)	0	1	 	 	 	 * E.g.f.: reverse(2*x/(1+exp(x))).					0
A058562	poly	0	"[1],[1,1]"	,reverse(,3,log(,p1,log),*,2,x,*,-,reverse)	0	1	 	 	 	 * E.g.f.: reverse(3*log(1+x)-2*x).					0
A259063	poly	0	"[1]"	,reverse(,3,x,*,2,x,*,exp(,x,exp),*,-,reverse)	0	1	 	 	 	 * E.g.f.: reverse(3*x-2*x*exp(x)).					0
A201466	poly	0	"[1]"	,reverse(,3,3,exp(,x,exp),*,-,4,x,*,+,reverse)	0	1	 	 	 	 * E.g.f.: reverse(3-3*exp(x)+4*x).					0
A259064	poly	0	"[1]"	,reverse(,4,x,*,3,x,*,exp(,x,exp),*,-,reverse)	0	1	 	 	 	 * E.g.f.: reverse(4*x-3*x*exp(x)).					0
A259065	poly	0	"[1]"	,reverse(,5,x,*,4,x,*,exp(,x,exp),*,-,reverse)	0	1	 	 	 	 * E.g.f.: reverse(5*x-4*x*exp(x)).					0
A259066	poly	0	"[1]"	,reverse(,6,x,*,5,x,*,exp(,x,exp),*,-,reverse)	0	1	 	 	 	 * E.g.f.: reverse(6*x-5*x*exp(x)).					0
A205806	poly	0	"[1],[0,-1]"	,reverse(,cos(,x,cos),exp(,p1,exp),-,reverse)	0	1	 	 	 	 * E.g.f.: reverse(cos(x)-exp(-x)).					0
A206404	poly	0	"[1],[0,-1]"	,reverse(,exp(,0,x,2,^,-,exp),exp(,p1,exp),-,reverse)	0	1	 	 	 	 * E.g.f.: reverse(exp(-x^2)-exp(-x)).					0
A334262	poly	0	"[1]"	,reverse(,exp(,x,exp),x,x,2,^,2,/,+,*,reverse)	0	1	 	 	 	 * E.g.f.: reverse(exp(x)*(x+x^2/2)).					0

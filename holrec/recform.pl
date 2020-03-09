#!perl

# Grep lines with (holonomic?) recurrences
# @(#) $Id$
# 2020-03-8, Georg Fischer
#
#:# Usage:
#:#   perl recform.pl cat25.txt > outfile
#---------------------------------
use strict;
use integer;
use warnings;
my $version = "V1.2";
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);

my $debug  = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{a}) {
    } elsif ($opt  =~ m{d}) {
        $debug  = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

while (<>) {
    if (m{^\%[NF] (A\d+)\s+([an\+\-\(\)\[\]\*\/\^\= 0-9]+\.)}) {
        my ($aseqno, $expr) = ($1, $2);
        # $expr =~ s{for [^\.]*\.}{\.}; 
        $expr =~ s{\..*}{\.}; 
        if (($expr =~ m{a\(n\)}) and ($expr =~ m{\.\Z})) {
        	$expr =~ s{\s}{}g;
        	if (length($expr) < 512) {
            	print join("\t", $aseqno
            		#, "recform", 0
            		, $expr) . "\n"; 
            }
        }
    } # %[NF]
} # while <>

sub norm_index {
} # norm_index
__DATA__
%F A000580 a(n) = (n^7 - 21*n^6 + 175*n^5 - 735*n^4 + 1624*n^3 - 1764*n^2 + 720*n)/5040.
%N A000588 a(n) = 7*binomial(2n,n-3)/(n+4).
%F A000588 (n+4)*a(n) +(-9*n-20)*a(n-1) +2*(13*n+5)*a(n-2) +(-25*n+38)*a(n-3) +2*(2*n-7)*a(n-4)=0. - _R. J. Mathar_, Jun 20 2013
%N A000589 a(n) = 11*binomial(2n,n-5)/(n+6).
%F A000589 -(n+6)*(n-5)*a(n) + 2*n*(2*n-1)*a(n-1) = 0. - _R. J. Mathar_, Jun 20 2013
%N A000590 a(n) = 13*binomial(2n,n-6)/(n+7).
%F A000590 -(n+7)*(n-6)*a(n) +2*n*(2*n-1)*a(n-1)=0. - _R. J. Mathar_, Jun 20 2013
%N A000643 a(n) = a(n-1) + 2^a(n-2).
%F A000657 a(n) = (-1)^(n)*Sum_{k=0..n} C(n,k)*Euler(n+k). - _Vladimir Kruchinin_, Apr 06 2015
%N A000659 a(n) = 2^a(n-1) + a(n-2).
%F A000660 a(n) = Sum_{k=0..n} A109449(n,k)*A028310(k). - _Reinhard Zumkeller_, Nov 04 2013
%N A000680 a(n) = (2n)!/2^n.

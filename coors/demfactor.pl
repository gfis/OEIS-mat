#!perl

# Split factors in result of Mathematica simplify.tpat
# @(#) $Id$
# 2020-05-14, Georg Fischer
# 
#:# Usage:
#:#   perl demfactor.pl [-gcd] inputfile ... > outputfile
#---------------------------------
use strict;
use integer;
use warnings;
use POSIX;

my $version = "V1.1";
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);
my $timestamp = sprintf("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
#----
my $with_gcd = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{gcd}) {
    	$with_gcd = 1;
    } elsif ($opt  =~ m{p}) {
    } elsif ($opt  =~ m{t}) {
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
#----
while (<>) {
    next if ! m{\AA\d\d+\t};
    my $line = $_;
    $line =~ s{\s+\Z}{}; # chompr
    # A310806	Gal.3.31.2	{{1, 1}, {-1 + x, 2}, {1 + x, 1}, {1 + x + x^2 + x^3 + x^4, 1}, {1 + x + x^2 + x^3 + x^4 + x^5 + x^6, 1}}
    my ($aseqno, $galid, $denp) = split(/\t/, $line);
    $denp =~ s{\s}{}g;
    $denp =~ s{\A\{\{1\,1\}\,\{}{};
    $denp =~ s{\}\}\Z}{};
    foreach my $pair(split(/\}\,\{/, $denp)) {
    	my ($factor, $exponent) = split(/\,/, $pair);
        print "$factor\n";
    }
} # while <>
__DATA__
A310806	Gal.3.31.2	{{1, 1}, {-1 + x, 2}, {1 + x, 1}, {1 + x + x^2 + x^3 + x^4, 1}, {1 + x + x^2 + x^3 + x^4 + x^5 + x^6, 1}}
A312245	Gal.3.31.3	{{1, 1}, {-1 + x, 2}, {1 + x + x^2 + x^3 + x^4, 1}, {1 + x + x^2 + x^3 + x^4 + x^5 + x^6, 1}}
A312115	Gal.3.32.1	{{1, 1}, {-1 + x, 2}, {1 - x + x^2, 1}, {1 + x + x^2, 1}, {1 + x + x^2 + x^3 + x^4, 2}}
A312012	Gal.3.32.2	{{1, 1}, {-1 + x, 2}, {1 + x, 2}, {1 - x + x^2, 1}, {1 + x + x^2, 1}, {1 + x + x^2 + x^3 + x^4, 2}}
A312253	Gal.3.32.3	{{1, 1}, {-1 + x, 2}, {1 + x, 1}, {1 - x + x^2, 1}, {1 + x + x^2, 1}, {1 + x + x^2 + x^3 + x^4, 2}}
A313051	Gal.3.33.1	{{1, 1}, {-1 + x, 2}, {1 + x + x^2 + x^3 + x^4 + x^5 + x^6, 1}}
A314445	Gal.3.33.2	{{1, 1}, {-1 + x, 2}, {1 + x + x^2, 1}, {1 + x + x^2 + x^3 + x^4 + x^5 + x^6, 1}}
A314874	Gal.3.33.3	{{1, 1}, {-1 + x, 2}, {1 + x + x^2, 1}, {1 + x + x^2 + x^3 + x^4 + x^5 + x^6, 1}}
A313101	Gal.3.34.1	{{1, 1}, {-1 + x, 2}, {1 + x + x^2 + x^3 + x^4, 1}, {1 + x^3 + x^6, 1}}
A314698	Gal.3.34.2	{{1, 1}, {-1 + x, 2}, {1 + x + x^2 + x^3 + x^4, 1}, {1 + x^3 + x^6, 1}}

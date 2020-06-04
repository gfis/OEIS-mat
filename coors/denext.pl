#!perl

# Extract and prepare denominators from Maple' guessgf 
# @(#) $Id$
# 2020-05-31, Georg Fischer: copied from denpoly.pl
# 
#:# Usage:
#:#   perl denext.pl inputfile ... > outputfile
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
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{n}) {
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
#----
while (<>) {
    next if ! m{\AGal};
    s{\s+\Z}{}; # chompr
    my $line = $_;
    my ($galid, $ibase, $vertex, $mapgf) = split(/\t/, $line);
    $mapgf =~ m{\/([^\,]+)};
    my $denom = $1;
    $denom =~ s{[\(\)]}{}g;
    if ($denom =~ m{\A\-}) { # negate it
        $denom =~ s{\+}{\#}g;
        $denom =~ s{\-}{\+}g;
        $denom =~ s{\#}{\-}g;
        $denom =~ s{\A\+}{};
    } # negate
    print join("\t", $galid, $ibase, $vertex, $denom) . "\n";
} # while <>
__DATA__
Gal.1.1.1	-1	6.6.6	[-(x^2+x+1)/(-x^2+2*x-1), ogf]
Gal.1.2.1	-1	8.8.4	[-(-x^4-2*x^3-2*x^2-2*x-1)/(x^4-x^3-x+1), ogf]
Gal.1.3.1	-1	12.6.4	[-(x^6+2*x^5+2*x^4+2*x^3+2*x^2+2*x+1)/(-x^6+x^5+x-1), ogf]
Gal.1.4.1	-1	12.12.3	[-(2*x^8-4*x^7+3*x^6-5*x^5+x^4-3*x^3-x^2-x-1)/(x^6-2*x^5+3*x^4-4*x^3+3*x^2-2*x+1), ogf]
Gal.1.5.1	-1	4.4.4.4	[-(x^2+2*x+1)/(-x^2+2*x-1), ogf]
Gal.1.6.1	-1	6.4.3.4	[-(x^2+2*x+1)/(-x^2+2*x-1), ogf]
Gal.1.7.1	-1	6.3.6.3	[-(-2*x^5+3*x^4+6*x^3+6*x^2+4*x+1)/(-x^4+2*x^2-1), ogf]
Gal.1.8.1	-1	4.4.3.3.3	[-(x^2+3*x+1)/(-x^2+2*x-1), ogf]
Gal.1.9.1	-1	4.3.4.3.3	[-(-x^4-4*x^3-6*x^2-4*x-1)/(x^4-x^3-x+1), ogf]
Gal.1.10.1	-1	6.3.3.3.3	[-(x^6+4*x^5+4*x^4+6*x^3+4*x^2+4*x+1)/(-x^6+x^5+x-1), ogf]

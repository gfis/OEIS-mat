#!perl

# Prepare denominators for Maple simplify
# @(#) $Id$
# 2020-05-13, Georg Fischer
# 
#:# Usage:
#:#   perl denpoly.pl inputfile ... > outputfile
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
    my ($aseqno, $callcode, $offset, $numv, $denv, $galid, @rest) = split(/\t/, $line);
    my $denpoly = "";
    my $iden = 0;
    # Reconstruct the polynomial. JoeisPreparer had normalized the sign.
    foreach my $den (split(/\,/, $denv)) {
        if ($den > 0) {
            $denpoly .= "+$den";
        } elsif ($den < 0) {
            $denpoly .= $den;
        }
        if ($den != 0) {
            if ($iden == 0) { # omit it
            } elsif ($iden == 1) {
                $denpoly .= "*x";
            } else { # > 1
                $denpoly .= "*x^$iden";
            }
        }
        $iden ++;
    } # foreach
    $denpoly =~ s{([\+\-])1\*}{$1}g; # remove "1*"
    $denpoly =~ s{\A\+}{}; # remove leading "*"
    print join("\t", $aseqno, $galid, $denpoly) . "\n";
} # while <>
__DATA__
A008486 lingfo  0   1,1,1   1,-2,1  Gal.1.1.1   1   1   s3  =   s3  -(x^2+x+1)/(-x^2+2*x-1)
A008576 lingfo  0   1,2,2,2,1   1,-1,0,-1,1 Gal.1.2.1   1   2   s5  =   s5  -(-x^4-2*x^3-2*x^2-2*x-1)/(x^4-x^3-x+1)
A072154 lingfo  0   1,2,2,2,2,2,1   1,-1,0,0,0,-1,1 Gal.1.3.1   1   3   s7  =   s7  -(x^6+2*x^5+2*x^4+2*x^3+2*x^2+2*x+1)/(-x^6+x^5+x-1)
A250122 lingfo  0   1,1,1,3,-1,5,-3,4,-2    1,-2,3,-4,3,-2,1    Gal.1.4.1   1   4   s7  <   a9  -(2*x^8-4*x^7+3*x^6-5*x^5+x^4-3*x^3-x^2-x-1)/(x^6-2*x^5+3*x^4-4*x^3+3*x^2-2*x+1)
A008574 lingfo  0   1,2,1   1,-2,1  Gal.1.5.1   1   5   s3  =   s3  -(x^2+2*x+1)/(-x^2+2*x-1)
A008574 lingfo  0   1,2,1   1,-2,1  Gal.1.6.1   1   6   s3  =   s3  -(x^2+2*x+1)/(-x^2+2*x-1)

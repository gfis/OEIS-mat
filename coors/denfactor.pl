#!perl

# Split factors in result of simplify.mpat
# @(#) $Id$
# 2020-05-13, Georg Fischer
# 
#:# Usage:
#:#   perl denfactor.pl [-gcd] nputfile ... > outputfile
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
    my ($aseqno, $galid, $denp) = split(/\t/, $line);
    $denp =~ s{\*\(}{\|\(}g;
    foreach my $factor(split(/\|/, $denp)) {
        if (0) {
        } elsif ($factor =~ m{\A\(([^\)]+)\)\Z}) {
            $factor = $1;
        } elsif ($factor =~ m{\A\(([^\)]+)\)\^\d+\Z}) {
            $factor = $1;
        } 
        if ($factor =~ m{\A1\+x\Z}) {
            $factor = "x+1";
        }
        if ($factor eq "x-1" or $with_gcd == 0) {
            # leave it
        } else { # may have a common power of x
            if ($factor !~ m{\+1\Z}) {
                print STDERR "# assertion 1: factor $factor without trailing \"+1\"\n";
            }
            if ($factor =~ m{\*}) {
                print STDERR "# assertion 2: factor $factor contains coefficient\n";
            }
            my $poly = $factor;
            $poly =~ s{x([\+\-])}{x^1$1}g;
            $poly =~ s{\+1\Z}{};
            my @expons = $poly =~ m{(\d+)}g;
            # print join(".", @expons) . "\n";
            my $num1 = shift(@expons) || 1;
            if (scalar(@expons) == 0) { # eq "x^n+1"
                # $factor = "x+1; x=y^$num1";
                $factor = "x+1";
            } else {
                my $shortable = 1;
                while ($shortable == 1 and scalar(@expons) > 0) {
                    my $num2 = shift(@expons);
                    my $num3 = &gcd($num1, $num2);
                    if ($num3 > 1) {
                        $num1 = $num3;
                    } else {
                        $num1 = 1;
                        $shortable = 0;
                    }
                } # while shift
                my $suffix = "";
                if ($num1 > 1) { # reduce
                    $suffix = "; x=y^$num1";
                    $poly =~ s{(\d+)}{$1/$num1}eg;
                    # $poly =~ s{x}{y}g;
                    # $factor = "$poly+1$suffix";
                    $factor = "$poly+1";
                } # reduce
        	} # ne x^n+1
        } # common power of x
        $factor =~ s{\^1(\D)}{$1}g;
        print "$factor\n";
    }
} # while <>

# from https://www.perlmonks.org/?node_id=109872
sub gcd {
  my ($a, $b) = @_;
  ($a,$b) = ($b,$a) if $a > $b;
  while ($a) {
    ($a, $b) = ($b % $a, $a);
  }
  return $b;
} # egcd
__DATA__
A008486 Gal.1.1.1   (x-1)^2
A008576 Gal.1.2.1   x^4-x^3-x+1
A072154 Gal.1.3.1   x^6-x^5-x+1
A250122 Gal.1.4.1   (x-1)^2*(x^2+1)^2
A008574 Gal.1.5.1   (x-1)^2
A008574 Gal.1.6.1   (x-1)^2
A008579 Gal.1.7.1   x^4-2*x^2+1
A008706 Gal.1.8.1   (x-1)^2
A219529 Gal.1.9.1   x^4-x^3-x+1
A250120 Gal.1.10.1  x^6-x^5-x+1
A008458 Gal.1.11.1  (x-1)^2
A265035 Gal.2.1.1   (x^2-x+1)*(x-1)^2
A265036 Gal.2.1.2   (x-1)^2*(x^2-x+1)^2
A301287 Gal.2.2.1   (x^2+1)*(x^2+x+1)*(x-1)^2
A301289 Gal.2.2.2   (x^2+1)*(x^2+x+1)*(x^2-x+1)*(x-1)^2
A301293 Gal.2.3.1   (x^2+1)*(x-1)^2
A301291 Gal.2.3.2   (x^2+1)*(x-1)^2


x^14-2*x^7+1
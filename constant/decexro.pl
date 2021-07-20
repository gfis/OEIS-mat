#!perl

# Extract decimal expansion sequences from roots of polynomials
# @(#) $Id$
# 2021-07-15, Georg Fischer
#
#:# Usage:
#:#   perl decexro.pl [-d debug] real_root.tmp > decexro.gen
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
$timestamp = sprintf ("%04d-%02d-%02d", $year + 1900, $mon + 1, $mday);

my $debug = 0;
if (scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
my $ignore = 1;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{i}) {
        $ignore    = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my $offset = 0;
while (<>) {
    my $line = $_;
    next if $line !~ m{\AA\d+};
    $line =~ s/\s+\Z//; # chompr
    my ($aseqno, $offset, $termlist, $superclass, $name) = split(/\t/, $line);
    if ($name =~ m{(of|to)[^x0-9]*([x \d\+\-\*\^\/]+)}) {
        my $poly = $2;
        $poly =~ s{ }{}g;
        my $low  = substr($termlist, 0, 1) . substr($termlist, 2, 1);
        my $hig  = $low + 1;
        if ($offset == 0) {
            $low =~ s{(\d\d)\Z}{0\.$1};
            $hig =~ s{(\d\d)\Z}{0\.$1};
        } else {
            $low =~   s{(\d)\Z}{\.$1};
            $hig =~   s{(\d)\Z}{\.$1};
        }
        # $low  = substr($termlist, 0, 1);
        # $hig  = $low + 1;
        # $low = "CR.valueOf(\"$low\", 10)";
        # $hig = "CR.valueOf(\"$hig\", 10)";
        my $nok = 0;
        if (0) {
        } elsif ($poly =~ m{\^\D}) {
            $nok = 1; # non-integer power
        } elsif ($poly !~ m{x}) {
            $nok = 2; # no variable x
        } elsif ($poly !~ m{[\+\-\*\^\/]}) {
            $nok = 3; # polynomial contains no operator
        } elsif ($poly =~ m{[\+\-\*\^\/]\Z}) {
            $nok = 4; # polynomial did not end properly
        } 
        if ($nok == 0) {
            print        join("\t", $aseqno, "fract1", $offset, $poly, 1, $low, $hig, $poly) . "\n";
        } else {
            # ignore
            print STDERR join("\t", $aseqno, "nok=$nok", $offset, $poly, 1, $low, $hig, $poly) . "\n";
        }
    }
} # while
__DATA__
A060006 1   1,3,2,4,7,1,7,9 null    Decimal expansion of real root of x^3 - x - 1 (the plastic constant).
A068960 1   2,3,7,1,4,5,0,6 null    Decimal expansion of the fifth smallest positive real root of sin(x) - sin(x^3) = 0.
A075778 0   7,5,4,8,7,7,6,6 null    Decimal expansion of the real root of x^3 + x^2 - 1.
A088559 0   4,6,5,5,7,1,2,3 null    Decimal expansion of R^2 where R^2 is the real root of x^3 + 2*x^2 + x - 1 = 0.
A089826 0   6,5,7,2,9,8,1,0 null    Decimal expansion of real root of 2*x^3+x^2-1.

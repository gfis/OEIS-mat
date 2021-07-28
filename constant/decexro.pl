#!perl

# Extract decimal expansion sequences from roots of polynomials
# @(#) $Id$
# 2021-07-15, Georg Fischer
#
#:# Usage:
#:#   perl decexro.pl [-d debug] [-w width] real_root.tmp > decexro.gen
#:#       -w width, number of relevant digits for boundaries (default: 4)
#--------------------------------------------------------
use strict;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
$timestamp = sprintf ("%04d-%02d-%02d", $year + 1900, $mon + 1, $mday);

my $debug = 0;
my $width = 4; # number of relevant digits for boundaries
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
    } elsif ($opt  =~ m{w}) {
        $width     = shift(@ARGV);
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
    $name =~ s{Decimal expansion of }{};
    if ($name =~ m{(root|solution|equation) (of|to) ([ \w\+\-\*\^\/\=\(\)]+)}) {
        my $poly = $3;
        $poly =~ s{ }{}g;
        $poly =~ s{\=0\Z}{}; # remove trailing "=0"
        $poly =~ s{\=(.+)\Z}{\-\($1\)}; # change "=expr" to "-(expr)"
        my $low  = &deconst($offset, 0, $termlist);
        my $hig  = &deconst($offset, 1, $termlist);
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
        } elsif ($poly =~ m{[A-Za-wyz]}) {
            $nok = 5; # letters other than x
        }
        if ($nok == 0) {
            print        join("\t", $aseqno, "fract1",   $offset, $poly, 1, $low, $hig, $poly, $name) . "\n";
        } else {
            # ignore
            print STDERR join("\t", $aseqno, "nok=$nok", $offset, $poly, 1, $low, $hig, $poly, $name) . "\n";
        }
    }
} # while
#----
sub deconst { # global: $width
    my ($offset, $add1, $termlist) = @_;
    my $result = ("0." . substr($termlist, 0, $width)) + ("0." . "0" x ($width - 1) . $add1);
    $result *= 10 ** $offset;
    # print "# offset=$offset, add1=$add1, termlist=$termlist, result=$result\n";
    return $result;
} # deconst
__DATA__
A060006 1   13247179 null    Decimal expansion of real root of x^3 - x - 1 (the plastic constant).
A068960 1   23714506 null    Decimal expansion of the fifth smallest positive real root of sin(x) - sin(x^3) = 0.
A075778 0   75487766 null    Decimal expansion of the real root of x^3 + x^2 - 1.
A088559 0   46557123 null    Decimal expansion of R^2 where R^2 is the real root of x^3 + 2*x^2 + x - 1 = 0.
A089826 0   65729810 null    Decimal expansion of real root of 2*x^3+x^2-1.

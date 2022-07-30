#!perl

# Determine whether a recurrence is D-finite.
# @(#) $Id$
# 2022-03-26, Georg Fischer
#
#:# Usage:
#:#   perl isDFinite.pl "recurrence annihilator"
#:# The recurrence must omit the trailing " = 0",
#;# and may only contain whitespace and the characters
#:#   a n ( ) + - * ^ [0-9]
#---------------------------------
use strict;
use integer;
use warnings;

my $rec = shift(@ARGV);

$rec =~ s{\s}{}g; # remove all whitespace
if ($rec =~ m{([^an\d\+\-\*\^\(\)\= ])} {
    die "# invalid character \"$1\"\n";
}
$rec =~ s{(\d)([a-z])}{${1}\*$2}g; # replace "2n" by "2*n"
$rec =~ s{(\))(\w)}{${1}\*$2}g; # replace ")a" by ")*a"
$rec =~ s{(\))(\()}{${1}\*$2}g; # replace ")( "by ")*("
$rec =~ s{^([^\+\-])}{\+$1}; # prefix with "+" if there is no leading sign
my @coeffs = map {
    s{(\w)(\()}{${1}\*$2}g; # replace "n(" by "n*("
    $_ # result of map
    } split(/a\(n([\+\-]\d+)?\)/, $rec); # split at "a(n[+-d])"

foreach my $coeff(@coeffs) {
    if ($coeff =~ m{a}) {
        print STDERR "# recurrence element not of the form a(n+-d): \"$coeff\"\n";
    }
    my $lcount = ($rec =~ s{\(}{\(}g;
    my $rcount = ($rec =~ s{\)}{\)}g;
    if ($lcount != $rcount) {
        print STDERR "# Coefficient \"$coeff\" has number of \"(\" <> number of \")\" ($lcount <> $rcount)\n";
    }
    if ($coeff =~ m{^([\^\*\)])}) {
        print STDERR "# Coefficient \"$coeff\" cannot start with \"$1\"\n";
    }
    if ($coeff =~ m{^\^([\(\*])}) {
        print STDERR "# Coefficient \"$coeff\" cannot start with \"$1\"\n";
    }
} # foreach $coeff



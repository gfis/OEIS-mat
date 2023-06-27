#!perl

# Truncate the names in seq4 records, separate "for n > 4" etc.
# @(#) $Id$
# 2023-06-13, Georg Fischer
#
#:# Usage:
#:#   perl trunc_name.pl [-d debug] [-forn] input.{seq4|cat25} > output
#
# The EXTENSION is removed, and any "for n >..." is appended as a separate field
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
$timestamp = sprintf ("%04d-%02d-%02d", $year + 1900, $mon + 1, $mday);
my $debug = 0;
if (0 && scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
my $with_forn = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{f}) {
        $with_forn = 1;
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my $name;
my $nok; # assume ok
# while (<DATA>) {
while (<>) {
    $nok = 0;
    my $line = $_;
    $line =~ s/\s+\Z//; # chompr
    $name = $line;
    my $orig_name = $name;
    
    $name =~ s{\. +\- \_?[A-Z].*}{}g; # normal extension string
    $name =~ s{ \- +\_?[A-Z][ \.a-zA-Z0-9]+\, \w\w\w \d{2} \d{4} *\Z}{}g; # normal extension string
    $name =~ s{ \- +_[A-Z][\.a-z].*\Z}{}g; # known author only
    $name =~ s{\. +\[\_.*}{}g; 
    if ($with_forn) {
        my $forn = "";
        #                   1                     1       2         2  3   3
        if ($name =~ s{\,? *(for|where|with|unless) +[n] *([\<\>]\=?) *(\d+)}{}) {
            my ($word, $relop, $min) = ($1, $2, $3 + 0);
            if ($relop !~ m{\=}) { # "<" resp. ">" 
                $min += ($word =~ m{unless}) ? 0 : 1;
            } else {
                $min += ($word =~ m{unless}) ? -1 : 0;
            }
            $forn = $min;
        }
        print join("\t", $name, "ge$forn") . "\n";
    } else {
        print "$name\n";
    }
} # while
__DATA__
#F A005610 a(n) = 6*a(n-1) + 2 for n > 1. - _Georg Fischer_, Nov 13 2018
#F A035021 D-finite with recurrence: a(1) = 1, a(n) = (9*n - 2)*a(n-1) unless n < 2. - _Georg Fischer_, Feb 15 2020
#F A005610 a(n) = 6*a(n-1) + 2 for n >= 1. - _Georg Fischer_, Nov 13 2018
#F A035021 D-finite with recurrence: a(1) = 1, a(n) = (9*n - 2)*a(n-1) unless n <= 2. - _Georg Fischer_, Feb 15 2020
#F A012960 a(n) = (n*A002019(n)-A002019(n+1))/(n-1) for n > 1. [_Mark van Hoeij_, Jul 02 2010]
%F A110707 a(n) = 2*A000172(n-1)+2*A000172(n) - _Mark van Hoeij_, Jul 14 2010

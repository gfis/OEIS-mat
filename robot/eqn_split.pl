#!perl

# Split equations in seq4 records
# @(#) $Id$
# 2023-06-13, Georg Fischer
#
#:# Usage:
#:#   perl trunc_name.pl input.{seq4|cat25} \
#:#   | perl eqn_split.pl [-d debug] > output
#
# Assume that 'trunc_name.pl' has been run before, and that there is a trailing "forn" field.
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
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

while (<DATA>) {
# while (<>) {
    my $line = $_;
    $line =~ s/\s+\Z//; # chompr
    my $orig_name = $line;
    my @parts = split(/\t/, $line);
    my $iname = scalar(@parts) - 2;
    my $name = $parts[$iname]; # before the last
    my @eqs = split(/ *\= */, $name);
    for (my $ieq = 1; $ieq < scalar(@eqs); $ieq ++) { # first is "... a(n)"
        $line = "";
        for (my $ipart = 0; $ipart < $iname; $ipart ++) {
            $line .= "$parts[$ipart]\t";
        }
        $line .= "$eqs[0] = $eqs[$ieq]\t" . $parts[$iname + 1];
        print "$line\n";
    }
} # while
__DATA__
#F A005610 a(n) = 6*a(n-1) + 2 = 2*(3*a(n) + 1)	ge2

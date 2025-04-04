#!perl

# Write several records for lists of equations
# @(#) $Id$
# 2025-02-03: default column=2
# 2024-06-05, Georg Fischer
#
#:# Usage:
#:#   perl split_equations.pl [-d debug] -c fieldno input.seq4 > output.seq4
#:#       -c number of field to be splitted (1, 2, ...; default 1)
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min);
my $pwd = `pwd`;
$pwd =~ m{(/OEIS\-mat\S*)};
print "# Generated by ..$1/$0 at $timestamp\n";
if (0 && scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
my $debug = 0;
my $column = 2;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{c}) {
        $column    = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

#while (<DATA>) {
while (<>) {
    next if ! m{\AA\d+\s};
    s/\s+\Z//; # chompr
    my $line = $_;
    my (@fields) = split(/\t/, $line);
    my $eqnlist = $fields[$column - 1];
    foreach my $eqn (split(/\=/, $eqnlist)) {
        $fields[$column - 1] = $eqn;
        print join("\t", @fields) ."\n";
    }
} # while
__DATA__
A348757	5*(5-sqrt(5))/(4*sqrt(5+2*sqrt(5)))=X094874*X179050=10*X094874/X344172
A349004	X073747-1
A349274	sqrt((17+7*sqrt(5))/22)*sqrt(1+b^2)/b
A349850	log(4*phi^(12/sqrt(5)))=2*log(2)+12*log(phi)/sqrt(5)

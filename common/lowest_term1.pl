#!perl

# Determine lowest first term (for PositionSubsequence)
# @(#) $Id$
# 2020-09-01, Georg Fischer
#
#:# usage:
#:#   perl lowest_term1.pl bfdata.txt > outputfile
#---------------------------------
use strict;
use integer;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday) = gmtime (time);
my $utc_stamp = sprintf ("%04d-%02d-%02dT%02d:%02d:%02d\z"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);

# get options
my $debug      = 0; # 0 (none), 1 (some), 2 (more)
if (0 and scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{\-d}) {
        $debug    = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while ARGV

my $minterm = 0;
while (<>) {
    s/\s+\Z//; # chompr
    my $line = $_;
    my ($aseqno, $termno, $termlist) = split(/\t/, $line);
    my $term1 = substr($termlist, 0, index($termlist, ','));
    if ($term1 !~ m{\A\-}) {
        # ignore nonegatives
    } elsif ($term1 < $minterm) {
        print join("\t", $aseqno, $term1) . "\n";
        $minterm = $term1;
    } elsif (length($term1) >= 15) {
        print join("\t", $aseqno, $term1) . "\n";
    }
} # while <>
#------------------------------------
__DATA__
A001529 9       1,2,3,6,15,63,567,14755,1366318
A001530 9       1,1,1,3,9,48,504,14188,1351563

A002070 -2,-
A006311 -3,
A011520 -362880,
A011524 -6227020800,
A011528 -355687428096000,
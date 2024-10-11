#!perl

# Process Mathematica "LinearRecurrence" statements
# @(#) $Id$
# 2024-10-01, Georg Fischer
#
#:# Usage:
#:#   perl tlinrec.pl jcat25-extract > output.seq4
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
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my ($line, $aseqno, $callcode, $offset1, $signature, $inits, @rest);
my $nok;
while (<>) {
    s/\s+\Z//;
    $line = $_;
    $nok = 0;
    #                   1    1                          2      2          3      3
    if ($line =~ m{^\%t (A\d+) *LinearRecurrence *\[ *\{([^\}]+)\} *\, *\{([^\}]+)\} *\, *}) {
        ($aseqno, $signature, $inits) = ($1, $2, $3);
    }
    if ($nok == 0) {
        my @signats = reverse(split(/\, */, $signature));
        my @terms   = split(/\, */, $inits);
        my $prelen  = scalar(@terms) - scalar(@signats);
        my $matrix = "[0," . (join(",", @signats)) . ",-1]";
        my $ilist = join(",", @terms);
        print join("\t", $aseqno, "holos", 0, $matrix, $ilist, 0, 0) ."\n";
        print "    make runholo A=$aseqno MATRIX=\"$matrix\" INIT=\"$ilist\"\n";
    } else {
        print STDERR join("\t", $aseqno, "$nok", 0, $line) ."\n";
    }
} # while <>
__DATA__
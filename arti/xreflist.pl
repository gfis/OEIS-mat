#!perl

# Extract nyi with names from jcat25(#Y) records of ari sequences
# @(#) $Id$
# 2025-06-14, Georg Fischer
#
#:# Usage:
#:#     perl xreflist.pl [-d mode] input.jcat25.txt > output.seq4
#:#     -d  debugging level (0=none (default), 1=some, 2=more)
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
$timestamp = sprintf ("%04d-%02d-%02d", $year + 1900, $mon + 1, $mday);

my $debug = 0;
if (0 and scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}

while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt   =~ m{\-d}  ) {
        $debug      = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while options

my $line;
my $name;
while (<>) {
    $line = $_;
    $line =~ s/\s+\Z//; # chompr
    my ($aseqno, $text) = split("\t", $line);
    my $xseqno = $aseqno;
    $aseqno =~ s{\A.}{A};
    $text =~ s{this( sequence)?}{$xseqno}g;
    my $callcode = "conum";
    my %hash = ();
    #              123       3        (                    )    2   1
    if ($text =~ s{(((€|[A-Z])\d{6} *\(\w+ *\= *[0-9\-\/]+\)\, *){3})} {\t$1}) {
        $text =~ s{ *\= *}{\=}g;
        my ($prefix, $list) = split(/\t/, $text);
        if ($list =~ m{€}) {
            print join("\t", $aseqno, $list, $prefix) . "\n";
        }
    }
} # while <>
#----------------
__DATA__
grep -P "#Y A117401" ../common/jcat25.txt | cut -b 4- | endirect | perl -pe 's/ /\t/; ' | tee x.tmp
A117401	Cf. J117402 (row sums), J117403 (antidiagonal sums), J002416 (central terms).
A117401	Cf. this sequence (m=0), J118180 (m=1), J118185 (m=2), J118190 (m=3), J158116 (m=4), J176642 (m=6), J158117 (m=8), J176627 (m=10), J176639 (m=13), €156581 (m=15).

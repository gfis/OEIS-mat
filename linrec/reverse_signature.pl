#!perl

# Generate linear recurrence programs
# @(#) $Id$
# 2019-03-29, Georg Fischer
#
#:# Usage:
#:#   perl reverse_signature.pl [-d debug] infile > outfile
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
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my $line;
my $aseqno;
my $signature;
my $initterms = "";
my $termno  = 0;

while (<>) {
    $line = $_;
    $line =~ s/\s+\Z//; # chompr
    ($aseqno, $signature, $initterms) = split(/\t/, $line);
    $signature =~ s{\-?\,1\Z}{};
    my @signatures = map {
        my $term = $_;
        ($term =~ m{\A\-}) ? substr($term, 1) : "-$term" # return value of map
    } reverse(split(/\,/, $signature));
    $signature = join(",", @signatures);
    print join("\t", ($aseqno, $signature, $initterms)) . "\n";
} # while <>
__DATA__
A000002 -1,1,0,0,0,-1,1 null    null
A000008 -1,1,1,-1,0,1,-1,-1,1   1,1,-1,0,1,-1,-1,1,0,1,-1,-1,1,0,-1,1,1,-1      Sequence
A000012 -1,1    1       Sequence
A000027 1,-2,1  2,-1    Sequence
A000030 -1,1    null    null
A000032 -1,-1,1 1,1     Sequence
A000034 -1,0,1  0,1     Sequence
A000035 -1,0,1  0,1     Sequence
wc -l    raeval_joeis.tmp
42190 raeval_joeis.tmp
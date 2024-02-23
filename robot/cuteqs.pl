#!perl

# Cut multiple equations into several lines
# @(#) $Id$
# 2024-02-02, Georg Fischer
#
#:# Usage:
#:#   perl cuteqs.pl input.cat25 > output.seq4
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min);
my $progname = $0;
print "# Generated by $progname at $timestamp\n";

my $CAT = "../common/jcat25.txt";
# my $pattern = "^\\%[NF] A\\d+ *a\\(n\\) *\\= *(gcd|GCD)\\(A\\d+\\(n( *\\+ *1)?\\)\\, *A\\d+\\(n( *\\+ *1)?\\)\\) *[\\..|\\=]*";
my $pattern = "^\\%[NFC] A\\d+ *a\\(n\\) *\\=";
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
print "# $pattern\n" if $debug > 0;

foreach my $line (split(/\r?\n/, `grep -P \"$pattern\" $CAT`)) {
    print "# $line\n" if $debug > 0;;
    my ($type, $aseqno, $rest) = split(/ +/, $line, 3);
    $rest =~ s{ *a\(n\) *\= *}{}; # remove "a(n) = "
    foreach my $eq1 (split(/ \= /, $rest)) {
        if (0) {
        } elsif ($eq1 =~ m{(Sum_|Prod(uct)?_)}i) { # ignore "Sum_{", "Prod_"
        } else {
            $eq1 =~ s{(\..*|\;.*)}    {};
            $eq1 =~ s{(\,.*)}         {\t$1};
            if (0) {
            } elsif ($eq1 =~ m{\AA\d+\(A\d+\(n\)\)}) {
                print        join("\t", $aseqno, "cuteqs", 0, "$eq1") ."\n";
            } elsif ($eq1 =~ m{\AA\d+\(A\d+\(n\)\)}) {
                print STDERR join("\t", $aseqno, "cut"   , 0, "$eq1") ."\n";
            }
        }
    } # foreach
} # foreach $line
#--------------------------------------------
__DATA__
%N A325975 a(n) = gcd(A325977(n), A325978(n)).
%F A325975 a(n) = gcd(A325977(n), A325978(n)).

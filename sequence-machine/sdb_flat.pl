#!perl

# remove spaces and insert complete A-numbers
# @(#) $Id$
# 2021-06-22, Georg Fischer: copied from ../deris.pl
#
#:# Usage:
#:#     perl sdb_flat.pl input > output
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
my $callcode;
my $ofter_file = "../../../OEIS-mat/common/joeis_ofter.txt";
my $pseudo  = 0;
my $prepend = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt   =~ m{\-cc}i) {
        $callcode   = shift(@ARGV);
    } elsif ($opt   =~ m{\-d}  ) {
        $debug      = shift(@ARGV);
    } elsif ($opt   =~ m{\-f}  ) {
        $ofter_file = shift(@ARGV);
    } elsif ($opt   =~ m{\-prep} ) {
        $prepend    = 1;
    } elsif ($opt   =~ m{\-pseudo} ) {
        $pseudo     = 1;
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
#----------------
my $aseqno;
my $offset = 1;
while (<>) {
    my $line = $_;
    $line =~ s/\s//g; # remove all whitespace
    $line =~ s{\A(\"oi\"\:)(\d+)\,}{"\t$1\n" . sprintf("\"A%06d\t\"", $2) .","}e;
    print $line;
} # while <>
print "\n";
#----------------
__DATA__
{
  "entities": [
    {
      "oi": 4,
      "ps": [
        {
          "ix": "0",
          "mt": 1001,
          "px": [
            "zero"
          ]
        }
      ]
    },
    
    {
      "oi": 8598,
      "ps": [
        {
          "ix": "16*n",
          "mt": 1001,
          "px": [
            "sixteen",
            "n",
            "*"
          ]
        }
      ]
    },
    {
      "oi": 22973,
      "ps": [
        {
          "ix": "17-n",
          "mt": 61,
          "px": [
            "seventeen",
            "n",
            "sub"
          ]
        }
      ]
    },
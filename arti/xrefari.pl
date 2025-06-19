#!perl

# Extract nyi with names from jcat25(#Y) records of ari sequences
# @(#) $Id$
# 2025-06-14, Georg Fischer
#
#:# Usage:
#:#     perl xrefari.pl [-d mode] input.jcat25.txt > output.seq4
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
my $skip;   # asemble skip instructions here
while (<>) {
    $line = $_;
    $line =~ s/\s+\Z//; # chompr
    my ($aseqno, $text) = (substr($line, 3, 7), substr($line, 11));  
    $text =~ s{€}{Y}g;
    my $callcode = "conum";
    my %hash = ();
    #                           1         (         )1
    foreach my $nyi ($text =~ m{(Y\d{6} *\([^\.\,]+\))}) {
        #              1     1   (2      2 )
        if ($nyi =~ m{Y(\d{6}) *\(([^\)]+)\)}) { 
            my ($seqno, $desc) = ($1, $2);
            if (0) {
            }
            print join("\t", "A$seqno", $callcode, 0, $aseqno, $desc) . "\n";
        } else {
      }  
    } # foreach nyi
} # while <>
#----------------
__DATA__
#Y A065854 Cf. €084740 (least k such that (n^k-1)/(n-1) is prime).
#Y A065883 Cf. A214392, A235127, €350091 (drop final 2's).
#Y A065919 Cf. €143411 (main diagonal), A143412.
#Y A065973 Cf. €260306 (numerators), €090804, A005446, A005447.
#Y A065997 Cf. A000396, A005820, €046060 (subsequences).
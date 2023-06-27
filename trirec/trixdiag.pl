#!perl

# Prepare trixdiag.gen
# @(#) $Id$
# 2023-06-24, Georg Fischer: copied from prep_traits
#
#:# Usage:
#:#   perl trixdiag.pl infile > trixdiag.gen
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

while (<>) {
    my $line = $_;
    $line =~ s{\s+\Z}{}; # chompr
    #              1    1                 2  2
    if ($line =~ m{(A\d+)\.java\:\s+super\((.*)}) {
        my ($aseqno, $rest) = ($1, $2);
        my $parm = "n -> Z.valueOf(n)";
        #              1            1
        if ($rest =~ m{(new A\d+\(\))}) {
           $parm = $1;
        }
        print join("\t", $aseqno, "trixdiag", 0, $parm, "", $rest) . "\n";
    } else {
        print STDERR "# $line\n";
    }
} # while <>

#--------------------------------------------
__DATA__
../../joeis-lite/internal/fischer/manual/A174712.java:    super("0", new A000041());
../../joeis-lite/internal/fischer/manual/A185740.java:    super("1", new A000079());
../../joeis-lite/internal/fischer/manual/A185911.java:    super(1, 1, -1);
../../joeis-lite/internal/fischer/manual/A198954.java:    super(0, new long[] {1, 1, 0}, new long[] {1, -2, 0, 1, 0, 0});
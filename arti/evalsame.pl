#!perl

# Evaluate the formulas with the same non-digit content
# @(#) $Id$
# 2023-09-01, Georg Fischer: copied from sortprep.pl
#
#:# Usage:
#:#   perl evalsame.pl input > output
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

my ($code, $type, $aseqno, $callcode, $offset1, $name, @nums, $numlist, @asns, $asnlist, @rest, $nok);
my ($ocode, $otype, $oaseqno, $oname, $onumlist, $oasnlist) = ("","","","","","");
my ($ncode, $ntype, $naseqno, $nname, $nnumlist, $nasnlist);
my @parms;
$callcode = "evalsame";
$offset1 = 0;
my $line;
my $state = 1; # searching for change "# -> %"

while (<>) {
    $line = $_;
    if ($debug >= 3) {
        print "# line=$line";
    }
    $line =~ s/\s+\Z//; # chompr
    $nok = 1; # assume failure
    ($ncode, $ntype, $naseqno, $nname, $nnumlist, $nasnlist, @rest) = split(/\t/, $line . "\t\t\t\t\t\t1");
    if (0) {
    } elsif ($state == 1 && $nname eq $oname && $ocode eq "#" && $ncode eq "%") { # switch from ari to nyi
        $state = 2;
        print "#----\n";
        print join("\t", ($ocode, $otype, $oaseqno, $oname, $onumlist, $oasnlist)) . "\n";
        print join("\t", ($ncode, $ntype, $naseqno, $nname, $nnumlist, $nasnlist)) . "\n";
    } elsif ($state == 2 && $nname eq $oname && $ocode eq "%" && $ncode eq "%") { # same, nyi
        print join("\t", ($ncode, $ntype, $naseqno, $nname, $nnumlist, $nasnlist)) . "\n";
    } else {
        $state = 1;
    }
    ($ocode, $otype, $oaseqno, $oname, $onumlist, $oasnlist) = 
    ($ncode, $ntype, $naseqno, $nname, $nnumlist, $nasnlist);
} # while <>

#--------------------------------------------
__DATA__

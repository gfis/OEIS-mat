#!perl

# Delete all records in the input file that stem from sequences with "... implements Conjectural" 
# @(#) $Id$
# 2023-05-05, Georg Fischer
#
#:# Usage:
#:#   perl delete_coral.pl [-d debug] [-f joeis_coral.txt] infile > outfile
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
$timestamp = sprintf ("%04d-%02d-%02d", $year + 1900, $mon + 1, $mday);

if (0  && scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
my $debug = 0;
my $coral_file = "joeis_coral.txt";
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt   =~ m{d}) {
        $debug      = shift(@ARGV);
    } elsif ($opt   =~ m{[cf]}) {
        $coral_file = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my %coral = ();
open(CORAL, "<", $coral_file) || die "cannot read \"$coral_file\"";
while (<CORAL>) {
    s/\s+\Z//; # chompr
    $coral{$_} = 1;
} # while CORAL
close(CORAL);

my $line;
my $aseqno;
while (<>) {
    my $line = $_;
    if ($line =~ m{\A(A\d+)}) {
        $aseqno = $1;
        if (! defined($coral{$aseqno})) {
            print $line;
        }
    } else {
        # ignore
    }
} # while <>
__DATA__

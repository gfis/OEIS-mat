#!perl

# Prepare files for circdiff
# @(#) $Id$
# 2021-04-08, Georg Fischer
#
#:# Usage:
#:#     perl circprep.pl [-d debug] -m [bf|gen] parmfile 
#:#         -m mode: bf (create b-files), gen (create *.gen file)
#:#         parmfile has tab-separated tuples (A-number,k,d)
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
my $mode = "bf";
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{m}) {
        $mode      = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my $line;
my ($aseqno, $k, $d);
if (0) {
#--------
} elsif ($mode =~ m{\Abf}) { # create b-files
    while (<>) {
        $line = $_;
        $line =~ s/\s+\Z//; # chompr
        ($aseqno, $k, $d) = split(/\t/, $line);
        &bfile($aseqno, $k, $d);
    } # while <>
#--------
} elsif ($mode =~ m{\Agen}) { # write *.gen for HolonomicRecurrence
    while (<>) {
        $line = $_;
        $line =~ s/\s+\Z//; # chompr
        ($aseqno, $k, $d) = split(/\t/, $line);
        &genfile($aseqno, $k, $d);
    } # while <>
#--------
} else {
    print STDERR "invalid mode \"$mode\"\n";
}   
#--------------------------------------------
sub bfile {
    my ($aseqno, $k, $d) = @_;
    my $ing_name = "george.$k.$d";
    my $bfi_name = "b" . substr($aseqno, 1) . ".txt";
    open(ING, "<", $ing_name) || die "cannot read \"$ing_name\"\n";
    open(BFI, ">", $bfi_name) || die "cannot write \"$bfi_name\"\n";
    print STDERR "$ing_name -> $bfi_name\n";
    print BFI "0 1\n";
    while (<ING>) {
        print BFI $_;
    } # while <ING>
    close(ING);
    print BFI "\n\n\n"; # for Alois
    close(BFI);
} # bfile
#--------
sub genfile {
    my ($aseqno, $k, $d) = @_;
    print join("\t", $aseqno, "circdiff", 0, $k, $d, "matrix", "1"); # a(0) is missing in george.* files
    my $ing_name = "george.$k.$d";
    open(ING, "<", $ing_name) || die "cannot read \"$ing_name\"\n";
    print STDERR "$ing_name -> $aseqno\n";
    while (<ING>) {
        m{\A(\d+)\s+(\d+)};
        my $term = $2;
        print ",$term";
    } # while <ING>
    close(ING);
    print "\t0\n"; # dist=0
} # genfile
#--------------------------------------------
__DATA__
A124696	3	1
A124697	4	1
A124698	5	1
A124699	6	1

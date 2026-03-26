#!perl

# Extract the lowest index in the b-files take from the input list
# @(#) $Id$
# 2026-03-26, Georg Fischer
#
#:# usage:
#:#   find ../common/bfile -name "b*.txt" |\
#:#   perl bfimin.pl [-d mode] > bfimin.tmp
#:#       -d mode    debug mode: none(0), some(1), more(2) 
#:#   Output records are (A-number, bfimin)
#---------------------------------
use strict;
use integer;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday) = gmtime (time);
my $utc_stamp = sprintf ("%04d-%02d-%02dT%02d:%02d:%02d\z"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);

# get options
my $debug      =  0; # 0 (none), 1 (some), 2 (more)
my $tabname = "bfoeis";
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{\-d}) {
        $debug    = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while ARGV
#----
my ($line, $nok, $aseqno, $sha256, $version, $fsize);
#while (<DATA>) {
while (<>) {
    s/\s+\Z//; #chompr
    my $file = $_;
    if ($file =~ m{b(\d{2}\d*)\.txt}) {
        my $seqno = $1;
        my $aseqno = sprintf("A%06d", $seqno);
        if (open(BF, "<", $file)) {
        	my $busy = 1;
            while (<BF>) {
                if (m{^\s*(\-?\d+)\s+(\-?\d)}) {
                    my $index = $1;
                    print join("\t", $aseqno, $index) . "\n";
                    close(BF);
                    last;
                }
            }
        } else {
            print STDERR "cannot read $file";
        }
    }
    # else ignore lines without a b-file name 
}
__DATA__
../common/bfile/b005302.txt
../common/bfile/b005303.txt
../common/bfile/b005304.txt
../common/bfile/b005305.txt
../common/bfile/b005306.txt
../common/bfile/b005307.txt
#!perl

# Synthesize b-files from 'jcat25.txt'
# @(#) $Id$
# 2023-05-04: copied from fsynth.pl
# 2019-02-19, Georg Fischer
#
#:# Usage:
#:#   perl bfdummy.pl [-d debug] -o outputdir infile
#:#       -d  debug mode (0=none, 1=some, 2=more)
#:#       -o  directory where to write synthesized b-files
#:#       infile: cat25 format 
#
# OEIS server writes:
# "# A178957 (b-file synthesized from sequence entry)"
# We write instead:
# "# A178957 (b-file synthesized from seq by bfdummy.pl at $timestamp)"
#---------------------------------
use strict;
use integer;
use warnings;
my $version = "V1.1";
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);

my $debug  = 0;
my $outdir = ".";
if (0 && scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{o}) {
        $outdir    = shift(@ARGV);
        if (substr($outdir, -1) ne "/") {
            $outdir .= "/";
        }
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my $count = 0;
my ($line, $type, $aseqno, $rest);
my ($termlist, $offset1, $hasbf) = ("", 0, 0);
while (<>) {
    s/\s+\Z//; # chompr
    $line   = $_;
    $type   = substr($line, 1, 1);
    $aseqno = substr($line, 3, 7);
    $rest   = substr($line, 11);
    if (0) {
    } elsif ($type =~ m{[STU]}) {
        $termlist .= "$rest";
        # %STU
    } elsif ($type eq "H") {
        if ($rest =~ m{href\=\"\/$aseqno\/b\d+\.txt\"\>}) {
            $hasbf = 1;
        }
        # %H
    } elsif ($type eq "O") {
        if ($hasbf == 0) {
            $rest =~ m{(\d+)};
            $offset1 = $1;
            &output();
        } else {
            if ($debug >= 3) {
                print STDERR "$aseqno skipped\n";
            }
        }
        ($termlist, $offset1, $hasbf) = ("", 0, 0); # for next A-number
        # %O
    }
} # while <STR>
print STDERR sprintf("%6d", $count) . " total b-files synthesized\n";
#--------------------
sub output {
    $count ++;
    my $bfname = "${outdir}b" . substr($aseqno, 1) . ".txt";
    open(OUT, ">", $bfname) or die "cannot write \"$bfname\"\n";
#   print OUT "# $aseqno (b-file synthesized from sequence entry)\n";
    print OUT "# $aseqno (b-file synthesized from seq bfdummy.pl at $timestamp)\n";
    #                                                ^^^^^^^^^^^
    # caution, extract_info.pl relies on this       |
    my $ind = $offset1;
    foreach my $term (split(/\,/, $termlist)) {
        print OUT "$ind $term\n";
        $ind ++;
    } # foreach $term
    close(OUT);
    $ind --;
    if ($debug >= 1 && $count % 1024 == 0) {
        print STDERR sprintf("%6d", $count) . " b-files synthesized $aseqno\n";
    }
    if ($debug >= 2) {
        print STDERR "$bfname\tn = $offset1..$ind\twritten\n";
    }
} # output
#--------------------
__DATA__
A130623 Number of polyhexes with perimeter at most 2n.      0
%I #7 Jan 16 2023 09:03:17
%S 0,0,1,1,2,3,6,8,20,34,84,182
%N Number of polyhexes with perimeter at most 2n.
%C The perimeter of a polyhex is always even.
%C Partial sums of A057779.
%C a(2n+1) >= A131467(n).
%Y Cf. A038142 (planar cata-polyhexes with n cells).
%Y Cf. A057779 (hexagonal polyominoes with perimeter 2n).
%Y Cf. A131467 (planar polyhexes with at most n cells).
%K hard,more,nonn
%O 1,5
%A _Tanya Khovanova_, Aug 11 2007
%E Offset corrected by _John Mason_, Jan 16 2023

not if:
%H Vincenzo Librandi, <a href="/A066355/b066355.txt">Table of n, a(n) for n = 1..1000</a>

# A130623 (b-file synthesized from sequence entry)
1 0
2 0
3 1
4 1
5 2
6 3
7 6
8 8
9 20
10 34
11 84
12 182

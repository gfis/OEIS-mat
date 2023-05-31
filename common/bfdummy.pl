#!perl

# Synthesize b-files from 'jcat25.txt'
# @(#) $Id$
# 2023-05-04: copied from fsynth.pl
# 2019-02-19, Georg Fischer
#
#:# Usage:
#:#   perl bfsynth.pl [-s substrip] -o outputdir infile
#:#       -s  subset of stripped file
#:#       -o  directory where to write synthesized b-files
#:#       infile: lines with aseqno tab offset1
#
# OEIS server writes:
# "# A178957 (b-file synthesized from sequence entry)"
# We write instead:
# "# A178957 (b-file synthesized from seq bfsynth.pl)"
#---------------------------------
use strict;
use integer;
use warnings;
my $version = "V1.1";
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);

my $stripped  = "../common/stripped";
my $asdata    = "asdata.txt";
my %terms     = (); # key is aseqno
my $outdir    = ".";

if (scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{o}) {
        $outdir    = shift(@ARGV);
        if (substr($outdir, -1) ne "/") {
            $outdir .= "/";
        }
    } elsif ($opt  =~ m{s}) {
        $stripped  = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

open(STR, "<", $stripped) || die "cannot read \"$stripped\"\n";
my $count = 0;
while (<STR>) {
    next if ! m{\AA\d+};
    s/\s+\Z//; # chompr
    my $aseqno = substr($_, 0, 7);
    my $list   = substr($_, 9);
    $list =~ s{\,\Z}{};
    $terms{$aseqno} = $list;
    $count ++;
} # while <STR>
close(STR);
print STDERR "$count records read from $stripped\n";

my ($aseqno, $offset1, @rest);
while (<>) {
    s/\s+\Z//; # chompr
    ($aseqno, $offset1, @rest) = split(/\s+/);
    if ($aseqno !~ m{\AA\d{6}}) {
        print STDERR "# no A-number: \"$aseqno\"\n";
    } elsif (defined($terms{$aseqno})) {
        &output($terms{$aseqno});
    } else {
        my $line = `grep $aseqno $asdata`;
        if ($line =~ m{\A($aseqno)\s+(\S+)}) {
            my $param = $2;
            &output($param);
        } else {
            print STDERR "# $aseqno neither in $stripped nor in $asdata\n";
        }
    }
} # while <>
#--------------------
sub output {
    my ($param) = @_;
    my $bfname = "${outdir}b" . substr($aseqno, 1) . ".txt";
    open(OUT, ">", $bfname) or die "cannot write \"$bfname\"\n";
#   print OUT "# $aseqno (b-file synthesized from sequence entry)\n";
    print OUT "# $aseqno (b-file synthesized from seq bfsynth.pl)\n";
    #                                                ^^^^^^^^^^^
    # caution, extract_info.pl relies on this       |
    my $ind = $offset1;
    foreach my $term (split(/\,/, $param)) {
        print OUT "$ind $term\n";
        $ind ++;
    } # foreach $term
    # print OUT "\n"; # for A.H. - but no, we want to have the same filesize
    close(OUT);
    $ind --;
    print STDERR "$bfname\tn = $offset1..$ind\twritten\n";
} # output
#--------------------
__DATA__
# A178957 (b-file synthesized from sequence entry)
0 1
1 1
2 1
3 6
4 12
5 60
6 180
7 1008
8 20160

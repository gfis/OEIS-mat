#!perl

# Synthesize b-files from 'stripped'
# @(#) $Id$
# 2019-02-19, Georg Fischer
#
# Usage:
#   perl bfsynth.pl -s substrip -o outputdir infile
#       -s  subset of stripped file
#       -o  directory where to write synthesized b-files
#       infile: lines with aseqno tab offset1
#
# OEIS server writes:
# "# A178957 (b-file synthesized from sequence entry)"
# We write:
# "# A178957 [b-file synthesized from sequence entry]"
#---------------------------------
use strict;
use integer;
use warnings;
my $version = "V1.0";
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);

my $basedir   = "../coincidence/database";
my $stripped  = "$basedir/stripped";     
my %terms     = (); # key is aseqno
my $outdir    = "bfile/";

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
while (<STR>) {
    s/\s+\Z//; # chompr
    next if ! m{\AA\d+};
    my ($aseqno, $list) = split(/\s+/);
    $list =~ s{\A\,}{};
    $list =~ s{\,\Z}{};
    $terms{$aseqno} = $list; 
} # while <STR>
close(STR);

while (<>) {
    s/\s+\Z//; # chompr
    my ($aseqno, $offset1) = split(/\s+/);
    if (defined($terms{$aseqno})) {
        my $bfname = "$outdir/b" . substr($aseqno, 1) . ".txt";
        open(OUT, ">", $bfname) or die "cannot write \"$bfname\"\n";
        print OUT "# $aseqno [b-file synthesized from sequence entry]\n";
        my $ind = $offset1;
        foreach my $term (split(/\,/, $terms{$aseqno})) {
            print OUT "$ind $term\n";
            $ind ++;
        } # foreach $term
        # print OUT "\n"; # for A.H. - but no, we want to have the same filesize
        close(OUT);
    } else {
        print STDERR "$aseqno not in stripped file\n";
    }
} # while <>    
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
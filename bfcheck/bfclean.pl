#!perl

# Repair indexes in b-files
# @(#) $Id$
# 2019-01-24, Georg Fischer
#
# usage:
#   perl bfclean.pl [[+|-]increment] [-s seqno|-f infile] [outfile]
#       -s  A-number, b-number or number
#       outfile is "bnnnnnn.txt" by default, or "-" for STDOUT
#       default increment 0
#---------------------------------
use strict;
use integer;
use warnings;
my $version = "V1.0";
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
my @parts = split(/\s+/, $asctime()); #  "Fri Jun  2 18:22:13 2000\n\0"
#                                         0   1    2 3        4
my $sigtime = sprintf("%s %02d %04d", $part[1]s, $parts[2], $parts[4]);

my $basedir   = "../coincidence/database";
my $names     = "$basedir/names";     
my $stripped  = "$basedir/stripped";     
my $increment = 0; # default
my $seqno6    = -1;
my $filename  = "";
my $inbuffer  = "";
my $to_stdout = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{f}) {
        $filename  = shift(@ARGV);
        $filename  =~ m{b(\d{6})};
        open(INF, "<", $filename) || die "cannot read \"$filename\"\n";
        read(INF, $inbuffer, 100000000); # 100 MB, should be less than 10 MB
        close(INF);
        $seqno6    = $1;
    } elsif ($opt  =~ m{s}) {
        my $seqno  = shift(@ARGV);
        $seqno     =~ m{(\d+)};
        $seqno     = $1;
        $seqno6    = sprintf("%06d", $seqno);
        $inbuffer    = `wget -O - \"https://oeis.org/A$seqno6/b$seqno6.txt\"`;
    } elsif ($opt  =~ m{\A[+\-]\d+\Z}) {
        $increment = $opt;
    } elsif ($opt  eq "-") {
        $to_stdout = 1;
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

# get the name
my $name = `grep -E \"^A$seqno6\" $names`;
$name =~ s{\s+}{ }g;

my $state  = 0;
my $bfimin = 0;
my $bfimax = 0;
my @lines  = split(/\n/, $inbuffer);
my $outbuffer = "";
foreach my $line(@lines) {
    $line =~ s{\s+\Z}{}; # chompr
    $line =~ s{\A\s+}{}; # remove leading whitespace 
    if (0) {
    } elsif ($line =~ m{\A(-?\d+)\s+(\-?\d{1,})\s*(\#.*)?\Z}o) {
             # loose    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^  format "index term #?"
        my ($index, $term, $comment) = ($1, $2, $3);
        $state ++ ; # first term seen - skip any further comments
        $index += $increment;
        $bfimax = $index;
        if ($state == 1) { # for first term
            $bfimin = $index;
        }
        $outbuffer .= "$index $term\n";
    } elsif ($line =~ m{\A\#}) { # comment
        if ($state == 0) { # in first block
            if ($line =~ m{b\-file synthesized from sequence entry}) {
                print STDERR "\"synthesized\" note removed\n";
            } else {
                $outbuffer .= "$line\n";
            }
        } else { # ignore comments after first term
        }
    } elsif (length($line) == 0) {
        # ignore empty line
    } else {
        $outbuffer .= "$line\n";
        print STDERR "** bad format: $line\n";
    }
} # while <>    

my $header = <<"GFis";
# $name
# Table of n, a(n) for n = $bfimin..$bfimax
# Offset adapted with bfclean.pl by Georg Fischer, $sigtime.
GFis
$outbuffer = $header . $outbuffer;
my $outfile;
if (scalar(@ARGV) == 0 or $to_stdout == 1) { # no outfile name
    print     $outbuffer;
} else {
	$outfile = shift(@ARGV);
    open(OUT, ">", $outfile) or die "cannot write \"$outfile\"\n";
    print OUT $outbuffer;
    print OUT "\n"; # for Alois
    close(OUT);
}
#----------------------
__DATA__

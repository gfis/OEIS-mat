#!perl

# Clean a b-file with optional index shift
# @(#) $Id$
# 2021-03-02: -c = naked, no comments
# 2019-10-27: print usage if no args
# 2019-06-04: syntax errors
# 2019-01-24, Georg Fischer
#
#:# usage:
#:#   perl bfclean.pl [[+|-]increment] [-s seqno|-f infile] [outfile]
#:#       -s A-number, b-number or number
#:#       outfile is "bnnnnnn.txt" by default, or "-" for STDOUT
#:#       default increment 0
#---------------------------------
use strict;
use integer;
use warnings;
use POSIX;

my $version = "V1.1";
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);
my $timestamp = sprintf("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
my @parts = split(/\s+/, asctime(localtime(time)));  #  "Fri Jun  2 18:22:13 2000\n\0"
#                                             0   1    2 3        4
my $sigtime = sprintf("%s %02d %04d", $parts[1], $parts[2], $parts[4]);

if (scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
my $basedir   = "../common";
my $names     = "$basedir/names";     
my $increment = 0; # default
my $seqno6    = -1;
my $filename  = "";
my $inbuffer  = "";
my $to_stdout = 0;
my $naked     = 0; # keep comments
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{c}) {
        $naked     = 1;
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
        $inbuffer  = `wget -O - \"https://oeis.org/A$seqno6/b$seqno6.txt\"`;
    } elsif ($opt  =~ m{\A[+\-]\d+\Z}) {
        $increment = $opt;
    } elsif ($opt  eq "-") {
        $to_stdout = 1;
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

# get the name
my $name = ($naked == 1) ? "A$seqno6" : `grep -E \"^A$seqno6\" $names`;
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
        # loose format: ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ -> "index term #?"
        my ($index, $term, $comment) = ($1, $2, $3);
        $state ++ ; # first term seen - skip any further comments
        $index += $increment;
        $bfimax = $index;
        if ($state == 1) { # for first term
            $bfimin = $index;
        }
        $outbuffer .= "$index $term\n";
    } elsif ($line =~ m{\A\#}) { # comment
        if ($naked == 0 && $state == 0) { # in first block
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
if ($naked == 0) {
    $outbuffer = $header . $outbuffer;
}
my $outfile;
if (scalar(@ARGV) == 0 or $to_stdout == 1) { # no outfile name
    print     $outbuffer;
    if ($naked == 0) {
        print     "\n"; 
        print     "\n"; # for AH
    }
} else {
    $outfile = shift(@ARGV);
    open(OUT, ">", $outfile) or die "cannot write \"$outfile\"\n";
    print OUT $outbuffer;
    if ($naked == 0) {
        print OUT "\n"; 
        print OUT "\n"; # for AH
    }
    close(OUT);
}
#----------------------
__DATA__
# A068610 Path of a knight's tour on an infinite chessboard. 
# Table of n, a(n) for n = 0..1088
# A068610 b-file computed by Hugo Pfoertner 2019-05-09
# Offset adapted with bfclean.pl by Georg Fischer, Jun 04 2019.
0 1
1 18
2 7
3 24
4 11



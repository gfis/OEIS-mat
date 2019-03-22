#!perl

# Extract long terms from b-files, and generate .tsv 
# @(#) $Id$
# 2019-03-20, Georg Fischer: copied from ../common/extract_info.pl
#
#:# usage:
#:#   perl extract_bflong.pl [-r range] [-f bflong.txt] inputdir > outputfile
#:#       -r min[,max] minimum and optional maximum length of terms
#:#       -f file      with [ab]seqno tab ..., default: bflong.txt
#:#       inputdir     default: ./bfile
#---------------------------------
use strict;
use integer;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday) = gmtime (time);
my $utc_stamp = sprintf ("%04d-%02d-%02dT%02d:%02d:%02d\z"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);

# get options
my $debug      =  0; # 0 (none), 1 (some), 2 (more)
my $rmin       =  32;
my $rmax       =  65536; # indefinite
my $listname   = "bflong.txt";
my $read_len_max = 100000000; # 100 MB
my $read_len_min =      8000; # stripped has about 960 max.
if (scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{\-d}) {
        $debug    = shift(@ARGV);
    } elsif ($opt =~ m{\-r}) {
        my $range = shift(@ARGV);
        if ($range =~ m{\A(\d+)\D(\d+)\Z}) {
        	$rmin = $1;
        	$rmax = $2;
        } else {
        	$rmin = $range;
        	$rmax = 65536;
        }
    } elsif ($opt =~ m{\-f}) {
        $listname = shift(@ARGV);
   } else {
        die "invalid option \"$opt\"\n";
    }
} # while ARGV
my $inputdir = "./bfile/";
if (scalar(@ARGV) > 0) {
	$inputdir = shift(@ARGV);
}

my $buffer; # contains the whole file
#----------------------------------------------
open(LIST, "<", $listname) or die "cannot read \"$listname\"";
while (<LIST>) {
	s/\s+\Z//; # chompr
	if (m{\A[Ab]?(\d+)}i) {
		my $seqno  = "$1";
		my $aseqno = "A$seqno";
		my $file   = "$inputdir/b$1.txt";
		&extract_from_bfile($aseqno, $file);
	} # match
} # while LIST
close(LIST);
#---------------------------
sub extract_from_bfile {
    my ($aseqno, $filename) = @_;
    open(FIL, "<", $filename) or die "cannot read \"$filename\"\n";
    read(FIL, $buffer, $read_len_max); # 100 MB, should be less than 10 MB
    close(FIL);
    my $iline   = 0;
    my $index;
    my $term;
    foreach my $line (split(/\n/, $buffer)) {
        if ($line =~ m{\A(\-?\d+)\s(\-?\d+)}o) { # index space term
            ($index, $term) = ($1, $2);
            my $term_len = length($term);
            if ($rmin <= $term_len and $term_len < $rmax) {
            	print join("\t", $term, $aseqno, $index) . "\n";
            }
        } # if index space term
    } # foreach $line
} # extract_from_bfile
#------------------------------------
__DATA__

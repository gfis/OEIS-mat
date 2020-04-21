#!perl

# Generate a tiling from Galebach's list
# https://oeis.org/A250120/a250120.html
# @(#) $Id$
# 2020-04-21, Georg Fischer
#
#:# usage:
#:#   perl tiler.pl extract.tmp > output
#---------------------------------
use strict;
use integer;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday) = gmtime (time);
my $utc_stamp = sprintf ("%04d-%02d-%02dT%02d:%02d:%02d\z"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
my $debug = 0;
my $nmax = 16;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug = shift(@ARGV);
    } elsif ($opt  =~ m{n}) {
        $nmax = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
      
my $state = "init";
my %tiles = ();
my $rest;
my $ind;
my $ntype = 0;
while (<>) {
    s{\s+\Z}{};
    my $line = $_;
	my ($aseqno, $gal_id, $dummy1, $std, $vtype, $angles, $sequence) = split(/\t/, $line);
    if ($debug >= 1) {
        print "$line\n";
    }
    $gal_id =~ m{Gal\.(\d+)\.(\d+)\.(\d+)};
    my ($tuni, $tnum, $tseq) = ($1, $2, $3);
    if ($tseq eq "1"}) { # start of new tiling
    	$ind = 0;
    	&save($vtype, $angles, $sequence);
    } else {
    	&save($vtype, $angles, $sequence);
    	if ($tseq eq $tuni) { # complete tilings was read
    	} # complete
    }
    		
} # while
#-----
sub save {
	my ($vtype, $angles, $sequence) = @_;
	
} # save
#----
sub repeat {

} # repeat

__DATA__
A265035	Gal.2.1.1	A12;A6;B4	3.4.6.4; 4.6.12	12.6.4; A 180'; A 120'; B 90	1,3,6,9,11,14,17,21,25,28,30,32,35,39,43,46,48,50,53,57,61,64,66,68,71,75,79,82,84,86,89,93,97,100,102,104,107,111,115,118,120,122,125,129,133,136,138,140,143,147
A265036	Gal.2.1.2	A6;A4;B3;B4	3.4.6.4; 4.6.12	6.4.3.4; A 270; A 210'; B 120; B 240	1,4,6,7,10,14,20,24,24,23,26,34,42,44,40,37,42,54,64,64,56,51,58,74,86,84,72,65,74,94,108,104,88,79,90,114,130,124,104,93,106,134,152,144,120,107,122,154,174,164

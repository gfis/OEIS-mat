#!perl

# Extract parameters from Galebach's website
# https://oeis.org/A250120/a250120.html
# @(#) $Id$
# 2020-04-17, Georg Fischer
#
#:# usage:
#:#   perl extract_gb.pl galabach.html > output
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
my $std_notation;
my $gal_id;
while (<>) {
    s{\s+\Z}{};
    my $line = $_;
    $line =~ s{\<br( \/)?\>}{}g;
    $line =~ s{\<\/?b\>}{}g;
    $line =~ s{\(([^\)]+)\)\<sup\>(\d+)\<\/sup\>}{  &repeat("; ", $1, $2)}eg;
    $line =~ s{(\D)(\d+)\<sup\>(\d+)\<\/sup\>}{$1 . &repeat(".", $2, $3)}eg;
    if ($debug >= 1) {
        print "state $state: $line\n";
    }
    if (0) {
    } elsif ($state eq "init" and ($line =~ m{^Standard Notation\:\s*(.*)}i)) {
        $rest =   $1;
        $rest =~ s{[\[\]]}{}g;
        $std_notation = $rest;
    } elsif ($state eq "init" and ($line =~ m{^Expanded Notation}i)) {
        %tiles = ();
        $state       = "expa";
    } elsif ($state eq "expa" and ($line =~ m{^(Gal[\.\d]+)\:\s*(.*)}i)) { # gal_id, vertex type, angles
        $gal_id = $1;
        $rest =   $2;
        my @edges  = split(/\;\s*/, $rest);
        my @vtypes = split(/\./, shift(@edges));
        my $eno = scalar(@edges);
        my $vno = scalar(@vtypes);
        if ($eno != $vno) {
            print STDERR "eno=$eno != vno=$vno in $gal_id\n";
        }
        my $condensed = "";
        for (my $ied = 0; $ied < $eno; $ied ++) {
            $condensed .= ";" . substr($edges[$ied], 0, 1) . $vtypes[$ied];
        } # foreach
        $tiles{$gal_id}  = join("\t"
        #	, substr($condensed, 1) 
        	, $std_notation, $rest);
    } elsif ($state eq "expa" and ($line =~ m{^(Coord)}i)) {
        $state =       "cseq";
    } elsif ($state eq "cseq" and ($line =~ m{^(Gal[\.\d]+)\:\s*(.*)}i)) { # cs follows
        $gal_id = $1;
        $rest =   $2;
        $rest =~ s{[\[\]]}{}g;
        $rest =~ s{\,\.\.\.\Z}{};
        $tiles{$gal_id} .= "\t" . $rest;
    } elsif ($state eq "cseq" and ($line =~ m{^A\-numbers\: (.*)}i)) { # list of A-numbers 
        $rest = $1;
        my $prefix = $gal_id;
        $prefix =~ s{\d+\Z}{}; # remove trailing sequential number
        $ind = 1;
        foreach my $aseqno (split(/\, ?/, $rest)) {
            print join("\t", $aseqno, "$prefix$ind", $tiles{"$prefix$ind"}) . "\n";
            $ind ++;
        } # foreach
        $state =       "init";
    } else {
        # print "invalid state $state\n";
    }
} # while
#-----
sub repeat {
    my ($sep, $string, $mult) = @_;
    return join($sep, ($string) x $mult);
} # repeat

__DATA__
<br />
A-numbers: A313990, A314063, A313964, A315324, A315223, A315433<br />
<br />
<u>Tiling #1248</u><br />
<a href="http://probabilitysports.com/tilings.html?u=0&amp;n=6&amp;t=673" target="_blank">6-Uniform Tiling 673 of 673</a><br />
Standard Notation: [(3<sup>6</sup>)<sup>3</sup>; (3<sup>4</sup>.6)<sup>3</sup>]<br />
Expanded Notation:<br />
Gal.6.673.1: 6.3<sup>4</sup>; B 60; C 300; D 300; A 180; D 120<br />
Gal.6.673.2: 6.3<sup>4</sup>; C 60; A 300; D 60; E 0; E 180<br />
Gal.6.673.3: 6.3<sup>4</sup>; A 60; B 300; E 120; F 300; D 0<br />
Gal.6.673.4: 3<sup>6</sup>; A 240; A 60; C 0; F 300; E 300; B 300<br />
Gal.6.673.5: 3<sup>6</sup>; E 180; B 0; D 60; F 180; C 240; B 180<br />
Gal.6.673.6: 3<sup>6</sup>; E 0; D 60; C 60; E 180; D 240; C 240<br />
Coordination Sequences:<br />
Gal.6.673.1:  [1,5,10,17,21,26,34,41,39,49,57,62,61,71,77,87,81,91,102,108,100,117,122,128,125,137,142,155,142,158,170,173,160,187,188,193,187,204,209,223,201,224,240,239,219,255,255,260,249,269,...]<br />
Gal.6.673.2:  [1,5,11,16,22,27,34,36,45,50,54,57,69,69,77,81,88,91,103,98,110,116,121,120,137,132,144,147,153,153,172,162,176,181,187,184,206,194,209,213,220,216,240,225,243,247,252,246,275,258,...]<br />
Gal.6.673.3:  [1,5,11,15,21,29,31,39,45,46,56,62,62,71,80,77,90,94,94,105,114,106,124,128,126,137,148,137,159,160,157,170,183,167,193,193,189,203,217,197,227,226,221,236,251,227,262,259,252,268,...]<br />
Gal.6.673.4:  [1,6,10,17,23,25,34,38,43,49,56,57,69,69,76,82,89,88,103,101,109,115,122,120,137,132,142,148,155,151,172,164,175,180,188,183,206,195,208,214,221,214,240,227,241,246,254,246,275,258,...]<br />
Gal.6.673.5:  [1,6,10,16,22,29,31,37,45,53,49,59,69,73,70,84,88,96,94,102,110,122,110,125,137,139,131,153,153,161,157,169,176,190,170,192,206,204,190,222,220,227,219,235,243,259,229,257,275,271,...]<br />
Gal.6.673.6:  [1,6,10,14,24,28,30,38,46,48,54,60,64,76,74,76,92,98,88,106,114,112,118,128,126,144,138,140,160,166,146,176,182,174,180,198,190,212,200,204,230,234,202,244,252,238,242,266,254,282,...]<br />
A-numbers: A313961, A314154, A314064, A315356, A315346, A315238<br />
<br />

=>

A311044 Gal.4.15.1  3.3.6.6; 3.6.3.6; 6.6.6; 6.6.6  6.6.6; A 180; B 180; B 180  1,3,6,11,15,17,20,23,26,33,37,37,40,43,46,55,59,57,60,63,66,77,81,77,80,83,86,99,103,97,100,103,106,121,125,117,120,123,126,143,147,137,140,143,146,165,169,157,160,163
A314409 Gal.4.15.2  3.3.6.6; 3.6.3.6; 6.6.6; 6.6.6  6.6.6; C 60; A 180; A 180   1,3,7,10,13,19,20,23,29,30,33,41,40,43,51,50,53,63,60,63,73,70,73,85,80,83,95,90,93,107,100,103,117,110,113,129,120,123,139,130,133,151,140,143,161,150,153,173,160,163
A310229 Gal.4.15.3  3.3.6.6; 3.6.3.6; 6.6.6; 6.6.6  6.6.3.3; D 60; B 300; D 60; C 180   1,4,7,10,13,16,22,26,27,30,33,36,44,48,47,50,53,56,66,70,67,70,73,76,88,92,87,90,93,96,110,114,107,110,113,116,132,136,127,130,133,136,154,158,147,150,153,156,176,180
A310710 Gal.4.15.4  3.3.6.6; 3.6.3.6; 6.6.6; 6.6.6  6.3.6.3; C 300; C 300; C 120; C 120 1,4,6,10,12,16,18,30,26,30,32,36,38,54,46,50,52,56,58,78,66,70,72,76,78,102,86,90,92,96,98,126,106,110,112,116,118,150,126,130,132,136,138,174,146,150,152,156,158,198

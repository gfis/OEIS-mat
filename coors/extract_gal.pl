#!perl

# Extract parameters from Galebach's website
# https://oeis.org/A250120/a250120.html
# @(#) $Id$
# 2020-05-09: new format of a250120.html
# 2020-04-17, Georg Fischer
#
#:# usage:
#:#   perl extract_gb.pl break.tmp > extract.tmp
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
my $tiling_no; # tiling #
my $gal_id;
my $vertex_letter;
while (<>) {
    s{\s+\Z}{};
    my $line = $_;
    $line =~ s{\<br( \/)?\>}{}ig;
    $line =~ s{\<\/?b\>}{}ig;
    $line =~ s{\(([^\)]+)\)\<sup\>(\d+)\<\/sup\>}{  &repeat("; ", $1, $2)}eg;
    $line =~ s{(\D)(\d+)\<sup\>(\d+)\<\/sup\>}{$1 . &repeat("." , $2, $3)}eg;
    if ($line =~ m{Gal\.3\.44\.3}) {
        $line =~ s{C 0\;}{C 180\;};
    }
    if ($debug >= 1) {
        print "state $state: $line\n";
    }
    if (0) {
    } elsif ($state eq "init" and ($line =~ m{\<u\>Tiling #(\d+)\<\/u\>}i)) {
        $tiling_no = $1;
    } elsif ($state eq "init" and ($line =~ m{^Standard Notation\:\s*(.*)}i)) {
        $rest =   $1;
        $rest =~ s{[\[\]]}{}g;
        $std_notation = $rest;
    } elsif ($state eq "init" and ($line =~ m{^Expanded Notation}i)) {
        %tiles = ();
        $state       = "expa";
    } elsif ($state eq "expa" and ($line =~ m{^(Gal[\.\d]+)\:\s*([A-Z])\:\s*(.*)}i)) { # gal_id, letter, vertex type, angles
        $gal_id = $1;
        $vertex_letter = $2;
        $rest =   $3;
        my @edges  = split(/\;\s*/, $rest);
        my $vertexId = shift(@edges);
        my @vtypes = split(/\./, $vertexId);
        my $eno = scalar(@edges);
        my $vno = scalar(@vtypes);
        if ($eno != $vno) {
            print STDERR "eno=$eno != vno=$vno in $gal_id\n";
        }
        $tiles{$gal_id} = join("\t", $std_notation, $vertexId, join(";", @edges));
    } elsif ($state eq "expa" and ($line =~ m{^(Coord)}i)) {
        $state =       "cseq";
    } elsif ($state eq "cseq" and ($line =~ m{^(Gal[\.\d]+)\:\s*(.*)}i)) { # cs follows
        $gal_id = $1;
        $rest =   $2;
        $rest =~ s{[\[\]]}{}g;
        $rest =~ s{\,\.\.\.\Z}{};
        $tiles{$gal_id} .= "\t" . $rest;
    } elsif ($state eq "cseq" and ($line =~ m{^A\-numbers\: (.*)}i)) { # list of A-numbers 
        $line =~ s{\<a\s+href[^\>]*\>\s*(A\d+)\s*\<\/a\>}{$1}g;
        $line =~ s{^A\-numbers\:\s*}{};
        $rest = $line;
        my $prefix = $gal_id;
        $prefix =~ s{\d+\Z}{}; # remove trailing sequential number
        $ind = 1;
        foreach my $aseqno (split(/\, ?/, $rest)) {
            print join("\t", $aseqno, "$prefix$ind", $tiles{"$prefix$ind"}, $tiling_no, "xnewnot", $aseqno, "xname") . "\n";
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
<a NAME="6.673"></a><u><b>Tiling #1248</b></u><br />
<a href=http://probabilitysports.com/tilings.html?u=0&n=6&t=673 target=_blank>6-Uniform Tiling 673 of 673</a><br />
<b>Standard Notation:</b> [(3<sup>6</sup>)<sup>3</sup>; (3<sup>4</sup>.6)<sup>3</sup>]<br />
<b>Expanded Notation:</b><br />
<b>Gal.6.673.1: A: 6.3<sup>4</sup></b>; B 60; C 300; D 300; A 180; D 120<br />
<b>Gal.6.673.2: B: 6.3<sup>4</sup></b>; C 60; A 300; D 60; E 0; E 180<br />
<b>Gal.6.673.3: C: 6.3<sup>4</sup></b>; A 60; B 300; E 120; F 300; D 0<br />
<b>Gal.6.673.4: D: 3<sup>6</sup></b>; A 240; A 60; C 0; F 300; E 300; B 300<br />
<b>Gal.6.673.5: E: 3<sup>6</sup></b>; E 180; B 0; D 60; F 180; C 240; B 180<br />
<b>Gal.6.673.6: F: 3<sup>6</sup></b>; E 0; D 60; C 60; E 180; D 240; C 240<br />
<b>Coordination Sequences:</b><br />
<b>Gal.6.673.1: </b> [1,5,10,17,21,26,34,41,39,49,57,62,61,71,77,87,81,91,102,108,100,117,122,128,125,137,142,155,142,158,170,173,160,187,188,193,187,204,209,223,201,224,240,239,219,255,255,260,249,269,...]<br />
<b>Gal.6.673.2: </b> [1,5,11,16,22,27,34,36,45,50,54,57,69,69,77,81,88,91,103,98,110,116,121,120,137,132,144,147,153,153,172,162,176,181,187,184,206,194,209,213,220,216,240,225,243,247,252,246,275,258,...]<br />
<b>Gal.6.673.3: </b> [1,5,11,15,21,29,31,39,45,46,56,62,62,71,80,77,90,94,94,105,114,106,124,128,126,137,148,137,159,160,157,170,183,167,193,193,189,203,217,197,227,226,221,236,251,227,262,259,252,268,...]<br />
<b>Gal.6.673.4: </b> [1,6,10,17,23,25,34,38,43,49,56,57,69,69,76,82,89,88,103,101,109,115,122,120,137,132,142,148,155,151,172,164,175,180,188,183,206,195,208,214,221,214,240,227,241,246,254,246,275,258,...]<br />
<b>Gal.6.673.5: </b> [1,6,10,16,22,29,31,37,45,53,49,59,69,73,70,84,88,96,94,102,110,122,110,125,137,139,131,153,153,161,157,169,176,190,170,192,206,204,190,222,220,227,219,235,243,259,229,257,275,271,...]<br />
<b>Gal.6.673.6: </b> [1,6,10,14,24,28,30,38,46,48,54,60,64,76,74,76,92,98,88,106,114,112,118,128,126,144,138,140,160,166,146,176,182,174,180,198,190,212,200,204,230,234,202,244,252,238,242,266,254,282,...]<br />
<b>A-numbers:</b> <a href="https://oeis.org/A313961" target="_blank">A313961</a>, <a href="https://oeis.org/A314154" target="_blank">A314154</a>, <a href="https://oeis.org/A314064" target="_blank">A314064</a>, <a href="https://oeis.org/A315356" target="_blank">A315356</a>, <a href="https://oeis.org/A315346" target="_blank">A315346</a>, <a href="https://oeis.org/A315238" target="_blank">A315238</a><br />
<br />

=>

A008486 Gal.1.1.1   6.6.6   6.6.6; A 60; A 60; A 60 1,3,6,9,12,15,18,21,24,27,30,33,36,39,42,45,48,51,54,57,60,63,66,69,72,75,78,81,84,87,90,93,96,99,102,105,108,111,114,117,120,123,126,129,132,135,138,141,144,147
A008576 Gal.1.2.1   4.8.8   8.8.4; A 270; A 180; A 90   1,3,5,8,11,13,16,19,21,24,27,29,32,35,37,40,43,45,48,51,53,56,59,61,64,67,69,72,75,77,80,83,85,88,91,93,96,99,101,104,107,109,112,115,117,120,123,125,128,131
A072154 Gal.1.3.1   4.6.12  12.6.4; A 180'; A 120'; A 0'    1,3,5,7,9,12,15,17,19,21,24,27,29,31,33,36,39,41,43,45,48,51,53,55,57,60,63,65,67,69,72,75,77,79,81,84,87,89,91,93,96,99,101,103,105,108,111,113,115,117
A250122 Gal.1.4.1   3.12.12 12.12.3; A 240; A 180; A 120    1,3,4,6,8,12,14,15,18,21,22,24,28,30,30,33,38,39,38,42,48,48,46,51,58,57,54,60,68,66,62,69,78,75,70,78,88,84,78,87,98,93,86,96,108,102,94,105,118,111
A008574 Gal.1.5.1   4.4.4.4 4.4.4.4; A 0; A 0; A 0; A 0 1,4,8,12,16,20,24,28,32,36,40,44,48,52,56,60,64,68,72,76,80,84,88,92,96,100,104,108,112,116,120,124,128,132,136,140,144,148,152,156,160,164,168,172,176,180,184,188,192,196
A008574 Gal.1.6.1   3.4.6.4 6.4.3.4; A 60; A 300; A 120; A 240  1,4,8,12,16,20,24,28,32,36,40,44,48,52,56,60,64,68,72,76,80,84,88,92,96,100,104,108,112,116,120,124,128,132,136,140,144,148,152,156,160,164,168,172,176,180,184,188,192,196
A008579 Gal.1.7.1   3.6.3.6 6.3.6.3; A 240; A 300; A 240; A 300 1,4,8,14,18,22,28,30,38,38,48,46,58,54,68,62,78,70,88,78,98,86,108,94,118,102,128,110,138,118,148,126,158,134,168,142,178,150,188,158,198,166,208,174,218,182,228,190,238,198
A008706 Gal.1.8.1   3.3.3.4.4   4.4.3.3.3; A 0; A 180; A 0; A 180; A 180    1,5,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85,90,95,100,105,110,115,120,125,130,135,140,145,150,155,160,165,170,175,180,185,190,195,200,205,210,215,220,225,230,235,240,245
A219529 Gal.1.9.1   3.3.4.3.4   4.3.4.3.3; A 90; A 270; A 90; A 270; A 180  1,5,11,16,21,27,32,37,43,48,53,59,64,69,75,80,85,91,96,101,107,112,117,123,128,133,139,144,149,155,160,165,171,176,181,187,192,197,203,208,213,219,224,229,235,240,245,251,256,261
A250120 Gal.1.10.1  3.3.3.3.6   6.3.3.3.3; A 60; A 300; A 180; A 120; A 240 1,5,9,15,19,24,29,33,39,43,48,53,57,63,67,72,77,81,87,91,96,101,105,111,115,120,125,129,135,139,144,149,153,159,163,168,173,177,183,187,192,197,201,207,211,216,221,225,231,235
A008458 Gal.1.11.1  3.3.3.3.3.3 3.3.3.3.3.3; A 0; A 0; A 0; A 0; A 0; A 0   1,6,12,18,24,30,36,42,48,54,60,66,72,78,84,90,96,102,108,114,120,126,132,138,144,150,156,162,168,174,180,186,192,198,204,210,216,222,228,234,240,246,252,258,264,270,276,282,288,294
A265035 Gal.2.1.1   3.4.6.4; 4.6.12 12.6.4; A 180'; A 120'; B 90    1,3,6,9,11,14,17,21,25,28,30,32,35,39,43,46,48,50,53,57,61,64,66,68,71,75,79,82,84,86,89,93,97,100,102,104,107,111,115,118,120,122,125,129,133,136,138,140,143,147
A265036 Gal.2.1.2   3.4.6.4; 4.6.12 6.4.3.4; A 270; A 210'; B 120; B 240    1,4,6,7,10,14,20,24,24,23,26,34,42,44,40,37,42,54,64,64,56,51,58,74,86,84,72,65,74,94,108,104,88,79,90,114,130,124,104,93,106,134,152,144,120,107,122,154,174,164
A301287 Gal.2.2.1   3.4.3.12; 3.12.12   12.12.3; B 30; A 180; B 120 1,3,6,7,8,15,18,17,20,25,28,29,30,35,40,39,40,47,50,49,52,57,60,61,62,67,72,71,72,79,82,81,84,89,92,93,94,99,104,103,104,111,114,113,116,121,124,125,126,131
A301289 Gal.2.2.2   3.4.3.12; 3.12.12   12.3.4.3; A 240; A 330; B 90; B 270 1,4,5,6,12,14,15,18,21,26,28,26,31,38,37,38,44,46,47,50,53,58,60,58,63,70,69,70,76,78,79,82,85,90,92,90,95,102,101,102,108,110,111,114,117,122,124,122,127,134
A301293 Gal.2.3.1   3.3.3.4.4; 4.4.4.4  4.4.4.4; A 0; A 180; A 0; B 0   1,4,9,14,18,22,27,32,36,40,45,50,54,58,63,68,72,76,81,86,90,94,99,104,108,112,117,122,126,130,135,140,144,148,153,158,162,166,171,176,180,184,189,194,198,202,207,212,216,220
A301291 Gal.2.3.2   3.3.3.4.4; 4.4.4.4  4.4.3.3.3; B 0; A 0; B 0; B 180; B 180  1,5,9,13,18,23,27,31,36,41,45,49,54,59,63,67,72,77,81,85,90,95,99,103,108,113,117,121,126,131,135,139,144,149,153,157,162,167,171,175,180,185,189,193,198,203,207,211,216,221
A298024 Gal.2.4.1   3.3.3.4.4; 4.4.4.4  4.4.4.4; A 0; B 180; A 0; B 0   1,4,10,14,18,24,28,32,38,42,46,52,56,60,66,70,74,80,84,88,94,98,102,108,112,116,122,126,130,136,140,144,150,154,158,164,168,172,178,182,186,192,196,200,206,210,214,220,224,228
A301298 Gal.2.4.2   3.3.3.4.4; 4.4.4.4  4.4.3.3.3; B 0; A 180; B 0; B 180; B 180    1,5,9,14,19,23,28,33,37,42,47,51,56,61,65,70,75,79,84,89,93,98,103,107,112,117,121,126,131,135,140,145,149,154,159,163,168,173,177,182,187,191,196,201,205,210,215,219,224,229
A301301 Gal.2.5.1   3.4.6.4; 3.4.4.6    6.4.4.3; A 180'; A 60'; A 240'; B 210   1,4,8,12,16,20,25,30,34,39,43,47,53,56,60,65,68,75,78,81,87,89,97,100,102,109,110,119,122,123,131,131,141,144,144,153,152,163,166,165,175,173,185,188,186,197,194,207,210,207
A301299 Gal.2.5.2   3.4.6.4; 3.4.4.6    6.4.3.4; B 60; B 300; A 330'; A 150 1,4,8,13,18,22,26,29,34,40,44,48,50,55,62,66,70,71,76,84,88,92,92,97,106,110,114,113,118,128,132,136,134,139,150,154,158,155,160,172,176,180,176,181,194,198,202,197,202,216
A301676 Gal.2.6.1   3.4.4.6; 3.6.3.6    6.4.4.3; B 240; A 60'; A 180; A 60' 1,4,8,13,18,22,27,31,35,41,44,48,55,57,61,69,70,74,83,83,87,97,96,100,111,109,113,125,122,126,139,135,139,153,148,152,167,161,165,181,174,178,195,187,191,209,200,204,223,213
A301674 Gal.2.6.2   3.4.4.6; 3.6.3.6    6.3.6.3; A 180'; A 300; A 0'; A 120 1,4,8,14,16,26,22,34,36,38,44,54,46,62,64,62,72,82,70,90,92,86,100,110,94,118,120,110,128,138,118,146,148,134,156,166,142,174,176,158,184,194,166,202,204,182,212,222,190,230
A301672 Gal.2.7.1   3.4.4.6; 3.6.3.6    6.4.4.3; B 240; A 60'; A 240'; A 60'    1,4,8,13,17,20,25,30,33,37,42,46,50,54,58,63,67,70,75,80,83,87,92,96,100,104,108,113,117,120,125,130,133,137,142,146,150,154,158,163,167,170,175,180,183,187,192,196,200,204
A301670 Gal.2.7.2   3.4.4.6; 3.6.3.6    6.3.6.3; A 180'; A 300; A 0'; A 120 1,4,8,12,16,22,26,26,36,36,44,42,54,50,64,56,72,66,82,70,92,80,100,86,110,94,120,100,128,110,138,114,148,124,156,130,166,138,176,144,184,154,194,158,204,168,212,174,222,182
A301293 Gal.2.8.1   3.3.3.4.4; 3.4.6.4  6.4.3.4; A 60; A 300; B 30; B 270   1,4,9,14,18,22,27,32,36,40,45,50,54,58,63,68,72,76,81,86,90,94,99,104,108,112,117,122,126,130,135,140,144,148,153,158,162,166,171,176,180,184,189,194,198,202,207,212,216,220
A301291 Gal.2.8.2   3.3.3.4.4; 3.4.6.4  4.4.3.3.3; A 330; B 180; A 90; B 120; B 240 1,5,9,13,18,23,27,31,36,41,45,49,54,59,63,67,72,77,81,85,90,95,99,103,108,113,117,121,126,131,135,139,144,149,153,157,162,167,171,175,180,185,189,193,198,203,207,211,216,221
A301680 Gal.2.9.1   3.3.4.3.4; 3.4.6.4  6.4.3.4; A 60; A 300; B 30; B 210   1,4,9,15,20,26,32,36,40,46,52,56,62,68,72,76,82,88,92,98,104,108,112,118,124,128,134,140,144,148,154,160,164,170,176,180,184,190,196,200,206,212,216,220,226,232,236,242,248,252
A301678 Gal.2.9.2   3.3.4.3.4; 3.4.6.4  4.3.4.3.3; A 330; B 120; B 240; A 150; B 180    1,5,10,14,20,26,31,36,41,46,52,58,60,65,74,79,80,86,96,98,99,108,117,118,120,130,136,137,142,151,156,158,164,170,175,180,185,190,196,202,204,209,218,223,224,230,240,242,243,252

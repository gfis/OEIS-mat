#!perl

# Generate coordination sequence 4.8.8 A008576 octogons and squares
# @(#) $Id$
# 2019-04-16, Georg Fischer
#
#:# usage:
#:#   perl mersenne.pl > table.wiki
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
       
# edges in square grid
#                0        1        2        3        4        5        6        7
my @deltas = ("+1,+0", "+1,-1", "+0,-1", "-1,-1", "-1,+0", "-1,+1", "+0,+1", "+1,+1"); # x,y translation of the 8 edges, starte with E
my @dueds  = (   4,       5,       6,       7,       0,       1,       2,       3   ); # map src -> tar edge

# vertex types  0,     1,     2,     3       with their valid edges
my @edges =  ("146", "036", "025", "247"); # 0=E, 1=NE, 2=N ... 7=south east
my @nexts =  ("213", "032", "310", "021"); # which next vertex is at the end of the edge

my %gen0 = ("0,0", "0,146"); # list of (position -> (vertex type, free edges))
my %gen1 = (); # next generation
my $n = 0;
print <<GFis;
0 1
GFis
while ($n < $nmax) {
    foreach my $srcpos (keys(%gen0)) { # compute and add targets and their positions
        my ($vsrc, $freds0) = split(/\,/, $gen0{$srcpos}); # vertex and its free edges
        if ($debug >= 1) {
         	print "process $vsrc\@$srcpos, freds=$freds0\n";
        }
        for (my $ind = 0; $ind < length($freds0); $ind ++) {
            my $edge = substr($freds0, $ind, 1);
            if ($edge ne "x") { # edge still free
                my $vtar = substr($nexts[$vsrc], $ind, 1);
                my ($xs, $ys) = split(/\,/, $srcpos); # source position
                my $tarpos = ($xs + substr($deltas[$edge], 0, 2))
                    . "," .  ($ys + substr($deltas[$edge], 3, 2));
                my ($v1, $freds1);
                if (defined($gen1{$tarpos})) {
                    ($v1, $freds1) = split(/\,/, $gen1{$tarpos});
                } else {
                    $v1 = $vtar;
                    $freds1 = $edges[$vtar];
                }
                $freds1 =~ s{$dueds[$edge]}{x}; # no more free: we came from $vsrc
                if ($v1 ne $vtar) { 
                    print "assertion: tarpos=$tarpos, v1=$v1, vtar=$vtar\n";
                }
                $gen1{$tarpos} = "$v1,$freds1";
                if ($debug >= 1) {
                	print "  gen1($tarpos) = ($v1,$freds1)\n";
                }
            } # edge still free
        } # for ind
    } # foreach $key
    if ($debug >= 1) {
      	print "generation " . ($n + 1) . ":\n" . join(""
      	    , map { my $key = $_; "  \@$key: $gen1{$key}\n"} keys(%gen1)) . "\n";
    }
    $n ++;
    print "$n " . scalar(%gen1) . "\n"; 
    %gen0 = %gen1;
    %gen1 = (); # prepare for next generation
} # while
__DATA__
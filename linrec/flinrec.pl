#!perl

# Find linear recurrences by quotient-difference tables
# @(#) $Id$
# 2019-02-17, Georg Fischer
# cf. <http://mathworld.wolfram.com/Quotient-DifferenceTable.html>
#
# usage:
#   perl flinrec.pl stripped > outputfile
#---------------------------------
use strict;
use integer;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday) = gmtime (time);
my $utc_stamp = sprintf ("%04d-%02d-%02dT%02d:%02d:%02d\z"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);

# get options
my $action     = "br"; # generate TSV for Dbat -r
my $debug      =  0; # 0 (none), 1 (some), 2 (more)
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{\-d}) {
        $debug    = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while ARGV

while (<DATA>) {
    # A000001 ,0,1,1,1,2,1,2,1,5,2,2,1,5,1,2,1,14,1,5,1,5,2,2,1,15,2,2,5,4,
    next if ! m{\A(A\d+)\s+\,?\s*(.*)};
    my ($aseqno, $tlist) = ($1, $2);
    my $result = &flinrec($tlist);
    if ($result =~ m{LinearRecurrence}) {
        print "$aseqno\t$result\n";
    }
} # while <>
#-------------
sub flinrec {
    my ($tlist) = @_;
    my $result = "";
    my @terms = split(/\D+/, $tlist);
    my $nt = scalar(@terms);
    # print "$nt terms: " . join(", ", @terms) . "\n";
    my @tab;
    my $i;
    my $j;
    for ($j = 0; $j < $nt; $j ++) {
        $tab[0][ $j    ] = 1;
        $tab[1][ $j + 1] = $terms[$j];
    } # for $j
    $tab[0][ $nt + 0] = 1;
    $tab[0][ $nt + 1] = 1;
#      [0] [1] [2]  3   4   5   6   7   8   9  nt  11         N
# [0]   1   1   1   1   1   1   1   1   1   1   1   1     W   X   E
# [1]       0   1   1   2   3   5   8  13  21  34             S          
# [2]           ?   ?   ?   ?   ?   ?   ?   ?             S := (X*X - W*E) / N
    if (1) {
        for ($j = 0; $j < $nt + 2; $j ++) {
            print sprintf("%3d", $tab[0][$j]);
        } # for $j
        print "\n";
        for ($j = 0; $j < $nt + 2; $j ++) {
            print sprintf("%3d", $tab[1][$j]);
        } # for $j
        print "\n";
    }
    $i = 2;
    my $busy = 1;
    while ($busy == 1 and $i < 5) {
        $j = 0;
        while ($j < $i) {
        	print "   ";
        	$j ++;
        }
        while ($j < $nt - $i + 2) {
            # print " compute S[$i][$j]; X = $tab[$i-1][$j], W = $tab[$i-1][$j-1], E = $tab[$i-1][$j+1], N = $tab[$i-2][$j]\n";
            $tab[$i][$j] = ($tab[$i-1][$j]**2 - $tab[$i-1][$j-1] * $tab[$i-1][$j+1]) 
                                         / $tab[$i-2][$j];  
            print sprintf("%3d", $tab[$i][$j]); 
            $j ++;
        }
        print "\n";
        $i ++;
    } # while $busy
    return $result;
} # flinrec
__DATA__
A000045 ,0,1,1,2,3,5,8,13,21,34
A000001 ,4 7 10 13 16 19 22



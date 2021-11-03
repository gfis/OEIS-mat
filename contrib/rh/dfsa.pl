#!perl

# Evaluate counts for a Deterministic Finite State Automaton
# @(#) $Id$
# 2021-11-03, Georg Fischer
#
#:# Usage:
#:#     perl dfsa.pl [-d mode] [-n noterms] nsym "state_list"  > output
#:#         -d debugging mode
#:#         -n number of terms to be computed
#:#         input symbols are 0,1,2, ... nsym-1
#:#         state_list is a string list of {0,1,2,3, ...}, 
#:#             where 1 is the start state and 0 is the end (or "forbidden") state
#:#     perl dfsa.pl -d 1 2 "1,2,3,2,3,0" | less # nx1 unimodal = A000124 Central polygonal numbers
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
$timestamp = sprintf ("%04d-%02d-%02d", $year + 1900, $mon + 1, $mday);

if (scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
my $debug = 0;
my $mode = "bf";
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{m}) {
        $mode      = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my $nsym = shift(@ARGV);
my $START_STATE = 1;
my $END_STATE = 0;
my $state_list = shift(@ARGV);
my @states = split(/\D+/, $state_list);

my @table;
my $nstat;
if (1) { # read state table
    $table[0] = [$END_STATE]; # should be repeated $nsym times
    $nstat = 1;
    while (scalar(@states) > 0) {
        $table[$nstat++] = [splice(@states, 0, $nsym)];
    } # while @states
} # read state table

if (1) { # show the state table
    for (my $istat = 0; $istat < $nstat; ++$istat) {
        print sprintf("%4d: ", $istat);
        for (my $isym = 0; $isym < $nsym; ++$isym) {
            print sprintf("%4d", $table[$istat][$isym]);
        } # for $isym
        print "\n";
    } # for $istat
}

if (1) { # build all output strings of length n and count them
    my %ostr = ();
    my %nstr = ();
    for (my $isym = 0; $isym < $nsym; ++$isym) { # initialize the strings
        $nstr{$isym} = 1;
    } # for $isym
    for (my $n = 1; $n < 64; ++$n) {
        if ($debug > 0) {
            print "a($n) = " . scalar(keys %nstr) . "\n";
        } else {
            print scalar(keys %nstr) . "\n"; # ",";
        }
        %ostr = %nstr;
        %nstr = ();
        foreach my $okey (sort(keys(%ostr))) {
            for (my $isym = 0; $isym < $nsym; ++$isym) { # append this symbol
                my ($str, $stat) = &compute($okey, $isym);
                if ($stat != $END_STATE) {
                    $nstr{$str} = 1;
                }
            } # for $isym
        } # for $okey
    } # for $n
    
} # count
#----
sub compute {
    my ($ostr, $nsym) = @_;
    print "compute($ostr, $nsym): " if $debug > 0;
    my $nstr = $ostr;
    my $nstat = $START_STATE;
    for (my $istr = 0; $istr < length($nstr); ++$istr) {
        my $sym = substr($nstr, $istr, 1);
        $nstat = $table[$nstat][$sym];
        if ($debug >= 2) {
            print substr($nstr, 0, $istr) 
                . "[>$nstat]"
                . substr($nstr, $istr) . " ";
        }
    }
    $nstat = $table[$nstat][$nsym];
    if ($nstat != $END_STATE) {
        $nstr .= $nsym;
    }
    print "; result = ($nstr,$nstat)\n" if $debug > 0;
    return ($nstr, $nstat);
} # compute
#--------------------------------------------
__DATA__
  state|   0   1 
  -----+--------- 
     s1|  s1  s2
     s2|  s3  s2
     s3|  s3  x0
W

       |  0 0   0 1   1 0   1 1   valid inputs
  -----+-------------------------
 1 s1t1|  s1t1  s1t2  s2t1  s2t2  4
 2 s1t2|  s1t3  s1t2  s2t3  s2t2  4
 3 s1t3|  s1t3  s1x0  s2t3  s2x0  2
 4 s2t1|  s3t1  s3t2  s2t1  s2t2  4
 5 s2t2|  s3t3  s3t2  s2t3  s2t2  4
 6 s2t3|  s3t3  s3x0  s2t3  s2x0  2
 7 s3t1|  s3t1  s3t2  x0t1  x0t2  2
 8 s3t2|  s3t3  s3t2  x0t3  x0t2  2
 9 s3t3|  s3t3  s3x0  x0t3  x0x0  1


    |  00 01 10 11  #vi
  -----+-------------------------
   1|  1  2  4  5    4
   2|  3  2  6  5    4
   3|  3  0  6  0    2
   4|  7  8  4  5    4
   5|  9  8  6  5    4
   6|  9  0  6  0    2
   7|  7  8  0  0    2
   8|  9  8  0  0    2
   9|  9  0  0  0    1

perl dfsa.pl -d 1 4 "1,2,4,5,3,2,6,5,3,0,6,0,7,8,4,5,9,8,6,5,9,0,6,0,7,8,0,0,9,8,0,0,9,0,0,0"
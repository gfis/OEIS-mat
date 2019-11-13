#!perl

# lexorder.pl - lexicographical order of ranges of numbers
# 2019-03-02, Georg Fischer
# cf. https://oeis.org/A119589, A115590
#----------------------------------------------------------------
# The program has a variety of options for the number base, range
# and form of the output:
#
#:# usage:
#:#     perl lexorder.pl [-a A-number] [-b 10] [-f] [-i] [-k 3] [-n] [-s]
#:#         -a  sequence A-number (default: A306nnn)
#:#         -b  number base (default 10, letters for bases 11..36)
#:#         -f  output b-file (default: comma separated list)
#:#         -i  inverse mapping, positions in lex. sort order
#:#         -k  numbers modulo 10^k (default 3)
#:#         -n  do not include zero (default: with zero)
#:#         -s  include negative range (default: a(n) >= 0)
#----------------------------------------------------------------
use strict;
use integer;
use POSIX;

my  ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst)
    = localtime (time);
my @parts = split(/\s+/, POSIX::asctime
    ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst));
#  "Fri Jun  2 18:22:13 2000\n\0"
#  0    1    2 3        4
my $sigtime = sprintf("%s %02d %04d", $parts[1], $parts[2], $parts[4]);
my $digits  = "0123456789abcdefghijklmnopqrstuvwxyz"; # for counting in base 11, 13, ...

my $aseqno  = "A306nn1";
my $base    = 10;
my $bfile   = 0;
my $inverse = 0;
my $kmax    = 3;
my $sign    = 0;
my $nozero  = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) { # get options
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt   =~ m{a}) {
        $aseqno  =  shift(@ARGV);
    } elsif ($opt   =~ m{b}) {
        $base    =  shift(@ARGV);
    } elsif ($opt   =~ m{f}) {
        $bfile   =  1;
    } elsif ($opt   =~ m{i}) {
        $inverse =  1;
    } elsif ($opt   =~ m{k}) {
        $kmax    =  shift(@ARGV);
    } elsif ($opt   =~ m{n}) {
        $nozero  =  1;
    } elsif ($opt   =~ m{s}) {
        $sign    =  1;
    }
} # while $opt
#----
if ($bfile == 1) { # print header
    print <<"GFis";
# $aseqno
# Table of n, a(n) for n =
# Georg Fischer, $sigtime
# using https://oeis.org/A306nnn/a306nnn.pl.txt: 
GFis
    print "# perl a306nnn.pl -a $aseqno -b $base"
        . ($bfile   > 0 ? " -f" : "")
        . ($inverse > 0 ? " -i" : "")
        . "-k $kmax"
        . ($nozero  > 0 ? " -n" : "")
        . ($sign    > 0 ? " -s" : "")
        . "\n#----\n";
}   
my $n = 0;
my $k;
my @list;

if (1) { # main
    for $k (1..$kmax) {
        my $range_min  = ($nozero == 1) ? 1 : 0;
        if ($sign == 1) {
            $range_min = - $base**$k + 1
        }
        my $range_max  = $base**$k - 1;
        @list = sort lexicographically
            map { &to_base($_) } ($range_min..$range_max);
        if ($inverse == 1) {
            my %hash;
            my $i;
            my 
            $ilist = 0;
            foreach $i ($range_min..$range_max) {
                $hash{$i} = $list[$ilist ++]; # map index i to a(n)
            } # foreach my $i
            foreach $i (sort numerically (keys(%hash))) {
            #   $list[$i] = $hash{$i}; 
                $list[$hash{$i}] = $i; 
            } # foreach my $i
        } # if inverse
        &output(@list);
    } # for $k
} # main
#----
sub lexicographically { $a cmp $b };
sub numerically       { $a <=> $b };
sub output { my @list = @_;
    foreach my $an (@list) {
        if ($bfile == 1) {
            print "$n $an\n";
        } else {
            if ($n > 0) {
                print ", ";
            }
            print $an;
        }
        $n ++;
    } # foreach
    if ($bfile == 1) {
        print "#----\n";
    } else {
    	print "\n";
    }
} # sub output
#----
# convert from decimal to $base
sub to_base { my ($num)  = @_;
    my $absnum = abs($num);
    my $result = "";
    while ($absnum > 0) {
        my $digit = $absnum % $base;
        $result =  substr($digits, $digit, 1) . $result;
        $absnum /= $base;
    } # while > 0
    if ($result eq "") {
        $result = 0;
    } elsif ($num < 0) {
        $result = - $result;
    }
    return $result;
} # to_base
#=====================
__DATA__

#!perl

# Guess whether a signature generates a (pesudo-) periodic sequence
# @(#) $Id$
# 2026-02-05: Georg Fischer, copied from signat_eval.pl
#
#:# Usage:
#:#   perl signat_period.pl [-d debug] [-m max_order] input > output
#:#      -d mode 0=none, 1=some, 2=more
#:#      -m maximum period length to try (default 256)
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);

my $debug = 0;
my $max_order   = 256;
# if (scalar(@ARGV) == 0) {
#     print `grep -E "^#:#" $0 | cut -b3-`;
#     exit;
# }
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{c}) {
        &create_sql();
        exit(0);
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{m}) {
        $max_order = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
#----

my @sig;
my @arr;
my $firstnz;
my $lastnz = -1; 
my $siglen = 0;
my $busy;
while (<>) {
    s/\s+\Z//; # chompr 
    next if !m{\A\:?\(?\-?\d+\,};
    my $line = $_;
    my $orig_line = $line;
    $line =~ s{\A[^\d\-\,]+}{};
    $line =~ s{[^\d\-\,].*}{};
    @sig = split(/\,/, $line);
    @arr = split(/\,/, $line);
    unshift(@sig, -1); # assume that the coefficient of a(n) is -1
    unshift(@arr, -1);
    if ($debug > 0) {
        print "# signature: " . join(",", @sig) . "\n";
    }
    $siglen = scalar(@sig);

    $firstnz = 1; # skip over $arr[0] == a(n)
    &adjust_first(); # now on the first nonzero element
    $busy = 1;
    while ($busy > 0 && $firstnz < $max_order) { # subtract signature shifted by 1 to the right
        my $factor = -$arr[$firstnz];
        if ($debug > 0) {
            print "before: nz1=$firstnz, nz9=$lastnz, " . join(",", @arr) . " -> factor=$factor\n";
        }
        for (my $isig = 0; $isig < $siglen; $isig ++) {
            $arr[$firstnz + $isig] -= $factor * $sig[$isig];
        } # for $isig 
        $lastnz = scalar(@arr) - 1;
        &adjust_last();
        if ($debug > 0) {
            print "after:  nz1=$firstnz, nz9=$lastnz, " . join(",", @arr) . "\n";
        }
        &adjust_first();
        if ($firstnz == $lastnz) {
            $busy = 0; 
            
            print join("\t", join("\,", splice(@sig, 1))
                , "period=$firstnz" . ($arr[0] == -$arr[$firstnz] ? "" : "*" . (-$arr[$firstnz]/$arr[0])) 
                , $orig_line) . "\n";
        } 
    } # while $istart 
    if ($busy > 0) {
        print STDERR "# noperiod\t$orig_line\n";
    }
    if ($debug > 0) {
        print "#--------------------------------\n";
    }
} # while <>
# end main
#----
sub adjust_first { 
    while ($firstnz < scalar(@arr) && $arr[$firstnz] == 0) {
        $firstnz ++;
        push(@arr, 0); # ensure that there are $siglen following elements
        if ($firstnz >= $max_order - $siglen) {
            $busy = 0;
        }
    }
} # adjust_first
#----
sub adjust_last  {
    while ($lastnz  > 0            && $arr[$lastnz ] == 0) {
        $lastnz  --;
    }
} # adjust_lastt
#-------------------------------------------------
__DATA__
0,1
0,-1
-1,-1
-2,-2,-1
0,0,1
0,0,-1
2,-2,1
-1,-1,-1  
1,2,3
0,0,0,0,-1,0,0,0,0,-1,0,0,0,0,-1,0,0,0,0,-1 
-1,0,1,1,0,-1,-1,0,1,1,0,-1,-1,0,1,1,1,0,-1,-1,0,1,1,0,-1,-1,0,1,1,0,-1,-1
0,0,0,-1,0,0,0,-1,0,0,0,-1,0,0,0,0,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1
:(0,1,0,-1,0,1,0,-1,0,1), i.e., 12-periodic: A070422, A131711
:(0,1,0,0,0,0,0,-1,0,1), i.e., 16-periodic: A304580
:(0,1,0,1,0,-1,0,-1,0,1), i.e., 24-periodic: A111912, A111913
:(1,-1,0,1,-1,1,0,-1,1,-1), i.e., 24-periodic: A257931
:(1,-1,1,-1,1,-1,1,-1,1,-1), i.e., 1/Phi(22), 22-periodic: A014031
:(1,0,0,0,0,1,-1), i.e., 1st differences are 6-periodic: A004484, A018840, A032775, A047303, A047304, A047306, A047310, A047318, A047368, A047422, A047428, A047
:(2,-1,0,0,1,-2,1), i.e., 2nd differences are 5-periodic: A008137, A008260, A008732, A008738, A008812, A008823, A011858, A033437, A034115, A036404, A085717, A10
:(3,-3,1,1,-3,3,-1), i.e., 3rd differences are 4-periodic: A011886, A011894, A026055, A026058, A026061, A026064, A026067, A078618, A083559, A106607, A122046, A1
:(4,-6,5,-5,6,-4,1), i.e., 4th differences are 3-periodic: A024178, A134507, A152729, A173707, A212088, A212089, A212249, A212250, A216172, A216173, A238702, A2
:(5,-9,5,5,-9,5,-1), i.e., 5th differences are 2-per
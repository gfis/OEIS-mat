#!perl

# Guess whether a signature generates a (pesudo-) periodic sequence
# @(#) $Id$
# 2026-02-05: Georg Fischer, copied from signat_eval.pl
#
#:# Usage:
#:#   perl signat_period.pl [-d debug] [-m max_order] input > output
#:#      -d mode 0=none, 1=some, 2=more
#:#      -m maximum period length to try
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);

my $debug = 0;
my $max_order   = 16;
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
while (<>) {
    s/\s+\Z//; # chompr 
    next if !m{\A\(?\-?\d+\,};
    my $line = $_;
    $line =~ s{[^\d\-\,]}{}g;
    my ($sigraw, $rest) = split(/\t/, $line);
    @sig = split(/\,/, $line);
    @arr = split(/\,/, $line);
    unshift(@sig, -1); # assume that the coefficient of a(n) is -1
    unshift(@arr, -1);
    if ($debug > 0) {
        print "# signature: " . join(",", @sig) . "\n";
    }
    my $siglen = scalar(@sig);

    $firstnz = 1; # skip over $arr[0] == a(n)
    &adjust_first(); # now on the first nonzero element
    my $busy = 1;
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
            print join("\t", $sigraw
                , "period=$firstnz" . ($arr[0] == -$arr[$firstnz] ? "" : "*" . (-$arr[$firstnz]/$arr[0])) 
                , $rest || "x") . "\n";
        }
    } # while $istart 
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
-2,-2,-1
0,0,1
0,0,-1
2,-2,1
-1,-1,-1

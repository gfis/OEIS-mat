#!perl

# Extract signatures and generate holos records
# @(#) $Id$
# 2025-07-05, Georg Fischer: copied from lingf.pl; *MH=77
#
#:# Usage:
#:#     perl lrlink_nyi.pl input > out.seq4
#:#     -d  debugging level (0=none (default), 1=some, 2=more)
#--------------------------------------------------------
use strict;
use integer;
use warnings;

my $debug = 0;
if (0 and scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt   =~ m{\-d}  ) {
        $debug      = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while options
#----------------
my $aseqno;
my $offset1 = 0;
my $signature;
my $revsig;
my $line;
my $order;
my $callcode = "holos";
my @sigs;
my $nok;
while (<>) {
    $line = $_;
    $line =~ s/\s+\Z//; # chompr
    #              1    1              2   2      3 (4      4 )3
    if ($line =~ m{(A\d+)[^\#]+\#order_(\d+)[^\(]+(\(([^\)]+)\))?}) {
        ($aseqno, $order, $signature) = ($1, $2, $4 || "");
        $nok = "";
        if ($signature ne "") {
            @sigs      = split(/\, */, $signature);
            $revsig    = join(",", reverse(@sigs));
            $signature = join(",", @sigs);
            if ($order != scalar(@sigs)) {
                $nok = "ordiff";
            }
        } else {
            $nok = "nosig";
        }
        if ($nok eq "") {
            print        join("\t", $aseqno, $callcode, $offset1, "[0," . $revsig . ",-1]", scalar(@sigs), 0, 0) . "\n";
        } else {
            print STDERR join("\t", $aseqno, $nok, $order, $signature) . "\n";
      }
    } else {
        print STDERR "$line\n";
    }
} # while <>
#----------------
__DATA__
%H A360278 <a href="/index/Rec#order_04">Index entries for linear recurrences with constant coefficients</a>, signature (3,0,-3,1).
%H A360418 <a href="/index/Rec#order_09">Index entries for linear recurrences with constant coefficients</a>, signature (1, 0, 0, 2, -2, 0, 0, -1, 1).
%H A362793 <a href="/index/Rec#order_35">Index entries for linear recurrences with constant coefficients</a>, signature (38,-502,2626,-2504,-23242,99084, -197022,65077,866512,-2636524, 4966500,-6966461,7466346, -7086208,-1403798,21097952, -40514042,39078082,-5628850, -4950479,4183652,-63712236,123870272, -67422400,-119464960,160163968, 24651264,-73854464,-4354048,3010560, 7200768,3362816,-1359872,-245760,-262144).
%H A362807 <a href="/index/Rec#order_34">Index entries for linear recurrences with constant coefficients</a>, signature (22,-150,226,1112,-5450,11884,-6878, -44971,146976,-284908,407972, -438909,443802,14624,-1169814,2380928, -2419194,370978,306798,-41711,3516276, -7451820,4641152,6836032,-10088448,-1251200, 4632064,258560,-217088,-462848, -204800,86016,16384,16384).
%H A364392 <a href="/index/Rec#order_4925">Index entries for linear recurrences with constant coefficients</a>, order 4925.
%H A364835 <a href="/index/Rec#order_06">Index entries for linear recurrences with constant coefficients</a>, signature (0,0,2,0,0,-1).
%H A365629 <a href="/index/Rec#order_26">Index entries for linear recurrences with constant coefficients</a>, order 26.
%H A366829 <a href="/index/Rec#order_03">Index entries for linear recurrences with constant coefficients</a>, signature (3,-3,1).
%H A366834 <a href="/index/Rec#order_04">Index entries for linear recurrences with constant coefficients</a>, signature (4,-6,4,-1).
%H A367758 <a href="/index/Rec#order_11">Index entries for linear recurrences with constant coefficients</a>, signature (1,-1,1,0,0,0,0,1,-1,1,-1).
%H A369543 <a href="/index/Rec#order_12">Index entries for linear recurrences with constant coefficients</a>, signature (0,0,0,0,0,2,0,0,0,0,0,-1).
%
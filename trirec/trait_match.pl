#!perl

# Read a sort of traits and bfdata, and find matching records
# @(#) $Id$
# 2021-11-12, Georg Fischer
#
#:# Usage:
#:#   sort -k3,3 bfdata.txt \
#:#   perl trait_match.pl > outfile
#---------------------------------
use strict;
use integer;
use warnings;
my $version = "V1.1";
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);

my $debug  = 0;
my $minlen = 16;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug  = shift(@ARGV);
    } elsif ($opt  =~ m{m}) {
        $minlen = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my  ($oseqno, $occ, $olen, $odata) = ("", "", 0, "");
my  ($nseqno, $ncc, $nlen, $ndata);
while (<>) {
    s/\s+\Z//; # chompr
    ($nseqno, $ncc, $nlen, $ndata) = split(/\t/);
    if ($olen >= $minlen) {
        if (0) {
        } elsif ($nlen <  $olen) {
            if ($ndata eq substr($odata, 0, $nlen)) { # ndata is prefix of odata - skip it
                # asssertion - should not happen with proper sort
                print STDERR join("\t", $nseqno, "bfuniqas", $nlen, $oseqno) . "\n"; 
            } else { # start of new group - output odata
            #   print        join("\t", $oseqno, "bfunimax", $olen, $odata ) . "\n";
            }
        } elsif ($nlen >  $olen) {
            if (substr($ndata, 0, $olen) eq $odata) { # odata is prefix of ndata - skip it
                print        join("\t", $oseqno, $occ      , $olen, $nseqno, $ncc, $ndata) . "\n";
            } else { # start of new group - output odata
            #   print        join("\t", $oseqno, "bfunimax", $olen, $odata ) . "\n";
            }
        } else { #     == $olen
            if ($ndata eq $odata) { # odata eq ndata - same sequence?
                print        join("\t", $oseqno, $occ      , $olen, $nseqno, $ncc, $ndata) . "\n";
            } else { # start of new group - output odata
            #   print        join("\t", $oseqno, "bfunimax", $olen, $odata ) . "\n";
            }
        }
    } # >= $minlen
    ($oseqno, $occ, $olen, $odata) = 
    ($nseqno, $ncc, $nlen, $ndata || "");
} # while <>
#--------------------
__DATA__
A348904	27	1,4,24,224,3264,76544,3055104,220125184,29946753024,7906463105024,4111398632914944,4242968041649209344,8723543411935886966784,35801422714130756942168064,293571666811153273905871847424,4812226763497124503879315624034304,157725544404988739801460227609821446144,10337963082518258453907341881547021241810944,1355100200857110094284888818599162600018006769664,355242227855113327576070063563006420398899278920024064,186252079095525820888586056576280465850370712870642100731904,195300950106303020851926897852192478244072577999687504142882832384,409577340524934488684562330704981276786701121541106744245618344296710144,1717895154291819048944767869337580812232250207599595083327031957115436766593024,14410762777614821968081897075811557664503748543840798022118222346270914728616330788864,241772595130906053931057274657740834873662810130775931436750507947669359123154587687021707264,8112544036964279332486317165990179146834415943663296329078016402778774442660307752402583902627037184
A348914	41	0,6,12,20,10,57,24,186,77,120,68,74,2121,1074,110,6104,10276,15765,24811,27170,18404,106578,50572,429823,632905,639390,182833,1064394,4938336,4868130,3498459,3117542,15919106,31939971,60913680,64944336,133285372,23346462,201271610,786480230,582166718

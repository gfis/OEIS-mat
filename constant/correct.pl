#!perl

# Correct the terms of a OEIS sequence
# @(#) $Id$
# 2021-08-01, Georg Fischer
#
#:# Usage:
#:#   perl correct.pl [-d debug] [-e] [-h] -f $(CC)4.txt -l $(FISCHER)/$(CC).fail.log -o $(CC).corr.tmp
#:#       -f output of Maple test
#:#       -l logfile of BatchTest
#:#       -o output with hints and clipboard texts
#:#       -e with extension line (default: false)
#:#       -h open edit window in browser (default: false)
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
$timestamp = sprintf ("%04d-%02d-%02d", $year + 1900, $mon + 1, $mday);

if (0 && scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
my $debug      = 0;
my $cas_file   = "solvetab4.txt"; # results from Maple fsolve
my $out_file   = "solvetab.corr.tmp"; # hints and clipboard textscomma-separated DATA section
my $data_file  = "../common/asdata.txt"; # comma-separated DATA section
my $log_file   = "../../joeis-lite/internal/fischer/solvetab.fail.log";
my $browser    = "\"C:/Program Files (x86)/Google/Chrome/Application/chrome.exe\"";
my $extension  = 0;
my $html       = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt   =~ m{d}) {
        $debug      = shift(@ARGV);
    } elsif ($opt   =~ m{e}) {
        $extension  = 1;
    } elsif ($opt   =~ m{h}) {
        $html       = 1;
    } elsif ($opt   =~ m{l}) {
        $log_file   = shift(@ARGV);
    } elsif ($opt   =~ m{o}) {
        $out_file   = shift(@ARGV);
    } elsif ($opt   =~ m{f}) {
        $cas_file   = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

open(LOG, "<", $log_file) || die "cannot read logfile \"$log_file\"\n";
open(OUT, ">", $out_file) || die "cannot write outfile \"$out_file\"\n";
while (<LOG>) {
    my $line = $_;
    next if $line !~ m{\AA\d+};
    $line =~ s/\s+\Z//; # chompr
    next if $line !~ m{\AA\d\d};
    my ($aseqno, $offset, $status, $expected, $dtext, $computed) = split(/\t/, $line);
    $computed = $computed || "";
    $expected =~ s{\,}{}g;
    $computed =~ s{\,}{}g;
    $offset -= length($computed); # BatchTest current is off by 8 if the error is not near the end
    next if $status ne "FAIL";
    my $cas_line = `grep -E \"$aseqno\" $cas_file`;
    my ($a, $c, $of, $result, @srest) = split(/\t/, $cas_line);
    $result =~ s{e[\+\-]\d+}{}; # remove exponent
    $result =~ s{[\-\.]}{}g; # remove dot and minus
    $result = substr($result, 0, $offset + 20);

    my $data_line = `grep -E \"$aseqno\" $data_file`;
    my ($b, $termno, $termlist, @drest) = split(/\t/, $data_line);
    $termlist =~ s{[\,\n]}{}g;
    my $flen = length($result);
    if ($termno > $flen) {
        print "# ?? fsolve has too few terms\n";
    } else { # truncate
        my $ind = $termno;
        while ($ind < $flen && substr($result, $ind, 1) gt "4") {
            $ind ++;
        } # while ind
        # now le "4"
        $flen = $ind; 
    } # truncate

    $result = substr($result, 0, $flen);
    my $findent = " " x ($offset);
    my $hints = "#" . ("-" x 100) . "\n"
        . "# $aseqno $findent$expected\n"
        . "# $aseqno $termlist\n"
        . "# $aseqno $findent$computed\n"
        . "# $aseqno $result\n"
        ;
    my $cmd = "$browser \"https://oeis.org/edit?seq=$aseqno\"";
    if ($html) {
        print "$cmd\n";
        print `$cmd`;
    }
    print OUT $hints;
    print     $hints;
    $result =~ s{(.)}{\, $1}g;
    $result = substr($result, 2);
    &clip_wait($result);
    if ($extension) {
        &clip_wait("a(" . ($offset + $of) . ") onwards corrected by");
    }
} # while
close(LOG);
close(OUT);
#----
sub clip_wait { # copy some text to the clipboard and wait for keyboard input
   my ($text) = @_;
    my $clip_file = "correct.clip.tmp";
    open(CLIP, ">", $clip_file) || die "cannot write to \"$clip_file\"\n";
    print CLIP "$text";
    close(CLIP);
    `cat $clip_file | clip`;
    print "clipboard := " . (length($text) <= 16 ? $text : substr($text, 0, 16) . " ...") . "\npress return: ";
    $text = <>; # wait for return key
} # clip_wait
#----
__DATA__
restart at 14:04:27 @0x0 in strip.tmp
A198425 97      FAIL    ,0,9,1,6,4,9,3,4        computed:       ,6,9,0,4,8,8,4,7
A198432 94      FAIL    ,5,9,2,5,9,0,5,6        computed:       ,9,8,8,9,0,2,1,5
A198433 99      FAIL    ,1,4,6,5,3,5,4,7        computed:       ,2,5,0,7,8,3,0,5
A198489 98      FAIL    ,5,8,8,8,2,4,9,9        computed:       ,7,7,7,4,1,0,2,6
A198499 98      FAIL    ,7,2,0,2,8,3,5,0        computed:       ,9,2,2,0,9,5,2,8
A198500 99      FAIL    ,7,9    computed:       ,8,0
A198545 94      FAIL    ,4,6,5,0,8,1,3,3        computed:       ,5,9,1,0,9,0,9,4
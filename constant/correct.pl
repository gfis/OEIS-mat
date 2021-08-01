#!perl

# Correct the terms of a OEIS sequence
# @(#) $Id$
# 2021-08-01, Georg Fischer
#
#:# Usage:
#:#   perl correct.pl [-d debug] $(FISCHER)/$(CC).fail.log >> $(CC).corr.tmp
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
my $debug = 0;
my $solve_file = "solvetab4.txt";
my $data_file  = "../common/asdata.txt";
my $browser = "\"C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe\"";
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt   =~ m{d}) {
        $debug      = shift(@ARGV);
    } elsif ($opt   =~ m{f}) {
        $solve_file = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

while (<>) {
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
    my $solve_line = `grep -E \"$aseqno\" $solve_file`;
    my ($a, $c, $of, $fsolve, @srest) = split(/\t/, $solve_line);
    $fsolve =~ s{e[\+\-]\d+}{}; # remove exponent
    $fsolve =~ s{[\-\.]}{}g; # remove dot and minus
    $fsolve = substr($fsolve, 0, $offset + 20);

    my $data_line = `grep -E \"$aseqno\" $data_file`;
    my ($b, $termno, $termlist, @drest) = split(/\t/, $data_line);
    $termlist =~ s{[\,\n]}{}g;
    my $flen = length($fsolve);
    if ($termno > $flen) {
        print "# ?? fsolve has too few terms\n";
    } else { # truncate
        my $ind = $termno;
        while ($ind < $flen && substr($fsolve, $ind, 1) gt "4") {
            $ind ++;
        } # while ind
        # now le "4"
        $flen = $ind; 
    } # truncate

    my $findent = " " x ($offset);
    print "#" . ("-" x 100) . "\n";
    print "# $aseqno $findent$expected\n";
    print "# $aseqno $termlist\n";
    print "# $aseqno $findent$computed\n";
    print "# $aseqno $fsolve\n";
    $fsolve = substr($fsolve, 0, $flen);
    $fsolve =~ s{(.)}{\, $1}g;
    print substr($fsolve, 2) . "\n";
    print "a(" . ($offset + $of) . ") onwards corrected by\n";
} # while
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
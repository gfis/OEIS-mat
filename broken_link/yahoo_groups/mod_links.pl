#!perl

# Modify links to Yahoo groups list and append the link to the thread text file
# @(#) $Id$
# 2019-11-12, Georg Fischer
#
#:# Usage:
#:#   perl mod_links.pl yahoo_check.htm 
#:#             (writes yahoo_check.html)
#---------------------------------
use strict;
use integer;
use warnings;
my $version = "V1.1";
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
my $url_path = "http://teherba.org/OEIS-mat/broken_link/yahoo_groups/text";
my $debug  = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug  = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my $filename = shift(@ARGV);
open (SRC, "<", $filename)      || die "cannot read \"$filename\"\n";
open (TAR, ">", "${filename}l") || die "cannot write \"${filename}l\"\n";
while (<SRC>) {
    s{\s+\Z}{}; # chompr
    my $line = $_;
    if (0) {
    } elsif ($line =~ m{\A\<tr\>\<th}) { # header line
        $line =~ s{\<\/tr\>}{<th class\=\"bor\">thread</th></tr>};

    } elsif ($line =~ m{\A\<tr\>\<td}) { # table line
        $line =~ m{href\=\"(https?\:\/\/group[^\"]*)\"};
        my $yahoo = $1 || "";
        my $messid = "";
        if ($yahoo =~ m{\/(\d+)\Z}) {
        	$messid = $1;
        }
        my $thread_link = "<a href=\"$url_path/yg.$messid.txt\" target=\"_new\">$messid</a>";
        $line =~ s{\<\/tr\>}{<td class\=\"bor\">$thread_link</td></tr>};
    } # table line
    print TAR "$line\n";
} # while <SRC>
close(SRC);
close(TAR);
#--------------------
__DATA__
<h3><a href="check_index.html" target="_blank">OEIS-mat</a> - yahoo_check</h3>
<h4>Work list for vanishing Yahoo group links</h4>
<table class="bor">
<tr><th class="bor">aseqno</th><th class="bor">status</th><th class="bor">last_change</th><th class="bor">info</th></tr>
<tr><td class="bor"><a href="https://oeis.org/A000978" target="_blank">A000978</a></td><td class="bor">njas</td><td class="bor">2019-11-10</td><td class="bor">Yahoo PrimeForm community: <a href="http://groups.yahoo.com/group/primeform/messages">PrimeForm</a> [There is insufficient information to determine which posting to the forum was intended. Probably not worth pursuing. - ~~~~]</td></tr>
<tr><td class="bor"><a href="https://oeis.org/A001108" target="_blank">A001108</a></td><td class="bor">edits</td><td class="bor">2019-11-10</td><td class="bor">K. Ramsey, <a href="http://groups.yahoo.com/group/Triangular_and_Fibonacci_Numbers/message/62">Generalized Proof re Square Triangular Numbers</a></td></tr>
<tr><td class="bor"><a href="https://oeis.org/A001109" target="_blank">A001109</a></td><td class="bor">edits</td><td class="bor">2019-11-10</td><td class="bor">K. J. Ramsey, <a href="http://groups.yahoo.com/group/Triangular_and_Fibonacci_Numbers/message/23">Relation of Mersenne Primes To Square Triangular Numbers</a> [edited by K. J. Ramsey, May 14 2011]</td></tr>

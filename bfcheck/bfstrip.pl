#!perl

# compare the output of bfanalyze.pl with 'stripped'
# @(#) $Id$
# 2019-01-18, Georg Fischer
#
# usage:
#   perl bfstrip.pl [-d level] [-s stripped] input > output
#---------------------------------
use strict;
use integer;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
my $commandline = join(" ", @ARGV);

# get options
my $action = "comp";
my $debug  = 0; # 0 (none), 1 (some), 2 (more)
my $stripped = "../coincidence/database/stripped";
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{\-a}) {
        $action = shift(@ARGV);
    } elsif ($opt =~ m{\-d}) {
        $debug  = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while ARGV
#----------------------------------------------
my @stripped;
if ($action eq "comp") {
	# read 'stripped'
	my $scount = 0;
    open(STR, "<", $stripped) or die "cannot read $stripped\n";
    while (<STR>) {
    	next if m{\A\s*(\#|\Z)}o; # skip comments
    	s/\s+\Z//; # chompr
    	my ($aseqno, $terms) = split(/\s+/);
    	my $seqno = substr($aseqno, 1);
    	$stripped[$seqno] = $terms;
    	# print "stripped[$seqno] = \"$terms\"\n";
    	# last if $scount > 64;
    	$scount ++;
    } # while <STR>
    close(STR);
    print STDERR "$scount rows read from $stripped\n";

    while (<>) {
    	s/\s+\Z//; # chompr
    	my ($aseqno, $bixmax, $terms, $mess) = split(/\t/);
    	my $seqno = substr($aseqno, 1);
    	$terms = ",$terms";
    	my @indexes = ($terms =~ m{\,(\-?\d+)\:}g);
    	# print join(", ", @indexes) . "\n";
    	$terms =~ s{\,(\-?\d+)\:}{\,}g;
    	# print "stripped[$seqno] \"$stripped[$seqno]\"\n";
    	# print "analyzed $aseqno \"$terms\"\n";
    	my $test = "$terms";
    	my $alen = length($test);
    	my $slen = length($stripped[$seqno]);
    	if ($alen > $slen) {
    		$alen = $slen;
    	}
    	if (substr($stripped[$seqno], 0, $alen) ne substr($test, 0, $alen)) {
    		print "diff: $aseqno " . substr($stripped[$seqno], 0, $alen) . "\n"
    		.     "              " . substr($test, 0, $alen) . "\n";
    	}
    } # while <>
} else {
}
#--------------------------------------------
__DATA__
A000018	36	0:1,1:1,2:2,3:2,4:4,5:8,6:13,7:25	
A000019	2499	1:1,2:1,3:2,4:2,5:5,6:4,7:7,8:7	
A000020	400	1:2,2:1,3:2,4:2,5:6,6:6,7:18,8:16	
A000021	36	0:1,1:1,2:2,3:2,4:6,5:9,6:17,7:30	
A000022	60	0:0,1:1,2:0,3:1,4:1,5:2,6:2,7:6	
A000023	250	0:1,1:-1,2:2,3:-2,4:8,5:8,6:112,7:656	sign
A000024	36	0:1,1:1,2:2,3:2,4:7,5:10,6:20,7:36	
A000025	1000	0:1,1:1,2:-2,3:3,4:-3,5:3,6:-5,7:7	sign
A000026	10000	1:1,2:2,3:3,4:4,5:5,6:6,7:7,8:6	
A000027	500000	1:1,2:2,3:3,4:4,5:5,6:6,7:7,8:8	

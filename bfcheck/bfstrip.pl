#!perl

# compare the output of bfanalyze.pl with 'stripped'
# @(#) $Id$
# 2019-01-18, Georg Fischer
#
# usage:
#   perl bfstrip.pl [-d level] [-s file] input > output
#       -s stripped file, default ../coincidence/database/stripped
#---------------------------------
use strict;
use integer;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02dT%02d_%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
my $commandline = join(" ", @ARGV);

# get options
my $action = "comp";
my $debug  = 0; # 0 (none), 1 (some), 2 (more)
my $stripped_file = "../coincidence/database/stripped";
my $offset_file   = "./neil_lists/offsetlist.txt";

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
my @offsets;
if ($action eq "comp") {
    # read 'stripped'
    my $scount = 0;
    open(STR, "<", $stripped_file) or die "cannot read $stripped_file\n";
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
    print STDERR "$scount rows read from $stripped_file\n";

    # read offset1
	# %O A000001 0,5
	# %O A000002 1,2
	# %O A000003 1,5
	# %O A000004 0,1
	# %O A000005 1,2
    $scount = 0;
    open(STR, "<", $offset_file) or die "cannot read $offset_file\n";
    while (<STR>) {
        next if m{\A\s*(\#|\Z)}o; # skip comments
        s/\s+\Z//; # chompr
        my ($operc, $aseqno, $terms) = split(/\s+/);
        my $seqno = substr($aseqno, 1);
        $terms =~ s{\,.*}{}; # remove any offset2
        $offsets[$seqno] = $terms;
        $scount ++;
    } # while <STR>
    close(STR);
    print STDERR "$scount rows read from $offset_file\n";

    # read buthors
    $scount = 0;
	my @buthors;
    open(STR, "<", "neil_lists/buthors3.man") or die "cannot read buthors\n";
    while (<STR>) {
        next if m{\A\s*(\#|\Z)}o; # skip comments
        s/\s+\Z//; # chompr
        my ($aseqno, $terms) = split(/\t/);
        my $seqno = substr($aseqno, 1);
        $buthors[$seqno] = $terms;
        $scount ++;
    } # while <STR>
    close(STR);
    print STDERR "$scount rows read from buthors\n";

    while (<>) {
        s/\s+\Z//; # chompr
        my ($aseqno, $bixmax, $terms, $mess) = split(/\t/);
        my $seqno = substr($aseqno, 1);
        $terms = ",$terms";
        $terms =~ m{\,(\-?\d+)\:};
        my $bixmin = $1;
        $terms =~ s{\,(\-?\d+)\:}{\,}g;
        my $test = "$terms";
        my $alen = length($test);
        my $slen = length($stripped[$seqno]);
        if ($alen > $slen) {
            $alen = $slen;
        }
        if (substr($stripped[$seqno], 0, $alen) ne substr($test, 0, $alen)) {
            print join("\t", $aseqno
                , $bixmin
                , $bixmax
                , $offsets[$seqno]
            	, substr($stripped[$seqno], 0, $alen),
                , substr($test, 0, $alen)
                , $mess
                , $buthors[$seqno]
                ) . "\n";
        }
    } # while <>
} else {
}
#--------------------------------------------
__DATA__
A000018 36  0:1,1:1,2:2,3:2,4:4,5:8,6:13,7:25
A000019 2499    1:1,2:1,3:2,4:2,5:5,6:4,7:7,8:7
A000020 400 1:2,2:1,3:2,4:2,5:6,6:6,7:18,8:16
A000021 36  0:1,1:1,2:2,3:2,4:6,5:9,6:17,7:30
A000022 60  0:0,1:1,2:0,3:1,4:1,5:2,6:2,7:6
A000023 250 0:1,1:-1,2:2,3:-2,4:8,5:8,6:112,7:656   sign
A000024 36  0:1,1:1,2:2,3:2,4:7,5:10,6:20,7:36
A000025 1000    0:1,1:1,2:-2,3:3,4:-3,5:3,6:-5,7:7  sign
A000026 10000   1:1,2:2,3:3,4:4,5:5,6:6,7:7,8:6
A000027 500000  1:1,2:2,3:3,4:4,5:5,6:6,7:7,8:8

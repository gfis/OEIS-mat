#!perl

# Get the OEIS history for keywords "new", "changed" or "recycled"
# @(#) $Id$
# 2019-10-27: recycled and allocated again
# 2019-01-25: rewritten for -t json
# 2019-01-17: Georg Fischer, copied from ../broken_link/brol_process.pl
#
#:# Usage:
#:#   perl history.pl [-k (new|changed|recycled|allocated)] [-n maxnum] [-w sleep] [-t (text|json)] [outputdir]
#:#       -k    for keyword kw (default "changed")
#:#       -n    fetch a maximum of n sequences 
#:#       -w    wait time in seconds (default 16)
#:#       -t    format, "text" or "json"
#:#       outputdir (default yyyy-mm-dd)
#------------------------------------
use strict;
use warnings;
use LWP;
use LWP::UserAgent;
use LWP::RobotUA;
use HTTP::Request::Common;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = gmtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d.%02d_%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min);

my $debug      = 0;
my $action     = "g";
my $keyword    = "changed";
my $minnum     = 1    ; # start of history (default 1)
my $maxnum     = 65536; # maximum number of sequences (default unlimited)
my $increment  = 10; # for &start, fixed by OEIS server
my $sleep      = 16; # wait time in seconds
my $type       = "json";
if (scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{c}) {
        $action    =   "c";
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{k}) {
        $action    = "g";
        $keyword   = shift(@ARGV);
    } elsif ($opt  =~ m{m}) {
        $minnum    = shift(@ARGV);
    } elsif ($opt  =~ m{n}) {
        $maxnum    = shift(@ARGV);
    } elsif ($opt  =~ m{r}) {
        $action    =   "r";
    } elsif ($opt  =~ m{w}) {
        $sleep      =  shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my $outdir = $timestamp;
if (scalar(@ARGV) > 0) {
    $outdir = shift(@ARGV);
}
print `mkdir $outdir`;
if (0) {
#-------------------------------------------------------------
} elsif ($action =~ m{g}) { # get blocks of 10 sequences
    my $ua;
    if (1) {
        $ua = LWP::UserAgent->new;
        $ua->agent("Mozilla/8.0"); # pretend we are a capable browser
        # $ua->agent("Chrome/70.0.3538.110");
    } else { # robot
        $ua = LWP::RobotUA->new('EiC-gfis/1.0', 'georg.fischer@t-online.de');
        $ua->delay($sleep/60);
    }
    $ua->timeout(6); # give up if server does not respond in time
    # https://oeis.org/search?q=keyword:changed&sort=modified&fmt=json&start=600
    # https://oeis.org/search?q=keyword:new&sort=created&fmt=json&start=280
    my $url = "https://oeis.org/search?q="
        . join("\&", ( "keyword:$keyword"
                     , "sort=" . ($keyword eq "new" ? "created" : "modified")
                     , "fmt=$type"
                     , "start="));
    my $start  = $minnum;
    my $total  = 0;
    while ($start < $maxnum) {
        my $status = "000";
        print STDERR "read $url$start\n";
        my $response = $ua->request(GET "$url$start");
        # print STDERR "status " . $response->code() . "\n";
        my $page  = $response->decoded_content(charset => 'UTF-8');
        $status   = $response->code();
        if ($status ne "200") {
            die "bad status $status\n";
        }
        my $outname = sprintf("$outdir/block_${keyword}_%04d\.$type", $start);
        open (OUT, ">", $outname) || die "cannot write \"$outname\"\n";
        print OUT "$page\n";
        close(OUT);
        #   "count": 451,
        $page =~ m{\n\t+\"count\"\: (\d+)\,}m;
        my $count = $1;
        #           "time": "2019-01-25T04:04:11-05:00",
        my @modtimes = ($page =~ m{\n\t+\"time\"\: \"([0-9\-\:T\+]+)\"\,}mg);
        $total += scalar(@modtimes);
        print STDERR "-> $outname\t$count\n";
        foreach my $modtime(@modtimes) {
            print STDERR "$modtime\n";
        } # foreach
        $start += $increment;
        if ($count == 0 or $count < $start) {
            $start = $maxnum; # break loop
        } else { # continue
            print STDERR "sleep $sleep s\n"; 
            sleep $sleep;
        }
    } # while $start < $count
    print STDERR "history.pl read $total sequences for keyword \"$keyword\"\n";
#-------------------------------------------------------------
} else {
    die "invalid action \"$action\"\n";
}
#=====================================
sub iso_time {
    my ($unix_time) = @_;
} # iso_time
#=====================================
__DATA__
{
    "greeting": "Greetings from The On-Line Encyclopedia of Integer Sequences! http://oeis.org/",
    "query": "keyword:new",
    "count": 451,
    "start": 0,
    "results": [
        {
            "number": 323715,
            "data": "2,10,130,4550,441350,121371250,96247401250,222812733893750,1518914406953693750,30674476448429845281250,1842707823686526095580531250,330204028465507043697553297343750,176836474792332245660656600199579843750",
            "name": "a(n) = Product_{k=0..n} (2^k + 3^k).",
            "formula": [
                "a(n) ~ c * 3^(n*(n+1)/2), where c = QPochhammer[-1, 2/3] = 10.934481779448897533..."
            ],
            "mathematica": [
                "Table[Product[2^k+3^k, {k, 0, n}], {n, 0, 12}]",
                "Table[2^(n*(n+1)/2)*QPochhammer[-1, 3/2, n+1], {n, 0, 12}]"
            ],
            "xref": [
                "Cf. A000079, A000244, A323716."
            ],
            "keyword": "nonn,new",
            "offset": "0,1",
            "author": "_Vaclav Kotesovec_, Jan 25 2019",
            "references": 0,
            "revision": 4,
            "time": "2019-01-25T04:04:11-05:00",
            "created": "2019-01-25T04:04:11-05:00"
        },
        {
            "number": 323716,
            "data": "2,8,80,2240,183680,44817920,32717081600,71584974540800,469740602936729600,9246374028206585446400,545998386365598870609920000,96722522147893108730806108160000,51402410615320609490117059732766720000",
            "name": "a(n) = Product_{k=0..n} (3^k + 1).",
            "formula": [
                "a(n) ~ c * 3^(n*(n+1)/2), where c = A132323 = QPochhammer[-1, 1/3] = 3.12986803713402307587769821345767..."
            ],
            "mathematica": [
                "Table[Product[3^k+1, {k, 0, n}], {n, 0, 12}]",
                "Table[QPochhammer[-1, 3, n+1], {n, 0, 12}]"
            ],
            "xref": [
                "Cf. A034472, A028361, A132323, A323715."
            ],
            "keyword": "nonn,new",
            "offset": "0,1",
            "author": "_Vaclav Kotesovec_, Jan 25 2019",
            "references": 0,
            "revision": 3,
            "time": "2019-01-25T04:03:54-05:00",
            "created": "2019-01-25T04:03:54-05:00"
        },

#!perl

# Operations on SQL table 'brol'
# @(#) $Id$
# 2019-01-02: $content
# 2018-12-20: refetch
# 2018-12-19: -x
# 2018-12-17: fetch URLs with LWP
# 2018-12-12: Georg Fischer - for OEIS
#
# Usage:
#   perl brol_prepare.pl (-c name|-g|-r|-x) [-w s] [inputfile] > outputfile
#       -c    generate CREATE SQL for name
#       -g    get HTTP status codes for splitted URLs on input lines, and generate UPDATEs
#       -gu   same as -g, but behave as normal user (not as robot)
#       -r    generate *.tsv file for table loading
#       -tsp  test URLs for spaces
#       -w    wait time in seconds
#       -x    generate HTM table from crossref.tmp, for manual corrections
#------------------------------------
use strict;
use warnings;
use LWP;
use LWP::UserAgent;
use LWP::RobotUA;
use HTTP::Request::Common;

my $TIMESTAMP = &iso_time(time());
my $debug      = 0;
my $action     = "r";
my $wait       = 2; # wait time in seconds
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{c}) {
        $action    =   "c";
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{g}) { # or -gu
        $action    =  $opt;
    } elsif ($opt  =~ m{r}) {
        $action    =   "r";
    } elsif ($opt  =~ m{tsp}) {
        $action    =   "tsp";
    } elsif ($opt  =~ m{w}) {
        $wait      =  shift(@ARGV);
    } elsif ($opt  =~ m{x}) {
        $action    =   "x";
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
#----------------
my  ( $linetype
    , $aseqno
    , $key2
    , $prefix
    , $protocol
    , $host
    , $noccur
    , $port
    , $path
    , $filename
    , $content
    , $status
    , $access
    , $replurl
    );
my  @fields = qw(
      linetype   VARCHAR(2)
      aseqno     VARCHAR(8)
      key2       VARCHAR(4)
      prefix     VARCHAR(128)
      protocol   VARCHAR(8)
      host       VARCHAR(64)
      port       VARCHAR(8)
      path       VARCHAR(512)
      filename   VARCHAR(512)
      content    VARCHAR(512)
      status     VARCHAR(32)
      access     TIMESTAMP
      replurl    VARCHAR(512)
    );
my $letters = "_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
$linetype = "%H";
my $tabname;
if (0) {
#-------------------------------------------------------------
} elsif ($action eq "c") { # print CREATE SQL
    $tabname = shift(@ARGV);
    if (0) {
    } elsif ($tabname eq "brol") {
        print <<"GFis";
-- Table for OEIS broken link maintenance
-- @(#) \$Id\$
-- $TIMESTAMP - generated by brol_prepare.pl -c $tabname, do not edit here!
DROP    TABLE  IF EXISTS $tabname;
CREATE  TABLE            $tabname
    ( linetype   VARCHAR(2)  -- %H
GFis
        my $ifield = 2;
        while ($ifield < scalar(@fields)) {
            print sprintf("    , %-10s %-16s\n", $fields[$ifield], $fields[$ifield + 1]);
            $ifield += 2;
        } # while $ifield
        print <<"GFis";
    , PRIMARY KEY(aseqno, key2)
    );
COMMIT;
GFis
    } elsif ($tabname eq "url1") {
        print <<"GFis";
-- Table for OEIS broken link maintenance
-- @(#) \$Id\$
-- $TIMESTAMP - generated by brol_prepare.pl -c $tabname, do not edit here!
DROP    TABLE  IF EXISTS $tabname;
CREATE  TABLE            $tabname
    ( protocol   VARCHAR(8)
    , host       VARCHAR(64)
    , port       VARCHAR(8)
    , path       VARCHAR(250)
    , filename   VARCHAR(250)
    , noccur     INT
    , status     VARCHAR(32)
    , access     TIMESTAMP
    , replurl    VARCHAR(512)
    , aseqno     VARCHAR(8)   -- minimal A-number with this URL
    , PRIMARY KEY(protocol, host, port, path, filename)
    );
COMMIT;
GFis
    } else {
        die "wrong tabname \"$tabname\"\n";
    }
#-------------------------------------------------------------
} elsif ($action =~ m{g}) { # get HTTP status codes for splitted URLs on input lines, and generate UPDATEs
    my $ua;
    if ($action =~ m{gu}) {
        $ua = LWP::UserAgent->new;
        # $ua->agent("Mozilla/8.0"); # pretend we are a capable browser
        $ua->agent("Chrome/70.0.3538.110");
    } else { # robot
        $ua = LWP::RobotUA->new('pu-robot/0.1', 'punctum@punctum.com');
        $ua->delay($wait/60);
    }
    $ua->timeout(6);
    open(UPD, ">", "update.tmp") || die "cannot write update.tmp\n";
    print "--brol_process.pl -g started:   " . &iso_time(time()) . "\n";
    print UPD "--brol_process.pl -g started: " . &iso_time(time()) . "\n";
    my $count = 0;
    while (<>) {
        if ($action =~ m{gu}) {
            sleep($wait);
        }
        s{\r?\n}{}; # chompr
        my $line = $_;
        ($noccur, $protocol, $host, $port, $path, $filename, $status, $aseqno) = split(/\t/, $line);
        my $url = join("", ($protocol, $host, $port, $path, $filename));
        # print "--\"$url\"\n";
        # my $response = $ua->get($url);
        my $response = $ua->request(GET "$url");
        my $last_mod = $response->last_modified();
        if (! defined($last_mod)) {
            $last_mod = 0;
        }
        $last_mod = &iso_time($last_mod);
        $access   = &iso_time(time());
        $status   = $response->code();
        $replurl = "";
        if ($response->redirects) {  # are there any redirects?
            my @redirs = $response->redirects;
            $replurl   = $redirs[-1]->header('Location'); # last array element: final location
        }
        if (length($replurl) > 200) {
            $replurl = "";
        }
        $replurl  =~ s{\'}{\%27}g;
        $path     =~ s{\-\-}{\-\'\|\|\'\-}g;
        $filename =~ s{\-\-}{\-\'\|\|\'\-}g;
        $replurl  =~ s{\-\-}{\-\'\|\|\'\-}g;
        print join("\t", $noccur, "*status"
            , $status
            , $aseqno
            , ($response->content_length() or -1)
            , $last_mod
            , $url
            , $replurl
            ) . "\n";
        print UPD "UPDATE url1 SET status=\'$status\', access=\'$access\', replurl=\'$replurl\'"
            . " WHERE protocol=\'$protocol\' AND host=\'$host\'"
            . " AND port=\'$port\' AND path=\'$path\' AND filename=\'$filename\';"
            . "\n";
        $count ++;
        if ($count % 2 == 0) {
            print UPD "COMMIT;\n";
        }
    } # while <>
    print "--brol_process.pl -g stopped:   " . &iso_time(time()) . "\n";
    print UPD "COMMIT;\n";
    print UPD "--brol_process.pl -g stopped: " . &iso_time(time()) . "\n";
    close(UPD);
#-------------------------------------------------------------
} elsif ($action eq "r") { # print tsv lines
    my $nseqno = "";
    my $hrowno = 1;
    my $hcolno = 0;
    $status = "unknown";
    while (<>) {
        next if ! m{^\%H};
        s{\r?\n}{}; # chompr
        my $line = $_;
        $line =~ m{^$linetype\s*(A\d{6})\s*([\w\s\.\-]*)};
        $aseqno = $1;
        $prefix = $2;
        if ($aseqno ne $nseqno) {
            $nseqno =  $aseqno;
            $hrowno = 1;
        } else {
            $hrowno ++;
        }
        $hcolno = 0;
        while (($line =~ s{\<a\s+href\=\"([^\"]+)\"[^\>]*\>([^\<]+)}{}i) > 0) { # external link found
            $hcolno ++;
            my $url  = $1;
            $content = $2;
            $port    = "";
            if (0) {
            } elsif ($url =~ m{^(\w+\:\/\/)([^\/\:]+)(\:\d+)?(.*)}) {
                $protocol = $1;
                $host     = $2;
                $port     = $3 || "";
                $path     = $4;
            } elsif ($url =~ m{^\/(.*)}) {
                $protocol = "file://";
                $host   = "";
                $path     = "/$1";
            } else {
                print STDERR "not matched: $url\n";
            }
            my @parts = split(/\//, $path);
            if (scalar(@parts) > 0) {
            	$filename = pop(@parts);
            } else {
            	$filename = "";
            }
            $path     = join("/", @parts) . "/";
            $status   = "";
            $replurl  = "";
            print join("\t",
                ( $linetype
                , $aseqno
                , sprintf("%03d", $hrowno) . substr($letters, $hcolno, 1) # = key2
                , $prefix
                , $protocol
                , $host
                , $port
                , $path
                , $filename
                , $content
                , $status
                , $TIMESTAMP
                , $replurl
                )
                ) . "\n";
        } # while external link href="http://..." found
    } # while <>
#-------------------------------------------------------------
} elsif ($action eq "tsp") { # test URLs for spaces
    my $nseqno = "";
    my $hrowno = 1;
    my $hcolno = 0;
    $status = "unknown";
    while (<>) {
        next if ! m{^\%H};
        s{\r?\n}{}; # chompr
        my $line = $_;
        $line =~ m{^$linetype\s*(A\d{6})\s*([\w\s\.\-]*)};
        $aseqno = $1;
        $prefix = $2;
        if ($aseqno ne $nseqno) {
            $nseqno =  $aseqno;
            $hrowno = 1;
        } else {
            $hrowno ++;
        }
        $hcolno = 0;
        while (($line =~ s{\<a\s+href\=\"([^\"]+)\"}{}i) > 0) { # external link found
            $hcolno ++;
            my $url = $1;
            $url =~ s{ +\Z}{};
            if ($url =~ m{ }) {
                print join("\t",
                    ( $aseqno
                    , "\"$url\""
                    )
                    ) . "\n";
            }
        } # while external link href="http://..." found
    } # while <>
#-------------------------------------------------------------
} else {
    die "invalid action \"$action\"\n";
}
#----
sub iso_time {
    my ($unix_time) = @_;
    my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
    return sprintf ("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
} # iso_time
__DATA__
%H A000001 H.-U. Besche and Ivan Panchenko, <a href="/A000001/b000001.txt">Table of n, a(n) for n = 0..2047</a> [Terms 1 through 2015 copied from Small Groups Library mentioned below. Terms 2016 - 2047 added by Ivan Panchenko, Aug 29 2009. 0 prepended by _Ray Chandler_, Sep 16 2015.]
%H A000001 H. A. Bender, <a href="http://www.jstor.org/stable/1967981">A determination of the groups of order p^5</a>, Ann. of Math. (2) 29, pp. 61-72 (1927).
%H A000001 Hans Ulrich Besche and Bettina Eick, <a href="http://dx.doi.org/10.1006/jsco.1998.0258">Construction of finite groups</a>, Journal of Symbolic Computation, Vol. 27, No. 4, Apr 15 1999, pp. 387-404.
%H A000001 Hans Ulrich Besche and Bettina Eick, <a href="http://dx.doi.org/10.1006/jsco.1998.0259">The groups of order at most 1000 except 512 and 768</a>, Journal of Symbolic Computation, Vol. 27, No. 4, Apr 15 1999, pp. 405-413.
%H A000001 H. U. Besche, B. Eick and E. A. O'Brien, <a href="http://www.ams.org/era/2001-07-01/S1079-6762-01-00087-7/home.html">The groups of order at most 2000</a>, Electron. Res. Announc. Amer. Math. Soc. 7 (2001), 1-4.
%H A000001 H. U. Besche, B. Eick and E. A. O'Brien, <a href="http://www.icm.tu-bs.de/ag_algebra/software/small/">The Small Groups Library</a>
%H A000001 H. U. Besche, B. Eick and E. A. O'Brien, <a href="http://www.icm.tu-bs.de/ag_algebra/software/small/number.html">Number of isomorphism types of finite groups of given order</a>
%H A000001 H.-U. Besche, B. Eick and E. A. O'Brien, <a href="http://dx.doi.org/10.1142/S0218196702001115">A Millennium Project: Constructing Small Groups</a>, Internat. J. Algebra and Computation, 12 (2002), 623-644.
%H A000001 H. Bottomley, <a href="/A000001/a000001.gif">Illustration of initial terms</a>
%H A000001 J. H. Conway, Heiko Dietrich and E. A. O'Brien, <a href="http://www.math.auckland.ac.nz/~obrien/research/gnu.pdf">Counting groups: gnus, moas and other exotica</a>, Math. Intell., Vol. 30, No. 2, Spring 2008.
%H A000001 Otto H�lder, <a href="http://dx.doi.org/10.1007/BF01443651">Die Gruppen der Ordnungen p^3, pq^2, pqr, p^4</a>, Math. Ann. 43 pp. 301-412 (1893).
%H A000001 Rodney James, <a href="http://dx.doi.org/10.1090/S0025-5718-1980-0559207-0">The groups of order p^6 (p an odd prime)</a>, Math. Comp. 34 (1980), 613-637.
%H A000001 Rodney James and John Cannon, <a href="http://dx.doi.org/10.1090/S0025-5718-1969-0238953-8">Computation of isomorphism classes of p-groups</a>, Mathematics of Computation 23.105 (1969): 135-140.
%H A000001 G. A. Miller, <a href="http://www.jstor.org/stable/2370630">Determination of all the groups of order 64</a>, Amer. J. Math., 52 (1930), 617-634.
%H A000001 Ed Pegg, Jr., <a href="http://www.mathpuzzle.com/MAA/07-Sequence%20Pictures/mathgames_12_08_03.html">Sequence Pictures</a>, Math Games column, Dec 08 2003.
%H A000001 Ed Pegg, Jr., <a href="/A000043/a000043_2.pdf">Sequence Pictures</a>, Math Games column, Dec 08 2003 [Cached copy, with permission (pdf only)]
%H A000001 D. S. Rajan, <a href="http://dx.doi.org/10.1016/0012-365X(93)90061-W">The equations D^kY=X^n in combinatorial species</a>, Discrete Mathematics 118 (1993) 197-206 North-Holland.
%H A000001 E. Rodemich, <a href="http://dx.doi.org/10.1016/0021-8693(90)90244-I">The groups of order 128</a>, J. Algebra 67 (1980), no. 1, 129-142.
%H A000001 Gordon Royle, <a href="http://staffhome.ecm.uwa.edu.au/~00013890/data.html">Combinatorial Catalogues</a>. See subpage "Generators of small groups" for explicit generators for most groups of even order < 1000.
%H A000001 D. Rusin, <a href="/A000001/a000001.txt">Asymptotics</a> [Cached copy of lost web page]

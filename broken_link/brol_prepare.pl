#!perl

# Prepare .tsv file to be loaded in table 'brol'
# 2018-12-12: Georg Fischer - for OEIS  
#
# Usage:
#   perl brol_prepare.pl [-t] [-h] H-lines.text 
#       -t cut behind tilde part
#       -h domain names only
#------------------------------------
use strict;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $TIMESTAMP = sprintf ("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);

my $debug      = 0;
my $domain_only  = 0;
my $tilde_only = 0;
my $action     = "i";
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{c}) {
        $action    = "c";
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{h}) {
        $domain_only = shift(@ARGV);
    } elsif ($opt  =~ m{i}) {
        $action    = "i";
    } elsif ($opt  =~ m{t}) {
        $tilde_only= shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my  ( $aseqno   
    , $urlno
    , $prefix   
#   , $postfix  
    , $protocol 
    , $domain   
    , $port     
    , $path     
    , $filename 
    , $status   
    , $replurl
    );
my  @fields = qw(
      aseqno     VARCHAR(8)  
      urlno      VARCHAR(4)
      prefix     VARCHAR(128) 
      protocol   VARCHAR(8)  
      domain     VARCHAR(64) 
      port       VARCHAR(8)  
      path       VARCHAR(512) 
      filename   VARCHAR(512) 
      status     VARCHAR(16) 
      replurl    VARCHAR(512) 
    );

if (0) {
} elsif ($action eq "c") { # print CREATE SQL
    print <<"GFis";
-- Table for OEIS broken link maintenance
-- @(#) \$Id\$
-- $TIMESTAMP, Georg Fischer
DROP    TABLE  IF EXISTS brol;
CREATE  TABLE            brol
    ( aseqno     VARCHAR(8)  -- Annnnnn
GFis
    my $ifield = 2;
    while ($ifield < scalar(@fields)) {
        print sprintf("    , %-10s %-16s\n", $fields[$ifield], $fields[$ifield + 1]);
        $ifield += 2;
    } # while $ifield
    print <<"GFis";
    , PRIMARY KEY(aseqno, urlno)
    );
COMMIT;
GFis
} elsif ($action eq "i") { # print tsv lines
	my $nseqno = "";
	my $urlno = 0;
    while (<>) {
        next if ! m{^\%H};
        s{\r?\n}{}; # chompr
        my $line = $_;
        $line =~ s{^\%H\s*(A\d{6})\s*([^\,\<�<\:]+)}{};
        $aseqno = $1;
        $prefix = $2;
        if ($aseqno ne $nseqno) {
        	$nseqno = $aseqno;
        	$urlno = 0;
        }
        while (($line =~ s{\<a\s+href\=\"([^\"]+)\"}{}i) > 0) { # external link found
            $urlno ++;
            my $url = $1;
            if (0) {
            } elsif ($url =~ m{^(\w+\:\/\/)([^\/\:]+)(\:\d+)?(.*)}) {
                $protocol = $1;
                $domain   = $2;
                $port     = $3;
                $path     = $4;
            } elsif ($url =~ m{^\/(.*)}) {
                $protocol = "oeis://";
                $domain   = "";
                $port     = "";
                $path     = $1;
            } else {
                print STDERR "not matched: $url\n";
            }
            my @parts = split(/\//, $path);
            $filename = @parts[scalar(@parts) - 1];
            pop(@parts);
            $path     = join("/", @parts);
            $status   = "";
            $replurl  = "";
            print join("\t", ( $aseqno   
                , sprintf("%04d", $urlno)
                , $prefix   
            #   , $postfix  
                , $protocol 
                , $domain   
                , $port     
                , $path     
                , $filename 
                , $status   
                , $replurl
                )) . "\n";        
        } # while external link href="http://..." found
    } # while <>
    
} else {
    die "invalid action \"$action\"\n";
}
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

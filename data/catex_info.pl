#!perl

# Extract fields for database tables from a cat25 file
# @(#) $Id$
# 2023-05-08: asdata
# 2023-05-05: Georg Fischer, modified from common/extract_info.pl
#
#:# Usage:
#:#   perl catex_info.pl [-d debug] ../common/jcat25.txt 
#:#     writes asinfo.txt, asname.txt, bfinfo.txt
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
$timestamp = sprintf ("%04d-%02d-%02d", $year + 1900, $mon + 1, $mday);

my  $debug       = 0;
my  $lead        =  8; # so many initial terms are printed
my  $tail_width  =  8; # length of last digits in last term
my  $terms_width = 64;
my  %months      = qw(Jan 01 Feb 02 Mar 03 APr 04 May 05 Jun 06 Jul 07 Aug 08 Sep 09 Oct 10 Nov 11 Dec 12);

if (scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my  $offset1 ;
my  $offset2 ;
my  $terms   ;
my  $term8   ;
my  $termno  ;
my  $datalen ;
my  $keyword ;
my  $program ;
my  $author  ;
my  $revision;
my  $created ;
my  $access  ;

my  $name    ;

my  $bfimin  ;
my  $bfimax  ;
my  $message ;
#----

my  $line;
my  $code     = "x";
my  $aseqno   = "A000001"; # first A-number
my  $ncode    = ""; # new $code
my  $nseqno   = ""; # new $aseqno
my  $ncontent = ""; # new $content
my  $count    = 0;
my  $content;
my  $tabname;
$tabname = "asdata"; open(ASDATA, ">", "$tabname.txt") || die "cannot write \"$tabname.txt\"";
$tabname = "asinfo"; open(ASINFO, ">", "$tabname.txt") || die "cannot write \"$tabname.txt\"";
$tabname = "asname"; open(ASNAME, ">", "$tabname.txt") || die "cannot write \"$tabname.txt\"";
$tabname = "bfinfo"; open(BFINFO, ">", "$tabname.txt") || die "cannot write \"$tabname.txt\"";
&initialize();
while (<>) {
    $line = $_;
    $line =~ s/\s+\Z/    /; # chompr, but append "    " in order to handle empty $ncontent
    #             1    2       3
    $line =~ m{\A.(\w) (A\d+) +(.*)\Z};
    $ncode    = $1;
    $nseqno   = $2;
    $ncontent = $3;
    if ($ncontent eq "") {
        print STDERR "** content=\"$content\" line=\"$line\"\n";
    }
    if ($debug >= 2) {
        print STDERR "* debug$debug: ncode=$ncode, nseqno=$nseqno, aseqno=$aseqno, content="
            . substr($content, 0, 64) . " line=" . substr($line, 0, 32) . "\n";
    }
    if ($nseqno ne $aseqno) { # new sequence start
        &output(); # print for the previous sequence
        &initialize();
        $count ++;
        if ($count % 16384 == 0) {
            print STDERR "$line\n";
        }
        # new sequence
    }
    $code    = $ncode;
    $aseqno  = $nseqno;
    $content = $ncontent;
    
    if (0) { # switch over the codes
    } elsif ($code =~ m{[CDeEY]}) { 
       # first ignore these b.o. performance
       
    } elsif ($code eq 'A')        { # AUTHOR
        if ($content =~ s{, (\w\w\w +\d+[\d\: ]*)}{}) {
            $created  = &timeconv($1);
        }
        $author = substr($content, 0, 64);

    } elsif ($code =~ m{[Fopt]})  { # FORMULA or programs
        if ($program !~ m{$code}) {
            $program .= $code;
        }

    } elsif ($code eq 'H')        { # LINKS; is it a b-file link?
        if ($content =~ m{href\=\"\/$aseqno/b\d+\.txt\"}) { # yes, it is
            # Table of n, a(n) for n = 0..2047
            if ($content =~ m{n *\= *(\-?\d+) *\.\. *(\-?\d+)}) {
                $bfimin = $1;
                $bfimax = $2;
                $message = ""; # remove "synth"
            }
        } # b-file link

    } elsif ($code eq 'I')        { # ID
        # %I A000001 M0098 N0035 #234 Jan 22 2022 19:45:19
        if ($content =~ m{\#(\d+) +(\w\w\w +\d+[TtZz\d\: ]*)}) {
            $revision = $1;
            $access  = &timeconv($2);
        }

    } elsif ($code eq 'K')        { # KEYWORD
        $keyword = $content;

    } elsif ($code eq 'N')        { # NAME
        $name   = $content;

    } elsif ($code eq 'O')        { # OFFSET
        if ($debug >= 1) {
            print STDERR "* debug$debug: $line\n";
        }
        if (0) {
        } elsif ($content =~ m{(\-?\d+)\,(\d+)}) {
            $offset1 = $1;
            $offset2 = $2;
        } elsif ($content =~ m{(\-?\d+)}) {
            $offset1 = $1;
            $offset2 =  1;
        } else {
            print STDERR "** wrong offset? aseqno=$aseqno, content=\"$content\", line=\"$line\"\n";
        }

    } elsif ($code =~ m{[STU]})   { # DATA
        $terms .= $content;
        if ($code eq 'S') { # first DATA line
            my @list = split(/\,/, $terms);
            my $ilead = $lead;
            @list = splice(@list, 0, $ilead);
            $term8 = join(",", @list);
            while (length($term8) > $terms_width && $ilead >= 2) {
                $ilead --;
                @list = splice(@list, 0, $ilead);
                $term8 = join(",", @list);
            }
            if (length($term8) > $terms_width) {
                $term8 = "";
            }
        }

    } else { # ignore unknown code
    } # switch over $code
} # while <>

&output();
close(ASDATA);
close(ASINFO);
close(ASNAME);
close(BFINFO);
# end main
#--------
sub output {
    if ($message =~ m{synth}) { # no real b-file
        my @list = split(/\,/, $terms);
        $bfimin = $offset1;
        if ($bfimin !~ m{\A\-?\d+\Z}) {
            print STDERR "** wrong bfimin? aseqno=$aseqno, bfimin=\"$bfimin\"\n";
            $bfimin = 0;
        }
        $bfimax = scalar(@list) + $bfimin - 1;
    } # no real b-file
    $termno = $bfimax - $bfimin + 1;
    print ASDATA join("\t", $aseqno, $termno, $terms) . "\n";
    print ASINFO join("\t", $aseqno, $offset1, $offset2, $term8, $termno, length($terms), $keyword, $program, $author, $revision, $created, $access) . "\n";
    print ASNAME join("\t", $aseqno, $name) . "\n";
    print BFINFO join("\t", $aseqno, $bfimin, $bfimax, 0, $term8, "", 0, 0, $message, "1971-01-01 00:00:01") . "\n";
} # output

sub initialize {
    $offset1    = "0";
    $offset2    = "";
    $terms      = "";
    $term8      = "";
    $termno     = "0";
    $datalen    = "0";
    $keyword    = "";
    $program    = "";
    $author     = "undef";
    $revision   = "0";
    $created    = "1974-01-01 00:00:00";
    $access     = "";
    $name       = "undef";
    $bfimin     = "0";
    $bfimax     = "-1";
    $message    = "synth";
} # initialize
#----
sub timeconv {
    my ($value) = @_;
    # %I A000001 M0098 N0035 #234 Jan 22 2022 19:45:19
    # %A A038607 Vasiliy Danilov (danilovv(AT)usa.net), Jul 1998
    my ($monthname, $day, $year, $hour, $min, $sec);
    if (0) {
    } elsif ($value =~ m{ *([A-Za-z]{3}) +(\d{4})}) {
        ($monthname, $day, $year, $hour, $min, $sec) = ($1,  1, $2,  1,  1,  1);
    } elsif ($value =~ m{ *([A-Za-z]{3}) (\d\d) +(\d{4}) (\d\d)\:(\d\d)\:(\d\d)}) {
        ($monthname, $day, $year, $hour, $min, $sec) = ($1, $2, $3, $4, $5, $6);
    } elsif ($value =~ m{ *([A-Za-z]{3}) (\d\d) +(\d{4})}) {
        ($monthname, $day, $year, $hour, $min, $sec) = ($1, $2, $3,  1,  1,  1);
    } else {
        ($monthname, $day, $year, $hour, $min, $sec) = ("Jan", 01, 1971, 1, 1,  1);
    }
    my $month = $months{$monthname} || "01";
    if ($year < 1970) {
        # OEIS server sometimes sets "0000"
        # MariaDB does not accept timestamps < "1970-01-01 01:01:01"
        $year = 1971;
    }
    return sprintf ("%04d-%02d-%02d %02d:%02d:%02d", $year, $month, $day, $hour, $min, $sec);
} # timeconv
#--------------------------------------------
__DATA__
#----
# mapping from internal format to JSON tags and vice versa
my  %codes = qw(
    A   author
    C   comment
    D   reference
    e   example
    E   ext
    F   formula
    H   link
    I   id
    K   keyword
    N   name
    o   program
    O   offset
    p   maple
    S   data
    t   mathematica
    T   data
    U   data
    Y   xref
    ); # codes
# OEIS as of February 28 14:44 EST 2019

%I A000001 M0098 N0035 #234 Jan 22 2022 19:45:19
%S A000001 0,1,1,1,2,1,2,1,5,2,2,1,5,1,2,1,14,1,5,1,5,2,2,1,15,2,2,5,4,1,4,1,51,
%T A000001 1,2,1,14,1,2,2,14,1,6,1,4,2,2,1,52,2,5,1,5,1,15,2,13,2,2,1,13,1,2,4,
%U A000001 267,1,4,1,5,1,4,1,50,1,2,3,4,1,6,1,52,15,2,1,15,1,2,1,12,1,10,1,4,2
%N A000001 Number of groups of order n.
%C A000001 Also, number of nonisomorphic subgroups of order n in symmetric group S_n. - _Lekraj Beedassy_, Dec 16 2004
%C A000001 Also, number of nonisomorphic primitives of the combinatorial species Lin[n-1]. - _Nicolae Boicu_, Apr 29 2011
%C A000001 The record values are (A046058): 1, 2, 5, 14, 15, 51, 52, 267, 2328, 56092, 10494213, 49487365422, ..., and they appear at positions (A046059): 1, 4, 8, 16, 24, 32, 48, 64, 128, 256, 512, 1024, .... _Robert G. Wilson v_, Oct 12 2012
%C A000001 In (J. H. Conway, Heiko Dietrich and E. A. O'Brien, 2008), a(n) is called the "group number of n", denoted by gnu(n), and the first occurrence of k is called the "minimal order attaining k", denoted by moa(k) (see A046057). - _Daniel Forgues_, Feb 15 2017
%C A000001 It is conjectured in (J. H. Conway, Heiko Dietrich and E. A. O'Brien, 2008) that the sequence n -> a(n) -> a(a(n)) = a^2(n) -> a(a(a(n))) = a^3(n) -> ... -> consists ultimately of 1s, where a(n), denoted by gnu(n), is called the "group number of n". - _Muniru A Asiru_, Nov 19 2017
%D A000001 L. Comtet, Advanced Combinatorics, Reidel, 1974, p. 302, #35.
%D A000001 J. H. Conway et al., The Symmetries of Things, Peters, 2008, p. 209.
%D A000001 H. S. M. Coxeter and W. O. J. Moser, Generators and Relations for Discrete Groups, 4th ed., Springer-Verlag, NY, reprinted 1984, p. 134.
...
%D A000001 N. J. A. Sloane and Simon Plouffe, The Encyclopedia of Integer Sequences, Academic Press, 1995 (includes this sequence).
%H A000001 H.-U. Besche and Ivan Panchenko, <a href="/A000001/b000001.txt">Table of n, a(n) for n = 0..2047</a> [Terms 1 through 2015 copied from Small Groups Library mentioned below. Terms 2016 - 2047 added by Ivan Panchenko, Aug 29 2009. 0 prepended by _Ray Chandler_, Sep 16 2015.]
%H A000001 H. A. Bender, <a href="http://www.jstor.org/stable/1967981">A determination of the groups of order p^5</a>, Ann. of Math. (2) 29, pp. 61-72 (1927).
%H A000001 Hans Ulrich Besche and Bettina Eick, <a href="http://dx.doi.org/10.1006/jsco.1998.0258">Construction of finite groups</a>, Journal of Symbolic Computation, Vol. 27, No. 4, Apr 15 1999, pp. 387-404.
%H A000001 Hans Ulrich Besche and Bettina Eick, <a href="http://dx.doi.org/10.1006/jsco.1998.0259">The groups of order at most 1000 except 512 and 768</a>, Journal of Symbolic Computation, Vol. 27, No. 4, Apr 15 1999, pp. 405-413.
%H A000001 H. U. Besche, B. Eick and E. A. O'Brien, <a href="http://www.ams.org/era/2001-07-01/S1079-6762-01-00087-7/home.html">The groups of order at most 2000</a>, Electron. Res. Announc. Amer. Math. Soc. 7 (2001), 1-4.
...
%H A000001 Gang Xiao, <a href="http://wims.unice.fr/~wims/wims.cgi?module=tool/algebra/smallgroup">SmallGroup</a>
%H A000001 <a href="/index/Gre#groups">Index entries for sequences related to groups</a>
%H A000001 <a href="/index/Cor#core">Index entries for "core" sequences</a>
%F A000001 From _Mitch Harris_, Oct 25 2006: (Start)
%F A000001 For p, q, r primes:
...
%F A000001 * Yes.........Yes.........Yes.........p+4 (table from Derek Holt) (End)
%F A000001 a(n) = A000688(n) + A060689(n). - _R. J. Mathar_, Mar 14 2015
%e A000001 Groups of orders 1 through 10 (C_n = cyclic, D_n = dihedral of order n, Q_8 = quaternion, S_n = symmetric):
%e A000001 1: C_1
...
%e A000001 9: C_9, C_3 X C_3
%e A000001 10: C_10, D_10
%p A000001 GroupTheory:-NumGroups(n); # with(GroupTheory); loads this command - _N. J. A. Sloane_, Dec 28 2017
%t A000001 FiniteGroupCount[Range[100]] (* _Harvey P. Dale_, Jan 29 2013 *)
%t A000001 a[ n_] := If[ n < 1, 0, FiniteGroupCount @ n]; (* _Michael Somos_, May 28 2014 *)
%o A000001 (MAGMA) D:=SmallGroupDatabase(); [ NumberOfSmallGroups(D, n) : n in [1..1000] ]; // _John Cannon_, Dec 23 2006
%o A000001 (GAP) A000001 := Concatenation([0], List([1..500], n -> NumberSmallGroups(n))); # _Muniru A Asiru_, Oct 15 2017
%Y A000001 The main sequences concerned with group theory are A000001 (this one), A000679, A001034, A001228, A005180, A000019, A000637, A000638, A002106, A005432, A000688, A060689, A051532.
%Y A000001 Cf. A046058, A023675, A023676. A003277 gives n for which A000001(n) = 1, A063756 (partial sums).
%Y A000001 A046057 gives first occurrence of each k.
%K A000001 nonn,core,nice,hard
%O A000001 0,5
%A A000001 _N. J. A. Sloane_
%E A000001 More terms from _Michael Somos_
%E A000001 Typo in b-file description fixed by _David Applegate_, Sep 05 2009

%I A000002 M0190 N0070
%S A000002 1,2,2,1,1,2,1,2,2,1,2,2,1,1,2,1,1,2,2,1,2,1,1,2,1,2,2,1,1,2,1,1,2,1,
%T A000002 2,2,1,2,2,1,1,2,1,2,2,1,2,1,1,2,1,1,2,2,1,2,2,1,1,2,1,2,2,1,2,2,1,1,
...


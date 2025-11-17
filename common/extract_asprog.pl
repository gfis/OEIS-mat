#!perl

# Extract foreign programs from jcat25.txt
# @(#) $Id$ 
# 2025-11-15: with timestamp in A000000; *EFF=4
# 2025-11-01: standalone, copied from extract_xref.pl
# 2019-01-22, Georg Fischer
#
#:# usage:
#:#   perl extract_prog.pl [-d mode] [-n] jcat25.txt > asprog.txt
#:#   perl extract_prog.pl [-d mode] -c              > asprog.create.sql
#:#       -d mode    debug mode: none(0), some(1), more(2)
#:#       -n extract only the ones not yet implemented in jOEIS
#---------------------------------
use strict;
use integer;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday) = gmtime (time);
my $utc_stamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d\z"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);

# get options
my $nyi      = 0;    # default: all sequences
my $in_prog;         # whether in "program|maple|mathematica" property
my $do_prog  = 0;    # whether in action -ap
my $program  = "";
my $prog_buffer;     # append program lines here
my $prog_sep = "~~"; # separator for program lines
my $debug    =  0;   # 0 (none), 1 (some), 2 (more)
my %xhash;           # for &extract_programs
my $aseqno;
my $tabname  = "asprog";
my $access   = "1971-01-01 00:00:00"; # modification timestamp from the file
my $revision = 0;    # from I record
my $author   = "";
my $revision = 0;
my $created  = $utc_stamp;
my %month_names = qw(Jan 1 Feb 2 Mar 3 Apr 4 May 5 Jun 6 Jul 7 Aug 8 Sep 9 Oct 10 Nov 11 Dec 12);

# get options
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{\-d}) {
        $debug    = shift(@ARGV);
    } elsif ($opt =~ m{\-c}) {
        &print_create_asprog();
        exit;
    } elsif ($opt =~ m{\-n}) {
        $nyi = 1;
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while ARGV
#----  
# $inprog = 0: outside pto
# $inprog = 1:  inside o
# $inprog = 2:  inside p
# $inprog = 3:  inside t

my $line;
my $type;
# while (<DATA>) {
while (<>) {  
    next if ($nyi == 1 && substr($_, 0, 1) ne "%");
    s/\s+\Z//;
    $type = substr($_, 1, 1);
    $line = substr($_, 3);
    $line =~ s{€}{A}g; # replace unknown €seqnos
    if ($debug >= 2) {
        print "line=$line~~\n";
    }
    my $nseqno = 'A' . substr($line, 1, 6);
    if (0) {
    } elsif ($type eq "I") { # new sequence
        # print "# line=$line\n";
        &output_prog();
        # %I A389847 #9 Oct 17 2025 09:57:54
        $in_prog = 0; # but terminate prog mode
        $aseqno  = $nseqno;
        #               aseqno mseqnos? #rev   Mon   day   year  hour   min     sec
        #                                1   1  2   2  3   3  4   4  5             5
        if ($line =~ m{\A[A-Z]\d+[^\#]+\#(\d+) +(\w+) +(\d+) +(\d+) +(\d+\:\d+\:\d+)}) {
            $revision = $1;
            $year     = $3;
            if ($year < 1970) {
                # OEIS server sometimes sets "0000"
                # MariaDB does not accept timestamps < "1970-01-01 01:01:01"
                $year = 1971;
            }
            my $date  = sprintf("%04d-%02d-%02d", $4, $month_names{$2} || "01", $3);
            my $time  = $5;
            $created = "${date}T$time"; 
            if ($debug >= 1) {
                print "# created=$created, line=$line\n";
            }
        } else {
            print "# line? $line\n";
        }
    } elsif ($type eq "p") { # Maple
        $line =~ s{\A[A-Z]\d+ *}{}; # remove aseqno
        if ($in_prog != 2) { 
            $prog_buffer .= "$prog_sep${prog_sep}\(Maple\)$line";
        } else {
            $prog_buffer .= "$prog_sep$line";
        }
        $in_prog  = 2;
        $program .= "p"; 
    } elsif ($type eq "t") { # Mathematica
        $line =~ s{\A[A-Z]\d+ *}{}; # remove aseqno
        if ($in_prog != 3) {
            $prog_buffer .= "$prog_sep${prog_sep}\(Mathematica\)$line";
        } else {
            $prog_buffer .= "$prog_sep$line";
        }
        $in_prog  = 3;
        $program .= "t";
    } elsif ($type eq "o") { # PARI, Haskell, Scheme, Python, SageMath etc.
        $in_prog  = 1;
        $program .= "o";
        $line =~ s{\A[A-Z]\d+ *}{}; # remove aseqno
        $line =~ s{\t}{  }g; # replace tabs?! 
        $line =~ s{\\\\(.*)}{\/\*$1 \*\/};
        $prog_buffer     .= "$prog_sep$line";
    } else {
        $in_prog = 0; # outside prog mode
    }
} # while <>
&output_prog();
#----
sub output_prog { 
    if ($debug > 0) {
        print "# prog_buffer=$prog_buffer\n";
    }
    print &accumulate_programs($aseqno, $prog_buffer);
    $prog_buffer = "";
    $in_prog     = 0;
} # output_prog
#----
sub accumulate_programs {
    my ($aseqno, $prog_buffer) = @_;
    my $buffer = "";
    #                              1                           1
    my @blocks = split(/($prog_sep\([A-Z][A-Za-z0-9]+[^\)]*\) *)/, $prog_buffer); # yields the separators: (~~(lang)) block (~~(lang)) block ...
    my $iblk = 1;
    my %curnos = (); # store the curno for some language
    my $lang;
    my $curno = 1;
    for (my $iblk = 1; $iblk < scalar(@blocks); $iblk ++) {
        my $block = $blocks[$iblk];
        if ($debug > 0) {
            print "# $aseqno block: $block\n";
        }
        if (0) {
#       } elsif ($block =~ m{\(Maple\)}) {
#           $block =~ s{[\(\)]}{}g;
#           $lang = lc($block);
#       } elsif ($block =~ m{\(Mathematica\)}) {
#           $block =~ s{[\(\)]}{}g;
#           $lang = "mma";
#           #                           1         1
        } elsif ($block =~ s{$prog_sep\(([A-Za-z]+)[^\)]*\)}{$prog_sep}) { # other language
            $lang = lc($1);
            if (0) {
            } elsif ($lang =~ m{scheme}i) {
                $lang = "scheme";
                if ($iblk < scalar(@blocks) - 1) {
                    $blocks[$iblk + 1] =~ s{\A\:}{}; # remove ":"
                }
            } elsif ($lang =~ m{Mathematica}i) {
                $lang = "mma";
            } elsif ($lang =~ m{gap}i) {
                $lang = "gap";
            }
        } else { # rest of the block, containing "~~"
            $curno = 1;
            if (! defined($curnos{$lang})) {
                $curnos{$lang} = $curno;
            } else {
                $curnos{$lang} ++;
                $curno = $curnos{$lang};
            }
            $buffer .= join("\t", $aseqno, $lang, $curno, "type", "$prog_sep$prog_sep$block") . "\n";
        } # rest pf block
    } # for $iblk
    return $buffer;
} # accumulate_programs
#----
sub print_create_asprog {
    print <<"GFis";
--  Table for OEIS - programs in sequences with their metadata
--  \@(#) \$Id\$
--  $utc_stamp  Georg Fischer - generated by extract_prog.pl - do NOT edit here!
--
DROP    TABLE  IF EXISTS asprog;
CREATE  TABLE            asprog;
    ( aseqno    VARCHAR(10)    -- e.g. A322469
    , lang      VARCHAR(16)    -- mma, maple, pari, gap etc.
    , curno     INT            -- current number of program for this language: 1, 2, ...
    , type      VARCHAR(16)    -- code for the wrapper pattern: "an" -> "a(n) = ..."
    , program   VARCHAR(16384) -- code lines started and separated by "~~"
    , author    VARCHAR(64)    -- author of the program or the sequence
    , created   TIMESTAMP DEFAULT '1971-01-01 00:00:01' -- time when the program was edited, in UTC
    , revision  INT            -- sequential version number in OEIS
    , PRIMARY KEY(aseqno, lang, curno)
    );
INSERT INTO asprog VALUES('A000000', 'system', 1, 'time', 'metadata', 'Gfis', CURRENT_TIMESTAMP, 0);
COMMIT;
GFis
} # print_create_asprog
#-----------------------
sub extract_programs { # for prog
    my ($aseqno, $line) = @_;
    $line =~ s{€}{A}g;
    if (1) {
        foreach my $aref ($line =~ m{(A\d{6})}g) { # get all referenced A-numbers
            if ($aref eq $aseqno) { # ignore reference to own
            } elsif (! defined($xhash{$aref})) {
                $xhash{$aref}  = ($in_prog == 1 ? 2 : 1);
            } else {
                $xhash{$aref} |= ($in_prog == 1 ? 2 : 1);
            }
        } # foreach
    }
    if ($in_prog == 1) {
      foreach my $pair ($line =~ m{A(\d{6}\-A\d{6})}g) { # get Ammmmmm-Annnnnn
        my ($lo, $hi) = split(/\-A/, $pair);
        if ($lo + 64 > $hi) {
          for (my $seqno = $lo + 1; $seqno < $hi; $seqno ++) {
            my $aref = sprintf("A%06d", $seqno);
            if ($aref eq $aseqno) { # ignore reference to own
            } elsif (! defined($xhash{$aref})) {
                $xhash{$aref}  = ($in_prog == 1 ? 2 : 1);
            } else {
                $xhash{$aref} |= ($in_prog == 1 ? 2 : 1);
            }
          } # for $seqno
        } # if limit
      } # foreach
    } # in_prog
} # extract_programs
#----
__DATA__
#I A308900 #45 Aug 04 2025 01:07:02
#S A308900 1,6,4,66,34,666,334,6666,3334,66666,33334,666666,333334,6666666,
#T A308900 3333334,66666666,33333334,666666666,333333334,6666666666,3333333334,
#U A308900 66666666666,33333333334,666666666666,333333333334,6666666666666,3333333333334,66666666666666,33333333333334
#N A308900 An explicit example of an infinite sequence with a(1)=1 and, for n >= 2, a(n) and S(n) = Sum_{i=1..n} a(i) have no digit in common.
#C A308900 Used in a proof that the initial terms of €309151 are correct.
#C A308900 The S(n) sequence is 1, 7, 11, 77, 111, 777, 1111, 7777, 11111, 77777, ...
#C A308900 A093137 interleaved with positive terms of A002280. - _Felix Fröhlich_, Jul 15 2019
#H A308900 Robert Israel, <a href="/A308900/b308900.txt">Table of n, a(n) for n = 1..1999</a>
#H A308900 R. Israel, <a href="https://web.archive.org/web/*/http://list.seqfan.eu/oldermail/seqfan/2019-July/018885.html">Re: Help with a(n) and a cumulative sum</a>, Seqfan (Jul 15 2019).
#H A308900 <a href="/index/Rec#order_03">Index entries for linear recurrences with constant coefficients</a>, signature (-1,10,10).
#F A308900 For even n >= 2, a(n) = 6666...66 (with n/2 6's). For odd n >= 5, a(n) = 3333...334 (with (n-3)/2 3's and a single 4).
#F A308900 From _Robert Israel_, Jul 15 2019: (Start)
#F A308900 G.f. (1+7*x)/((1+x)*(1-10*x^2)).
#F A308900 a(n) = -a(n - 1) + 10*a(n - 2) + 10*a(n - 3). (End)
#F A308900 a(-n) = a(n+1). - _Paul Curtz_, Jul 18 2019
#F A308900 a(n) = (1/60)*(-40*(-1)^n + (1 + (-1)^n)*(2^(2+n/2)*5^(1+n/2)) + (1 + (-1)^(n+1))*10^((1+n)/2)). - _Stefano Spezia_, Jul 20 2019
#p A308900 1, seq(op([6*(10^i-1)/9, 3*(10^i-1)/9+1]), i=1..30); # _Robert Israel_, Jul 15 2019
#t A308900 CoefficientList[Series[(1 + 7 x)/((1 + x) (1 - 10 x^2)), {x, 0, 26}], x] (* _Michael De Vlieger_, Jul 18 2019 *)
#t A308900 LinearRecurrence[{-1,10,10},{1,6,4},30] (* _Harvey P. Dale_, Jan 02 2022 *)
#o A308900 (PARI) Vec((1+7*x)/((1+x)*(1-10*x^2)) + O(x^20)) \\ _Felix Fröhlich_, Jul 15 2019
#o A308900 (PARI) a(n) = if(n==1, 1, if(n%2==0, 6*(10^(n/2)-1)/9, 3*(10^((n-1)/2)-1)/9+1)) \\ _Felix Fröhlich_, Jul 15 2019
#o A308900 (Magma) I:=[1,6,4]; [n le 3 select I[n] else - Self(n-1) + 10*Self(n-2) + 10*Self(n-3): n in [1..30]]; // _Vincenzo Librandi_, Jul 20 2019
#Y A308900 Cf. A002280, A093137, €309151.
#Y A308900 Cf. A289404.
#K A308900 nonn,base,easy
#O A308900 1,2
#A A308900 _N. J. A. Sloane_, Jul 15 2019
%I A389847 #9 Oct 17 2025 09:57:54
%S A389847 1,0,0,6,72,720,8280,120960,2116800,41610240,903571200,21674822400,
%T A389847 571548700800,16417540339200,509709674073600,17011056372710400,
%U A389847 607616125788672000,23133198948507648000,935196923565557452800,40010432908461913497600,1806175046642174208000000
%N A389847 E.g.f. A(x) satisfies A(x) = exp(x^3 * A(x) / (1-x)^3).
%F A389847 E.g.f.: exp( -LambertW(-x^3 / (1-x)^3) ).
%F A389847 a(n) = n! * Sum_{k=0..floor(n/3)} (k+1)^(k-1) * binomial(n-1,n-3*k)/k!.
%o A389847 (PARI) a(n) = n!*sum(k=0, n\3, (k+1)^(k-1)*binomial(n-1, n-3*k)/k!);
%Y A389847 Cf. A367789, €389844.
%Y A389847 Cf. A361572, A387951.
%K A389847 nonn,new
%O A389847 0,4
%A A389847 _Seiichi Manyama_, Oct 17 2025
%I A389853 #12 Oct 18 2025 02:34:00
%S A389853 14,29,47,53,71,73,179,277,311,349,353,599,613,643,1117,1123
%N A389853 Numbers k such that both 2^k-1 and 2^k+1 are sphenic.
%e A389853 14 is a term: 2^14-1 = 16383 = 3*43*127 and 2^14+1 = 16385 = 5*29*113.
%p A389853 q:= n-> andmap(x-> ifactors(x)[2][.., 2]=[1$3], [2^n-1, 2^n+1]):
%p A389853 select(q, [$1..200])[];  # _Alois P. Heinz_, Oct 17 2025
%t A389853 Select[Range[180], AllTrue[2^# + {-1, 1}, And[SquareFreeQ[#], PrimeNu[#] == 3] &] &]
%Y A389853 Cf. A000051, A000225, A007304, A092558 (both 2^k-1 and 2^k+1 are semiprimes).
%Y A389853 Supersets: €262978, €389854.
%K A389853 nonn,hard,more,new
%O A389853 1,1
%A A389853 _Michael De Vlieger_, Oct 17 2025

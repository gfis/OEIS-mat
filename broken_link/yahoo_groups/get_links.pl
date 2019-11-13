#!perl

# Get links from Yahoo groups list (%H from cat25.txt file)
# @(#) $Id$
# 2019-11-12, Georg Fischer
#
#:# Usage:
#:#   perl get_links.pl yahoo_links.txt > wget.tmp
#---------------------------------
use strict;
use integer;
use warnings;
my $version = "V1.1";
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);

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

while (<>) {
    s{\s+\Z}{}; # chompr
    m{(\<a[^\>]*\>)};
    my $aelem = $1;
    $aelem =~ m{href=\"([^\"]*)\"};
    my $link = $1;
    if ($link =~ m{\/\Z}) {
        print "# $link\n";
    } else {
        print "$link\n";
    }
} # while <>
#--------------------
__DATA__
done %H A000978 Yahoo PrimeForm community: <a href="http://groups.yahoo.com/group/primeform/messages">PrimeForm</a> [There is insufficient information to determine which posting to the forum was intended. Probably not worth pursuing. - ~~~~]
%H A001108 K. Ramsey, <a href="http://groups.yahoo.com/group/Triangular_and_Fibonacci_Numbers/message/62">Generalized Proof re Square Triangular Numbers</a>
%H A001109 K. J. Ramsey, <a href="http://groups.yahoo.com/group/Triangular_and_Fibonacci_Numbers/message/23">Relation of Mersenne Primes To Square Triangular Numbers</a> [edited by K. J. Ramsey, May 14 2011]
%H A001109 Kenneth Ramsey, <a href="http://groups.yahoo.com/group/Triangular_and_Fibonacci_Numbers/message/62">Generalized Proof re Square Triangular Numbers</a>
%H A001110 K. Ramsey, <a href="http://groups.yahoo.com/group/Triangular_and_Fibonacci_Numbers/message/62">Re_Generalized_Proof_re_Square_Triangular_Numbers</a>
%H A001605 David Broadhurst, <a href="http://groups.yahoo.com/group/primeform/files/LucasFib/">Fibonacci Numbers</a>
done %H A001606 D. Broadhurst, <a href="http://groups.yahoo.com/group/primenumbers/message/1003">Lucas record follows Fibonacci</a>, Yahoo! group "primenumbers", Apr 26 2001
done %H A002237 <a href="http://groups.yahoo.com/group/primeform/">Discussion group for the primality-testing program, PrimeForm.</a> [There is insufficient information to determine which posting to the forum was intended. Probably not worth pursuing. - ~~~~]
%H A003141 Yahoo Groups, <a href="http://groups.yahoo.com/group/RangeVoting/">Range Voting</a>
%H A006527 polyforms list, <a href="http://tech.dir.groups.yahoo.com/group/polyforms/message/2086">Triangles with MacMahon's pieces</a>
%H A007510 Yahoo! Groups, <a href="http://groups.yahoo.com/group/primeform/message/6481">PrimeForm e-group</a>
%H A018899 Mike Oakes, <a href="http://groups.yahoo.com/group/primenumbers/message/13418">Posting to primenumbers list, Aug 30 2003</a>.
%H A019546 David Broadhurst: primeform, <a href="http://groups.yahoo.com/group/primeform/message/3846">82000-digit prime with all digits prime</a>
%H A020483 Jens Kruse Andersen, <a href="http://groups.yahoo.com/group/primenumbers/message/15641">Prime gaps (not necessarily consecutive)</a>, Yahoo! group "primenumbers", Nov 26 2004.
%H A046029 M. Oakes, <a href="http://groups.yahoo.com/group/primeform/message/10881">Re: Gaussian primorial and factorial primes</a>, Primeform, Dec 21 2010
%H A051856 M. Oakes, <a href="http://groups.yahoo.com/group/primeform/message/10881">Re: Gaussian primorial and factorial primes</a>, Primeform, Dec 21 2010
%H A051857 M. Oakes, <a href="http://groups.yahoo.com/group/primeform/message/10881">Re: Gaussian primorial and factorial primes</a>, Primeform, Dec 21 2010
done %H A052007 <a href="http://groups.yahoo.com/group/primeform/">Primeform:</a> User group for PFGW & PrimeForm programs. Yahoo Groups Primeform, <a href="http://groups.yahoo.com/group/primeform/">Discussion group for the primality-testing program, PrimeForm.</a> [There is insufficient information to determine which posting to the forum was intended. Probably not worth pursuing. - ~~~~]
%H A054416 D. Broadhurst, <a href="http://groups.yahoo.com/group/primenumbers/message/783">Proof that 1505 term is prime</a>
%H A054681 Mark Underwood's <a href="http://groups.yahoo.com/group/primenumbers/message/12794">Problem posed on the "PrimeNumbers" yahoogroup</a> (2003)
%H A055997 K. Ramsey, <a href="http://groups.yahoo.com/group/Triangular_and_Fibonacci_Numbers/message/62">Generalized Proof re Square Triangular Numbers</a>
done %H A056806 <a href="http://groups.yahoo.com/group/primeform/">Primeform:</a> User group for PFGW & PrimeForm programs. [There is insufficient information to determine which posting to the forum was intended. Probably not worth pursuing. - ~~~~]
done %H A056807 <a href="http://groups.yahoo.com/group/primeform/">Primeform:</a> User group for PFGW & PrimeForm programs.  [There is insufficient information to determine which posting to the forum was intended. Probably not worth pursuing. - ~~~~]
done %H A058013 Yahoo Groups, <a href="http://groups.yahoo.com/group/primeform/">User group for PFGW & PrimeForm programs.</a>  [There is insufficient information to determine which posting to the forum was intended. Probably not worth pursuing. - ~~~~]
%H A061558 Jaroslaw Wroblewski, <a href="http://groups.yahoo.com/group/primenumbers/message/25033">Re: AP19 starting with 19</a>, Yahoo group "primenumbers", Apr 10 2013.
done %H A064539 <a href="http://groups.yahoo.com/group/primeform/">Discussion group for the primality-testing program PrimeForm.</a>  [There is insufficient information to determine which posting to the forum was intended. Probably not worth pursuing. - ~~~~]
%H A065092 Warren D. Smith et al., <a href="http://groups.yahoo.com/group/primenumbers/message/24989">Primes such that every bit matters?</a>, on "primenumbers" Yahoo group, Apr 04 2013
%H A066408 Mike Oakes, <a href="http://groups.yahoo.com/group/primenumbers/message/4607">Eisenstein Mersenne and Fermat primes</a>
%H A066730 J. Brennen, discussion about <a href="http://groups.yahoo.com/group/primenumbers/message/4801">issquare() tests without use of sqrt()</a> on Caldwell's 'primenumbers' list
%H A067834 M. Oakes, <a href="http://groups.yahoo.com/group/primenumbers/message/5217">Posting to primenumbers list on Feb 08 2002</a>
%H A068940 <a href="http://groups.yahoo.com/group/AttackingQueens/database">Attacking Queens Programming Contest Database</a>
%H A068941 Al Zimmermann, <a href="http://groups.yahoo.com/group/AttackingQueens/database">Attacking Queens Programming Contest Database</a> [broken link?]
%H A074282 Jens Kruse Andersen, <a href="http://groups.yahoo.com/group/primeform/message/5201">Invitation for 101 titanic helpers</a>
%H A075311 Phil Carmody, <a href="http://groups.yahoo.com/group/primenumbers/message/9173">Re: New sieve and a challenge</a>
%H A075311 Jon Perry, <a href="http://groups.yahoo.com/group/primenumbers/message/9171">New sieve and a challenge</a>
%H A076806 A. V. Kulsha, <a href="http://groups.yahoo.com/group/primenumbers/message/9836">More terms</a>
%H A078400 Cino Hilliard, <a href="http://groups.yahoo.com/group/B2LCC/files/digital%20roots">Digital Roots</a>
%H A081308 Mark Underwood, <a href="http://groups.yahoo.com/group/primenumbers/message/23479">another goldbachian theme</a>, Mar. 16, 2009 and follow-up on Oct. 21, 2011.
%H A081710 Mike Oakes, <a href="http://groups.yahoo.com/group/primenumbers/message/12028">Primo-factorials</a>
%H A081711 Mike Oakes, <a href="http://groups.yahoo.com/group/primenumbers/message/12028">Primo-factorials</a>
%H A081712 Mike Oakes, <a href="http://groups.yahoo.com/group/primenumbers/message/12028">Primo-factorials</a>
%H A081713 Mike Oakes, <a href="http://groups.yahoo.com/group/primenumbers/message/12028">Primo-factorials</a>
done %H A082182 <a href="http://groups.yahoo.com/group/primeform/">User group for the PrimeForm program.</a>  [There is insufficient information to determine which posting to the forum was intended. Probably not worth pursuing. - ~~~~]
done %H A082387 Primeform, <a href="http://groups.yahoo.com/group/primeform/">User group for PFGW and PrimeForm programs</a>  [There is insufficient information to determine which posting to the forum was intended. Probably not worth pursuing. - ~~~~]
%H A084945 Primeform, <a href="http://groups.yahoo.com/group/primeform/message/10249?var=0"> PrimeForm message</a> on the first 1659 digits. [From David Broadhurst, Apr 02 2010]
%H A086239 D. Broadhurst, <a href="http://groups.yahoo.com/group/primenumbers/message/21083">post in primenumbers group</a>, Oct 29 2009
%H A086259 Zak Seidov, <a href="http://groups.yahoo.com/group/primenumbers/message/12962">Prime sum of three neighbor digits</a>.
done %H A086346 Mike Oakes, <a href="http://groups.yahoo.com/group/primenumbers/message/12980">KingMovesForPrimes</a>.
done %H A086346 Zak Seidov, <a href="http://groups.yahoo.com/group/primenumbers/message/12947">KingMovesForPrimes</a>. New puzzle? King moves for primes
done %H A086346 Sleephound, <a href="http://groups.yahoo.com/group/primenumbers/message/12976">KingMovesForPrimes</a>. Re: New puzzle? King moves for primes
done %H A086347 Mike Oakes, <a href="http://groups.yahoo.com/group/primenumbers/message/12980">KingMovesForPrimes</a>.
done %H A086347 Zak Seidov, <a href="http://groups.yahoo.com/group/primenumbers/message/12947">KingMovesForPrimes</a>.
done %H A086347 Sleephound, <a href="http://groups.yahoo.com/group/primenumbers/message/12976">KingMovesForPrimes</a>.
done %H A086348 Mike Oakes, <a href="http://groups.yahoo.com/group/primenumbers/message/12980">KingMovesForPrimes</a>.
done %H A086348 Zak Seidov, <a href="http://groups.yahoo.com/group/primenumbers/message/12947">KingMovesForPrimes</a>.
done %H A086348 Sleephound, <a href="http://groups.yahoo.com/group/primenumbers/message/12976">KingMovesForPrimes</a>.
done %H A086349 Mike Oakes, <a href="http://groups.yahoo.com/group/primenumbers/message/12980">KingMovesForPrimes</a>.
done %H A086349 Zak Seidov, <a href="http://groups.yahoo.com/group/primenumbers/message/12947">KingMovesForPrimes</a>.
done %H A086349 Sleephound, <a href="http://groups.yahoo.com/group/primenumbers/message/12976">KingMovesForPrimes</a>.
done %H A087576 PFGW, <a href="http://groups.yahoo.com/group/primeform/">User group for the PrimeForm program.</a>  [There is insufficient information to determine which posting to the forum was intended. Probably not worth pursuing. - ~~~~]
%H A088430 Zak Seidov, <a href="http://groups.yahoo.com/group/primenumbers/message/13656">Question About Prime Numbers</a>.
%H A089166 Mark Underwood, <a href="http://groups.yahoo.com/group/primenumbers/message/13421">[PrimeNumbers] pi(x)</a>.
%H A090495 Cino Hilliard, <a href="http://groups.yahoo.com/group/B2LCC/files/Bernoulli/">Bernoulli ratios</a>.
%o A090869 (PARI) \\ Irregular prime-indexed primes. Download the ir12mill2.txt file from this link into the gp working dir http://groups.yahoo.com/group/B2LCC/files/Bernoulli/ This was simplified from Shokrollahi's table. ftp://ftp.reed.edu/pub/users/jpb/ Start a new PARI session. Default(histsize,310443). Perform irp12mill2.txt to read in the file.
%H A093429 P. Samidoost, <a href="http://groups.yahoo.com/group/primenumbers/message/14849">Primenumbers group posting</a>.
done %H A093621 <a href="http://groups.yahoo.com/group/primeform/">User group for the PrimeForm program.</a> [There is insufficient information to determine which posting to the forum was intended. Probably not worth pursuing. - ~~~~]
done %H A093623 <a href="http://groups.yahoo.com/group/primeform/">User group for the PrimeForm program.</a> [There is insufficient information to determine which posting to the forum was intended. Probably not worth pursuing. - ~~~~]
done %H A095303 PFGW, <a href="http://groups.yahoo.com/group/primeform/">User group for the PrimeForm program.</a> [There is insufficient information to determine which posting to the forum was intended. Probably not worth pursuing. - ~~~~]
done %H A095306 PFGW, <a href="http://groups.yahoo.com/group/primeform/">Discussion group for the PrimeForm program</a>. [There is insufficient information to determine which posting to the forum was intended. Probably not worth pursuing. - ~~~~]
done %H A095829 PFGW, <a href="http://groups.yahoo.com/group/primeform/">Discussion group for the PrimeForm program</a>. [There is insufficient information to determine which posting to the forum was intended. Probably not worth pursuing. - ~~~~]
done %H A095967 PFGW, <a href="http://groups.yahoo.com/group/primeform/">Discussion group for the PrimeForm program</a>. [There is insufficient information to determine which posting to the forum was intended. Probably not worth pursuing. - ~~~~]
done %H A095991 PFGW, <a href="http://groups.yahoo.com/group/primeform/">Discussion group for the PrimeForm program</a>. [There is insufficient information to determine which posting to the forum was intended. Probably not worth pursuing. - ~~~~]
done %H A096149 PFGW, <a href="http://groups.yahoo.com/group/primeform/">Discussion group for the PrimeForm program</a>. [There is insufficient information to determine which posting to the forum was intended. Probably not worth pursuing. - ~~~~]
done %H A096177 <a href="http://groups.yahoo.com/group/primeform/">Discussion group for the primality-testing program PrimeForm.</a> [There is insufficient information to determine which posting to the forum was intended. Probably not worth pursuing. - ~~~~]
done %H A096547 <a href="http://groups.yahoo.com/group/primeform/">Discussion group for the primality-testing program PrimeForm.</a> [There is insufficient information to determine which posting to the forum was intended. Probably not worth pursuing. - ~~~~]
%H A096548 Daniel Heuer, <a href="http://groups.yahoo.com/group/primeform/message/4503">Smallest 100000-digit prime?</a> Discussion in the PrimeForm user group.
done %H A099439 <a href="http://groups.yahoo.com/group/primeform/">User group for PFGW & PrimeForm programs.</a> [There is insufficient information to determine which posting to the forum was intended. Probably not worth pursuing. - ~~~~]
done %H A100496 <a href="http://groups.yahoo.com/group/primeform/">Primeform:</a> User group for PFGW & PrimeForm programs. [There is insufficient information to determine which posting to the forum was intended. Probably not worth pursuing. - ~~~~]
done %H A100501 <a href="http://groups.yahoo.com/group/primeform/">Primeform:</a> User group for PFGW & PrimeForm programs [There is insufficient information to determine which posting to the forum was intended. Probably not worth pursuing. - ~~~~]
%H A101042 J. K. Andersen, <a href="http://groups.yahoo.com/group/primenumbers/message/15641">Prime gaps (not necessarily consecutive)</a>.
%H A101043 J. K. Andersen, <a href="http://groups.yahoo.com/group/primenumbers/message/15641">Prime gaps (not necessarily consecutive)</a>.
%H A101044 J. K. Andersen, <a href="http://groups.yahoo.com/group/primenumbers/message/15641">Prime gaps (not necessarily consecutive)</a>.
%H A101045 J. K. Andersen, <a href="http://groups.yahoo.com/group/primenumbers/message/15641">Prime gaps (not necessarily consecutive)</a>.
%H A101046 J. K. Andersen, <a href="http://groups.yahoo.com/group/primenumbers/message/15641">Prime gaps (not necessarily consecutive)</a>.
%H A103246 MathForFun, <a href="http://groups.yahoo.com/group/mathforfun/message/9962">Title?</a>
%H A103248 MathForFun, <a href="http://groups.yahoo.com/group/mathforfun/message/9962">Pythagorean triples</a>
%H A103249 MathForFun, <a href="http://groups.yahoo.com/group/mathforfun/message/9962">Pythagorean triples</a>
%H A103250 MathForFun, <a href="http://groups.yahoo.com/group/mathforfun/message/9962">Title?</a>
%H A103251 MathForFun, <a href="http://groups.yahoo.com/group/mathforfun/message/9962">Pythagorean triples</a>
%H A103253 MathForFun, <a href="http://groups.yahoo.com/group/mathforfun/message/9962">Title?</a>
%H A104185 Michael Paul Goldenberg, <a href="http://groups.yahoo.com/group/MathTalk/message/1378">Online discussion</a>
%H A108261 K. J. Ramsey, <a href="http://groups.yahoo.com/group/Triangular_and_Fibonacci_Numbers/message/16">RecursiveSeriesProblem</a> [Edited by Kenneth J. Ramsey, May 14 2011]
%H A108262 K. J. Ramsey, <a href="http://groups.yahoo.com/group/Triangular_and_Fibonacci_Numbers/message/16">RecursiveSeriesProblem</a> [Edited by Kenneth J. Ramsey, May 14 2011]
%H A113432 Caldwell, C., <a href="http://groups.yahoo.com/group/primeform/message/6588/">"Pierpont primes." primeform posting, Oct 25, 2005.</a>
%H A113433 Caldwell, C., <a href="http://groups.yahoo.com/group/primeform/message/6588/">"Pierpont primes." primeform posting, Oct 25, 2005.</a>
%H A113434 Caldwell, C., <a href="http://groups.yahoo.com/group/primeform/message/6588/">"Pierpont primes." primeform posting, Oct 25, 2005.</a>
%H A115563 David Broadhurst, <a href="http://groups.yahoo.com/group/primeform/message/7081">Re: need help about 2 constants</a>, primeforum, Mar 20 2006
done %H A116899 <a href="http://groups.yahoo.com/group/primeform/">Primeform:</a> User group for PFGW and PrimeForm programs.  [There is insufficient information to determine which posting to the forum was intended. Probably not worth pursuing. - ~~~~]
%H A117223 David Broadhurst, <a href="http://groups.yahoo.com/group/primenumbers/message/20305">Flat ternary cyclotomic polynomials, in: Yahoo! group "primenumbers"</a>, May 2009.
%H A118539 David Broadhurst, <a href="http://groups.yahoo.com/group/primeform/message/7397">Posting to PrimeForm</a> list.
%H A121046 David Broadhurst, <a href="http://groups.yahoo.com/group/primeform/message/7223">Primeform yahoo group</a>.
%H A122026 Yahoo Groups, <a href="http://groups.yahoo.com/group/RangeVoting/">Range Voting</a>
%H A122027 Yahoo Groups, <a href="http://groups.yahoo.com/group/RangeVoting/">Range Voting</a>
%H A123159 Primeform Group, <a href="http://groups.yahoo.com/group/primeform/message/4773">base=2</a>
%H A123159 Primeform Group, <a href="http://groups.yahoo.com/group/primeform/message/7747">base=3</a>
%H A123159 Primeform Group, <a href="http://groups.yahoo.com/group/primeform/message/4742">base=5</a>
%H A129542 C. Hilliard, <a href="http://groups.yahoo.com/group/seqfun/files/Isolated%20primes/">Sum Isolated Primes</a>.
%H A129542 C. Hilliard, <a href="http://groups.yahoo.com/group/seqfun/message/38">Gcc code</a>. It took 7.5 hrs to compute a(12). It will take the Gcc program 3.2 days to compute a(13). For a(16) it will take about 8 years.
%H A129697 C. Hilliard, <a href="http://groups.yahoo.com/group/seqfun/files/Isolated%20primes/">Sum Isolated Primes</a>.
%H A129697 C. Hilliard, <a href="http://groups.yahoo.com/group/seqfun/message/38">Gcc code</a>.
%H A131043 Cino Hilliard, <a href="http://groups.yahoo.com/group/seqfun/message/58">Count primes in a range</a>.
%H A137985 Warren D. Smith et al., <a href="http://groups.yahoo.com/group/primenumbers/message/24989">Primes such that every bit matters?</a>, Yahoo group "primenumbers", April 2013
%H A147844 MathForFun, <a href="http://groups.yahoo.com/group/mathforfun/message/13576">Binomial Identity</a>
%H A151611 Antreas P. Hatzipolakis, <a href="http://groups.yahoo.com/group/Anopolis/message/103">Concurrent NPC's</a>
%H A156051 David Broadhurst, <a href="https://groups.yahoo.com/neo/groups/primeform/conversations/topics/9395">Statistics on Pierre CAMI's Riesel-hypotenuse (RH) primes</a>, Yahoo! group "primenumbers", Feb 04 2009
%H A156997 MathForFun, <a href="http://groups.yahoo.com/group/mathforfun/message/13635">Pythagorean triple digital sums</a>
%H A158460 S. M. Ruiz, <a href="http://groups.yahoo.com/group/primenumbers/message/19899">Integer equal</a>
%H A158470 S. M. Ruiz, <a href="http://groups.yahoo.com/group/primenumbers/message/19899">Integer equal</a>
%H A158509 S. M. Ruiz, <a href="http://groups.yahoo.com/group/primenumbers/message/19899">Integer then equal</a>.
%H A158529 S. M. Ruiz, <a href="http://groups.yahoo.com/group/primenumbers/message/19899">Integer then equal</a>.
%H A158790 D.Broadhurst, <a href="http://groups.yahoo.com/group/primenumbers/message/19925">The House That Jack Built</a>
%H A158892 David Broadhurst, <a href="http://groups.yahoo.com/group/primenumbers/message/19940">The house that Jack built</a>, in Yahoo! group "primenumbers", Mar 25 2009
%H A159266 M. F. Hasler, <a href="http://groups.yahoo.com/group/primenumbers/message/20014">Primes of the form (x+1)^p-x^p</a>, Apr 7, 2009.
%H A159270 David Broadhurst, <a href="https://groups.yahoo.com/neo/groups/primenumbers/conversations/topics/20062">2^m+3^n and 2^n+3^m</a>, Prime numbers and primality testing Group, Apr 11 2009.
%H A159270 Mark Underwood, <a href="https://groups.yahoo.com/neo/groups/primenumbers/conversations/topics/20013">Re: primes of the form (x+1)^p-x^p</a>, Prime numbers and primality testing Group, Apr 07 2009.
%H A159625 Underwood's <a href="http://groups.yahoo.com/group/primenumbers/message/20029">posting</a> in the PrimeNumbers list
%H A159625 Broadhurst's <a href="http://groups.yahoo.com/group/primenumbers/message/20062">heuristic</a> in the PrimeNumbers list
%H A159908 Phil Carmody, <a href="http://groups.yahoo.com/group/primenumbers/message/20245">"Cyclotomic polynomial puzzles", in: "primenumbers" group</a>, May 9, 2009.
%H A159909 Phil Carmody, <a href="http://groups.yahoo.com/group/primenumbers/message/20245">"Cyclotomic polynomial puzzles", in: "primenumbers" group</a>, May 9, 2009.
%H A161681 Yahoo groups,<a href="http://groups.yahoo.com/group/primenumbers/message/20400">Primenumbers</a>
%H A166509 J. P. Benney and others, <a href="http://groups.yahoo.com/group/primenumbers/message/21075">Is this a convergent series and if so what is its sum?</a>, in primenumbers group, Oct 26 2009.
%H A166510 J. P. Benney, <a href="http://groups.yahoo.com/group/primenumbers/message/21075">Is this a convergent series and if so what is its sum?</a>, in primenumbers group, Oct 26 2009.
%H A167504 M. Underwood, <a href="http://groups.yahoo.com/group/primenumbers/message/21119">2^a*3^b one away from a prime</a>. Post to primenumbers group, Nov. 19, 2009.
%H A167505 M. Underwood, <a href="http://groups.yahoo.com/group/primenumbers/message/21119">2^a*3^b one away from a prime</a>. Post to primenumbers group, Nov. 19, 2009.
%H A167506 M. Underwood, <a href="http://groups.yahoo.com/group/primenumbers/message/21119">2^a*3^b one away from a prime</a>. Post to primenumbers group, Nov. 19, 2009.
%H A179400 D. Broadhurst, <a href="http://groups.yahoo.com/group/primenumbers/message/22386">Re: 1993/2011 puzzle [and Puzzle 7]</a>, in primenumbers@yahoogroups.com, Jan 2011.
%H A179678 D. Broadhurst, <a href="http://groups.yahoo.com/group/primenumbers/message/22386">Re: 1993/2011 puzzle [and Puzzle 7]</a>, in primenumbers@yahoogroups.com, Jan 2011.
%H A180476 W. Sindelar, <a href="http://groups.yahoo.com/group/primenumbers/message/22455">Certain Pairs of Consecutive Prime Numbers</a>, in yahoo group "primenumbers".
%H A180481 W. Sindelar, <a href="http://groups.yahoo.com/group/primenumbers/message/22455">Certain Pairs of Consecutive Prime Numbers</a>, in yahoo group "primenumbers", Jan 20 2011.
%H A181696 D. Broadhurst, Warren D. Smith, et al., <a href="http://groups.yahoo.com/group/primenumbers/message/22043">Prime chains x -> Ax+B</a>. Yahoo group "primenumbers", Nov 2010.
%H A182987 D. Broadhurst, <a href="http://groups.yahoo.com/group/primenumbers/message/23128">Re: adding to prime number [primes in A182987]</a>, primenumbers group, Sep 20 2011.
%H A185446 D. Skordev et al., <a href="http://groups.yahoo.com/group/primenumbers/message/22543">On the representation of some even numbers as sums of two prime numbers</a>, in "primenumbers" Yahoo group, Feb 02 2011.
%H A185447 D. Skordev et al., <a href="http://groups.yahoo.com/group/primenumbers/message/22543">On the representation of some even numbers as sums of two prime numbers</a>, in "primenumbers" yahoo group, Feb 02 2011.
%H A190639 J. K. Anderson, in reply to R. Wood, <a href="http://groups.yahoo.com/group/primenumbers/message/22717">Re: First repetition of prime pattern within "centuries"</a>, Yahoo group "primenumbers", May 15, 2011.
%H A191913 D. Broadhurst (in reply to James Merickel), <a href="http://groups.yahoo.com/group/primenumbers/message/22771">Re: Sphenic chain by concatenation of factors</a>, "primenumbers" group, June 16, 2011.
%H A193888 J. Brennen, in reply to J. Merickel, <a href="http://groups.yahoo.com/group/primenumbers/message/22932">Problem that should be solvable requiring scientific approach</a> on yahoo group "primenumbers", Aug 07 2011
%H A193889 J. Brennen, in reply to J. Merickel, <a href="http://groups.yahoo.com/group/primenumbers/message/22932">Problem that should be solvable requiring scientific approach</a> on yahoo group "primenumbers", Aug 07 2011.
%H A195987 D. Broadhurst, <a href="http://groups.yahoo.com/group/primenumbers/message/23431">Re: Square factors of n^n+(n+1)^(n+1) [starting with 907^2]</a>, on yahoo group "primenumbers", Oct 12 2011
%H A196511 D. J. Broadhurst et al., <a href="http://groups.yahoo.com/group/primenumbers/message/23313">Re: Square factors of b^p-1</a> on yahoo group "primenumbers", Sept.-Oct. 2011
%H A196733 D. J. Broadhurst et al., <a href="http://groups.yahoo.com/group/primenumbers/message/23175">Re: Square factors of b^p-1</a> on yahoo group "primenumbers", Sept.-Oct. 2011
%H A198196 D. Broadhurst, <a href="http://groups.yahoo.com/group/primenumbers/message/23490">Re: Cubic factors of n^n+(n+1)^(n+1)</a>, in "primenumbers" Yahoo group, Oct 21 2011
%H A202803 Bagula, R., <a href="http://groups.yahoo.com/group/Active_Mathematica/message/1366">Active_Mathematica: n-agonal numbers generalization from a vector Markov approach (Jan 02 2011)</a>
%H A204656 Nathan Russell, <a href="http://groups.yahoo.com/group/primenumbers/message/23995">n!10+2 results</a>, primenumbers group, Jan 2012
%H A204657 Nathan Russell, <a href="http://groups.yahoo.com/group/primenumbers/message/23995">n!10+2 results</a>, primenumbers group, Jan 2012
%H A204658 Nathan Russell, <a href="http://groups.yahoo.com/group/primenumbers/message/23995">n!10+2 results</a>, primenumbers group, Jan 2012
%H A204659 Nathan Russell, <a href="http://groups.yahoo.com/group/primenumbers/message/23995">n!10+2 results</a>, primenumbers group, Jan 2012
%H A204660 Nathan Russell, <a href="http://groups.yahoo.com/group/primenumbers/message/23995">n!10+2 results</a>, primenumbers group, Jan 2012
%H A204661 Nathan Russell, <a href="http://groups.yahoo.com/group/primenumbers/message/23995">n!10+2 results</a>, primenumbers group, Jan 2012
%H A204662 Nathan Russell, <a href="http://groups.yahoo.com/group/primenumbers/message/23995">n!10+2 results</a>, primenumbers group, Jan 2012
%H A204663 Nathan Russell, <a href="http://groups.yahoo.com/group/primenumbers/message/23995">n!10+2 results</a>, primenumbers group, Jan 2012
%H A204664 Nathan Russell, <a href="http://groups.yahoo.com/group/primenumbers/message/23995">n!10+2 results</a>, primenumbers group, Jan 2012
%H A207262 Yahoo Groups, <a href="http://groups.yahoo.com/group/primenumbers/msearch?query=Aurifeuille">Aurifeuille and factoring</a>
%H A212279 K. Rose, <a href="http://groups.yahoo.com/group/primenumbers/message/24241">Law of small numbers</a>, primenumbers group, May 2012
%H A213605 Woodhodgson, <a href="http://groups.yahoo.com/group/primenumbers/message/24261">Adjacent composite numbers with pairs of adjacent prime factors</a>, Primenumbers Group, Jun 15 2012
%H A213606 Woodhodgson, <a href="http://groups.yahoo.com/group/primenumbers/message/24261">Adjacent composite numbers with pairs of adjacent prime factors</a>, primenumbers group, Jun 15 2012
%H A215830 J. Merickel, <a href="http://groups.yahoo.com/group/primenumbers/message/24399">Are these new questions?</a>, Yahoo! group "primenumbers", Aug 24 2012.
%H A215952 Woodhodgson, <a href="http://groups.yahoo.com/group/primenumbers/message/24405">Digit block repetition in prime squares</a>, Yahoo! group primenumbers, Aug 28 2012
%H A216374 <a href="http://groups.yahoo.com/group/UnsolvedProblems/message/919">"Pythagorean ... Tuples"</a>, message #919, Unsolved Problems Yahoo Group
%H A216854 J. Merickel, <a href="http://groups.yahoo.com/group/primenumbers/message/24454">Conjecture</a>, Sept. 2012
%H A217016 D. Broadhurst (in reply to M. Underwood), <a href="http://groups.yahoo.com/group/primenumbers/message/24482">Re: Here's some Goldbach separation data</a>, Yahoo! group "primenumbers", Sep 23 2012
%H A217032 Ed Mertensotto, <a href="http://groups.yahoo.com/group/AlZimmermannsProgrammingContests/message/5479">post about enumerating all sequences of 12 steps</a>
%H A217376 W. Smith and others, <a href="http://groups.yahoo.com/group/primenumbers/message/24505">n, 2n-1, 2n+1 all prime or prime-power (maybe n-2 also)</a>, on primenumbers Yahoo! group, Oct 01 2012.
done %H A226291 P. Carmody, <a href="http://groups.yahoo.com/group/primenumbers/message/25152">three-prime sum chains</a>, "primenumbers" group on Yahoo!
done %H A234631 A. Kulsha, <a href="http://groups.yahoo.com/neo/groups/primenumbers/conversations/messages/25438">Re: The probability of occurrence of 3 consecutive primes</a>, primenumbers group, Dec 28 2013.
%H A237263 D. J. Broadhurst et al., <a href="https://groups.yahoo.com/neo/groups/primenumbers/conversations/topics/25454">Prime Numbers and Primality Testing, Topic 25454</a>, Yahoo Groups, 2014
%H A239790 B. Sindelar, <a href="https://groups.yahoo.com/neo/groups/primenumbers/conversations/topics/25924">Two Sets of Consecutive Primes and their Sum of Digits Connection</a>
%H A240174 James G. Merickel, <a href="http://groups.yahoo.com/neo/groups/primenumbers/conversations/messages/25448">curio on powers of e (1st appearing leading right-truncatables of each length concatenated)</a>
%H A266948 Bill Krys, <a href="https://groups.yahoo.com/neo/groups/primenumbers/conversations/messages/25782">Not much response but I still think this is outrageous result</a>, Yahoo! group primenumbers, Jan. 6, 2016
done %H A275685 Yahoo! Groups, <a href="http://groups.yahoo.com/neo/groups/primenumbers/conversations/messages/25549">Quintuplet found</a>

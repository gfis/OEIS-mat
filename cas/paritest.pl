#!perl

# Run a batch of PARI snippets and compare the results with the b-files
# 2022-06-15, Georg Fischer
#:# Usage:
#:#   perl paritest.pl [-bf bfiledir] [-d debugmode] [-s startno] [-t timeout] [-w errorwindow] input.seq4
#:#       -bf directory for b-file comparision (default ../common/bfile)
#:#       -d  mode 0=none, 1=some, 2=more (default 0)
#:#       -s  skip all <<= this aseqno (default A000000)
#:#       -t  timeout in seconds (4)
#:#       -w  window for number of terms following a difference (default 4)
#:#
#:# input.seq4 has tab-separated:
#:#   aseqno type offset gplines curno bfimax revision created author
#--------------------------------
use strict;
# do not use integer; because of hires timing
use warnings;
use POSIX;
use Time::HiRes qw(gettimeofday tv_interval);

# use IPC::Open3;
use IPC::Open2;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday) = gmtime (time);
my $utc_stamp = sprintf ("%04d-%02d-%02dT%02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec) . "z";
if (0 and scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}

my $bfiledir = "../common/bfile";
my $debug    = 0; # 0 (none), 1 (some), 2 (more)
my $startno  = "A000000"; # start behind this aseqno
my $timeout  = 4; # in seconds
my $dwindow  = 4; # window of differing terms to be shown
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{bf}) {
        $bfiledir  = shift(@ARGV);
    } elsif ($opt  =~ m{d})  {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{s})  {
        $startno   = shift(@ARGV);
    } elsif ($opt  =~ m{t})  {
        $timeout   = shift(@ARGV);
    } elsif ($opt  =~ m{w}) {
        $dwindow   = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
#----
# start gp process
# my $pid = open3(\*PIN, \*POUT, \*PERR, 'gp -fq') or die "open3() failed $!";
my $pid = open2(\*POUT, \*PIN, 'gp -fq 2>&1') or die "open2() failed $!";
my $openlude = <<'GFis';
default(realprecision, 2000); default(parisize,1024000000); default(primelimit,10^7); 
GFis
print "# start batch; process gp created, pid = $pid\n";
print "# gp <- $openlude";
print PIN $openlude;
#----
my $READY   = "READY";
# states of the automaton in &test1
my $IN_READ = 1;
my $IN_DIFF = 2;
my $IN_SKIP = 3;
my $WPROMPT = 4;
my @terms;
my $start_time;
my $index; # current index
my ($aseqno, $type, $offset, $code, $curno, $bfimax, $revision, $created, $author);
my ($result, $idiff, $expected, $computed, $elapsed, $logline);
my $ok; # if record is to be repeated
my $prompt_is_requested = 0;

while (<>) { # read seq4 format
    $ok = 1; # assume success
    s/\s+\Z//; # chompr
    my $line = $_;
    if (m{\AA\d{4}\d+\s}) { # starts with A.number; not commented out
        ($aseqno, $type, $offset, $code, $curno, $bfimax, $revision, $created, $author) = split(/\t/, $line);
        next if $aseqno le $startno;
        $start_time = [gettimeofday]; # $elapsed = tv_interval($start_time, [gettimeofday]);
        &read_bfile($aseqno); # -> @terms
        if ($debug >= 1) {
            print "#--------------------------------\n# start test $line\n";
        }
        &test1();
    } # starts with A-number
} # while seq4
#--------
sub test1 {
    # Run the test for one A-number until:
    # (1) the timeout stops the computation
    # (2) there is a difference, and a windows of following terms will be shown
    # (3) the number of required terms (bfimax - bfimin + 1) is reached
    $index = $offset;
    my $state = $IN_READ;
    $prompt_is_requested = 0;

    my $gpline;
    # write the specific prolog
    if (0) {
    } elsif ($type =~ m{\A(pari_an|an)}) {
        $gpline = <<"GFis";
default(realprecision, 2000); default(parisize,1024000000); default(primelimit,10^7); 
GFis
        if ($debug >= 2) {
    #       print "# $aseqno $index,prolog gp <- $gpline\n";
        }
    #   print PIN "$gpline\n";
    } else {
        print "unknown type \"$type\" for $aseqno\n";
    }

    # write the program's code lines
    # my $sep = substr($code, 0, 2); # should quote it
    foreach my $gpline(split(/\~\~/, substr($code, 4), -1)) { # behind 2nd separator
        if (length($gpline) > 0) {
        if ($debug >= 2) {
            print "# $aseqno $index,gpcode gp <- $gpline\n";
        }
        print PIN "$gpline\n";
        }
    } # foreach gpline

    # write the specific epilog
    if (0) {
    } elsif ($type =~ m{\A(pari_an|an)}) {
        # iferr(alarm(4, for(n=0,40,print(a(n))); print("READY,pass")); print("READY,FATO"), E, print("READY,",errname(E)))
        $gpline = <<"GFis";
iferr(alarm($timeout, for(n=$offset,$bfimax,print(a(n))); print(\"$READY,pass\")); print(\"$READY,FATO\"), E, print(\"$READY,\",errname(E)))
GFis
        # ??? alarm is also caught by iferr: "e_ALARM" ?
        if ($debug >= 2) {
            print "# $aseqno $index,epilog gp <- $gpline\n";
        }
        print PIN "$gpline\n";
    } else {
        print "unknown type \"$type\" for $aseqno\n";
    }

    # read until "READY"
    $result = ""; # unknown so far
    $expected = "";
    $computed = "";
    my $bfi   = 0; # b-file terms alsways start with [0]
    my $wincount = $dwindow;
    while (<POUT>) { # read output of gp
        s/\s+\Z//; # chompr
        my $line = $_;
        if ($debug >= 2) {
            print "# $aseqno $index,state$state gp -> $line\n";
        }
        if (0) {
        } elsif ($line =~ m{\A([\-]?\d+)}) { # next term
            my $term = $1;
            if (0) {
            } elsif ($state == $IN_READ) {
                if ($term ne $terms[$bfi]) { # first difference, start the window
                    $idiff    = $index;
                    $result   = "FAIL";
                    $expected = &shorten($terms[$index]);
                    $computed = &shorten($term);
                    $wincount = $dwindow;
                    $state    = $IN_DIFF;
                } else { # term ok
                    # continue
                }
            } elsif ($state == $IN_DIFF) {
                $expected .= "," . &shorten($terms[$index]);
                $computed .= "," . &shorten($term);
                $wincount  --;
                if ($wincount <= 0) {
                    $state = $IN_SKIP;
                }
            } elsif ($state == $IN_SKIP) {
                # ignore further terms
            }
            $index ++;
            $bfi ++;
        } elsif ($line =~ m{\A$READY\,(.*)}) { # epilog has signaled end of test
            my $info = $1;
            $elapsed = sprintf("%d ms", tv_interval($start_time, [gettimeofday]) * 1000);
            if ($debug >= 1) {
                print "# $aseqno $index,state$state ready $line\n";
            }
            if (0) {
            } elsif ($info eq "prompt") { # from epilog
                if ($debug >= 2) {
                    print "# $aseqno $index,state$state prompt reached\n";
                }
                last; # stop reading from POUT
            } elsif ($info eq "pass") { # from epilog
                if ($result ne "FAIL") {
                    $index --; # was already 1 too far
                    $result = $info;
                }
                &request_prompt();
            } elsif ($info eq "FATO") { # from 'alarm()' epilog
                if ($result ne "FAIL") {
                    $result = $info;
                }
                &request_prompt();
            } elsif ($info eq "e_ALARM") { # from 'iferr()', should not happen
                if ($result ne "FAIL") {
                    $result = $info;
                }
                &request_prompt();
            } elsif ($info =~ m{\Ae_}) { # other error from 'iferr()'
                if ($result ne "FAIL") {
                    $result = $info;
                }
                &request_prompt();
            } else {
                if ($result ne "FAIL") {
                    $result = "FAUNK";
                }
                &request_prompt();
            }
            # READY message
        } else { # some other message - skip it
            if ($debug >= 2) {
                print "# $aseqno $index,$state gp !> $line\n";
            }
            # some other message
        }
    } # while <POUT>
} # test1

sub request_prompt { # and write logfile
    if ($prompt_is_requested == 0) { # was not yet requested
        $prompt_is_requested = 1;
        my $logline = join("\t", $aseqno, (($result eq "FAIL") 
            ? ($idiff, $result, $expected, "", $computed)
            : ($index, $result, $elapsed,  "", $bfimax  )
            )) . "\n";
        print        $logline;
        print STDERR $logline;
        my  $gpline = <<"GFis";
print(\"$READY,prompt\")
GFis
        if ($debug >= 2) {
            print "# $aseqno $index,prompt gp <- $gpline\n";
        }
        print PIN "$gpline\n";
    } # was not yet requested
} # request_prompt

sub read_bfile { # parameter aseqno; writes to @terms
    my ($aseqno) = @_;
    my $filename = "$bfiledir/b" .substr($aseqno, 1) . ".txt";
    my $inbuffer  = "";
    open(BF, "<", $filename) || die "cannot read \"$filename\"\n";
    read(BF, $inbuffer, 100000000); # 100 MB, should be less than 10 MB
    close(BF);
    my $state  = 0;
    my $bfimin = 0;
    my $bfimax = 0;
    my @lines  = split(/\n/, $inbuffer);
    @terms = (); # start a fresh list
    foreach my $line(@lines) {
        $line =~ s{\s+\Z}{}; # chompr
        $line =~ s{\A\s+}{}; # remove leading whitespace
        if (0) {
        } elsif ($line =~ m{\A(-?\d+)\s+(\-?\d{1,})\s*(\#.*)?\Z}o) {
            # loose format: ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ -> "index term #?"
            my ($index, $term, $comment) = ($1, $2, $3);
            $bfimax = $index;
            $state ++ ; # first term seen - skip any further comments
            if ($state == 1) { # for first term
                $bfimin = $index;
            }
            push(@terms, $term);
        } elsif ($line =~ m{\A\#})   { # ignore comment
        } elsif (length($line) == 0) { # ignore empty line
        } else { # print STDERR "** bad format: $line\n";
        }
    } # foreach line
} # read_bfile

sub shorten {
    my ($term) = @_;
    if (length($term) > 16) {
        $term = substr($term, 0, 4) . "..." . substr($term, -4);
    }
    return $term;
} # shorten
__DATA__
A007117	pari_an	0	~~~~~~a(n) = if(n<2, 0, my(lim=2^(2^n-(n+2))); for(k=1, lim, my(p=k*2^(n+2)+1); if(Mod(2,p)^(2^n)==-1, return(k))))	1	19	34	2021-03-02	_Jianing Song_			a(0) = a(1) = 0; for n >= 2, a(n)*2^(n+2) + 1 is the smallest prime factor of the n-th Fermat number F(n) = 2^(2^n) + 1.
A007324	pari_an	1	~~~~~~a(n) = my(b, p=factorback(primes(n-1))); forcomposite(k=9, oo, if(gcd(k, p)==1, b=2; while(Mod(b, k)^(k\2) == kronecker(b, k), b++); if(b>=prime(n), return(k))));	1	12	17	2022-06-04	_Jinyuan Wang_			Least number for which Solovay-Strassen primality test on bases < prime(n) fails.
A023199	pari_an	1	~~~~~~a(n) = my(k=1); while (sigma(k)/k < n, k++); k;	1	9	35	2019-10-07	_Michel Marcus_			a(n) is the least k with sigma(k) >= n*k.
A031508	pari_an	0	~~~~~~{a(n) = my(k=1); while(ellanalyticrank(ellinit([0, 0, 0, 0, -k]))[1]<>n, k++); k}	1	6	40	2019-08-24	_Seiichi Manyama_			Smallest k>0 such that the elliptic curve y^2 = x^3 - k has rank n, if k exists.
A046024	pari_an	0	~~~~~~a(n)=my(t); forprime(p=2,, t+=1./p; if(t>n, return(p)))	1	4	34	2015-04-29	_Charles R Greathouse IV_			a(n) = smallest k such that Sum_{ i = 1..k } 1/prime(i) exceeds n.
A057623	pari_an	1	~~~~~~{a(n) = my(t=''t); n!*polcoef(polcoef(prod(k=1, n, (1-x^k+x*O(x^n))^(-1-t)), n), 1)}	1	400	36	2020-11-07	_Seiichi Manyama_			a(n) = n! * (sum of reciprocals of all parts in unrestricted partitions of n).
A057625	pari_an	1	~~~~~~a(n)=n! * sumdiv(n, d, 1/d! );	1	449	37	2012-10-07	_Joerg Arndt_			a(n) = n! * sum 1/k! where the sum is over all positive integers k that divide n.
A057627	pari_an	1	~~~~~~a(n)=my(s); forprime(p=2,sqrtint(n), s+=n\p^2); s	1	10000	47	2015-05-18	_Charles R Greathouse IV_			Number of nonsquarefree numbers not exceeding n.
A057635	pari_an	1	~~~~~~a(n) = if(n%2, 2*(n==1), forstep(k=floor(exp(Euler)*n*log(log(n^2))+2.5*n/log(log(n^2))), n, -1, if(eulerphi(k)==n, return(k)); if(k==n, return(0))))	1	10000	35	2019-02-15	_Jianing Song_			a(n) is the largest m such that phi(m) = n, where phi is Euler's totient function = A000010, or a(n) = 0 if no such m exists.
A057643	pari_an	1	~~~~~~a(n)=lcm(apply(d->d+1,divisors(n)))	1	10000	26	2013-02-14	_Charles R Greathouse IV_			Least common multiple of all (k+1)'s, where the k's are the positive divisors of n.

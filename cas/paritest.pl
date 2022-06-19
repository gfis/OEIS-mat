#!perl

# Run a batch of PARI snippets and compare the results with the b-files
# 2022-06-15, Georg Fischer
#:# Usage:
#:#   perl paritest.pl [-bf bfiledir] [-d debugmode] [-t timeout] [-dw errorwindow] input.seq4
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
my $timeout  = 8; # in seconds
my $dwindow  = 4; # window of differing terms to be shown
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{bf}) {
        $bfiledir  = shift(@ARGV);
    } elsif ($opt  =~ m{dw}) {
        $dwindow   = shift(@ARGV);
    } elsif ($opt  =~ m{d})  {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{t})  {
        $timeout   = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
#----
# start gp process
# my $pid = open3(\*PIN, \*POUT, \*PERR, 'gp -fq') or die "open3() failed $!";
my $pid = open2(\*POUT, \*PIN, 'gp -fq 2>&1') or die "open2() failed $!";
my $openlude = <<'GFis';
default(realprecision, 2000); default(parisize,1024000000);
GFis
print "# start batch; process gp created, pid = $pid\n";
print "# gp <- $openlude";
print PIN $openlude;
#----
my $READY   = "ready";
# states of the automaton in &test1
my $IN_READ = 1;
my $IN_DIFF = 2;
my $IN_SKIP = 3;
my @terms;
my $start_time;
my $index; # current index
my @result;

my ($aseqno, $type, $offset, $code, $curno, $bfimax, $revision, $created, $author);
my $ok; # if record is to be repeated
while (<>) { # read seq4 format
    $ok = 1; # assume success
    s/\s+\Z//; # chompr
    my $line = $_;
    if (m{\AA\d{4}\d+\s}) { # starts with A.number
        ($aseqno, $type, $offset, $code, $curno, $bfimax, $revision, $created, $author) = split(/\t/, $line);
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
    $index = $offset - 1;
    my $state = $IN_READ;

    # write the specific prelude
    if (0) {
    } elsif ($type =~ m{\A(pari_an|an)}) {
        my $prelude = <<"GFis";
default(realprecision, 2000); default(parisize,1024000000);
GFis
        if ($debug >= 2) {
            print "# prelude=$prelude\n";
        }
        print PIN "$prelude\n";
    } else {
        print "unknown type \"$type\" for $aseqno\n";
    }

    # write the program's code lines
    my $sep = substr($code, 0, 2);
    foreach my $gpline(split(/\~\~/, substr($code, 4), -1)) { # behind 2nd separator
        if (length($gpline) > 0) {
            # $gpline =~ s{\A($sep)+}{}; # why?
            if ($debug >= 1) {
                print "# $aseqno $state gp <-[$index]: $gpline\n";
            }
            print PIN "$gpline\n";
        }
    } # foreach gpline

    # write the specific postlude
    if (0) {
    } elsif ($type =~ m{\A(pari_an|an)}) {
        my $postlude = <<"GFis";
iferr(alarm($timeout, for(n=0,$bfimax,print(a(n))); print("ready,pass")); print("ready,FATO"), E, print("ready,",errname(E)))
GFis
        # ??? alarm is also caught by iferr: "e_ALARM" ?
        if ($debug >= 2) {
            print "# postlude=$postlude\n";
        }
        print PIN "$postlude\n";
    } else {
        print "unknown type \"$type\" for $aseqno\n";
    }

    # read until "ready"
    my $busy  = 1;
    @result = ($aseqno, 0, "", 0, "ms");
    my $wincount = $dwindow;
    while (<POUT>) {
        s/\s+\Z//; # chompr
        my $line = $_;
        if ($debug >= 1) {
            print "# $aseqno $state gpout[$index]: $line\n";
        }
        if (0) {
        } elsif ($line =~ m{\A([\-]?\d+)}) { # next term
            my $term = $1;
            $index ++;
            if (0) {
            } elsif ($state == $IN_READ) {
                if ($term ne $terms[$index]) { # first difference, start the window
                    $result[1] = $index;
                    $result[2] = "FAIL";
                    $result[3] = &shorten($terms[$index]);
                    $result[4] = &shorten($term);
                    $wincount  = $dwindow;
                    $state     = $IN_DIFF;
                } else { # term ok
                    $result[1] = $index;
                }
            } elsif ($state == $IN_DIFF) {
                $result[3] .= "," . &shorten($terms[$index]);
                $result[4] .= "," . &shorten($term);
                $wincount  --;
                if ($wincount <= 0) {
                    $state = $IN_SKIP;
                }
            } elsif ($state == $IN_SKIP) {
                # ignore further terms
            }
        } elsif ($line =~ m{\A$READY\,(.*)}) { # postlude signaled end of test
            my $info = $1;
            if ($debug >= 2) {
                print "# $aseqno $state ready[$index]: $line\n";
            }
            if (0) {
            } elsif ($info eq "pass"    && $result[2] ne "FAIL") {
                $result[2] = $info;
            } elsif ($info eq "FATO"    && $result[2] ne "FAIL") {
                $result[2] = $info;
            } elsif ($info eq "e_ALARM" && $result[2] ne "FAIL") {
                $result[2] = "FATO";
                $result[4] = "ms";
            } elsif ($info =~ m{\Ae_}) {
                $result[2] = "FATAL";
                $result[3] = "$info";
                $result[4] = "";
            } else {
                $result[2] = "FAUNK";
                $result[3] = "$info";
                $result[4] = "";
            }
            $result[1] = $index - 1;
            &log();
            last;
        } else { # some message
            if ($debug >= 1) {
                print "# $aseqno $state gpmsg[$index]: $line\n";
            }
        }  # some message
    } # while POUT
} # test1

sub log {
    if ($result[2] =~ m{pass|FATO}) {
        $result[3] = sprintf("%d", tv_interval($start_time, [gettimeofday]) * 1000);
        $result[4] = "ms";
    }
    my $logline = join("\t", @result) . "\n";
    print        $logline;
    print STDERR $logline;
} # log

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

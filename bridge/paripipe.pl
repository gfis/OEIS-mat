#!perl

# Experiment with a bidirectional pipe to PARI/GP
# 2022-06-13, Georg Fischer
#:# Usage:
#:#   perl paripipe.pl
#--------------------------------
use strict;
use integer;
use warnings;
use POSIX;
# use IPC::Open3;
use IPC::Open2;

my $count = shift(@ARGV);

# my $pid = open3(\*PIN, \*POUT, \*PERR, 'gp -fq') or die "open3() failed $!";
my $pid = open2(\*POUT, \*PIN, 'gp -fq') or die "open2() failed $!";
print "pid = $pid\n";
print PIN <<'GFis';
\\ source=[https://oeis.org/A065048 https://oeis.org/A065048] type=an offset=0 bfimax=448 timeout=4 status=pass
default(realprecision, 2000); default(parisize,1024000000);
a(n) = if (n==0, 1, vecmax(vector(n, k, abs(stirling(n+1, k, 1)))));
alarm(4,for(n=0,+oo,print(a(n))))
GFis
my $busy = 1;
while (<POUT>) {
    my $line = $_;
    print "out: $line";
    if ($line =~ m{\A[\-]?\d}) { # next term
      $count --;
      if ($count <= 0) {
        # print "try to kill $pid\n";
        my $tl =`tasklist | grep gp`;
        $tl =~ m{(\d+)};
        my $winpid = $1;
        print "trying to send SIGINT, pid=$pid winpid=$winpid\n";
        print `SendSignal $winpid`;
        # print `python ctrl_c.py $winpid`;
        print "2^16 = ";
        # print PIN chr(0x03) ."\n"; 
        # kill(14, $pid); # sends SIGTERM instead
        print PIN "2^16\n";
        # print `kill -2 $pid`; # print PIN chr(0x03); # Ctrl-C
        # print `taskkill /PID $pid /F`;
      }
    } else {
        last;
    }
} # while <>
__DATA__
while (<PERR>) {
    print "err: $_";
} # while <>
__DATA__


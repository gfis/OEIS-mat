#!perl

# @(#) $Id$ 
# 2026-07-10: with read_b_file in any case; *MB=69
# 2026-06-16: but not more than 32 terms; *HA=69
# 2026-05-22: not only 4 terms; *TP=77
# 2025-07-06: with bfile if necessary, and over leading <= 1
# 2024-07-02, Georg Fischer
#
#:# Filter seq4 records and in some column c, replace a range "n>=17" by the initial terms
#:# Usage:
#:#   perl getinits.pl [-p parmno] infile.seq4 > outfile.seq4
#:#       -c 4      column number behind $aseqno (default = 4 = $(PARM2))
#:#       -m max    replace by at most max terms
#:#       -q        quotes around the term list (default: without quotes)
#:#
#:# Cf. holinits.pl; Read b-files from $(COMMON)/bfile.
#:# seq4 records are (aseqno, callcode, parms[0]=offset, parms[1..n]).
#:# Initial terms ($(PARM2)) in input may be:
#:#   (empty)   replace by <order> terms
#:#   n>=17     replace by 17 terms
#:#   [lo..hi]  replace by hi - lo + 1 terms
#:#   1,3,4     with comma = keep that list
#:#   17        a single number = replace by 17 terms
#--------------------------------------------------------
use strict;
use integer;
use warnings;

my $gits      =  $ENV{'GITS'};
my $stripped  = "$gits/OEIS-mat/common/stripped";
my $bfdir     = "$gits/OEIS-mat/common/bfile";
my $col       = 4; # operate on this parameter
my $nok       = 0;
my $debug     = 0;
my $quoted    = 0; # default 
my $HIGH      = 19470629; # no b-file has so many terms
my $max_count = $HIGH;

while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     =  shift(@ARGV);
    } elsif ($opt  =~ m{m}) {
        $max_count =  shift(@ARGV);
    } elsif ($opt  =~ m{[cp]}) {
        $col       =  shift(@ARGV);
    } elsif ($opt  =~ m{q}) {
        $quoted    =  1;
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my @terms;
#while (<DATA>) {
while (<>) {
    if (m{\AA\d+\t}) { # assume seq4 format
        s/\s+\Z//;
        my $line = $_;
        my (@parms) = split(/\t/, "$line\t\t", -1);
        my $aseqno = $parms[0];
        my $inits = $parms[$col];
        if (0) {
        } elsif ($inits =~ m{\A\s*\Z}) { # empty - read the whole b-file
            &read_b_file($aseqno, $HIGH);
        } elsif ($inits =~ m{\,}) { # comma already there, keep this termlist
            @terms = split(/\, */, $inits);
        #                      1   1    2   2
        } elsif ($inits =~ m{\[(\d+)\.\.(\d+)\]}) { # e.g. "[1..17] -> 18 terms
            my ($lo, $hi) = ($1, $2);
            &read_b_file($aseqno, $hi - $lo + 1);
        #                      1     1 2   2
        } elsif ($inits =~ m{\A(n\>\=)?(\d+)\Z}) { # n>=17 or a single number 17
            $inits = $2;
            &read_b_file($aseqno, $inits);
        }
        my $termlist = join(",", @terms);
        $parms[$col] = $quoted ? "\"$termlist\"" : $termlist;
        print join("\t", @parms) . "\n";
    } else { # no seq4
        print;
    }
} # while
#----
sub read_b_file {
    my ($aseqno, $nterm) = @_;
    my $src_file = "$bfdir/b" . substr($aseqno, 1) . ".txt";
    my $buffer;
    my @all; # all terms from b-file resp. stripped
    if (open(FIL, "<", "$src_file")) { # b-file could be read
        read(FIL, $buffer, 100000000); # 100 MB
        # print "# length of $src_file: " . length($buffer) . "\n";
        close(FIL);
        my $it = 0;
        my @all = grep { m{\S} } # keep non-empty lines only
            map {
                s{\#.*}{};      # remove comments
                s{\A\s+}{};     # remove leading whitespace
                s{\s+\Z}{};     # remove trailing whitespace
                # s{\s\s+}{ };  # make single space
                s{\-?\d+\s+}{}; # remove index
                # $it ++ if (m{\S});
                $_
            } split(/\n/, $buffer);
        @terms = splice(@all, 0, ($nterm < $max_count ? $nterm : $max_count));
    } else { # fall back to $(COMMON)/stripped
        # die "cannot read $src_file\n";
        if ($debug >= 1) {
            print "grep -P \"\^$aseqno\" $gits/OEIS-mat/common/stripped\n";
        }
        $buffer = `grep -P \"\^$aseqno\" $gits/OEIS-mat/common/stripped`;
        # 1234567890
        # A000017 ,1,0,0,2,2,4,8,4,16,12,48,80,136,420,1240,2872,7652,18104,50184,
        $buffer =~ s{\A\w+ \,}{};
        $buffer =~ s{\,\Z}{};
        my @all = split(/\,/, $buffer);
        @terms = splice(@all, 0, ($nterm < $max_count ? $nterm : $max_count));
    }
} # read_b_file
__DATA__
# test data
A079078	lsm	0	a(0) = 1, a(1) = 2; for n > 1, a(n) = prime(n)*a(n-2).	7
A079078	lsm	0	a(0) = 1, a(1) = 2; for n > 1, a(n) = prime(n)*a(n-2).	[2..5]
A079121	lsm	0	a(n+1) = floor((1/n)*(Sum_{k=1..n} a(k)^((n+1)/k))), given a(0)=1, a(1)=3, a(2)=8.	n>=3
A079271	lsm	0	a(n) = 4 * a(n-1) * (3^(2^(n-1))-a(n-1)) with a(0)=1.	2
A033333	lsm	0	a(n) = 4 * a(n-1) * (3^(2^(n-1))-a(n-1)) with a(0)=1.	1,2,3,4
A329069	lsm	0	dummy		x
A397719	nyi	0	dummy		x

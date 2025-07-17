#!perl

# @(#) $Id$ 
# 2025-07-06: with bfile if necessary, and over leading <= 1
# 2024-07-02, Georg Fischer
#
#:# Filter seq4 records and replace a range "n>=17" by the initial terms
#:# Usage:
#:#   perl getinits.pl [-p parmno] infile.seq4 > outfile.seq4
#:#       -p parameter number for the range (1..8, default = 2 = $(PARM2))
#:#       -q no quotes around the constant inits (default: with quotes)
#--------------------------------------------------------
use strict;
use integer;
use warnings;

my $gits =  $ENV{'GITS'};
my $stripped = "$gits/OEIS-mat/common/stripped";
my $bfdir    = "$gits/OEIS-mat/common/bfile";
my $iparm  = 2; # operate on this parameter
my $nok    = 0;
my $debug  = 0;
my $fatal  = 0; # no fatal error so far
my $quoted = 1; # default

while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     =  shift(@ARGV);
    } elsif ($opt  =~ m{p}) {
        $iparm     =  shift(@ARGV);
    } elsif ($opt  =~ m{q}) {
        $quoted    =  0;
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

#while (<DATA>) {
while (<>) {
    if (m{\AA\d+\t}) { # assume seq4 format
        s/\s+\Z//;
        my $line = $_;
        my ($aseqno, $callcode, @parms) = split(/\t/, "$line\t\t", -1);
        my $parm = $parms[$iparm];
        $nok = 0;
        if (0) {
        } elsif ($parm =~ m{(\d+)\Z}) {
            my $count = $1;
            $parm = get_inits($aseqno, $count);
            $parms[$iparm] = $quoted ? "\"$parm\"" : $parm;
        } elsif (length($parm) == 0) {
            $parms[$iparm] = $quoted ? "\"$parm\"" : $parm;
        }
        if ($nok eq "0") {
            print        join("\t", $aseqno, $callcode        , @parms) . "\n";
        } else {
            print STDERR join("\t", $aseqno, "$callcode\#$nok", @parms) . "\n";
        }
    } else { # no seq4
        # print;
    }
} # while
#----
sub get_inits { # 
    my ($aseqno, $count) = @_;
    my $line = `grep $aseqno $stripped`; 
    $line =~ s{\s+\Z}{}; # chompr
    # print "# from asinfo: $line";
    my ($dummy, $termlist) = split(/ /, $line);
    $termlist = substr($termlist, 1); # remove leading ","
    my @terms = split(/\,/, $termlist);
    my $term;
    my $len = scalar(@terms);
    my $ix = 0;
    while ($ix < $len && $terms[$ix] == 0) { # skip over leading abs(terms) <= 0
        $ix ++;
    }
    $count += $ix;
    if ($count >= $len) { # try to read a b-file 
        my $bfname = "$bfdir/b" . substr($aseqno, 1) . ".txt";
        if (open(BF, "<", $bfname) != 0) {  
            @terms = ();
            while (<BF>) {
               s/\s+\Z//; # chompr
               s/\#.*//;
               #          1      1   2      2
               if (m{\A\s*(\-?\d+)\s+(\-?\d+)}) {
                   ($ix, $term) = ($1, $2);
                   push(@terms, $term);
               }
               if ($ix >= $count) {
                   last;
               }
            } # while BF
            close(BF); 
            if ($ix < $count) {
                print STDERR "# b-file for $aseqno has $ix < $count terms\n";
            }
        } else {
            print STDERR "# cannot read b-file $bfname\n;"
        }
    }
    return join(",", splice(@terms, 0, $count));
} # get_inits
__DATA__
# test data
A079078	lsm	0	a(0) = 1, a(1) = 2; for n > 1, a(n) = prime(n)*a(n-2).	17
A079121	lsm	0	a(n+1) = floor((1/n)*(Sum_{k=1..n} a(k)^((n+1)/k))), given a(0)=1, a(1)=3, a(2)=8.	n>=3
A079271	lsm	0	a(n) = 4 * a(n-1) * (3^(2^(n-1))-a(n-1)) with a(0)=1.	2

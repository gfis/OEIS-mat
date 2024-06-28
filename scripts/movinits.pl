#!perl

# @(#) $Id$
# 2024-06-28, Georg Fischer
#
#:# Filter seq4 records and move initial terms from $(PARM1) to $(PARM2).
#:# Usage:
#:#   perl movinits.pl infile.seq4 > outfile.seq4
#--------------------------------------------------------
use strict;
use integer;
use warnings;

my $iparm = 1; # operate on this parameter and the next
my $asinfo = "\$GITS/OEIS-mat/common/asinfo.txt"; # print "$asinfo\n";
#while (<DATA>) {
while (<>) {
    if (m{\AA\d+\t}) { # assume seq4 format
        s/\s+\Z//;
        my $line = $_;
        my ($aseqno, $callcode, @parms) = split(/\t/, "$line\t\t", -1);
        my $parmi = $parms[$iparm];

        my %inits = ();
        # first remove any chained assignments like "a(0) = a(1) = a(2) = 1"
        #                  1  (    )  2      (       )  2 1    3      3
        while ($parmi =~ m{(a\(\d+\) *(\= *a\(\-?\d+\) *)+)\= *(\-?\d+)}) {
            my ($chain, $value) = ($1, $3);
            # print "while1 parmi=$parmi, chain=\"$chain\", value=\"$value\"\n";
            my $qchain = quotemeta($chain);
            $parmi =~ s{$qchain\= *$value}{};
            # print "while2 parmi=$parmi, chain=\"$chain\"\n";
            foreach my $ix ($chain =~ m{(\-?\d+)}g) {
                $inits{$ix} = $value;
            } # foreach $ix
        } # while chain
        # then all single assignments "a(0) = 1"
        #                    (1   1 )   =  2      23          3
        while ($parmi =~ s{a\((\d+)\) *\= *(\-?\d+)(\, *| and )?}{}) {
            my ($ix, $init) = ($1, $2);
            $inits{$ix} = $init;
        }
        # same for MMA "a[0] == 1" (no chains yet)
        #                    [1   1 ]   ==   2      23    3
        while ($parmi =~ s{a\[(\d+)\] *\=\= *(\-?\d+)(\, *)?}{}) {
            my ($ix, $init) = ($1, $2);
            $inits{$ix} = $init;
        } # while MMA

        # then check for conditions "for n > 0"
        my $cond = "";
        $parmi =~ s{\A[\.\,\;\: ]+}{};
        #               1              1  2           2
        if ($parmi =~ s{(for|given|with) +([a-z]\D+\d+) *}{}i) {
            $cond = $2;
            $cond =~ s{ }{}g;
            #          1   12         23      3
            if ($cond =~ m{([i-n])([\>\=\<]+)(\-?\d+)}) {
                my ($var, $relop, $ge) = ($1, $2, $3);
                if ($relop =~ m{\<}) { # "<" is invalid - ignore
                } elsif ($relop !~ m{\=}) { # n > 0
                    $ge ++;
                    $relop .= "=";
                }
                $cond = &get_inits($aseqno, $ge); # handle offset in sub
            }
        }
        $parmi =~ s{\band\b}       {}g;
        # print "# $aseqno parmi=\"$parmi\"\n";
        $parmi =~ s{\A[\.\,\;\: ]+}{};
        $parmi =~ s{[\,\;\:]? *(given|with|for|and|)[\.\,\;\: ]*\Z}{};
        if (0) {
        } elsif (scalar(%inits)  > 0) {
            $parms[$iparm + 1] = "\"" . join(",", map { $inits{$_} } sort(keys(%inits))) . "\"";
        } elsif ($cond ne "") {
            $parms[$iparm + 1] = "\"$cond\"";
        }
        $parms[$iparm] = $parmi;
        print join("\t", $aseqno, $callcode, @parms) . "\n";
    } else { # no seq4
        print;
    }
} # while
#----
sub get_inits { # and care for offset; (A001717, n >= 2, offset1=0)
    my ($asn, $ge) = @_;
    my $line = `grep $asn $asinfo`;
    # print "# from asinfo: $line";
    my ($aseqno, $offset1, $offset2, $termlist, @rest) = split(/\t/, $line);
    my @terms = split(/\,/, $termlist);
    $ge += $offset1;
    return join(",", splice(@terms, 0, $ge));
} # get_inits
    
my $dummy = <<'GFis';
CREATE  TABLE            asinfo
    ( aseqno    VARCHAR(10)   -- A322469
    , offset1   BIGINT        -- index of first term, cf. OEIS definition
    , offset2   BIGINT        -- sequential number of first term with abs() > 1, or 1
    , terms     VARCHAR(64)   -- first 8 terms if length <= 64
    , termno    INT           -- number of terms in DATA section
GFis
__DATA__
# test data
A079078	lsm	0	a(0) = 1, a(1) = 2; for n > 1, a(n) = prime(n)*a(n-2).
A079121	lsm	0	a(n+1) = floor((1/n)*(Sum_{k=1..n} a(k)^((n+1)/k))), given a(0)=1, a(1)=3, a(2)=8.
A079271	lsm	0	a(n) = 4 * a(n-1) * (3^(2^(n-1))-a(n-1)) with a(0)=1.
A079274	lsm	0	a(n) = A074141(n) - 2* A074141(n-1) for n > 0 and a(0) = 1
A079318	lsm	0	a(0) = 1; for n > 0, a(n) = (3^(A000120(n)-1) + 1)/2.
A079438	lsm	0	a(0) = a(1) = 1, a(n) = 2*(floor((n+1)/3) + (if n >= 14) (floor((n-10)/4) + floor((n-14)/8))).
A079438	lsm	0	a(0) = a(1) = 1, a(n) = 2*(floor((n+1)/3) + (if n >= 14) (floor((n-10)/4) + floor((n-14)/8))).
A079512	lsm	0	a(0)=1, a(1)=1; for n>1, a(n) = Sum_{i=0..n/2} binomial(n-i-1,i)*a(n-2i-1) + ((n+1) mod 2).
A079708	lsm	0	a(0)=0, a(n) = A052330(a(n-1))
A079719	lsm	0	a(n) = n + floor[sum_k{k<n}a(k)/2] for n >= 3
A080068	lsm	0	a(n) = €080067(a(n-1)). for n > 2
A080073	lsm	0	a(n)=((n-1)!*sum(i=0..n-1, (binomial(n,i)*sum(j=0..n, j!*(-1)^(j)*binomial(n,j)*stirling1(n-i-1,j)))/(n-i-1)!)), n>0
A080135	lsm	0	a(n+1) = floor( a(n)*sum(k=0..n, 1/a(k)^s) ), where s = sum(k>=0, 1/a(k)^s) and a(0)=1; s = 2.260568736857767...
A080254	lsm	0	a(0)=a(1)=1. For n>1, a(n)=1 + sum('2^r*binomial(n, r)*a(n-r)', 'r'=1..n)
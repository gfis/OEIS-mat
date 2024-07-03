#!perl

# @(#) $Id$
# 2024-06-28, Georg Fischer
#
#:# Filter records into seq4 format and move initial terms from $(PARM1) to $(PARM2).
#:# Usage:
#:#   perl movinits.pl infile.seq4 > outfile.seq4
#--------------------------------------------------------
use strict;
use integer;
use warnings;

my $iparm = 1; # operate on this parameter and the next
my $asinfo = "\$GITS/OEIS-mat/common/asinfo.txt"; # print "$asinfo\n";
my $nok = 0;
#while (<DATA>) {
while (<>) {
    #       1    1   2  2
    if (m{\A(A\d+)\s+(.*)}) { # starts with A-number
        s/\s+\Z//; # chompr
        my $line = $_;
        my ($aseqno, $callcode, @rest) = split(/\t/, $line);
        my $parm = $rest[$iparm];
        $nok = 0;
        my %inits = ();
        my $cond = "";
        if ($parm =~ m{a[\(\[]\d}) {
            # first remove any chained assignments like "a(0) = a(1) = a(2) = 1"
            #                  1  (    )  2      (       )  2 1    3      3
            while ($parm =~ m{(a\(\d+\) *(\= *a\(\-?\d+\) *)+)\= *(\-?\d+)}) {
                my ($chain, $value) = ($1, $3);
                # print "while1 parmi=$parm, chain=\"$chain\", value=\"$value\"\n";
                my $qchain = quotemeta($chain);
                $parm =~ s{$qchain\= *$value}{};
                # print "while2 parmi=$parm, chain=\"$chain\"\n";
                foreach my $ix ($chain =~ m{(\-?\d+)}g) {
                    $inits{$ix} = $value;
                } # foreach $ix
            } # while chain
            # then all single assignments "a(0) = 1"
            #                    (1   1 )   =  2      23          3
            while ($parm =~ s{a\((\d+)\) *\= *(\-?\d+)(\, *| and )?}{}) {
                my ($ix, $init) = ($1, $2);
                $inits{$ix} = $init;
            }
            # same for MMA "a[0] == 1" (no chains yet)
            #                    [1   1 ]   ==   2      23    3
            while ($parm =~ s{a\[(\d+)\] *\=\= *(\-?\d+)(\, *)?}{}) {
                my ($ix, $init) = ($1, $2);
                $inits{$ix} = $init;
            } # while MMA
            $cond = "\"" . join(",", map { $inits{$_} } sort(keys(%inits))) . "\"";
        } # if a(1)=0 ...
        # print "# $line\$parm $cond\n";  
        if ($cond eq "") {
            # then check for conditions like "for n > 0"
            #              1              1  2    2 3           3
            if ($parm =~ s{(for|given|with) +(all )?([i-n]\D+\d+)}{}i) {
                $cond = $3;
                # print "# cond2=\"$cond\", parm=\"$parm\"\n";
                $cond =~ s{ }{}g;
                #              1     12         23      3
                if ($cond =~ m{([i-n])([\>\=\<]+)(\-?\d+)}) {
                    my ($var, $relop, $count) = ($1, $2, $3);
                    if ($relop !~ m{\>}) { # "<" and "=" alone are invalid - ignore
                        $nok = "<=";
                    } elsif ($relop !~ m{\=}) { # n > 0
                        $count ++;
                        $relop .= "=";
                    }
                    $cond = "$var$relop$count"; # handle offset in sub
                }
            }
        }
        $parm =~ s{\band\b}{}g;
        # print "# $aseqno parmi=\"$parm\"\n";
        $parm =~ s{[\,\;\:]? *(given|with|for|and|)[\.\,\;\: ]*\Z}{};
        $parm =~ s{\A[ \.\,\;\:]+}{};
        if ($parm =~ m{(a\(n\) *\= *)}p) {
            $parm = ${^POSTMATCH};  # only keep formula behind "a(n) = "
        }
        # $parm =~ s{\Aa\(n\) *\= *}{}; # remove leading "a(n) = "
        $rest[$iparm + 0] = $parm;
        $rest[$iparm + 1] = $cond;
        if ($nok eq "0") {
            print        join("\t", $aseqno, $callcode        , @rest) . "\n";
        } else {
            print STDERR join("\t", $aseqno, "$callcode\#$nok", @rest) . "\n";
        }
    } else { # no seq4
        # print;
    }
} # while
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
A079708	lsm	0	a(0)=0, a(n) = A052330(a(n-1)) for n <=17
A079719	lsm	0	a(n) = n + floor[sum_k{k<n}a(k)/2] for n >= 3
A080068	lsm	0	a(n) = €080067(a(n-1)). for n > 2
A080073	lsm	0	a(n)=((n-1)!*sum(i=0..n-1, (binomial(n,i)*sum(j=0..n, j!*(-1)^(j)*binomial(n,j)*stirling1(n-i-1,j)))/(n-i-1)!)), n>0
A080135	lsm	0	a(n+1) = floor( a(n)*sum(k=0..n, 1/a(k)^s) ), where s = sum(k>=0, 1/a(k)^s) and a(0)=1; s = 2.260568736857767...
A080254	lsm	0	a(0)=a(1)=1. For n>1, a(n)=1 + sum('2^r*binomial(n, r)*a(n-r)', 'r'=1..n)
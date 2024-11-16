#!perl

# Polishing of PARI/GP program lines
# @(#) $Id$
# 2024-11-14, Georg Fischer: copied from oeisprep.pl
#
#:# Usage:
#:#   perl pariprep.pl {options} in.seq4 > out.seq4
#:#       with the following options:
#:#       -cmt: remove comments
#:#       -idv: replace integer division "\\" with "/"
#:#       -sti: move digits 1,2 in stirling calls
#:#       -sum: move the loop variable to the 3rd position
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my $debug = 0;
my $cmt = 1;
my $idv = 1;
my $mod = 1;
my $sti = 1;
my $sum = 1;

while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{\A\-d})    { 
        $debug = shift(@ARGV); 
    } elsif ($opt =~ m{\A\-all})  {
        $cmt = 1;
        $idv = 1;
        $mod = 1;
        $sti = 1;
        $sum = 1;
    } else {
        if  ($opt =~ m{\bcmt}) { $cmt = 0; }
        if  ($opt =~ m{\bidv}) { $idv = 0; }
        if  ($opt =~ m{\bmod}) { $mod = 0; }
        if  ($opt =~ m{\bsti}) { $sti = 0; }
        if  ($opt =~ m{\bsum}) { $sum = 0; }
    }
} # while $opt

#while (<DATA>) {
while (<>) {
    s/\s+\Z//; # chompr;
    my $line = $_;
    if ($debug >= 1) {
        print STDERR "# sti=$sti, line=$line\n";
    }
    my ($aseqno, $callcode, $offset, $parm1, @rest) = split(/\t/, $line);
    my $nok = 0;
    if ($mod > 0) { # must be done before space removal!
        #           1     1
        $parm1 =~ s{([ \)])mod +}                                  {$1\%}g;
    }
    $parm1 =~ s{ }{}g; # remove all spaces
    if ($idv > 0) {
        $parm1 =~ s{(\w) *\\ *(\w+)}{$1\$$2}; # "$" <- integer division without rest
    }
    if ($sti > 0) {
        while ($parm1 =~ m{stirling}p) { # modifier "p" is essential!
            my $before = ${^PREMATCH};
            $parm1 = ${^POSTMATCH};
            $parm1 =~ s{\,([12])\)}{\)};
            $parm1 = "${before}S$1$parm1";
        #   if ($debug >= 1) {
        #       print STDERR "# before=$before, parm1=$parm1\n";
        #   }
        } # while stirling
    }
    if ($sum > 0) {
        #                       1  1  2      2  3      3  4  4
        while ($parm1 =~ s{sum\((\w)\=([^\,]+)\,([^\,]+)\,(.*)}        {SU($2, $3, $1 -> $4}ig) {
        }
        #                          1      1  2      2  3  3
        while ($parm1 =~ s{sumdiv\(([^\,]+)\,([^\,]+)\,(.*)}           {SD($1, $2 -> $3}ig) {
        }
        #                        1  1  2      2  3      3  4  4
        while ($parm1 =~ s{prod\((\w)\=([^\,]+)\,([^\,]+)\,(.*)}       {PR($2, $3, $1 -> $4}ig) {
        }
        #                           1      1  2      2  3  3
        while ($parm1 =~ s{proddiv\(([^\,]+)\,([^\,]+)\,(.*)}          {PD($1, $2 -> $3}ig) {
        }
        if ($parm1 =~ m{(Sum|Prod(uct)?)_?}) {
            $nok = "sum";
        }
    }
    if ($nok ne "0") {
        print STDERR join("\t", $aseqno, "$nok=$callcode", $offset, $parm1, @rest) . "\n";
    } else {
        print        join("\t", $aseqno, $callcode,        $offset, $parm1, @rest) . "\n";
    }
} # while <>
__DATA__
A077611	lambdan	0	(n-1)!*(2*n*(n-1)-(2*n-1)*(-1)^n-1)/8
A077611	lambdan	0	4!*(A099284 - X001620 - X073742 + 1)
A077640	lambdan	0	-A188347(n)- 3
A077642	lambdan	0	Sum_{j=0..-1+10^n}abs(mu(10^n + j))
A077641	lambdan	0	Sum_{j=0..n-1}abs(mu(n+j))
A077643	lambdan	0	Sum_{j|n} abs(mu(2^n + j))
A077641	lambdan	0	Product_{j=0..n-1}abs(mu(n+j))
A077643	lambdan	0	Product_{j|n} abs(mu(2^n + j))
A077645	lambdan	0	Sum_{10^(n-1)<=p <=10^n, p prime}p 
A077645	lambdan	0	D007504(F000720(10^n))- D007504(F000720(10^(n-1)))
A077657	lambdan	0	J045984(n+1)+A077655(J045984(n+1))-n
A077691	lambdan	0	A076803(n)/n!
A077697	lambdan	0	A077696(n+1)/A077696(n)
A077699	lambdan	0	A077698(n+1)/A077698(n)

#!perl

# Preprocess general expressions from OEIS FORMULA section lines
# @(#) $Id$
# 2024-05-29, Georg Fischer: copied from expr_oeis.pl
#
#:# Usage:
#:#   perl gex_oeis.pl cat25-extract > seq4-format
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min);
my $pwd = `pwd`;
$pwd =~ m{(/OEIS\-mat\S*)};
print "# Generated by ..$1/$0 at $timestamp\n";
if (0 && scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}

my $debug = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my ($line, $aseqno, $callcode, $offset1,  $name, $orig_name, $expr, $var, $cond);
# while (<DATA>) {
while (<>) {
    next if !m{\AA\d+}; # must start with A-number
    $line = $_;
    $line =~ s/\s+\Z//; # chompr
    my $nok = 0;
    ($aseqno, $callcode, $offset1, $name) = split(/\t/, $line);
    if ($debug >= 1) {
        print "# aseqno=$aseqno, name=$name\n";
    }
    $orig_name = $name;
    if (0) { # from expr_mma.pl, insert missing "*" signs
    #   $name =~ tr{\[\]}
    #              {\(\)};
        $name =~ s{[\)\!] *\(}          {\)\*\(}g;      # ) (
        $name =~ s{[\)\!] *(\w)}        {\)\*$1}g;      # ) a
        $name =~ s{(\b\w|\!) +\(}       {$1\*\(}g;      # a (
        $name =~ s{(\b\d) *([a-z])}     {$1\*$2}g;      # 2 a
        $name =~ s{(\w|\!) +(\w)}       {$1\*$2}g;      # a b
    }
    $name =~ s{^ *a\(n\) *\= *}{}; # remove "a(n)="
    $cond = "";
    #              1                    1     2           2  3   3
    if ($name =~ s{(for|when|where|if|\,) +n *([\>\=]{1,2}) *(\d+)\.?\Z}{}) {
        my ($oper, $lim) = ($2, $3);
        if ($oper !~ m{\=}) {
            $lim ++;
        }
        $cond = "n>= $lim";
    }

    # moderate polishing
    my $loop_check = 32;
    while ($name =~ s{\|([^\|]+)\|}{abs\($1\)}) { # |...| -> abs(...)
        last if --$loop_check < 0;
    } # while abs
    $name =~ s{ for .*|(\, )?where.*}                   {}; # remove conditions
    $name =~ s{\[(From |[A-Z]+\.? [A-Z]+)([^\]]+)\]}    {}; # remove trailing "[From author] "
    $name =~ s{\. +\- \_[A-Z]\w*.*}                     {}; # remove trailing ". - _author "
    $name =~ s{\.\Z}                                    {}; # remove trailing dot
    $name =~ s{\[([^\=\<\>]+)([\=\<\>]+)([^\=\<\>]+)\]} {if\($1 $2 $3\,1\,0\)}g; # Iversion bracket: [op1 rel op2] -> if(op1 rel op2,1,0)
    $name =~ s{\) *\(}                                  {\)\*\(}g;      # ") (" -> ")*("
    #            1  12     2
    $name =~ s{(\d)([i-n])}                             {\($1\*$2}g;    # "(4n)" -> "(4*n)"
    $name =~ s{\bmod\b}                                 {\%}g; # mod -> "%"
    #          1 (       )1 $
    $name =~ s{(\([^\)]+\))\$}                          {swingingFactorial$1}g;
    $name =~ s{([i-n])\$}                               {swingingFactorial$1}g;
    $name =~ s{\bC\(|[Bb]inom(ial)?\(}                  {binomial\(}g;
#   $name =~ s{\bphi\(}                                 {eulerphi\(}g;
    $name =~ s{\bprimePi\(|prime\#\(}                   {primepi\(}ig;
    #                            1  1                   
    $name =~ s{Stirling[a-zA-Z_]*(\d)\(}                {stirling$1\(}g;
    $name =~ s{(log|sigma|tau)_?(\w+)\(}                {$1$2\(}ig;   
    #          1                                       1                    2      2
    $name =~ s{(Sumdiv|sum|product|prod|min|max|gcd|lcm)_?\{([^\}]+)\}}     {$1\($2\)}ig;
    $name =~ s{\bx\_(\d)}                               {x$1}g; # "x_i" -> "xi"

    if ($name =~ m{\A\[x\^}) { # coeffients
        $nok = "1xpow";
    }
    if ($name =~ m{[A-za-z ]{16}}) { # too much text
        $nok = "2text";
    }
    if ($name =~ m{€}) { # €-number = nyi
        $nok = "5anyi";
    }
    if ($name =~ m{\.\.\.}) { # "..." ellipsis
        $nok = "3dots";
    }
    if ($name =~ m{_}) { # underscore - special name, Integral_ etc.
        $nok = "4usco";
    }

    if ($nok eq "0") {
        print join("\t", $aseqno, "lambda", 0, "$name", $cond, $orig_name) . "\n";
    } else {
        print STDERR "# $nok: $line\n";
    }
} # while <>
#--------------------------------------------
__DATA__
A364980	lambda	0	a(n) = n! * Sum_{k=0..n} k^(n-k) * binomial(2*n-k+1,k)/( (2*n-k+1)*(n-k)! ).
A364981	lambda	0	a(n) = n! * Sum_{k=0..n} k^(n-k) * binomial(3*n-2*k+1,k)/( (3*n-2*k+1)*(n-k)! ).
A364982	lambda	0	a(n) = (n!/(2*n+1)) * Sum_{k=0..n} k^(n-k) * binomial(2*n+1,k)/(n-k)!.
A364983	lambda	0	a(n) = n! * Sum_{k=0..n} k^(n-k) * binomial(3*k+1,k)/( (3*k+1)*(n-k)! ) = n! * Sum_{k=0..n} k^(n-k) * A001764(k)/(n-k)!.
A364984	lambda	0	a(n) = n! * Sum_{k=0..n} k^(n-k) * binomial(n+2*k+1,k)/( (n+2*k+1)*(n-k)! ).
#!perl
# Extract parameters from Clark Kimberling's guides
# @(#) $Id$
# 2021-08-22, Georg Fischer
#
#:# Usage:
#:#   perl ck_guide_D.pl [-d debug] joeis_names.txt > output
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
$timestamp = sprintf ("%04d-%02d-%02d", $year + 1900, $mon + 1, $mday);
my $debug = 0;
if (0 && scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
my $asel = "0-9a-z"; # select all possible TAB codes
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{a}) {
        $asel      = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my $offset = 0;
my $asave;
my $rsave;
my $hsave;
while (<>) {
    my $line = $_;
    $line =~ s/\s+\Z//; # chompr
    my ($aseqno, $superclass, $name, @rest) = split(/\t/, $line);
    next if $name =~ m{acci constant|if n is even};
    $name =~ s{\Aa\(n\) *\= *}{};
    $name =~ s{ *\. *\Z}{};
    $name =~ s{( with|\,? *where) }{\,}g;
    $name =~ s{ and }{\,}g;
    next if $name =~ s{n mod (\d+)}{mod\(n\,$1\)}g;
    $name =~ s{\, *\[ *\] (denotes|represents) the floor function}{}g;
    $name =~ s{[\;\,] *\[ *\] *\= *floor}{}g;
    $name =~ s{\[}{floor\(}g; # [...] -> floor(...)
    $name =~ s{\]}{\)}g;
    $name =~ s{(\d)([a-zA-Z])}{$1\*$2}g;
    $name =~ s{pi}{Pi}g;
    if ($name =~ s{\, *tau *\= *golden *ratio( *\= *\(1 *\+ *sqrt\(5\)\) *\/ *2)?}{}) {
        $name =~ s{tau}{phi}g;
    }
    $name =~ s{ }{}g; # remove spaces
    $name =~ s{n([rstuvwxyz])}{n\*$1}g; # insert "*"
    if ($name =~ s{r\=golden\*ratio\,}{}) {
        $name =~ s{r}{phi}g;
    }
    $name =~ s{\;}{\,}g; # remove spaces
    if ($name =~ s{\, *x\=([^\.\,\;]+)}{}) { # special treatment of "x" - the only nested one?
        my $x = $1;
        $name =~ s{x}{$x}g;
    }
    if ($name =~ m{\An\+floor\(n}) {
        foreach my $part(split(/\,/, $name)) {
            my $cc = "floor_";
            $part =~ s{\A((\w)\=)?(.+)}{$3};
            my $code = defined($2) ? ("m" . uc($2)) : "z"; # "Z" is the highest lowercase letter and may not be a variable name
            print join("\t", $aseqno, "$cc$code", 0, "$part") . "\n";
        } # foreach
    } else {
    }
} # while
__DATA__
#--------------------------------
A190754	null	a(n)=n+[nr/u]+[ns/u]+[nt/u]+[nv/u]+[nw/u], where r=sinh(x),s=cosh(x),t=tanh(x),u=csch(x),v=sech(x),w=coth(x),x=Pi/2.	nonn,changed,synth	1..65	nyi
A189377	null	a(n) = n + floor(ns/r) + floor(nt/r) with r=2, s=(-1+sqrt(5))/2, t=(1+sqrt(5))/2.	nonn,changed,synth	1..84	nyi
A189378	null	a(n) = n + [nr/s] + [nt/s]; r=2, s=(-1+sqrt(5))/2, t=(1+sqrt(5))/2.	nonn,changed,synth	1..82	nyi
A189379	null	n+[nr/t]+[ns/t]; r=2, s=(-1+sqrt(5))/2, t=(1+sqrt(5))/2.	nonn,changed,synth	1..84	nyi
A189380	null	a(n) = n + floor(n*s/r) + floor(n*t/r); r=1, s=-1+sqrt(2), t=1+sqrt(2).	nonn,	1..10000	nyi
A189381	null	a(n) = n + [n*r/s] + [n*t/s]; r=1, s=-1+sqrt(2), t=1+sqrt(2).	nonn,	1..10000	nyi
A189382	null	a(n) = n + [n*r/t] + [n*s/t]; r=1, s=-1+sqrt(2), t=1+sqrt(2).	nonn,	1..10000	nyi


A184820 floor   n+[n/t]+[n/t^2];tisthetribonaccicon*stan*t.
A184821 floor   n+[n*t]+[n/t];tisthetribonaccicon*stan*t.
A184822 floor   n+[n*t]+[n*t^2];tisthetribonaccicon*stan*t.
A184823 floor   n+[n/t]+[n/t^2]+[n/t^3];tisthetetranaccicon*stan*t.
A184824 floor   n+[n*t]+[n/t]+[n/t^2];tisthetetranaccicon*stan*t.
A184825 floor   n+[n*t]+[n*t^2]+[n/t];tisthetetranaccicon*stan*t.
A184826 floor   n+[n*t]+[n*t^2]+[n*t^3];tisthetetranaccicon*stan*t.
A184835 floor   n+[n/t]+[n/t^2]+[n/t^3]+[n/t^4];tisthepen*tanaccicon*stan*t.
A184836 floor   n+[n*t]+[n/t]+[n/t^2]+[n/t^3];tisthepen*tanaccicon*stan*t.
A184837 floor   n+[n*t]+[n*t^2]+[n/t]+[n/t^2];tisthepen*tanaccicon*stan*t.
A184838 floor   n+[n*t]+[n*t^2]+[n*t^3]+[n/t];tisthepen*tanaccicon*stan*t.
A184839 floor   n+[n*t]+[n*t^2]+[n*t^3]+[n*t^4];tisthepen*tanaccicon*stan*t.
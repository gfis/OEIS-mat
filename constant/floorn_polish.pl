#!perl

# Polish formulae for floor|ceil|roudn|frac
# @(#) $Id$
# 2021-08-29, Georg Fischer
#
#:# Usage: (cf. makefile)
#:#   perl floorn.pl [-d debug] input > output
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
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my $offset = 0;
my ($aseqno, $superclass, $name, @rest);
my $nok; # assume ok
# while (<DATA>) {
while (<>) {
    $nok = 0;
    my $line = $_;
    $line =~ s/\s+\Z//; # chompr
    next if ! m{\AA\d+};
    ($aseqno, $superclass, $name, @rest) = split(/\t/, $line);
    my $orig_name = $name;
    $name =~ s{[\;\:]}{\,}g; # normalize to ","
    $name =~ s{[\(\,]?complementofA\d+.*}{};
    $name =~ s{ceiling}{ceil}ig;
    $name =~ s{(ceil|floor|round|frac)}{lc($1)}ieg;
    $name =~ s{\,\[\.?\](\=|denotes|is|represents)(the)?floor(function)?}{}; # remove explanation
    $name =~ s{\,(\{\.?\}|frac)denotesthefract\w*}{}; # remove explanation
    $name =~ s{\,\{\.?\}\=frac\w*}{}; # remove explanation
    $name =~ s{\(thegoldenratio\.?\)?|isthegoldenratio}{}i; # remove expanation
    $name =~ s{\=goldenratio}{\=phi}g; # normalize to "phi"
    $name =~ s{pi}{Pi}g; # for Maple
    $name =~ s{gamma\(}{GAMMA\(}ig; # for Maple
    $name =~ s{cuberootof(\d)}{$1\^\(1\/3\)}g;
    $name =~ s{\(1\+sqrt\(5\)\)\/2}{phi}g;
    $name =~ s{\|}{abs\(}; # no! global
    $name =~ s{\|}{\)};
    $name =~ s{floor\[([^\]]*)\]}{floor\($1\)}g; # floor[ ] -> floor( )
    $name =~ s{\*forx=}{\,x\=}g;
    $name =~ s{n(cot|csc)\(}{n\*$1\(}g; # insert "*"
    if ($name =~ s{\,fcomputesthefractionalpart}{}) {
        $name =~ s{f\(}{frac\(}g;
    }
    $name =~ s{cotangent}{cot}g;
    $name =~ s{tau}{phi}g;
    $name =~ s{phi\=phi}{phi}g;
    $name =~ s{\,phi\Z}{}g;
    $name =~ s{\[}{floor\(}g;
    $name =~ s{\]}{\)}g;
    $name =~ s{\{}{frac\(}g;
    $name =~ s{\}}{\)}g;
    $name =~ s{phi\^\-1}{\(1/phi\)}g;

    $name =~ s{(sin|cos|tan|cot|sec|csc)n\)}{$1\(n\)\)}g;
    $name =~ s{0?\.5}{1\/2}g;
    $name =~ s{(\W)E(\W)}{${1}e$2}g;
    $name =~ s{\)([a-z])}{\)\*$1}g; # insert "*" behind ")"
    $name =~ s{(\d)([a-z])}{$1\*$2}g; # insert "*" behind digit
    $name =~ s{\)\(}{\)\*\(}g; # ")*(" 
    $name =~ s{(\W)([eknrstu])([a-z])(\W)}{$1$2\*$3$4}g; # nr -> n*r
    $name =~ s{(\W)(n)\*([a-z])(\W)}{$1$3\*$2$4}g; # n*r -> r*n
    $name =~ s{\(\-}{\(0\-}g; 
    $name =~ s{\A\-}{0\-};
    if ($name =~ s{\,([a-z])\=phi\Z}{}) {
        my $var = $1;
        $name =~ s{(\W)$var(\W)}{${1}phi$2}g;
    }
    
    if ($nok > 0) { # already set
    } elsif ($name =~ m{A\d\d\d+}) {
        $nok = 1; # A-number
    } elsif ($name =~ m{acciconstant}) {
        $nok = 2;
    } elsif ($name =~ m{(\W)[abcxyA-Z]\(}) {
        $nok = 3;
    } elsif ($name =~ m{(floors?|ceil)of}) {
        $nok = 4;
    } elsif ($name =~ m{H_n}) {
        $nok = 5;
    } elsif ($name =~ m{(fraction|sigma|omega|phi\(n\)|isodd|Bell)}i) {
        $nok = 6;
    } elsif ($name =~ m{solution|L\=}) {
        $nok = 7;
    } elsif ($name =~ m{\w{7}}) {
        $nok = 8;
    } elsif ($name =~ m{with}) {
        $nok = 9;
    } elsif (($name =~ m{\=}) && ($name !~ m{\,})) {
        $nok = 10;
    }
    &check_parentheses();
    if ($nok == 0) {
        print join("\t", $aseqno, "floor", 0, $name) . "\n";
    } else { 
        print STDERR join("\t", $aseqno, "nok=$nok", $name) . "\n";
    }
} # while
#----
sub check_parentheses {
    my $expr = $name;
    $expr =~ s{[^\(\)]}{}g;
    my $len = length($expr);
    my $leo = $len + 1;
    while ($len < $leo) {
        $expr =~ s{\(\)}{}g;
        $leo = $len;
        $len = length($expr);
    }
    if ($len > 0) {
        $superclass = "$expr";
    }
}
#----
sub insert_mul {
    my ($name) = @_;
    $name =~ s{(\W)([a-z])([a-z])(\W)}{$1$2\*$3$4}g; # \W = non-word char.
    $name =~ s{([\)\]])([a-z])(\W)}   {$1\*$2$3}g; 
    $name =~ s{(\W)([a-z])([\[\(])}   {$1$2\*$3}g; 
    return $name;
} # insert_mul
__DATA__
A184929	null	n+[rn/s]+[tn/s]+[un/s],[]=floor,r=sin(Pi/2),s=sin(Pi/3),t=sin(Pi/4),u=sin(Pi/5)
A184930	null	n+[rn/t]+[sn/t]+[un/t],[]=floor,r=sin(Pi/2),s=sin(Pi/3),t=sin(Pi/4),u=sin(Pi/5)
A184931	null	n+[rn/u]+[sn/u]+[tn/u],[]=floor,r=sin(Pi/2),s=sin(Pi/3),t=sin(Pi/4),u=sin(Pi/5)
A185546	null	floor((1/2)*(n+1)^(3/2));complementofA185547
A185548	null	floor(floor(n^(5/2))^(2/3))
A185549	null	ceil(n^(3/2));complementofA185550
A185592	null	floor(n^(3/2))*floor(1+n^(3/2))*floor(2+n^(3/2))/6
A185593	null	floor(n^(3/2))*floor(3+n^(3/2))/2

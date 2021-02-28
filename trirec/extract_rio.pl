#!perl

# Extract a bivariate g.f. from "Riordan array" notation 
# @(#) $Id$
# 2021-02-20: pseudo-type "r"
# 2019-07-05: more parentheses
# 2019-06-07, Georg Fischer
#
#:# Usage:
#:#   perl extract_rio.pl [-d debug] cat25.txt > outfile
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
$timestamp = sprintf ("%04d-%02d-%02d", $year + 1900, $mon + 1, $mday);

my $debug = 0;
if (scalar(@ARGV) == 0) {
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

my $line;
my $aseqno;
my $oseqno   = ""; # old $aseqno
my $offset1  = "";
my $rio      = "";
my $code;
my $oper     = "";
my $content;
my @dens;
while (<>) {
    $line = $_;
    $line =~ s/\s+\Z//; # chompr
    $line =~ m{^\%(\w) (A\d+)\s+(.*)};
    $code    = $1 || "";
    $aseqno  = $2 || "";
    $content = $3 || "";
    if (0) {
    } elsif ($code eq "O") { # OFFSET
        $content =~ m{(\-?\d+)(\,\d*)?};
        $offset1 = $1 || "0";
        if ($oper ne "") {
            if ($oper eq "rioarr") {
                $rio =~ s{[a-z]}{x}g;
                my ($g, $f) = split(/\#/, $rio);
                if (defined($f)) {
                    $rio = "($g)/(1-y*($f))";
                } else {
                    $oper = "?undef";
                }
            }
            print join("\t", $aseqno, $oper, $offset1, $rio) . "\n";
            $oseqno = $aseqno; 
            $oper = "";
        }
    } elsif ( ($code =~ m{[FNC]}) # FORMULA, NAME, COMMENT
              and 
              ($content =~ m{[Rr]iordan\s*[Aa]rray[\s\:]*(\([\w\s\+\-\^\,\;\(\)\[\]\*\/]+)}) 
            ) {
        # print "$line\n";
        $rio = $1;
        if ($aseqno ne $oseqno) { # only the first in the sequence
            $rio =~ s{\s}{}g;
            $rio =~ s{\,}{\#};
            $rio =~ s{[\,\;].*}{};
            $rio =~ s{\)[\(a-z][a-z].*}{\)};
            $rio = lc($rio);
            $oper = "rioarr";
            $oper = "?aseqno" if $rio =~ m{a\d{6}};
            $oper = "?stdf"   if $rio =~ m{[a-z][a-z]+};
            $oper = "?funct"  if $rio =~ m{[a-z]\([a-z]\)};
            $oper = "?letai"  if $rio =~ m{[a-i]};
        }   
    } elsif ( ($code =~ m{r}) ) {
            $offset1 = 0;
            $rio = $content;
            $rio =~ s{\s}{}g;
            $rio =~ s{\,}{\#};
            $rio =~ s{[\,\;].*}{};
            $rio =~ s{\)[\(a-z][a-z].*}{\)};
            $rio = lc($rio);
            $oper = "rioarr";
            $oper = "?aseqno" if $rio =~ m{a\d{6}};
            $oper = "?stdf"   if $rio =~ m{[a-z][a-z]+};
            $oper = "?funct"  if $rio =~ m{[a-z]\([a-z]\)};
            $oper = "?letai"  if $rio =~ m{[a-i]};
        if ($oper ne "") {
            if ($oper eq "rioarr") {
                $rio =~ s{[a-z]}{x}g;
                my ($g, $f) = split(/\#/, $rio);
                if (defined($f)) {
                    $rio = "($g)/(1-y*($f))";
                } else {
                    $oper = "?undef";
                }
            }
            print join("\t", $aseqno, $oper, $offset1, $rio) . "\n";
        }   
    } else {
        # ignore
    }
} # while <>
#--------------------------------------------
__DATA__
%C A146080 Row sums of Riordan array (1,x(1-10x)).
%C A146083 Row sums of Riordan array (1,x(1-11x)).
%C A146084 Row sums of Riordan array (1,x(1-12x)).
%N A146314 Inverse of Riordan array A127543.
%C A146314 Riordan array (1/(1-x), x*(1-2*x)/(1-x)^2). - _Philippe Deléham_, Jan 27 2014
%N A147308 Riordan array [sech(x), arcsin(tanh(x))].
%N A147309 Riordan array [sec(x), log(sec(x) + tan(x))].
%N A147311 Riordan array [1, arcsin(tanh(x))].
%N A147312 Riordan array [1,log(sec(x)+tan(x))].
%F A147703 Riordan array ((1-2x)/(1-3x+x^2), x(1-x)/(1-3x+x^2)).
%N A147704 Diagonal sums of Riordan array ((1-2x)/(1 - 3x + x^2),x(1-x)/(1 - 3x + x^2)).
%N A147720 Riordan array (1, x(1-x)/(1-3x)).
%F A147721 Riordan array ((1-3x)/(1-4x+x^2), x(1-x)/(1-4x+x^2)).
%N A147722 Row sums of Riordan array ((1-3x)/(1-4x+x^2), x(1-x)/(1-4x+x^2)).

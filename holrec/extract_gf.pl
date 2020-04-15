#!perl

# Grep generating functions of type (o)rdinary or (e)xponential for JoeisPreparer 
# @(#) $Id$
# 2020-04-08, Georg Fischer: copied from holrec/extract_hosqrt.pl
#
#:# Usage:
#:#   perl extract_homgf.pl [-m (extr|linr|eval)] $(COMMON)/cat25.txt > homgf1.tmp
#:#       -m selection of functions
#-----------------------------------------------------------------------------
use strict;
use integer;
use warnings;
use POSIX;

my $version = "V1.1";
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);
my $timestamp = sprintf("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
my @parts = split(/\s+/, asctime(localtime(time)));  #  "Fri Jun  2 18:22:13 2000\n\0"
#                                             0   1    2 3        4
my $sigtime = sprintf("%s %02d %04d", $parts[1], $parts[2], $parts[4]);
#----
my $mode = "extr"; # default
my $pow  = 2; # ^(-1/2) is allowed
my $pat  = ",trig,elem,sqrt,"; 
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{m}) {
        $mode = shift(@ARGV);
    } elsif ($opt  =~ m{pat}) {
        $pat = "," . shift(@ARGV) . ","; # comma separated function names
    } elsif ($opt  =~ m{pow}) {
        $pow = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
if (1) {
        my @trig = qw(sin cos tan cot sec csc);
        $pat =~ s{\,trig}{"," . join(",", @trig)}e;
        $pat .= "," . join("h,", @trig) . "h,arc" . join(",arc", @trig);
        $pat =~ s{\,elem}{\,exp\,log\,besseli\,besselj\,catalan};
}
print STDERR "# extract_gf.pat=\"$pat\"\n";

#----
my $line;
my $aseqno;
my $oseqno = ""; # old aseqno
my $ano = 0; # current number of g.f. in this $aseqno
my $expr;
my $rest;
my $gftype; # "egf" if e.g.f, "ogf" otherwise
my $callcode = "homgf";
my $offset   = 0;
my $ok = 1;
my %letters = ();
my $letter;
if (0) {
} elsif ($mode =~ m{^extr}) {
    while(<>) {
        $line   = $_;
        if ($line =~ m{Conjecture|Empirical|Apparant|Appears}i) {
            # ignore
        #                              1        2                 3                              4                    5         6 
        } elsif ($line =~ m{\A\%[NF]\s+(A\d+)\s+(Expansion of\s*)?([EO]\.)?[Gg]\.f\.\s*[\:\=]?\s*(A\([a-z]\)\s*\=\s*)?([^\.\;]+)(.*)}i) { 
            $expr   = " $5";
            $rest   = $6;
            $aseqno = $1;
            $gftype = substr(lc($3 || "o"), 0, 1) . "gf";
            if ($rest !~ m{\A\.\.\.}) {
                if ($aseqno eq $oseqno) {
                    $ano ++;
                } else {
                    $oseqno = $aseqno;
                    $ano = 0;
                } 
                $expr   =~ s{\-\s*[a-zA-Z\ _\.\,]+(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) \d\d \d\d\d\d}{}; # remove - a.b. author, Apr 13 2020
                $expr   =~ s{(\W|\A)c\(}{$1 . "Catalan("}eig;
                $expr   =~ s{(with|where|\-\s*\_|\[From).*}{};
                $expr   =~ s{Bessel_([A-Z])}{Bessel$1}g;
                $expr   =~ s{\A\s+}{};
                $expr   =~ s{\s+\Z}{};
                $expr   =~ s{\,\Z}{};
                $callcode = "homgf" . substr($gftype, 0, 1) . $ano;
                &output();
            } # rest not "..."
        } # if %NF line
    } # while <>
    # mode extract

} elsif ($mode =~ m{^linr}) {
    while(<>) {
        s{\s+\Z}{}; # chompr
        $line   = $_;
        ($aseqno, $callcode, $offset, $expr, $gftype) = split(/\t/, $line);
        $expr =~ s{\s}{}g;
        if ($expr =~ m{\A([0-9t-z\+\-\/\*\^\(\)])+\Z}) { # ( + - * / ) t u v w x y z
            if ($expr !~ m{[a-z][a-z]}) { # single letters only
                %letters = ();
                foreach $letter ($expr =~ m{([a-z])}g) { # collect the different ones
                    $letters{$letter} = 1;
                } # foreach
                if (scalar(%letters) == 1) {
                    if ($expr !~ m{\^\D}) { # a natural number power
                                $expr =~ s{[a-z]}{x}g; # unify to x
                                $callcode = "lingf" . substr($gftype, 0, 1);
                                &output();
                    } else {
                        print "#2.^nok "; &output();
                    }
                } else {
                    # print "#3.2d "; &output();
                }
            } else {
                # print "#4.func "; &output();
            }
        } else {
            # print "#1 "; &output();
        }
    } # while <>
    # mode linrec
    
} elsif ($mode =~ m{^eval}) {
    while(<>) {
        s{\s+\Z}{}; # chompr
        $line   = $_;
        ($aseqno, $callcode, $offset, $expr, $gftype) = split(/\t/, $line);
        $expr =~ s{\s}{}g;
        $ok = 1;
        if ($expr =~ m{A\d{6}}) { # Aseqno
            $ok = 0;
        }
        $expr = lc($expr);
        if ($ok < 1) {
            # ignore
        } elsif ($pow eq 0 and ($expr =~ m{\^\D})) {
            $ok = 0;
        } elsif ($pow eq 1 and ($expr =~ m{\^\([\-\d]*[^\-\d]})) {
            $ok = 0;
        } elsif ($pow eq 2 and ($expr =~ m{\^\([\-\+\/\d]*[^\-\+\/\d]})) {
            $ok = 0;
        }
        if ($ok > 0) {
            %letters = ();
            foreach my $word ($expr =~ m{([a-z]+)}g) { # examine all words
                if (0) {
                } elsif (length($word) == 1) {
                    $letters{$word} = 1;
                } elsif ($pat =~ m{\,$word\,}) { 
                    # allowed word
                } else {
                    $ok = 0;
                }
            } # foreach
            if ($ok > 0 and scalar(%letters) == 1) {
                $expr =~ s{(\W|\A)[a-z](\W|\Z)}{${1}x$2}g; # unify to x
                if ($expr =~ m{(\W|\A)x\(0\)}) {
                    $ok =0;
                } else {
                    &output();
                }
            } else {
                # print "#4.func "; &output();
            }
        } else {
            # print "#1 "; &output();
        }
    } # while <>
    # mode eval
  
    
} else {
    die "invalid mode \"$mode\"\n";
} # mode
#---------
sub output {
    $expr =~ s{(arc?(sin|cos|tan|cot)h?)\^2\*x}{$1\(x\)\^2}g; # care for sin^2(x)
    $expr =~ tr{\[\]\{\}}
               {\(\)\(\)}; # equalize brackets
    print join("\t", $aseqno, $callcode, 0, "$expr", $gftype) . "\n";
} # output
__DATA__

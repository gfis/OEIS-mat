#!perl

# Prepare PAIR formulas for postfix generation
# Superceedes expr_pari.pl
# @(#) $Id$
# 2023-08-22, Georg Fischer
#
#:# Usage:
#:#   perl form_pari.pl input.seq4 > output.seq4
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

my %zops = 
  ( "+", ".add("
  , "-", ".subtract("
  , "*", ".multiply("
  , "/", ".divide("
  );
my %znames = (0, "Z.ZERO", 1, "Z.ONE", 2, "Z.TWO"  , 3, "Z.THREE", 4, "Z.FOUR"
             ,5, "Z.FIVE", 6, "Z.SIX", 7, "Z.SEVEN", 8, "Z.EIGHT", 9, "Z.NINE", 10, "Z.TEN", -1
             , "Z.NEG_ONE");
my ($aseqno, $callcode, $offset1, $name, $form, $prefix, $nok);
my ($expr, $list);
my @parms;
$callcode = "lambda";
my $max_ivar = 0; # maximum of $ivar below
my $ivar; # generate variable names V{ivar}_
$offset1 = 0;
my $line;
my %functions = qw(
abs                    1
bell                   1
bigomega               1
binomial               1
bitand                 1
bitxor                 1
core                   1
eulerphi               1
fibonacci              1
floor                  1
gcd                    1
gpf                    1
hammingweight          1
if                     1
kronecker              1
lcm                    1
log                    1
logint                 1
lpf                    1
max                    1
min                    1
mod                    1
moebius                1
numdiv                 1
omega                  1
prime                  1
primepi                1
prod                   1
rad                    1
sigma                  1
sign                   1
sqrtint                1
sqrtn                  1
sqrtnint               1
stirling               1
sum                    1
sumdiv                 1
valuation              1
Mod                    1
Stirling               1
Stirling2              1
);

while (<>) {
    $line = $_;
    if ($debug >= 3) {
        print "# line=$line";
    }
    $line =~ s/\s+\Z//; # chompr
    $nok = "";
    ($aseqno, $callcode, $offset1, $name) = split(/\t/, $line);
    if ($debug >= 1) {
        print "# aseqno=$aseqno, name=$name\n";
    }
    $name =~ s{\(PARI[^\)]*\) *}{}; # e.g. "A248705 (PARI: For b-file)"
    $name =~ s/[\{\}]//g; # remove any  "{" ... "}"
    $name =~ s{\A +}{}; # remove leading spaces
    my $left = "";
    #              1        1           2  2
    if ($name =~ m{(A\d{6}|a)\(n\) *\= *(.*)}i) {
        ($left, $form) = ($1, $2);
        if (uc($left) eq $aseqno || $left eq "a") {
           $form =~ s/[ \{\}]//g;  # spaces and "{ }"
           $form =~ s/\;.*//;      # end of statement
           $form =~ s/\\\\.*//;    # end-of-line comment with "\\" at the end
        #  $name =~ s/\\\\.*//;    # same with original line
           $form =~ s/\/\*.*//;    # C-style comment with "/*" - ignore the rest
        #  $name =~ s/\/\*.*//;    # same with original line
           # $form =~ s/\\\\/\//g;     # "\" -> "/", integer division
           if ($debug >= 2) {
               print "# aseqno=$aseqno, form=$form\n";
           }
        } else {
           $nok = "3/noleft";
        }
    } else {
        $nok = "4/noass";
    }
    if ($nok eq "") {
        foreach my $word ($form =~ m{([a-zA-Z]\w*\()}g) {
            $word =~ s{\(\Z}{};
            if (! defined($functions{$word})) {
                $nok = "2/$word";
            }
        } # foreach word
    }
    if ($nok eq "") {
        if ($form =~ m{\[}) {
            $nok = "5/squabr";
        }
    }
    if ($nok eq "") {
        print        join("\t", $aseqno, $callcode, 0, $form, $name) . "\n";
    } else {
        print STDERR join("\t", $aseqno, $callcode, 0, $name, $nok) . "\n";
    }
} # while <>

#--------------------------------------------
__DATA__
A357394 a(n)=sum(k=1,n,(2*n)^(k-1)*stirling(n,k,2))
A357334 a(n)=sum(k=1,n,(3*k)^(k-1)*abs(stirling(n,k,1)))
A357338 a(n)=sum(k=1,n,(3*k)^(k-1)*stirling(n,k,1))

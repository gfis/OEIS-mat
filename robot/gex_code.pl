#!perl

# Generate target Java code (for jOEIS) from general expressions 
# @(#) $Id$
# 2024-05-30, Georg Fischer: copied from gex_parse.pl
#
#:# Usage:
#:#   perl gex_parse.pl ... \
#:#   | perl gex_code.pl [-l {oeis|java}] > seq4-format 2> rest
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
my $lang = "java"; # target language; also: "OEIS"; maybe "PARI" ??
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{l}) {
        $lang      = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my ($line, $aseqno, $callcode, $offset1, $name, @rest);
my @list;
my %hash; # map placeholder -> text
my $nok;
# while (<DATA>) {
while (<>) {
    next if !m{\AA\d+}; # must start with A-number
    $line = $_;
    $line =~ s/\s+\Z//; # chompr
    $nok = 0;
    ($aseqno, $callcode, $offset1, $name, @rest) = split(/\t/, $line);
    if ($debug >= 2) {
        print "#----------------\n# $line\n";
    }
    my @list = split(/\;/, $name);
    %hash = ();
    my ($placeholder, $text);
    for (my $ilist = 0; $ilist < scalar(@list); $ilist ++) { # for random access to placeholders
        ($placeholder, $text) = split(/\=/, $list[$ilist], 2);
        $hash{$placeholder} = $text;
    } # for $ilist
    my $expression = $placeholder; # start with the last list element
    my $ilist = scalar(@list); 
    while ($nok eq 0 && $ilist > 0) {
        $ilist --; # process from the end
        ($placeholder, $text) = split(/\=/, $list[$ilist], 2);
        if (0) {
        } elsif ($lang =~ m{oeis}i) {
            $text = &translate_oeis($placeholder, $text);
        } elsif ($lang =~ m{java}i) {
            $text = &translate_java($placeholder, $text);
        } else {
            die "# invalid target language $lang\n";
        }
        $expression =~ s{$placeholder}{$text}g;
    } # main substitution loop

#   if ($name =~ m{\A_[CQZij]\d+\Z}) { # all substituted
#   } else { # some unparsed rest remained
#       $nok = "2npar";
#   }

    if ($nok eq "0") {
        print        join("\t", $aseqno, "lambda"     , 0, "$expression", join(";", @list), @rest) . "\n";
    } else {
        print STDERR join("\t", $aseqno, "#not=$nok"  , 0, "$expression", $name,            @rest) . "\n";
    }
} # while <>
#----
sub translate_java {
    my ($placeholder, $text) = @_;
    my $type = substr($placeholder, 1, 1); # 2nd character
    my $code = substr($placeholder, 2, 1); # 3rd character
    if (0) {
    } elsif ($code eq "A") { # addition, list of summands
        $text =~ s{\,}  {\.\+\(};
        $text =~ s{\,}{\)\.\+\(}g;
        $text .= ")";
    } elsif ($code eq "B") { # brackets
        $text = "($text)";
    } elsif ($code eq "C") { # call
        $text =~ s{\,}{\(};
        $text = "$text)";
    } elsif ($code eq "D") { # division
        $text =~ s{\,}  {\.\/\(};
        $text =~ s{\,}{\)\.\/\(}g;
        $text .= ")";
    } elsif ($code eq "E") { # exponentiation
        $text =~ s{\,}  {\.\^\(};
        $text =~ s{\,}{\)\.\^\(}g;
        $text .= ")";
    } elsif ($code eq "F") { # Factorial
        my ($parm1, $parm2) = split(/\,/, $text, 2);
        $parm1 = &declose($parm1);
        $text = ($parm2 == 1) ? "FA($parm1)" : "Functions.MULTIFACTORIAL($parm2, $parm1)";
    } elsif ($code eq "M") { # multiplication
        $text =~ s{\,}  {\.\*\(};
        $text =~ s{\,}{\)\.\*\(}g;
        $text .= ")";
    } elsif ($code eq "N") { # negation
        $nok = "3un=$code";
        $text = "(-$text)";
    } else {
        # $nok = "3un=$code";
    }
    return $text;
} # translate_java
#----
sub translate_oeis {
    my ($placeholder, $text) = @_;
    my $type = substr($placeholder, 1, 1); # 2nd character
    my $code = substr($placeholder, 2, 1); # 3rd character
    if (0) {
    } elsif ($code eq "A") { # addition, list of summands
        $text =~ s{\,}{\+}g;
    } elsif ($code eq "B") { # brackets
        $text = "($text)";
    } elsif ($code eq "C") { # call
        $text =~ s{\,}{\(};
        $text = "$text)";
    } elsif ($code eq "D") { # division
        $text =~ s{\,}{\/}g;
    } elsif ($code eq "E") { # exponentiation
        $text =~ s{\,}{\^}g;
    } elsif ($code eq "F") { # Factorial
        my ($parm1, $parm2) = split(/\,/, $text, 2);
        $text = $parm1 . ("!" x $parm2);
    } elsif ($code eq "M") { # multiplication
        $text =~ s{\,}{\*}g;
    } elsif ($code eq "N") { # negation
        $nok = "3un=$code";
        $text = "(-$text)";
    } else {
        # $nok = "3un=$code";
    }
    return $text;
} # translate_oeis
#----
sub declose { # remove the outermost level of brackets
    my ($text) = @_;
    if ($text =~ m{\A\_B\d+\Z}) { # (B)racket
        $text = $hash{$text};
        $text =~ s{\A\(}{};
        $text =~ s{\)\Z}{};
    }
    return $text;
} # declose
#--------------------------------------------
__DATA__
A000679 lambda  0   _E0=2^n;_C1=A000001(_E0)    \\  a(n) = A000001(2^n). - _Amiram Eldar_, Mar 10 2024
A007117 lambda  0   _C0=A093179(n);_A1=_C0-1;_A2=n+2;_B3=(_A1);_B4=(_A2);_E5=2^_B4;_D6=_B3/_E5  \\  a(n) = (A093179(n) - 1)/2^(n+2) for n >= 2. - _Jianing Song_, Mar 02 2021
A007894 lambda  0   _C0=sigma9(n);_E1=n^8;_D2=809/2612138803200;_A3=_C0+O;_C4=A3(_E1);_B5=(_D2);_M6=_B5*__C4    \\  a(n) = (809/2612138803200)*sigma_9(n) + O(n^8) where sigma_9(n) is the ninth divisor power sum, cf. A013957. - _Philip Engel_, Nov 29 2017
A049288 lambda  0   _C0=A002086(n)  \\  a(n) = A002086(n) for squarefree 2n-1. - _Andrew Howroyd_, Apr 28 2017

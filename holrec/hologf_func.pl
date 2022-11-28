#!perl

# Extract reasonable functions from hologf1.tmp
# @(#) $Id$
# 2022-11-09, Georg Fischer
#
#:# Usage:
#:#   cat hologf1.tmp \
#:#   perl hologf_funct.pl > output
#-----------------------------------------------------------------------------
use strict;
use integer;
use warnings;

#----
my $debug = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
#----
my $line;
my $aseqno;
my $gf;
my @rest;
my $callcode = "homgf";
my $offset = 0;

my %words = qw(
  Catlan  func
  p       var
  q       var
  r       var
  s       var
  t       var
  u       var
  v       var
  w       var
  x       var
  y       var
  z       var
  sqrt    func
  sin     func
  cos     func
  sinh    func
  cosh    func
  arcsin  func
  arccos  func
  );

while(<>) {
    s{\s+\Z}{}; # chompr
    $line = $_;
    my ($aseqno, $callcode, $offset, $gf, @rest) = split(/\t/, $line);
    $gf =~ s{\=.*}{}; # keep first equation only
    my @os = $gf =~ m{(\()}g; 
    my @cs = $gf =~ m{(\))}g;
    my $openbr = scalar(@os);
    my $closbr = scalar(@cs);
    my $nok = ($openbr == $closbr) ? "" : "$openbr(<>$closbr)"; # number of "(" and ")" differs
    if (length($gf) == 0) {
        $nok = "empty";
    }
    my %varns = (); # no variables so far
    my $varn = "";
    if ($debug >= 1) {
      print "# $aseqno openbr=$openbr, closbr=$closbr, invalid=$nok, gf=$gf\n";
    }
    if ($nok eq "") { # matching brackets
        my $list = $gf;
        $list =~ s{[^A-Za-z]}{ }g; # why ??? m{  i
        foreach my $name ($list =~ m{(\w+)}g) { # check validity
            if (! defined($words{$name})) {
                $nok = $name;
            }
            if (defined($words{$name}) && ($words{$name} eq "var")) {
                $varn = $name;
                if (defined($varns{$name})) {
                    $varns{$name} ++;
                } else {
                    $varns{$name} = 1;
                }
            }
        }
        $gf = &polish($gf);
        $gf =~ s{ }{}g;
        my $varcount = scalar(keys(%varns));
        if (0) {
        } elsif ($varcount == 1) { # one unique variable name
            # ok
        } elsif ($varcount >  1) { # at least 2 variable names
            $nok = join("/", sort(keys(%varns)));
        }
    } # matching brackets
    if ($nok eq "") {
      print        join("\t", $aseqno, $callcode, $varn, "$gf", @rest) . "\n";
    } else {
      print STDERR join("\t", $aseqno, $nok     , $varn, "$gf", @rest) . "\n";
    }
} # while <>
#----
sub polish {
    my ($gf) = @_;
    $gf =~ s{ }{}g;
    $gf =~ s{(\d|\))([A-Za-z])}{$1\*$2}g; # 17x -> 17*x, )x -> )*x
    $gf =~ s{(\d|\))\(}        {$1\*\(}g; # )( -> )*(, 4( -> 4*(
    $gf =~ s{\b([p-z])\(}      {$1\*\(}g; # x( -> x*(
    return $gf;
}
__DATA__
A305098	homgfo0	0	1 / (1 + t*x - 2t^2)	ogf
A305185	homgfo0	0	(x^2*(1 + x^2)*(1 + 2*x - x^3 + x^4))/((1 - x)^3*(1 + x + x^2)^2) (End)	ogf

#!perl

# Generate a seq4 record with CC=poly* from the parameters and append it to today's aman/date.man file
# @(#) $Id$
# 2025-06-03, Georg Fischer
#
#:# Usage:
#:#   perl poly_seq4.pl $1 $2 ...
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d", $year + 1900, $mon + 1, $mday);
my $gits =  $ENV{'GITS'};
my $lite_aman =  "$gits/joeis-lite/internal/fischer/aman";
$lite_aman =~ s{\\}{\/}g;

my $cc = "poly";
my $polys   = shift(@ARGV);
my $polys_org = $polys;
my $postfix = shift(@ARGV); 
my $options = join(" ", @ARGV);
my $offset  = 0;
my $dist    = "";
my $gftype  = "";
my $seqs    = "";
while (scalar(@ARGV) > 0) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{-i}) {
        $dist   = shift(@ARGV);
    } elsif ($opt =~ m{-o}) {
        $offset = shift(@ARGV);
    } elsif ($opt =~ m{-t}) {
        $gftype = shift(@ARGV);
    } else { # ignore -n
        shift(@ARGV);
    }
}
if ($dist ne "") {
    if ($gftype eq "") {
        $gftype = "0";
    }
    $cc =~ s{poly\Z}{polyx};
}
if ($gftype ne "") {
    if ($dist eq "") {
        $dist = "0";
    }
    $cc =~ s{poly\Z}{polyx};
}
my @alist = ();
if ($polys =~ s{((\, *A\d{6}\!?)+)}{}) { # move the A-numbers to instances at the end
    my $list = substr($1, 1);  
    if (1 or $list !~ m{\!}) { # always
        my @anos = split(/\, */, $list);
        $cc =~ s{a?\Z}{a};
        @alist = join(", ", map {
                    ($_ =~ s{\!}{}) ? "egf(new $_())" : "new $_()"
                    } @anos);
    } # always
}
$postfix = "\"$postfix\"";
if ($cc =~ m{x\Z}) {
    $postfix .= "\t$dist\t$gftype";
}
my $record = join("\t", "", $cc, $offset, "\"$polys\"", $postfix, @alist) . "\n";
if (0) {
    open (PIPE, "| clip");
    print PIPE $record;
    close(PIPE);
}
print      $record; 
my $file = "$lite_aman/$timestamp.man";
open (AMAN, ">>", $file) || die "# cannot write to $file\n";
# print AMAN "# poly \"$polys_org\" $postfix $options\n";
print AMAN $record;
close(AMAN);
__DATA__
      A polyx 0 polys postfix 0 1
A polyx 0 "polys" "postfix" 0 1

#!perl

# Generate a seq4 record with CC=ratos|holos from the parameters and append it to today's aman/date.man file
# @(#) $Id$
# 2025-06-13, Georg Fischer
#
#:# Usage:
#:#   perl ratos_seq4.pl $1 $2 ...  
#:#       -h generate CC=holos instead
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d", $year + 1900, $mon + 1, $mday);
my $gits =  $ENV{'GITS'};
my $lite_aman =  "$gits/joeis-lite/internal/fischer/aman";
$lite_aman =~ s{\\}{\/}g;

my $cc = "ratos";
my $matrix  = shift(@ARGV);
my $init    = shift(@ARGV); 
my $options = join(" ", @ARGV);
my $offset  = 0;
my $dist    = 0;
my $gftype  = 0;
while (scalar(@ARGV) > 0) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{-h}) {
        $cc     = "holos";
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
$matrix =~ s{\"}{}g;
$init   =~ s{\"}{}g;

# if ($matrix !~ m{\A\"}) {
# 	  $matrix = "\"$matrix\"";
# }
# if ($init   !~ m{\A\"}) {
# 	  $init   = "\"$init\"";
# }
my $record = join("\t", "", $cc, $offset, $matrix, $init, $dist, $gftype) . "\n";
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

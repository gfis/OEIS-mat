#!perl

# Generate a seq4 record with CC=ratos|holos from the parameters and append it to today's aman/date.man file
# @(#) $Id$
# 2025-07-14, seqno with 6 digits; *CZ=73
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
my $makefile = "$gits/OEIS-mat/scripts/makefile";
$makefile =~ s{\\}{\/}g;
require "$gits/OEIS-mat/scripts/last_seqno.inc";

my $debug   = 0;
my $cc      = "ratos";
my $matrix  = shift(@ARGV);
my $init    = shift(@ARGV);
my $options = join(" ", @ARGV);
my $offset  = 0;
my $dist    = 0;
my $gftype  = 0;
while (scalar(@ARGV) > 0) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{-d}) {
        $debug    = shift(@ARGV);;
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
my $seqno = sprintf("%06d", &last_seqno($makefile));
my $record   = join("\t", "A$seqno", $cc, $offset, $matrix, $init, $dist, $gftype) . "\n";
if ($cc !~ m{holos}) {
    $record .= join("\t", "A" . ($seqno + 1), "conum", 0, "A$seqno")               . "\n"; 
}
if (0) {
    open (PIPE, "| clip");
    print PIPE $record;
    close(PIPE);
}
print      $record;
my $file = "$lite_aman/$timestamp.man";
open (AMAN, ">>", $file) || die "# cannot write to $file\n";
print AMAN $record;
close(AMAN); 
__DATA__

#----
#----
sub last_seqno { # get aseqno from history.txt
    my ($makefile) = @_;
    map {   #        1   1
            if (m{\/A(\d+)}) { # take the 1st
                return $1;
            }
        }
        split(/\n/, `make -f $makefile histoeis`);
    return "";
} # last_seqno
1;
tasklist /FI "STATUS eq RUNNING" /FI "IMAGENAME eq chrome.exe" /nh /v | grep OEIS | perl -e "$_ = <>; my @f = split; print $f[9];"

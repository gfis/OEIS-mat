#!perl

# Prepare PARI snippets and copy them to OEIS-prog
# 2022-06-14, Georg Fischer
#:# Usage:
#:#   grep -E "^A058" ... \
#:#   | perl pari_prep.pl
#:# Writes files to gits/OEIS-prog/gp/a058/A058*.gp
#--------------------------------
use strict;
use integer;
use warnings;

my $tardir = "../../OEIS-prog/sandbox";
my $type = "an";

while (<>) {
    s/\s+\Z//; # chompr
    my ($aseqno, $callcode, $offset, @parms) = ("","","",(""));
    (   $aseqno, $callcode, $offset, @parms) = split(/\t/);
    if (defined($callcode) && $callcode ne "") { # valid cc
        my $adir = lc(substr($aseqno, 0, 4));
        mkdir "$tardir/$adir";
        my $target = "$tardir/$adir/$aseqno.gp";
        open (TAR, ">", $target) || die "cannot write \"$target\"\n";
        print TAR "\\\\ https://oeis.org/$aseqno type=$type offset=$offset curno=1\n";
        print TAR "$parms[1]\n";
        print "$target $type $offset written\n";
        close(TAR);
    } # valid cc
} # while <>
__DATA__


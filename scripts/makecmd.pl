#!perl

# @(#) $Id$
# 2024-06-28, Georg Fischer
#
#:# Generate Windows *.cmd files from all shell scripts (without extension).
#:# Usage:
#:#   perl makecmd.pl
#--------------------------------------------------------
use strict;
use integer;
use warnings;

foreach my $fname (glob("*")) {
    if ($fname !~ m{\.}) {
        my %parms = ();
        open(SRC, "<", $fname) || die "cannot read $fname\n";
        while (<SRC>) {
            foreach my $iparm (m{\$(\d+)}g) {
                $parms{$iparm} = 1;
            }
        } # <while <SRC>
        close(SRC);
        my $line = "sh \%GITS\%/OEIS-mat/scripts/$fname";
        for (my $iparm = 1; $iparm <= scalar(keys(%parms)); $iparm ++) {
            $line .= " \%$iparm";
        }
        print     "$line\n";
        open(TAR, ">", "$fname.cmd") || die "cannot write $fname.cmd\n";
        print TAR "$line\n\n";
        close(TAR);
    }
} # foreach
__DATA__
#!/bin/sh

name=`perl $GITS/OEIS-mat/scripts/Anumber.pl -s $1`.java
fname=$GITS/joeis-lite/internal/fischer/manual/`perl $GITS/OEIS-mat/scripts/Anumber.pl $1`.java
cp -v $GITS/joeis/src/irvine/oeis/$name $fname
e $fname

-> 

sh %GITS%/OEIS-mat/scripts/je %1


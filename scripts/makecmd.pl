#!perl

# @(#) $Id$ 
# 2026-11-05: sort(keys(, exclude "c"
# 2026-11-02: all arguments with "%*" for Windows cmd, "$@" for Unix bash
# 2024-06-28, Georg Fischer
#
#:# Generate Windows *.cmd files from all shell scripts (without extension).
#:# Usage:
#:#   perl makecmd.pl
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my $system  = ($ENV{'OS'} =~ m{\AWin}) ? "win" : "unix:";

foreach my $fname (glob("*")) { 
    next if $fname =~ m{\A(c)\Z}; # exclude special Windows scripts, eg. "c"
    if ($fname !~ m{\.}) { # only for files without extension
        my %parms = ();
        open(SRC, "<", $fname) || die "cannot read $fname\n";
        while (<SRC>) {
            #                      1      1
            foreach my $iparm (m{\$(\d+|\@)}g) {
                if ($iparm eq "@") { # all arguments
                    if ($system eq "win") {
                        $iparm = "*"; # yields "%*" below
                    }
                }
                $parms{$iparm} = 1;
            } # foreach
        } # <while <SRC>
        close(SRC);
        my $line = "sh \%GITS\%/OEIS-mat/scripts/$fname";
    #?  for (my $iparm = 1; $iparm <= scalar(keys(%parms)); $iparm ++) {
        foreach my $iparm (sort(keys(%parms))) {
            $line .= " \%$iparm";
        }
        print     "$line\n";
        open(TAR, ">", "$fname.cmd") || die "cannot write $fname.cmd\n";
        print TAR "$line\n\n";
        close(TAR);
    } # without extension
} # foreach
__DATA__
#!/bin/sh

name=`perl $GITS/OEIS-mat/scripts/Anumber.pl -s $1`.java
fname=$GITS/joeis-lite/internal/fischer/manual/`perl $GITS/OEIS-mat/scripts/Anumber.pl $1`.java
cp -v $GITS/joeis/src/irvine/oeis/$name $fname
e $fname

-> 

sh %GITS%/OEIS-mat/scripts/je %1


#!perl

# @(#) $Id$
# 2024-06-28, Georg Fischer
#
#:# Filter seq4 records and split equations (at "=" outside of parentheses) in $(PARM1) into several records
#:# Usage:
#:#   perl spliteq.pl infile.seq4 > outfile.seq4
#--------------------------------------------------------
use strict;
use integer;
use warnings;

my $iparm = 1; # operate on this parameter
#while (<DATA>) {
while (<>) {
    if (m{\AA\d+\t}) { # assume seq4 format
        s/\s+\Z//;
        my ($aseqno, $callcode, @parms) = split(/\t/);
        my $oparmi = $parms[$iparm];
        my @parts  = split(/([\{\[\(\)\]\}\=]) */, $oparmi); # split with separators
        my @levels = ();
        my $nparmi = "";
        my $level  = 0;
        my $eqno   = 1;
        for (my $ipart = 0; $ipart < scalar(@parts); $ipart ++) {
            my $part = $parts[$ipart];
            if (0) {
            } elsif ($part =~ m{[\(\[\{]}) { # opening
                $level ++;
                $nparmi .= $part;
            } elsif ($part =~ m{[\)\]\}]}) { # closing
                $level --;
                $nparmi .= $part;
            } elsif ($part eq "=") { # eq - group change
                # print "# nparmi=$nparmi, level=$level\n";
                if ($level == 0) { # split iff "=" on level 0
                    $parms[$iparm] = $nparmi;
                    print join("\t", $aseqno, "$callcode.$eqno", @parms) . "\n";
                    $eqno ++;
                    $nparmi = "";
                } else { 
                    $nparmi .= $part;
                }
            } else { 
                $nparmi .= $part;
            }
        } # for $ipart
        if (1) { # repeat at end of group
                    $parms[$iparm] = $nparmi;
                    print join("\t", $aseqno, "$callcode", @parms) . "\n";
                    $nparmi = "";
        } # end of group
    } else { # no seq4
        print;
    }
} # while
__DATA__
# test data
A358847	spliteq	0	E358755(6*n)	18	19	20
A368339	spliteq	0	J002349(8*n) = A002349(8*n) = 17*n	"1,2,2"
A368340	spliteq	0	[J002350(8*n) == A002350(8*n)]	"1"	new D000001()
A371125	spliteq	0	J005708(6*n) = SU(k=1..n, A005708(6*n))


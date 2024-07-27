#!perl

# @(#) $Id$
# 2024-06-28, Georg Fischer
#
#:# Filter seq4 records and split equations in $(PARM1) (at "=" outside of parentheses) into several records
#:# Usage:
#:#   perl spliteq.pl infile.seq4 > outfile.seq4
#--------------------------------------------------------
use strict;
use integer;
use warnings;

my $iparm = 1; # operate on this parameter
my ($aseqno, $callcode, @parms);
my $oparmi;
my @parts ;
my @levels;
my $nparmi;
my $level ;
my $eqno  ;
my $nok;

#while (<DATA>) {
while (<>) {
    if (m{\AA\d+\t}) { # assume seq4 format
        s/\s+\Z//;
        ($aseqno, $callcode, @parms) = split(/\t/);
        $oparmi = $parms[$iparm];
        @parts  = split(/([\{\[\(\)\]\}\=]) */, $oparmi); # split on bracket separators and keep them
        @levels = ();
        $nparmi = "";
        $level  = 0;
        $eqno   = 1;
        $nok = 0;
        for (my $ipart = 0; $ipart < scalar(@parts); $ipart ++) {
            my $part = $parts[$ipart];
            if (0) {
            } elsif ($part =~ m{[\(\[\{]}) { # opening bracket
                $level ++;
                $nparmi .= $part;
            } elsif ($part =~ m{[\)\]\}]}) { # closing bracket
                $level --;
                $nparmi .= $part;
            } elsif ($part eq "=") { # eq - group change
                # print "# nparmi=$nparmi, level=$level\n";
                if ($level == 0) { # split iff "=" on level 0
                    &output();
                } else { 
                    $nparmi .= $part;
                }
            } else { 
                $nparmi .= $part;
            }
        } # for $ipart
        if (1) { # repeat at end of group
                    &output();
        } # end of group
    } else { # no seq4
        print;
    }
} # while
#----
sub output {
                    $parms[$iparm] = $nparmi;
                    if (length($nparmi) > 1) {
                        print        join("\t", $aseqno, "$callcode", @parms) . "\n";
                    } else {
                        print STDERR join("\t", $aseqno, "$callcode", @parms) . "\n";
                    }
                    $eqno ++;
                    $nparmi = "";
} # output
__DATA__
# test data
A358847	spliteq	0	E358755(6*n)	18	19	20
A368339	spliteq	0	J002349(8*n) = A002349(8*n) = 17*n	"1,2,2"
A368340	spliteq	0	[J002350(8*n) == A002350(8*n)]	"1"	new D000001()
A371125	spliteq	0	J005708(6*n) = SU(k=1..n, A005708(6*n))


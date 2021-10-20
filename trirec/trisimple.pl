#!perl

# Extract parameters for "inverse binomail transform of" 
# 2021-10-14, Georg Fischer: copied from divpow.pl
#
#:# Usage:
#:#   perl invbinom.pl [-d debug] $(COMMON)/joeis_names.txt > output.seq4
#:#     -d  debugging level (0=none (default), 1=some, 2=more)
#--------------------------------------------------------
use strict;
use integer;
use warnings;

my $line = "";
my ($aseqno, $superclass, $callcode, $name, @rest);

while (<>) {
    my $line = $_;
    #                               1     1    2     2          34                     4 5     6                     6 5 37                        7
    if ($line =~ m{\s[ATsta] *[\(\[]([a-z])\, *([a-z])[\)\]] *\=(([\d\+\-\*\/\^ \!\(\)])*([a-z]([\d\+\-\*\/\^ \!\(\)])+)+)([\,\.\<\=\>\;]|for|with|where|if)}) {
        my ($n, $k, $expr) = ($1, $2, $3);
        $expr =~ s{ }{}g;
        ($aseqno, $superclass, $name, @rest) = split(/\t/, $line);
        if (0) { # excludes:
        } elsif ($superclass ne "null") { # already in jOEIS
        } elsif ($rest[0] !~ m{tabl}) { # no keyword tabl
        } elsif ($expr =~ m{[\+\-\+\/\^\(]\Z}) { # incomplete
        } else {
            my $ok = 1;
            foreach my $letter ($expr =~ m{([a-z])}g) {
                if ($letter ne $n and $letter ne $k) {
                    $ok = 0;
                }
            } # foreach
            if ($ok == 1) { # only $n and $k - normalize them to "n" and "k"
                $expr =~ s{$n}{\{$n\}}g; # shield it
                $expr =~ s{$k}{\{$k\}}g; # shield it
                $expr =~ s{\{$n\}}{n}g;  # unshield and normalize
                $expr =~ s{\{$k\}}{k}g;  # unshield and normalize
                print join("\t", $aseqno, "trisimple", 0, $expr, "", "", $name). "\n";
            }
        }
    } # if line
} # while

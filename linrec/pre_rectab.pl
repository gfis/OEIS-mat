#!perl

# Preprocess grepped lines with "Recurrence: " for rectab.pl
# @(#) $Id$
# 2019-12-03, Georg Fischer

use strict;

while (<>) {
    s{\s+\Z}{};
    my ($aseqno, $callcode, $offset, $info, $data, $termno) = split(/\t/);
    $info =~ s/\..*//; # remove all behind 1st dot
    $info =~ s/\[From.*//i;
    $info =~ s/ (and|or) /\,/ig;
    $info =~ s/[\{\}]//g; 
    $info =~ s/\;/\,/g; 
    $info =~ s{\ARecurrence\:}{};
    my $range = "{n,0,$termno}";
    if ($info =~ m{(for|with|\,)\s+n\s*(\>\=?)(\d+)}) {
        my $op = $2;
        my $n  = $3;
        if ($op eq ">") {
            $n ++;
        }
        $range = "{n,$n,$termno}";
        $info =~ s{(for|with|\,)\s+n\s*(\>\=?)(\d+)}{};
    }
    if (($info !~ m{[A-Zb-mo-z]}) and ($info =~ m{a[\(\[]})) { # only allow "a", "n"
        $info =~ s/ //g; 
        $info =~ s{a\(([0-9n\+\-]+)\)}{a\[\1\]}g; # make a[square brackets]
        $info = &norm_index($info);
        if (1) { # now determine the number of initial terms
            my %hinx = ();
            foreach my $index ($info =~ m{\[n([\+\-]\d+)\]}g) {
                $index =~ s{\+}{};
                $hinx{$index} = 1;
            } # foreach
            my @anshifts = sort { $a <=> $b } (keys(%hinx));
            my $inx0 = $anshifts[0];
            my $inx9 = $anshifts[scalar(@anshifts) - 1];
            # print "# inx0=$inx0, inx9=$inx9\n";
            my $degree = $inx9 - $inx0 + 1;;
            my @terms = split(/\,/, $data, $degree + 1);
            pop(@terms); # remove the additional
            my $ind = 0;
            foreach my $term (@terms) {
                $info .= ",a[$ind]=$term";
                $ind ++;
            }
        } # initial terms
        $info = "RecurrenceTable\[\{" . $info; 
        $info .= "\},a,$range\]"; 
        print join("\t", $aseqno, $callcode, $offset, $info, substr($data, 0, 16)) . "\n";
    } # allowed, else ignore
} # while <>

sub norm_index {
    my ($info) = @_;
    $info =~ s{\[(\-\d+)\+n\]}{\[n$1\]};
    $info =~ s{\[(\d+)\+n\]}{\[n\+$1\]};
    $info =~ s{\[n\]}{\[n\+0\]};
    return $info;
} # norm_index
__DATA__

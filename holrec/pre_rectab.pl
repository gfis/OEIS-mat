#!perl

# Preprocess grepped lines with "Recurrence: " for rectab.pl
# @(#) $Id$
# 2019-12-03, Georg Fischer
#
#:# Usage:
#:#   perl pre_rectab.pl [-a init] infile > outfile
#:#       -a additional initial terms (more than order)
#---------------------------------
use strict;
use integer;
use warnings;
my $version = "V1.2";
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);

my $debug  = 0;
my $ainit  = 0; # additional initial terms
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{a}) {
        $ainit  = shift(@ARGV);
    } elsif ($opt  =~ m{d}) {
        $debug  = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

while (<>) {
    s{\s+\Z}{};
    my ($aseqno, $callcode, $offset, $info, $data, $termno, $ninits) = split(/\t/);
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
        $info =~ s{a\(([0-9n\+\-]+)\)}{a\[$1\]}g; # make a[square brackets]
        $info = &norm_index($info);
        # now determine the number of initial terms
        my %hinx = ();
        foreach my $index ($info =~ m{\[n([\+\-]\d+)\]}g) {
            $index += 0;
            $hinx{$index} = 1;
        } # foreach
        my @anshifts = sort { $a <=> $b } (keys(%hinx));
        my $inx0 = $anshifts[0];
        my $inx9 = $anshifts[scalar(@anshifts) - 1];
        # print "# inx0=$inx0, inx9=$inx9\n";
        my $degree = $inx9 - $inx0 + 1;
        $ninits = $ninits + 1 - $offset;
        if ($ninits > $degree) {
        	$degree = $ninits;
        }
        $degree += $ainit;
        if ($degree <= 32) { # reasonable
            my @terms = split(/\,/, $data, $degree + 1);
            pop(@terms); # remove the last which consumed the whole rest of the term list
            my $ind = 0;
            foreach my $term (@terms) {
                $info .= ",a[$ind]=$term";
                $ind ++;
            }
            $info = "RecurrenceTable\[\{" . $info; 
            $info .= "\},a,$range\]"; 
            print join("\t", $aseqno, $callcode, $offset, $info, substr($data, 0, 16)) . "\n";
        } # if reasonable
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
%t A226302 a = DifferenceRoot[Function[{a, n}, {(-(6*n^2) + 2*n + 4)*a[n+2] + (n^2 + n - 2)*a[n+4] + 8*(n - 1)*n*a[n] - 4*

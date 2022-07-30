#!perl

# Prepare constant order recurrences from Mathematica's RecurrenceTable
# @(#) $Id$
# 2022-07-14, Georg Fischer; CKZ=70
#
#:# Usage:
#:#   grep -E "^%|RecurrenceTable" $(COMMON)/jcat25.txt \
#:#   | perl cordrectab.pl > output.cat25 with types [FO]
#---------------------------------
use strict;
use integer;
use warnings;
use English;

my $debug  = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug  = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my $init;
my $matrix;
my $relev = 0;
my $rec;
my $offset; # both!
my $aseqno;
while (<>) {
    s/\s+\Z//;
    my $line = $_;
    if (0) {
    } elsif ($line =~ m{\A\%t (A\d+)}) {
        $aseqno = $1;
        if ($line =~ m{RecurrenceTable\[\{([^\}]+)\}}) {
            $rec = $1;
            $relev = 1;
            $rec = &prep($rec);
            print join(" ", "%F", $aseqno, "$rec.") . "\n";
        }
    #                          1    1  2      2
    } elsif ($line =~ m{\A\%O +(A\d+) +(\-?\d+(\,\-?\d+))}) {
        ($aseqno, $offset) = ($1, $2);
        if ($relev == 1) {
            print join(" ", "%O", $aseqno, $offset) . "\n";
        } # else ignore %O
        $relev = 0;
    }
} # while <>
#----
sub prep {
    my ($rec) = @_;
    $rec =~ s{ }{}g; # remove spaces
    $rec =~ s{\=\=}{\=}g; # ==
    $rec =~ tr{\[\]}
              {\(\)};     # [ ]
    $rec =~ s{([A-Z])([a-z]+)}  {lcfirst($1) . $2}eg; # make all functions lowercase
    $rec =~ s{(\d)([a-z])}      {$1\*$2}g;  # 3n -> 3*n
    $rec =~ s{(\d)(\()}         {$1\*\(}g;  # 3( -> 3*(
    $rec =~ s{\)([a-z0-9])}     {\)\*$1}g;  # )a -> )*a
    $rec =~ s{\)\(}             {\)\*\(}g;  # )( -> )*(
    $rec =~ s{\bna\(}           {n\*a\(}g;  # )( -> )*(
    #                1        2          2 13       3
    while ($rec =~ m{(a\(\d+\)(\=a\(\d+\))+)(\=\-?\d+)}) {
    	my ($rpre, $rpost) = ($PREMATCH, $POSTMATCH);
        my ($list, $val) = ($1, $3);
        my $list2 = "";
        foreach my $part(split(/\=/, $list)) {
            $list2 .= ",$part$val";
        }
        $list2 = substr($list2, 1); # remove leading ","
        # print STDERR "# $rec: $list, $val -> $list2\n";
        $rec = "$rpre$list2$rpost";
    }
    return $rec;
}
__DATA__
->

%F A058181 a(0)=1,a(1)=0,a(n)=a(n-1)^2-a(n-2).
%O A058181 0,5
%F A059232 a(1)=1,a(n)=a(n-1)^a(n-1)+n.
%O A059232 1,2
%F A060723 a(0)=0,a(1)=1,a(n)=a(n-1)+a(n-2)/2.
%O A060723 0,4
%F A060984 a(1)=1,a(n)=a(n-1)+floor(sqrt(a(n-1)))^2.
%O A060984 1,2

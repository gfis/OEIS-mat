#!perl

# Generate sequences from linear recurrence signatures
# @(#) $Id$
# 2026-02-13: Georg Fischer, copied from signat_eval.pl
#
#:# Usage:
#:#   perl signat_gen.pl [-d debug] [-m mode] input > output
#:#      -d 0=none, 1=some, 2=more
#:#      -m mode black,binom ...
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);

my $debug = 0;
my $mode  = 'black';
if (0 && scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{m}) {
        $mode      = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
#----
my ($line, $aseqno, $callcode, $offset1, $sigord, $longord, $wordord, $signature, $keyword, $inits);
my $nok = "";
my @sigelems; # terms in the signature
my @aterms;   # initial data terms
my @bterms;   # initial data terms

while (<>) {
    s/\s+\Z//; # chompr
    $line = $_;
    $nok  = "";
    ($aseqno, $callcode, $offset1, $signature, $sigord, $keyword, $inits) = split(/\t/, $line);
    next if $aseqno eq "A000000";
    @sigelems = reverse(split(/\,/, "-1," . $signature . ",0"));
    @aterms    = split(/\, */, $inits);
    if (scalar(@aterms) > $sigord) {
        @bterms = splice(@aterms, 0, $sigord);
    } else {
        $nok = "toofew";
    }
    if ($nok ne "") {
    } elsif ($mode =~ m{\Abla}) { # black start
        my $ix = 0;
        while ($ix < scalar(@bterms) && $bterms[$ix] == 0) {
            $ix ++;
        }
        if ($ix < scalar(@bterms)) {
            @aterms = splice(@bterms, 0, $ix + 1);
        }
        &output();
    #                          12   2 13    3
    } else {
        die "# $0: invalid mode $mode\n";
    }
} # while <>
# end main
#----------
sub output {
    if ($nok eq "") {
        print join("\t"
            , $aseqno
            , $callcode
            , 0
            , "[" . join(",", @sigelems) . "]"
            , join(",", @aterms)
            , 0, 0
            ) . "\n";
    } else {
        print STDERR "$line -> $nok\n";
    }
} # output

#-------------------------------------------------
__DATA__
A239294	holos	0	12,45	2	other	0,1,12,189,2808,42201,632772,9492309
A239305	holos	0	4,-3,-4,3,2	5	other	1,1,2,6,13,31,69,153
A239325	holos	0	3,-3,1	3	binom=3	1,15,41,79,129,191,265,351
A239352	holos	0	5,-10,10,-5,1	5	binom=5	0,0,1,12,48,130,285,546	2501

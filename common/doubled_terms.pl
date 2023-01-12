#!perl

# Grep sequences where most terms are doubled
# @(#) $Id$
# 2022-11-26, Georg Fischer, copied from highest_term.pl
#
#:# usage:
#:#   perl doubled_terms.pl [-u] [-n] stripped > outputfile
#:#       -u "unequal": previous pair must be different
#:#       -a take absolute of terms in the pairs
#---------------------------------
use strict;
use integer;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday) = gmtime (time);
my $utc_stamp = sprintf ("%04d-%02d-%02dT%02d:%02d:%02d\z"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);

# get options
if (0 and scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
my $datafile = "stripped";
my $debug      = 0; # 0 (none), 1 (some), 2 (more)
my $absolute= 1;
my $unequal = 0;
my $ofter_file = "../../OEIS-mat/common/joeis_ofter.txt";
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{\-d}) {
        $debug    = shift(@ARGV);
    } elsif ($opt =~ m{\-a}) {
        $absolute = 1;
    } elsif ($opt =~ m{\-u}) {
        $unequal  = 1;
    } elsif ($opt   =~ m{\-f}  ) {
        $ofter_file = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while ARGV
#----------------
my $termlist;
my %ofters = ();
open (OFT, "<", $ofter_file) || die "cannot read $ofter_file\n";
while (<OFT>) {
    s{\s+\Z}{};
    my ($aseqno, $offset, $termlist) = split(/\t/);
    $termlist = $termlist || "";
    $ofters{$aseqno} = "$offset\t$termlist";
} # while <OFT>
close(OFT);
print STDERR "# $0: " . scalar(%ofters) . " jOEIS offsets and some terms read from $ofter_file\n";
foreach my $key (("A000001", "A000007", "A183652", "A400000")) {
    print STDERR "$key " . ($ofters{$key} || "undef") . "\n";
}
#----------------
my $aseqno;
my $termlist;
my @terms;
my @singles;
while (<>) {
    s/\s+\Z//; # chompr
    my $line = $_;
    ($aseqno, $termlist) = split(/ \,/, $line);
    @terms = split(/\,/, $termlist);
    @singles = ();
    my $ind = scalar(@terms) - 3;
    if ($ind > 16) {
        if ($absolute == 0) {
            if ($terms[$ind] == $terms[$ind - 1]) {
                &check_pairs($ind);
            } else {
                $ind --;
                if ($terms[$ind] == $terms[$ind - 1]) {
                    &check_pairs($ind);
                }
            }
        } else {
            if (abs($terms[$ind]) == abs($terms[$ind - 1])) {
                &check_pairs($ind);
            } else {
                $ind --;
                if (abs($terms[$ind] == $terms[$ind - 1])) {
                    &check_pairs($ind);
                }
            }
        }
    }
} # while <>
#----
sub check_pairs {
    my ($ind) = @_;
    unshift(@singles, $terms[$ind]);
    $ind -= 2;
    my $busy = 1;
    my $same = 0; # assume that all term pairs are different
    while ($busy && $ind >= 1) {
        if ($absolute == 0) {
            if ($terms[$ind] != $terms[$ind - 1]) { # differ
                $busy = 0;
            } else {
                if ($terms[$ind + 2] == $terms[$ind]) {
                    $same = 1;
                }
                unshift(@singles, $terms[$ind]);
                $ind -= 2;
            }
        } else {
            if (abs($terms[$ind]) != abs($terms[$ind - 1])) { # differ
                $busy = 0;
            } else {
                if (abs($terms[$ind + 2]) == abs($terms[$ind])) {
                    $same = 1;
                }
                unshift(@singles, $terms[$ind]);
                $ind -= 2;
            }
        }
    } # while $busy
    if ($busy == 1) {
        my $ninit = $ind + 1; # number of initial terms in target sequence that are not doubled
        my $prefix = "";
        my $ind = 0;
        while ($ind < $ninit) {
            $prefix .= ",$terms[$ind ++]";
        } # while
        my $singlelist = join("\,", splice(@singles, 0, 64));
        my @asns = ();
        my $asnlist = "";
        my $asmin = "";
        my $skiplen = 0xfffffff; # very high
        if (length($singlelist) >= 16 && ! defined($ofters{$aseqno}) && ($unequal == 0 || $same == 0)) { # not yet in jOEIS
            my %strips = ();
            my %stlens = ();
            my $search = $singlelist;
            $search =~ s{\-}{\\\-}g;
            my $response = `grep -E \"$search\" $datafile 2>&1`;
            if ($response =~ m{grep}) {
                print "# $aseqno: grep problem - $response\n";
            }
            map {   my ($as, $tl) = split(/ \,/, $_); # termlists in 'stripped' have a leading ","
                    $strips{$as} = $tl;
                    my $pos      = index($tl, $singlelist);
                    my $skipstr  = substr($tl, 0, $pos);
                    $skipstr =~ s{\,\Z}{};
                    $stlens{$as} = scalar(split(/\,/, $skipstr));
                    if ($stlens{$as} < $skiplen) {
                        $asmin   = $as;
                        $skiplen = $stlens{$as};
                    }
                } split(/\n/, $response);
            @asns = sort(keys(%strips));
            @asns = splice(@asns, 0, 4);
            $asnlist = join(",", @asns);
            # print "# $aseqno ninit=$ninit, asmin=$asmin, skiplen=$skiplen, prefix=$prefix\n";
            if (scalar(keys(%strips)) > 0) {
                if (length($prefix) == 0 && $skiplen == 0) { # no PrependSequence parameters
                    print join("\t", $aseqno
                        , "doubled"
                        , 0 # instead of offset
                        , (scalar(@asns) > 0 && defined($ofters{$asmin})) ? $asmin : "nyi"
                        , ""
                        , ""
                        , $singlelist
                        , $asnlist
                        , join("\,", splice(@terms, 0, 16))
                        ) . "\n";
                } else { # with PrependSequence parameters
                    print join("\t", $aseqno
                        , "doublep"
                        , 0 # instead of offset
                        , (scalar(@asns) > 0 && defined($ofters{$asmin})) ? $asmin : "nyi"
                        , $skiplen # to be skipped in source sequence
                        , (length($prefix) == 0 ? "" : (", " . substr($prefix, 1))) # to be prefixed to target sequence
                        , substr($strips{$asmin}, 0, 16)
                        , $asnlist
                        , substr($termlist, 0, 32)
                        , "ninit=$ninit"
                        ) . "\n";
                }
            }
        } # not yet in jOEIS
    }
} # check_pairs
#------------------------------------
__DATA__

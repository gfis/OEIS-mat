#!perl

# create an extract of the jcat25.txt file 
# 2023-10-14, Georg Fischer
#
#:# Usage:
#:#   perl catex_select.pl -f ofter_file [-d debug] jcat25.txt > output.cat25
#:#     -d debugging mode: 0=none, 1=some, 2=more
#:#     -f file with leading aseqno and other parameters
#--------------------------------------------------------
use strict;
use integer;
use warnings;

my $sel_file = "wrong-f.name.txt";
my $debug = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt   =~ m{\-d}  ) {
        $debug      = shift(@ARGV);
    } elsif ($opt   =~ m{\-f}  ) {
        $sel_file = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
#----------------
my %sels = ();
open (SEL, "<", $sel_file) || die "cannot read $sel_file\n";
while (<SEL>) {
    next if ! m{^(A\d{6})};
    $sels{$1} = 1;
} # while <SEL>
close(SEL);
print STDERR "# " . scalar(keys(%sels)) . " A-numbers read\n";
#----------------
my $oseqno = "A000000";
while (<>) { # CAT25 format
    if (m{^.. (A\d{6})}) {
        my $aseqno = $1;
        if (defined($sels{$aseqno})) {
            if ($oseqno ne $aseqno) {
                print "== $aseqno ================\n";
                $oseqno = $aseqno;
            }
            print;
        }
    }
} # while <>
#================
__DATA__
012345678901234567
%I
%I A000001  M0098 N0035
%S A000001 0,1,1,1,2,1,2,1,5,2,2,1,5,1,2,1,14,1,5,1,5,2,2,1,15,2,2,5,4,1,4,1,51,
%T A000001 1,2,1,14,1,2,2,14,1,6,1,4,2,2,1,52,2,5,1,5,1,15,2,13,2,2,1,13,1,2,4,
%U A000001 267,1,4,1,5,1,4,1,50,1,2,3,4,1,6,1,52,15,2,1,15,1,2,1,12,1,10,1,4,2
%N A000001 Number of groups of order n.
%C A000001 Also, number of nonisomorphic subgroups of order n in symmetric group S_n. - _Lekraj Beedassy_, Dec 16 2004
%C A000001 Also, number of nonisomorphic primitives of the combinatorial species Lin[n-1]. - _Nicolae Boicu_, Apr 29 2011
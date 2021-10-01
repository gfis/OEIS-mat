#!perl

# Prepare parameters for SimpleRecurrenceTriangles 
# @(#) $Id$
# 2021-10-01, Georg Fischer: copied from prep_traits.pl
#
#:# Usage:
#:#   perl prep_pascal.pl pascal4.tmp > output 2> rest
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
$timestamp = sprintf ("%04d-%02d-%02d", $year + 1900, $mon + 1, $mday);

my $debug = 0;
my $minlen = 6;
if (scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{l}) {
        $minlen    = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

# there must be groups of 3 traits in the order Left, Right, Pascal
my ($lseqno, $rseqno, $pseqno) = ("", "", "");
my $gok = 1; # assume successful group
my $sep = "~~"; # separator for seq4 statement parameters
my $default_compute = "get(k - 1).add(get(k))";

while (<>) {
    my $line = $_;
    $line =~ s{\s+\Z}{}; # chompr
    if ($line =~ m{\A(A\d+)}) {
        my ($aseqno, $trait, $len, $parm1, @rest) = split(/\t/, $line);
        if ($parm1 !~ m{\A[A-Z]}) { # A-number or sequence class starting with uppercase letter
            $gok = 0;
        }
        if (0) { # switch for traits
        } elsif ($trait =~ m{Left}i) {
            $lseqno = $parm1;
        } elsif ($trait =~ m{Righ}i) {
            $rseqno = $parm1;
        } elsif ($trait =~ m{Pasc}i) { # end of group: generate the seq4 record
            $pseqno = $parm1;
            if ($gok && $len >= $minlen) {
                my $callcode = "pastri";
                my $skip_parm = "";
                if ($lseqno =~ s{_(\d+)\Z}{}) {
                    $skip_parm .= "${sep}skipLeft($1);";
                }
                if ($rseqno =~ s{_(\d+)\Z}{}) {
                    $skip_parm .= "${sep}skipRight($1);";
                }
                if (length($skip_parm) > 0) {
                    $skip_parm = "${sep}    $skip_parm";
                }
                #----
                my $compute_parm = "";
                if (0) {
                } elsif ($pseqno eq "A000004") { # not "all zeroes" 
                    # use default 'compute' method
                } elsif ($pseqno eq "A000012") { # all ones
                    $compute_parm .= "$default_compute\.add(1)";
                } elsif ($pseqno =~ m{\A(A\d+)\Z}) { # more complicated sequence
                    $callcode = "pastrico"; # will evaluate mSeqA
                } elsif ($pseqno =~ m{\-1\,\-1\,\-1\,\-1\,\-1\,\-1\,\-1\,\-1\,}) { # all -1
                    $compute_parm .= "$default_compute\.subtract(1)";
                } else {
                	$gok = 0;
                }
                if (length($compute_parm) > 0) {
                    $compute_parm = "${sep}    ${sep}return $compute_parm;";
                    $callcode = "pastrico";
                }
                print        join("\t", $aseqno, $callcode, 0, $lseqno, $rseqno, $pseqno, $skip_parm, $compute_parm) . "\n";
                # pastrico uses:                               PARM1    PARM2    PARM3    PARM4       PARM5
                # pastri   uses:                               PARM1    PARM2             PARM4
            } else {
                print STDERR join("\t", $aseqno, "Left", 0, $lseqno) . "\n";
                print STDERR join("\t", $aseqno, "Righ", 0, $rseqno) . "\n";
                print STDERR join("\t", $aseqno, "Pasc", 0, $pseqno) . "\n";
                print STDERR "#--------\n";
            }
            $gok = 1; # assume successful group
            ($lseqno, $rseqno, $pseqno) = ("", "", "");
            # end of group
        } # switch traits
    } else {
        # ignore
    }
} # while <>

#----------------
__DATA__
A000012	Left	0	A000012	all ones	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1	well-known		
A000012	Righ	0	A000012	all ones	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1	well-known		
A000012	Pasc	30	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1	unknown
A002024	Left	0	A000027	positive integers	1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32	well-known		
A002024	Righ	0	A000027	positive integers	1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32	well-known		
A002024	Pasc	30	A001478	The negative integers.
A003056	Left	0	A001477	nonnegative integers	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31	well-known		
A003056	Righ	0	A001477	nonnegative integers	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31	well-known		
A003056	Pasc	30	A001489	a(n) = -n.
A005145	Left	32	A070159	Numbers k such that phi(k)/(sigma(k)-k) is an integer.
A005145	Righ	32	A070159	Numbers k such that phi(k)/(sigma(k)-k) is an integer.
A005145	Pasc	30	-1,-3,-3,-9,-9,-15,-15,-17,-27,-25,-33,-39,-39,-41,-47,-57,-55,-63,-69,-67,-75,-77,-81,-93,-99,-99,-105,-105,-99,-123	unknown

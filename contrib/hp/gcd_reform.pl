#!perl

# Reformat Hugo's GCD files
# @(#) $Id$
# 2023-08-09, Georg Fischer: copied from contrib/data_bf.pl; *VF=42
#
#:# usage:
#:#   perl gcd_reform.pl [-c code] input > output
#:#       -c one of the codes "gcd0", "gcdminus", "gcdplus"
#:#
#:# Cf. <https://github.com/HugoPfoertner/OEIS-Search-GCD-reduced>
#---------------------------------
use strict;
use integer;
# get options
my $debug   = 0; # 0 (none), 1 (some), 2 (more)
my $offset  = 0;
my $code    = 0;
my $width   = 65536; # very high
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{\-d}) {
        $debug    = shift(@ARGV);
    } elsif ($opt =~ m{\-c}) {
        $code     = substr(shift(@ARGV), 3, 1);
    } elsif ($opt =~ m{\-w}) {
        $width    = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while ARGV

#----------------
my $ofter_file = "../../common/joeis_ofter.txt";
my $terms;
my %ofters = ();
open (OFT, "<", $ofter_file) || die "cannot read $ofter_file\n";
while (<OFT>) {
    s{\s+\Z}{};
    my ($aseqno, $offset, $terms) = split(/\t/);
    $terms = $terms || "";
    $ofters{$aseqno} = "$offset\t$terms";
} # while <OFT>
close(OFT);
print STDERR "# $0: " . scalar(%ofters) . " jOEIS offsets and some terms read from $ofter_file\n";
#----------------

while (<>) {
    next if ! m{\A\d{6}};
    s/\s+\Z//; # chompr
    my ($seqno, $gcd, $count, @data) = split(/\s+/);
    my $aseqno = "A$seqno";
    if (defined($ofters{$aseqno})) {
        print join("\t", $aseqno,  "jcd$code", substr($ofters{$aseqno}, 0, index($ofters{$aseqno}, "\t")), $gcd, join("\,", @data)) . "\n";
    } else {
        print join("\t", $aseqno,  "gcd$code", -22                                                       , $gcd, join("\,", @data)) . "\n"; # unknown offset
    }
} # while <>
# seqno gcd count data
__DATA__
# Last Modified: July 30 03:26 UTC 2023
000013 2 34 1 1 2 2 4 5 10 15 28 47 90 158 298 548 1034 1928 3658 6899 13136 24970 47710 91181 174858 335546 645436 1242767 2397044 4628198 8948416 17318417 33555466 65075294 126324496 245426708
000016 2 33 1 1 2 3 5 8 15 26 47 86 158 293 548 1024 1928 3643 6899 13108 24970 47663 91181 174768 335546 645278 1242767 2396746 4628198 8947868 17318417 33554432 65075294 126322568 245426708
000017 4 14 1 2 1 4 3 12 20 34 105 310 718 1913 4526 12546

#!perl

# Postprocess output of target ropost
# @(#) $Id$
# 2026-10-07, Georg Fischer
#
#:# Usage:
#:#     perl ropost_clean.pl [-d mode] input.seq4 > output.seq4
#:#     -d  debugging level (0=none (default), 1=some, 2=more)
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my $debug = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt   =~ m{\-d}  ) {
        $debug      = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while options
#----------------
my $cond;
my $nok;
while (<>) {
    my $line = $_;
    $line =~ s/\s+\Z//; # chompr
    my ($aseqno, $callcode, $offset, $post, @rest) = split(/\t/, $line);
    $post =~ s{binomial}{BI}g;
    if(0) {
    } elsif (length($post) < 8) {
        # ignore, too short
    } elsif ($post =~ m{\A[n0-9\;\+\-\*\/\^\(\)BIEFJM]+\Z}) {
        print join("\t", $aseqno, $callcode, $offset, $post, @rest) . "\n";
    } else {
        print STDERR $line . "\n";
    }
} # while <>
__DATA__
A115948	lambdan	0	;2;semiprime(;n;semiprime);1;-;^;modulo(;semiprime(;n;semiprime);2;^;modulo);*						0
A263133	lambdan	0	;2;J000267(;n;J000267);^;2;J384688(;n;J384688);^;+;3;/;1;-	for n >= 1					0
A263132	lambdan	0	;2;J000267(;n;1;-;J000267);^;2;J384688(;n;1;-;J384688);^;+;3;/						0
A161400	lambdan	0	;2;F070939(;p;F070939);^;1;+;p;*	where p = J006995(n+1). [From _R. J. Mathar_, Sep 27 2009]					0
A199574	lambdan	0	;2;floor(;n;2;/;floor);^;2;binomial(;n;2;,;binomial);floor(;n;2;/;floor);2;/;+;^;2;/;+						0

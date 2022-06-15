#!perl

# Extract PARI pattern "a(n) = ..." from jcat25.txt
# 2022-06-12, Georg Fischer
#:# Usage:
#:#   grep -E "^\%o" $(COMMON)/jcat25.txt \
#:#   | perl pari_an.pl > output.seq4
#--------------------------------
use strict;
use integer;
use warnings;

while (<>) {
    s/\s+\Z//; # chompr
    if (m{\A\%o (A\d+) +\(PARI[^\)]*\) *(\{?a\(n\) *\=.*)}) {
        my ($aseqno, $prog) = ($1, $2);
        my $pos = index($prog, "\\\\");
        if ($pos >= 0) { # only those with author at the end
            $prog = substr($prog, 0, $pos);
            $prog =~ s{\s+\Z}{};
            $prog =~ s{([^\;])\Z}{$1\;};
            $prog =~ s/\\/\\\\/g;
            $prog =~ s/\"/\\\"/g;
            $prog =~ s/\'/\\\'/g;
            print join("\t", $aseqno, "an", 0, 0, $prog, "") . "\n";
        } # if \\ author
    } # if PARI
} # while <>
__DATA__


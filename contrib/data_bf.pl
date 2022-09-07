#!perl

# Convert between sequential terms (DATA section) and b-file format
# @(#) $Id$
# 2022-03-03, Georg Fischer: copied from bfcheck/bfhead.pl
#
#:# usage:
#:#   perl data_bf.pl [-o offset] [-n noterms] [-to {data|bf}] [-s ","] [-w width] input > output
#:#       -o  offset for "-to bf", default 0
#:#       -n  number of terms to be output (default 65536)
#:#       -s  separator: "," (default), ", " etc.
#:#       -to data format, of b-file format (default)
#:#       -w  maximum width of lines for "-to data" (default 65536)
#---------------------------------
use strict;
use integer;
# get options
my $debug   = 0; # 0 (none), 1 (some), 2 (more)
my $offset  = 0;
my $noterms = 65536; # very high
my $sep     = ",";
my $to      = "bf";
my $width   = 65536; # very high
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{\-d}) {
        $debug    = shift(@ARGV);
    } elsif ($opt =~ m{\-n}) {
        $noterms  = shift(@ARGV);
    } elsif ($opt =~ m{\-o}) {
        $offset   = shift(@ARGV);
    } elsif ($opt =~ m{\-s}) {
        $sep      = shift(@ARGV);
    } elsif ($opt =~ m{\-t}) {
        $to       = shift(@ARGV);
    } elsif ($opt =~ m{\-w}) {
        $width    = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while ARGV

if (1) {
    my $src_file = shift(@ARGV);
    if (! -r $src_file) {
        die "cannot read \"$src_file\"\n";
    }
    my $buffer;
    my @terms;
    open (FIL, "<", $src_file) or die "cannot read $src_file\n";
    read (FIL, $buffer, 500000000); # 500 MB
    close(FIL);
    my $n = $offset;
    if ($to =~ m{d(ata)?}) { # -to data
        @terms = 
            grep { m{\S} } # keep non-empty lines only
                map {
                    s{\#.*}{};        # remove comments
                    s{\A\s+}{};       # remove leading whitespace
                    s{\s+\Z}{};       # remove trailing whitespace
                    s{\A\-?\d+\s+}{}; # remove index and space(s)
                    $_
                } split(/\n/, $buffer);
        my $sep1 = "";
        my $line = "";
        foreach my $term (splice(@terms, 0, $noterms)) {
            if (length($line) + length("$sep1$term") <= $width) {
                $line .= "$sep1$term";
            } else {
                print "$line\n";
                $line = "$sep1$term";
            }
            $sep1 = $sep;
            $n ++;
        } # foreach $term
        print "$line\n";
    } else { # -to bf
        $buffer =~ s{[^\,\-\d]}{}g;
        $buffer =~ s{\A\,+}{};
        @terms  = split(/\,/, $buffer);
        foreach my $term (splice(@terms, 0, $noterms)) {
            print "$n $term\n";
            $n ++;
        } # foreach $term
        print "\n\n"; # for AH
    }
    print STDERR "# data_bf: terms [$offset.." . ($n - 1) . "] written\n";
} # 1
__DATA__

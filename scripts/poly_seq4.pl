#!perl

# Generate a seq4 record with CC=poly* from the parameters and append it to today's aman/date.man file
# @(#) $Id$
# 2025-07-14, enclose with egf(); .skip(), .prepend(); *CZ=73
# 2025-06-03, Georg Fischer
#
#:# Usage:
#:#   perl poly_seq4.pl $1 $2 ...
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d", $year + 1900, $mon + 1, $mday);
my $gits =  $ENV{'GITS'};
my $lite_aman =  "$gits/joeis-lite/internal/fischer/aman";
$lite_aman =~ s{\\}{\/}g;
my $makefile = "$gits/OEIS-mat/scripts/makefile";
$makefile =~ s{\\}{\/}g;

my $cc = "poly";
my $polys   = shift(@ARGV);
my $polys_org = $polys;
my $postfix = shift(@ARGV); 
my $options = join(" ", @ARGV);
my $offset  = 0;
my $dist    = "";
my $gftype  = "";
my $seqs    = "";
while (scalar(@ARGV) > 0) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{-i}) {
        $dist   = shift(@ARGV);
    } elsif ($opt =~ m{-o}) {
        $offset = shift(@ARGV);
    } elsif ($opt =~ m{-t}) {
        $gftype = shift(@ARGV);
    } else { # ignore -n
        shift(@ARGV);
    }
}
if ($dist ne "") {
    if ($gftype eq "") {
        $gftype = "0";
    }
    $cc =~ s{poly\Z}{polyx};
}
if ($gftype ne "") {
    if ($dist eq "") {
        $dist = "0";
    }
    $cc =~ s{poly\Z}{polyx};
}
my @alist = ();
#                    1     1
if ($polys =~ s{\, *A(\d+.+)}{}) { # move the enhanced A-numbers to instances at the end
    my $list = $1;  
    my @snos = split(/\, *A/, $list);
    $cc =~ s{a?\Z}{a};
    @alist = join(", ", map { &aseqno_instance($_) } @snos);
}
$postfix = "\"$postfix\"";
if ($cc =~ m{x}) {
    $postfix .= "\t$dist\t$gftype";
}
my $seqno = &last_seqno();
my $record = join("\t", "A$seqno", $cc, $offset, "\"$polys\"", $postfix, @alist) . "\n";
if (0) {
    open (PIPE, "| clip");
    print PIPE $record;
    close(PIPE);
}
print      $record; 
my $file = "$lite_aman/$timestamp.man";
open (AMAN, ">>", $file) || die "# cannot write to $file\n";
# print AMAN "# poly \"$polys_org\" $postfix $options\n";
print AMAN $record;
close(AMAN);
#----
sub aseqno_instance { # convert the enhanced aseqno syntax into an instance of the sequence
    # seqen may have less than 6 digits
    # ".skip(i)" may be appended
    # ".prepend(i1,i2...)" may be appended
    # "!" may be appended for e.g.f.s
    my ($seqenh) = @_;
    $seqenh =~ m{(\d+)}; 
    my  $nseqno = sprintf("new A%06d()", $1);
    #                 1       (    )1
    if ($seqenh  =~ m{(\.skip\(\d*\))}) {
        $nseqno = "$nseqno$1";
    }
    #                          (1   2         2 1 )
    if ($seqenh  =~ m{\.prepend\((\d+( *\, *\d+)*)\)}) {
        $nseqno = "new PrependSequence(0, $nseqno, $1)"; # normalize to offset=0
    }
    if ($seqenh =~ m{\!}) {
        $nseqno = "egf($nseqno)";
    }
    return $nseqno;
} # aseqno_instance
#----
sub last_seqno { # get aseqno from history.txt
    map {   #        1   1
            if (m{\/A(\d+)}) { # take the 1st
                return $1;
            }
        }
        split(/\n/, `make -f $makefile histoeis`);
    return "";
} # last_seqno 
__DATA__
      A polyx 0 polys postfix 0 1
A polyx 0 "polys" "postfix" 0 1

#!perl

# Annotate seq4 records: append grepped jcat25 records that reference oseqno|nseqno
# @(#) $Id$
# 2023-08-11, Georg Fischer: copied from match_align.pl
#
#:# usage:
#:#   perl gcd_annot.pl [-w width] input.seq4 > output.seq4
#
# $o... = target, $n... = source
#---------------------------------
use strict;
use integer;

my $jcat25 = "jcat25_extract.tmp"; # all with oseqno and nseqno
my $debug   = 0; # 0 (none), 1 (some), 2 (more)
my $width   = 64;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{\-d}) {
        $debug    = shift(@ARGV);
    } elsif ($opt =~ m{\-w}) {
        $width    = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while ARGV
#----------------
while (<>) {
    next if ! m{\AA\d{6}};
    s/\s+\Z//; # chompr
    my ( $oseqno, $occ, $ooff, $ogcd
       , $nseqno, $ncc, $noff, $ngcd, $odata, $ndata) = split(/\t/);
    if (1) {
        print join("\t", ($oseqno, $occ, $ooff, $ogcd)) . "\t";  # aseqno already implemented 
        #                                       parm1
        print join("\t", ($nseqno, $ncc, $noff, $ngcd, $odata, $ndata)) . "\n";  # parm2  not yet implemented 
        #                 parm2    parm3 parm4  parm5  parm6   parm7
        &xref($oseqno, $nseqno);
        &xref($nseqno, $oseqno);
        print "\n";
    }
} # while <>
#--
sub xref {
    my ($oseqno, $nseqno) = @_;
    my @lines = grep { m{$nseqno} } map { s/\A\s+//; s/\s+\Z//; $_ # trim()
        } split(/\r?\n/, `grep -P \"^.[NCFY] $oseqno\" $jcat25`);
    if (scalar(@lines) > 0) {
        print "  " . join("\n  ", @lines), "\n";
    }
} # xref
# oseqno occ  ooff ogcd nseqno  ncc   noff ngcd odata                               ndata count data
__DATA__
A065689	ngcd0	1	100	A050634	yorig	1	1	0,100,8100,168100,146168100,2208	1,81,1681,1461681,220861461681,3
A065690	ngcd0	1	10	A050635	yorig	1	1	0,10,90,410,12090,4699590,176270	1,9,41,1209,469959,176270001209,
A065765	ngcd0	1	3	A065766	yorig	1	1	3,15,39,63,93,195,171,255,363,46	1,5,13,21,31,65,57,85,121,155,13
A067348	ngcd0	1	2	A058008	yorig	1	1	2,12,30,56,84,90,132,154,182,220	1,6,15,28,42,45,66,77,91,110,126
A068501	norig	1	1	A048161	yjcdm	1	2	1,2,5,9,14,29,30,35,39,50,65,69,	3,5,11,19,29,59,61,71,79,101,131
A069486	ngcd0	1	2	A006094	yorig	1	1	12,30,70,154,286,442,646,874,133	6,15,35,77,143,221,323,437,667,8
A069918	norig	1	1	A063867	yjcd0	0	2	1,1,1,1,3,5,4,7,23,40,35,62,221,	1,2,2,2,2,6,10,8,14,46,80,70,124
A070969	ngcd0	0	3	A006485	yorig	1	1	5,9,33,513,131073,8589934593,368	3,11,171,43691,2863311531,122978

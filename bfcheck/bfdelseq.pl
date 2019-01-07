#!perl

# Evaluate Wiki files "Deleted sequences" and create a tab-separated list
# @(#) $Id$
# 2019-01-06, Georg Fischer
#
# usage:
#   perl bfdelseq.pl delseq.2017.tmp >> delseq.tsv.txt
#---------------------------------
use strict;
use integer;

my ($aseqno, $date, $comment);
my $count = 0;
while (<>) {
    s/\s+\Z//; # chompr
    my $line = $_;
    $line =~ s{\A(\<(dd|dl|ul)\>)+}{};
    if ($line =~ m{\A\<li\>\s*\<a\s+href\=\"https?\:\/\/oeis\.org\/A}) { # proper line
    	# print STDERR "$line\n";
        my @anums = ();
        # $line =~ s{\A\<li\>}{};
        while ($line =~ s{\A\<li\>([ \-\.\,]|and)*\<a\s+href\=\"https?\:\/\/oeis\.org\/(A\d+)\"\>\2\<\/a\>\s*}{\<li\>}) {
            push(@anums, $2);
        } # while @anums
        $comment = $line;
        # $comment =~ s{\<\/li\>}{};
        $comment =~ s{\&\#8212\;|\x97}{\-}g;
        # $comment =~ s{\A[ \-\.\)]+\s*}{};
        # $comment =~ s{\A\-\s*}{};
        $comment =~ s{\<[^\>]+\>}{}g;
        $comment =~ s{\s\s+}{ }g; # all whitespace to a single space
        foreach my $anum (@anums) {
            print join("\t", ($anum, $comment)) . "\n";
            $count ++;
        } # foreach $anum 
    } else { # ignore
    }
} # while <>
print STDERR sprintf("# $count deleted sequences found\n", $count);
__DATA__
<li> <a href="http://oeis.org/A200220">A200220</a> (Luschny) withdrawn in favor of <a href="http://oeis.org/A070824">A070824</a> &#8212; R. J. Mathar, P. Luschny, Nov 16 2011</li>
<li> <a href="http://oeis.org/A200248">A200248</a> (Sloane) rifo <a href="http://oeis.org/A130911">A130911</a> &#8212; N. J. A. Sloane, Nov 16 2011</li>
<li> <a href="http://oeis.org/A200046">A200046</a> (Deleham) powers of 2 repeated &#8212; T. D. Noe, Nov 14 2011</li>
<li> <a href="http://oeis.org/A200045">A200045</a> (Deleham) Lucas numbers in an array &#8212; T. D. Noe, Nov 14 2011</li>
<li> <a href="http://oeis.org/A200089">A200089</a> (Borgo) same as <a href="http://oeis.org/A073002">A073002</a> &#8212; T. D. Noe, Nov 13 2011</li>
<li> <a href="http://oeis.org/A293925">A293925</a> (Rajarshi Maiti) NOGI — Editors, Nov 16 2017</li>
<li> <a href="http://oeis.org/A294152">A294152</a> (Halfdan Skjerning) NOGI &#8212; Editors, Nov 15 2017</li>
<li> <a href="http://oeis.org/A293687">A293687</a>, <a href="http://oeis.org/A294921">A294921</a> (A. W. Ferencz) rifo <a href="http://oeis.org/A007494">A007494</a>, <a href="http://oeis.org/A032766">A032766</a> &#8212; Editors, Nov 15 2017</li>
<li> <a href="http://oeis.org/A295086">A295086</a> (Burghard Herrmann) Duplicate of <a href="http://oeis.org/A190250">A190250</a> &#8212; Editors, Nov 15 2017</li>
<li> <a href="http://oeis.org/A294992">A294992</a> (M. F. Hasler) merged into <a href="http://oeis.org/A000194">A000194</a> - <a href="/wiki/User:N._J._A._Sloane" title="User:N. J. A. Sloane">N. J. A. Sloane</a> 03:11, 14 November 2017 (UTC)</li>

#!perl

# Detect similiar OEIS sequences
# @(#) $Id$
# 2018-10-24: &compare_terms, &repair_starts
# 2018-10-20: bfc.cmd incorporated
# 2018-10-17: titles on Axxxxxx, extract always; avoid dead and fini
# 2018-10-16: count warnings
# 2018-10-05: reads &fmt=text
# 2018-10-04: copied from subseq.pl
# 2018-10-01, Georg Fischer
#
# to do: remove fini, optional listing, count warnings
#
# usage:
#   (1) perl simseq.pl -a prep [-d 0] -h 4 -l 8 < stripped | sort > stripsort.tmp
#   (2) perl simseq.pl [-a gen] [-d 0] [-min 0] [-max 999999] -p 2 [-s 8] [-n] < stripsort.tmp
#   (3) perl simseq.pl -a index < regen.date.log > index.html
#   (4) perl simseq.pl -a wget  < newseq.data.lst
#   (5) perl simseq.pl -a name  < names > namurl.tmp
#   (6) perl simseq.pl -a bfc   Ammmmmm-Annnnnn
#       -a      action:
#          "gen"erate HTML list (default),
#          "prep"rocess,
#          "index".html,
#          "wget" only
#          "name" preprocessing,
#          "bfc"  fetch and compare b-files
#       -d      debug level, 0 (none), 1 (some), 2 (more)
#       -h      minimum sequence value where comparision starts
#       -l      minimum length for both sequences
#       -min    minimal sequence number
#       -max    maximal sequence number
#       -n      = 1 (0) do (not) read file namurl.tmp
#       -p      there must be values >= 10**p in both sequences to be compared
#       -s      sleep so many seconds before each wget request
#
# file usage:
#   <  stripsort        sequence values sorted by subsequence starting with value >= h
#   <  names            sequence names (titles)
#   <> ../store         directory for locally saved A*.text and b*.txt files
#   >  Amin-Amax.html   resulting output
#---------------------------------
use strict;
use integer;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
my $commandline = join(" ", @ARGV);

# get options
my $action = "gen"; # "prep"rocess for sort, "gen"erate HTML lists
my $debug  = 0; # 0 (none), 1 (some), 2 (more)
my $higher = 4; # minimum sequence value where comparision starts
my $minlen = 8; # minimum length for both sequences
my $minseq = 0;
my $maxseq = 999999; # all
my $readnu = 1; # = 1 (0) do (not) read file namurl.tmp
my $pow10  = 2; # there must be values >= 10**p in both sequences to be compared
my $sleep  = 8; # sleep 8 s before all wget requests
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{\-a}) {
        $action = shift(@ARGV);
    } elsif ($opt =~ m{\-d}) {
        $debug  = shift(@ARGV);
    } elsif ($opt =~ m{\-h}) {
        $higher = shift(@ARGV);
    } elsif ($opt =~ m{\-l}) {
        $minlen = shift(@ARGV);
    } elsif ($opt =~ m{\-min}) {
        $minseq = shift(@ARGV);
    } elsif ($opt =~ m{\-max}) {
        $maxseq = shift(@ARGV);
    } elsif ($opt =~ m{\-n}  ) {
        $readnu = shift(@ARGV);
    } elsif ($opt =~ m{\-p}) {
        $pow10  = shift(@ARGV);
    } elsif ($opt =~ m{\-s}) {
        $sleep  = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while ARGV
my $range = sprintf("A%06d-A%06d", $minseq, $maxseq);
my @names; # with links to http://oeis.org/Axxxxxx
my @nawol; # without links
#----------------------------------------------
# perform one of the actions
if (0) {
} elsif($action =~ m{^prep}) { # preprocess for sort
    # read file "stripped"
    open(SIP, "<", "stripped") || die "cannot read file \"stripped\"\n";
    while (<SIP>) {
        next if m{\A\s*\#};
        s/\s+\Z//; # chompr
        my ($seqno, $list) = split(/\s+\,/);
        my @sequence = split(/\,/, $list);
        my $ind = 0;
        while ($ind < scalar(@sequence) and $sequence[$ind] < $higher) { # start point
            $ind ++;
        } # while $ind
        if (scalar(@sequence) - $ind >= $minlen) { # long enough
            print join(" ", splice(@sequence, $ind))
                . "\t" . join(" ", splice(@sequence, 0, $ind))
                . "\t$seqno\n";
        } # long enough
    } # while <>
    close(SIP);
    exit(0);
#----------------------
} elsif ($action =~ m{^in})   { # generate index.html from regen.data.log
    print &get_html_head("Similar OEIS Sequences");
    print <<"GFis";
<body>
<h2><a href="https://oeis.org/wiki/User:Georg_Fischer/Coincidences">Similiar OEIS Sequences</a> </h2>
C.f. <a href="https://oeis.org/wiki/User:Georg_Fischer/Coincidences" target="_new">OEIS-Wiki/User:Georg_Fischer/Coincidences</a><br />

GFis
    my $datetime;
    while (<>) { # read regen.date.log
        # A000000-A049999 608 pairs, 222 warnings - 2018-10-11 09:35:26
        s/\s+\Z//; # chompre
        if (m{(\w+\-\w+)\s+(\d+)\s+pairs\, (\d+)\D+(.*)}) {
            my $range = $1;
            my $cpair = $2;
            my $cwarn = $3;
            $datetime = $4;
            my $wider = $range;
            $wider =~ s{\-}{ \- };
            print "<br /><a href=\"http://www.teherba.org/fasces/oeis/database/$range.html\">$wider</a>"
                . sprintf("%6d pairs, %5d warnings\n", $cpair, $cwarn);
        } # pairs total
    } # while <>
    print <<"GFis";
<br />
<br />
Links to <a href="https://oeis.org">OEIS</a> content are included according to
<a href="http://www.oeis.org/wiki/The_OEIS_End-User_License_Agreement">The OEIS End-User License Agreement</a>.
<br />
Regenerated at $datetime by
<a href="mailto:dr.georg.fischer\@gmail.com" target="_new">Georg Fischer</a><br />

</body>
</html>
GFis
    exit(0);
#----------------------
} elsif ($action =~ m{^wget}) { # wget outdated files from newseq.data.lst
    while (<>) {
        s/\s//g; # remove whitespace
        my $oseqno = $_;
        my $otext = join("<br />\n", &wget($oseqno));
        print "wget $oseqno\n";
        # print $otext . "\n================================================\n";
    } # while <>
    exit(0);
#----------------------
} elsif ($action =~ m{^name}) { # preprocess names: $0 -a name < names > namurl.tmp
    my $seqno;
    while (<>) {
        s/\s+\Z//; # chompr
        next if m{\A\s*\#}; # skip comments
        my $line = $_;
        $line    =~ m{^(\w)(\d+)\s+(.*)};
        $seqno   = $2;
        my $name = $3;
        $name =~ s{\&}{\&amp\;}g;
        $name =~ s{\<}{\&lt\;}g;
        $name =~ s{\>}{\&gt\;}g;
        $name =~ s{\"}{\"\"}g;
        $nawol[$seqno] = $name;
    } # while <>

    $seqno = 0;
    while ($seqno < scalar(@nawol)) {
        my $aseqno = sprintf("A%06d", $seqno);
        if (defined($nawol[$seqno])) {
            my $nawo = $nawol[$seqno];
            my $name = $nawo;
            $name =~ s{(A)(\d{6})}
                {\<a href\=\"https\:\/\/oeis.org\/$1$2\" title\=\"$nawol[$2]\" target\=\"_new\"\>$1$2\<\/a\>}g;
            print "w\t$aseqno $name\n"; # with links
            print "o\t$aseqno $nawo\n"; # without links
        } else {
            if ($seqno < 306000) {
                print "$aseqno undefined\n";
            }
        }
        $seqno ++;
    } # while seqno
    print scalar(@nawol) . " sequence names preprocessed\n";
    exit(0);
#----------------------------------------------
} # else ($action =~ m{^gen}) { # generate
# print HTML header
my $lastwarn="startlist";
open(HTM, ">", "$range.html") or die "cannot write HTML file\n";
print HTM &get_html_head("{$range} - OEIS Similiarities");
print HTM <<"GFis";
<body>
<h2 id="$lastwarn">
  <span class="same"><a href="https://oeis.org/wiki/User:Georg_Fischer/Coincidences">Similiar
    OEIS Sequences</a></span> in the Range $range</h2>
<p><a href="." title="Overview of all lists">All ranges</a> -
  <a href="#endlist" title="Jumps to the end of the list">End of list</a>
<br />Links to <a href="https://oeis.org">OEIS</a> content are included according to
  <a href="http://www.oeis.org/wiki/The_OEIS_End-User_License_Agreement">The OEIS End-User License Agreement</a>.
<br />Generated by \"perl <a href="https://github.com/gfis/fasces/blob/master/oeis/database/simseq.pl"
   target="_new">simseq.pl</a> $commandline\" at $timestamp.
<br />Questions: Email <a href="https://oeis.org/wiki/User:Georg_Fischer" target="_new">OEIS user</a>
  <a href="mailto:dr.georg.fischer\@gmail.com">Georg Fischer</a>
</p>
<table>
GFis
#---------
# read file "namurl"
my $seqno = 0; # is printed behind the loop
if ($readnu) {
    open(NAU, "<", "namurl.tmp") || die "cannot read file \"namurl.tmp\"\n";
    while (<NAU>) {
        s/\s+\Z//; # chompr
        next if m{\A\s*\#}; # skip comments
        my $line = $_;
        $line    =~ m{\A(\w)\tA(\d+)\s+(.*)};
        my $wo   = $1;
        $seqno   = $2;
        my $name = $3;
        if ($wo   eq "o") {
            $nawol[$seqno] = $name;
        } else { # eq "w"
            $names[$seqno] = $name;
        }
    } # while NAU
    close(NAU);
} # 0
print scalar(@names) . " sequence names read\n";
#--------
# process file stripsort
my $IGNORE     = 0;
my $LISTING    = 1;
my $WARNING    = 2;
my $status     = $IGNORE; # 0 (ignore), 1 (show in list), 2 (warning)
my $warn_count = 0;
my ($omid, $oleft, $oseqno) = ("a,a,a", "b,b,b", "Axxxxxx");
my $count      = 0;
my @bifurls;  # links to b-files (from %H line)
my @bifsinds; # starting indices in b-files
my @bifeinds; # ending   indices in b-files
my @colors;   # colors pref, refn, warn
my @datsinds; # starting indices in DATA sections, 1st part of OFFSET (%O line)
my @dateinds; # ending   indices in DATA sections
my @midsinds; # starting indices of @xmid
my @mideinds; # ending   indices of @xmid
my $comment;  # final comment behind the DATA lines

while (<>) {
    s/\s+\Z//; # chompr
    my ($nmid, $nleft, $nseqno) = split(/\t/);
    if (($nmid =~ m{^$omid}) or ($omid =~ m{^$nmid})) {
        if ($oseqno lt $nseqno) {
            &check($omid, $oleft, $oseqno, $nmid, $nleft, $nseqno);
        } else {
            &check($nmid, $nleft, $nseqno, $omid, $oleft, $oseqno);
        }
    } # if substring
    ($omid, $oleft, $oseqno) = ($nmid, $nleft, $nseqno);
} # while <>

# print HTML trailer
($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
$timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
print HTM <<"GFis";
<tr><td class="bor">
$count pairs - $timestamp
    </td></tr>
</table>
<a name="endlist" />
$warn_count warnings, last is <a href="\#$lastwarn" title="Jumps to last warning">$lastwarn</a>
</body>
</html>
GFis
close(HTM);
print "$range $count pairs, $warn_count warnings - $timestamp\n";
# end action eq "gen"
#-------------------
sub check {
    my ($omid, $oleft, $oseqno, $nmid, $nleft, $nseqno) = @_;
    @datsinds = (1, 1); # if any is missing
    my $entry = "";
    $comment  = ""; # no comment so far
    @bifurls  = ("", ""); # missing
    my $ono   = substr($oseqno, 1) + 0;
    my $nno   = substr($nseqno, 1) + 0;
    if ($nno >= $minseq and $nno <= $maxseq) {
        if (!(($omid  !~ m{\d{$pow10}}o           ) and ($nmid  !~ m{\d{$pow10}}o           ))) {
        my $oname = $names[$ono];
        my $nname = $names[$nno];
        # print "names: $oname\n       $nname\n";
        if (  ($oname !~ m{$nseqno}               ) and ($nname !~ m{$oseqno}               ) ) {
        if (  ($oname !~ m{Coxeter}               ) and ($nname !~ m{Coxeter}               ) ) {
        if (!(($oname =~ m{ Weyl group }i         ) and ($nname =~ m{ Weyl group }i         ))) {
        if (!(($oname =~ m{McKay\-Thompson series}) and ($nname =~ m{McKay\-Thompson series}))) {
            $status = $LISTING;
            $count ++;
            if (($count & 0xff) == 0) {
                print "$count pairs\n";
            }
            @bifsinds   = (1, 1);
            @bifeinds   = (0, 0); # no b-files known
            ($omid, $oleft, $nmid, $nleft) = &repair_starts
            ($omid, $oleft, $nmid, $nleft);
            my $otext   = join("<br />\n", &wget($oseqno));
            my $ntext   = join("<br />\n", &wget($nseqno));
            $bifurls[0] = &get_bif_range(0, $oseqno, $otext);
            $bifurls[1] = &get_bif_range(1, $nseqno, $ntext);
            $entry .= &compare_texts($oseqno, $otext, $nseqno, $ntext);
            # determine the starting indices of @xmid
            $midsinds[0] = $datsinds[0] + scalar(split(/\s+/, $oleft));
            $midsinds[1] = $datsinds[1] + scalar(split(/\s+/, $nleft));
            ($omid, $nmid) = &strong_last($omid, $nmid);
            my $lenol  = length($oleft);
            my $lennl  = length($nleft);
            my ($olead, $nlead) = ("", "");
            if      ($lenol == $lennl) {
                # ok
            } elsif ($lenol <  $lennl) {
                $olead = (" " x ($lennl - $lenol));
            } else { #lenol >  $lennl
                $nlead = (" " x ($lenol - $lennl));
            }
            $entry .= <<"GFis";
    <a href="http://oeis.org/$oseqno" target="_blank">$oseqno</a> $oname<br />
    <a href="http://oeis.org/$nseqno" target="_blank">$nseqno</a> $nname<br />
    <span class="prefor">$olead a($datsinds[0]) = $oleft</span>
    <span class="narrow"><span class="same">$omid $bifurls[0]</span><br />
    <span class="prefor">$nlead a($datsinds[1]) = $nleft</span>
    <span class="narrow"><span class="same">$nmid $bifurls[1]</span>
GFis
            if ($status >= $LISTING) {
                if ($status >= $WARNING) {
                    $lastwarn = "${oseqno}_$nseqno";
                    # $lastwarn =~ s{A}{x}g;
                    $warn_count ++;
                }
                if ($colors [0] eq "refn" or  $colors [1] eq "warn") { # not both references
                    $comment .= "<br /><span class=\"comt\">"
                    	. &compare_terms($oseqno, $nseqno)
                    	. "</span>";
                } # not both references
                print HTM <<"GFis";
<tr id="${oseqno}_$nseqno"><td id="$nseqno" class="bor">
$entry $comment
</td></tr>
GFis
            } # is_chosen
        } # not both "McKay-Thompson series"
        } # not both " Weyl group "i
        } # not some "Coxeter"
        } # not referenced in other name
        } # numbers >= 10**($pow10-1) somewhere
    } # $nseqno in range
} # check
#----------------------
sub repair_starts { # shift the start of the coinciding terms downwards from mid to left
    my ($omid, $oleft, $nmid, $nleft) = @_;
    my @omids  = split(/\s+/, $omid );
    my @olefts = split(/\s+/, $oleft);
    my @nmids  = split(/\s+/, $nmid );
    my @nlefts = split(/\s+/, $nleft);
    my $ollen  = scalar(@olefts);
    my $nllen  = scalar(@nlefts);
    while ($ollen > 0 and $nllen > 0 and $olefts[$ollen - 1] == $nlefts[$nllen - 1]) { # shift
        unshift(@omids, pop(@olefts));
        unshift(@nmids, pop(@nlefts));
        $ollen  = scalar(@olefts);
        $nllen  = scalar(@nlefts);
    } # while shifting
    return ( join(" ", @omids), join(" ", @olefts)
           , join(" ", @nmids), join(" ", @nlefts)
           );
} # repair_starts
#----------------------
sub strong_last { # emphasize last coinciding term
    my ($omid, $nmid) = @_;
    my @omids = split(/\s+/, $omid);
    my @nmids = split(/\s+/, $nmid);
    my $last  = scalar(@omids);
    if (scalar(@nmids) < $last) { # min(#$omids, #$nmids)
        $last = scalar(@nmids);
    }
    $last --;
    $mideinds[0] = $midsinds[0] + $last;
    $mideinds[1] = $midsinds[1] + $last;
    $omids[$last] = "<strong>$omids[$last] = a($mideinds[0])</strong></span>";
    $nmids[$last] = "<strong>$nmids[$last] = a($mideinds[1])</strong></span>";
    $omid = join(" ", @omids);
    $nmid = join(" ", @nmids);
    return ($omid, $nmid);
} # strong_last
#----------------------
sub compare_texts {
    my ($oseqno, $otext, $nseqno, $ntext) = @_;
    my $result = "";
    if ($otext =~ m{$nseqno}) {
        $colors[0] = "refp";
        $result .= &get_extract(0, $oseqno, $colors[0], $otext)
                 . &get_refs   (0, $oseqno, $nseqno   , $otext);
    } else {
        $colors[0] = "refn";
        $result .= &get_extract(0, $oseqno, $colors[0], $otext);
    } # $nseqno in $obuf
    $result .= "</span><br />\n";

    if ($ntext =~ m{$oseqno}) {
        $colors[1] = "refp";
        $result .= &get_extract(1, $nseqno, $colors[1], $ntext)
                 . &get_refs   (1, $nseqno, $oseqno   , $ntext);
    } else {
        $colors[1] = "warn";
        if ($colors[0] eq "refp") {
            $colors[1] = "refn"; # does not count as warning
        } else {
        }
        if ($status >= $LISTING) {
            $status = $WARNING;
        }
        $result .= &get_extract(1, $nseqno, $colors[1], $ntext);
    } # $oseqno in $nbuf
    $result .= "</span><br />\n";

    return $result;
} # compare_texts
#----------------------
sub compare_terms { # checks the b-file contents, and compare as much as possible
    #   $bfcomp = "<br /><span class=\"comt\"><a href=\"\""
    #           . " title=\"perl simseq.pl -a bfc $oseqno $nseqno\""
    #           . " onclick=\"bfc(\'$oseqno $nseqno\');"
    #           . " return false;\">bfc</a></span>";
    my ($oseqno, $nseqno) = @_;
    my $idelta = $midsinds[0] - $midsinds[1];
    my $result = "a(n) = ${oseqno}(n" # a(n) is $nseqno
            . ($idelta == 0 ? "" : $idelta > 0 ? "+$idelta" : $idelta) . ") for ";
    if ($bifurls[0] ne ""     and $bifurls[1] ne ""    ) { # non-generated b-files
        my @obifterms = &get_bifterms(0, $oseqno, $bifsinds[0], $bifeinds[0]);
        my @nbifterms = &get_bifterms(1, $nseqno, $bifsinds[1], $bifeinds[1]);
        my $oind = $midsinds[0];
        my $nind = $midsinds[1];
        my $busy = 1;
        while ($busy == 1 and $oind <= $bifeinds[0] and $nind <= $bifeinds[1]) { # compare
            if ($debug >= 3) {
                print "[$oind] $obifterms[$oind]?$nbifterms[$nind]; ";
            }
            if ($obifterms[$oind] != $nbifterms[$nind]) {
                $busy = 0; # break loop
            }
            $oind ++;
            $nind ++;
        } # while comparing
        if ($debug >= 3) {
            print "\nbusy=$busy\n";
        }
        $oind --;
        $nind --;
        $result .= "$midsinds[1] <= n ";
        if ($busy == 1) { # there was no difference
            $result .= "\&lt;= $nind";
        } else { # difference
            $result .= "\&lt; $nind, but a($nind) = $nbifterms[$nind]"
                . " differs from ${oseqno}($oind) = $obifterms[$oind]";
            if ($debug >= 2) {
                $result .= "; midsinds=" . join(",", @midsinds);
            }
        } # difference
        # with bf-file compare
    } else { # no b-file compare
        $result .= "n \&gt;= " . ($midsinds[1]);
    } # no b-file compare
    $result .= ". - ~~~~";
    return $result;
} # compare_terms
#----------------------
sub get_bif_range { # extract the range of the b-file, if any
    my ($lix, $oseqno, $otext) = @_;
    my $seqno_A = $oseqno; # OEIS seqno minus A
    $seqno_A =~ s{\D}{}g;
    my @obuf = split(/\n/, $otext);
    my $result = "";
    my $bflink = join("", grep(m{\>Table of n\,\s*a\(n\)}
                        , grep(m{^\%[H]}
                        , @obuf)));
    if ($debug >= 1) {
        print "\%H($oseqno) = \"$bflink\"\n";
    }
    if ($bflink =~ m{ n\s*\=\s*(\-?\d+)\s*\.\.\s*(\-?\d+)\<}) { # standard link to b-file
        $bifsinds[$lix] = $1;
        $bifeinds[$lix] = $2;
        $result = " ... <a href=\"https://oeis.org/A$seqno_A/b$seqno_A.txt\""
                . " target=\"_new\">b$seqno_A.txt($bifsinds[$lix]..$bifeinds[$lix])</a>";
    } else { # no standard link to b-file
        $bifsinds[$lix] = 1;
        $bifeinds[$lix] = 0;
        $result = "";
    }
    return $result; # non-empty if there was a standard link to the b-file
} # get_bif_range
#----------------------
sub get_extract { # extract OFFSET, KEYWORDS and AUTHOR
    my ($lix, $seqno, $class, $otext) = @_;
    my @obuf = split(/\n/, $otext);
    my @extract = map { s{\<br\s*\/\>}{ }g; $_ } grep { m{^\%[KOA]} } @obuf;
    my $author   = join(" ", grep { m{^\%[A]} } @extract);
    my $keywrd   = join(" ", grep { m{^\%[K]} } @extract);
    my $offset   = join(" ", grep { m{^\%[O]} } @extract);
    $offset =~ m{(\-?\d+)\,};
    $datsinds[$lix] = $1;
    $bifsinds[$lix] = $datsinds[$lix];
    # A004279 %K easy,nonn %O 0,2 %A _N. J. A. Sloane_.
    $author =~ s{\%A\s*\_([^\_]+)\_}
                {\%A \<a href\=\"https:\/\/oeis.org\/wiki\/User\:$1\" target\=\"_new\"\>$1\<\/a\>};
    $keywrd =~ s{(\W)more(\W)}
                {$1\<span class\=\"more\"\>more\<\/span\>$2};
    if (($keywrd =~ s{(\W)dead(\W)}
                     {$1\<span class\=\"dead\"\>dead\<\/span\>$2}) > 0) {
        $status = $IGNORE;
    }
    if (($keywrd =~ s{(\W)fini(\W)}
                     {$1\<span class\=\"fini\"\>fini\<\/span\>$2}) > 0) {
        $status = $IGNORE;
    }
    return "<span class=\"$class\">"
        . "<a href=\"https://oeis.org/$seqno\" target=\"_new\">$seqno</a> "
        . ($lix == 0
          ? "<a href=\"\#$lastwarn\" title=\"Jump to warning \#$warn_count\">&lt;</a> "
          : <<"GFis"
    <a href="https://oeis.org/edit?seq=$seqno" title="Edit $seqno"
        onclick="window.open('https://oeis.org/edit?seq=$seqno', 'newwindow');
            return false;">&gt;</a>
GFis
          )
        . join(" ", ($keywrd, $offset, $author));
} # get_extract
#----------------------
sub get_refs { # extract any lines which refer the other seqno
    my ($lix, $oseqno, $nseqno, $otext) = @_;
    my @obuf = map {
            s{\>($nseqno)\<}{\>\<strong\>$1\<\/strong\>\<}g;
            s{\<br\s*\/?\>}{ }g;
            $_
            } split(/\n/, $otext);
    return " " . join("", grep { m{$nseqno} } @obuf);
} # get_refs
#----------------------
sub get_bifterms {
    my ($lix, $aseqno, $bifsind, $bifeind) = @_;
    my $bseqno = "b" . substr($aseqno, 1);
    my @pairs = &wget($bseqno);
    my @result = ();
    while (scalar(@result) < $datsinds[$lix]) { # care for offset > 0
        push(@result, "");
    } # care for offset
    my $npair = scalar(@pairs);
    if ($npair != $bifeind - $bifsind + 1) {
        print "** $bseqno: wrong range $bifsind..$bifeind ($npair terms)\n";
        $comment .= "<br /><span class=\"err\">$bseqno: wrong range $bifsind..$bifeind ($npair terms)</span>";
    }
    while (substr($pairs[0], 0, 1) eq "-") { # care for offset < 0
        print "** $bseqno: negative offset in \"$pairs[0]\"\n";
        $comment .= "<br /><span class=\"err\">$bseqno:  negative offset in \"$pairs[0]\"</span>";
        shift(@pairs); # remove negative indices
        $bifsinds[$lix] ++;
        $bifsind ++;
    } # while negative
    my $ind = 0;
    while ($ind < scalar(@pairs)) {
        my ($n, $an) = split(/ +/, $pairs[$ind]);
        if ($n != $bifsind) {
            print "** $bseqno: non-sequential index n=$n\n";
            $comment .= "<br /><span class=\"err\">$bseqno: non-sequential index n=$n</span>";
        }
        push(@result, $an);
        if ($debug >= 3) {
            print "push($n, $an), pairs[$ind]=\"$pairs[$ind]\"\n";
        }
        $bifsind ++;
        $ind ++;
    } # while $ind
    return @result;
} # get_bifterms
#----------------------
sub wget {
    # old call: my $otext = &wget("https://oeis.org/search?q=id:$oseqno\\&fmt=text", "$oseqno.text");
    # my ($src_url, $tar_file) = @_;
    my ($xseqno) = @_;
    my $src_url;
    my $tar_file;
    my @result;
    if (0) {
    } elsif ($xseqno =~ m{^A}) {
        $src_url  = "https://oeis.org/search?q=id:$xseqno\\&fmt=text";
        $tar_file = "../store/$xseqno.text";
    } elsif ($xseqno =~ m{^b}) {
        $src_url  = "https://oeis.org/$xseqno.txt";
        $tar_file = "../bfiles/$xseqno.txt";
    } else {
        die "wrong parameter in \"\&wget($xseqno)\"\n";
    }
    if (! -r $tar_file) {
        print "sleeping $sleep s before wget $tar_file\n";
        sleep $sleep;
        print `wget -o log.tmp -O $tar_file $src_url`;
    }
    my $buffer;
    open(FIL, "<", $tar_file) or die "cannot read $tar_file\n";
    read(FIL, $buffer, 100000000); # 100 MB
    close(FIL);

    if (0) {
    } elsif ($xseqno =~ m{^A}) {
        @result = map {
                s{^(\%\w)\s+(\w+)\s+}
                 {$1 };
                s{(A(\d{6}))}
                 {\<a href\=\"https\:\/\/oeis.org\/$1\" target\=\"_new\" title=\"$nawol[$2]\"\>$1\<\/a\>}g;
                $_
            } grep { m{^\%} } split(/\r?\n/, $buffer);
    } elsif ($xseqno =~ m{^b}) {
        @result = grep { m{\S} } # keep non-empty lines only
            map {
                s{\#.*}{};   # remove comments
                s{^\s+}{};   # remove leading whitespace
                s{\s+\Z}{};  # trailing whitespace
                s{\s\s+}{ }; # single space
                $_
            } split(/\r?\n/, $buffer);
        if ($debug >= 3) {
            print "wget: ". join("/", @result) . "\n";
        }
    } else {
        die "wrong parameter in \"\&wget($seqno)\"\n";
    }
    return @result;
} # wget
#-----------------------------
sub get_html_head {
    my ($title) = @_;
    return <<"GFis";
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd" [
]>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>$title</title>
<meta name="generator" content="https://github.com/gfis/fasces/blob/master/oeis/database/subseq.pl" />
<meta name="author"    content="Georg Fischer" />
<style>
body,table,p,td,th
        { font-family: Verdana,Arial,sans-serif; }
table   { border-collapse: collapse; }
td      { padding-right: 4px; }
tr,td,th{ text-align: left; vertical-align:top; }
.arr    { background-color: white          ; color: black; }
.bor    { border-left  : 2px solid gray    ;
          border-top   : 2px solid gray    ;
          border-right : 2px solid gray    ;                                 }
.refp   { background-color: lightgreen;    } /* refers to the partner */
.warn   { background-color: yellow;        } /* no reference to the partner and newer */
.comt   { background-color: peachpuff;     } /* lightpink; #fff0f0; a lightred like in history, for conclusion */
.err    { background-color: red; color: white; } /* for errors */
.refn   { background-color: greenyellow;   } /* no reference to the partner */
.more   { color:white  ; background-color: blue;      }
.dead   { color:white  ; background-color: gray;      }
.fini   { color:black  ; background-color: turquoise; }
.narrow { font-size    : smaller;  }
.prefor { font-family  : monospace; white-space: pre;
          font-size    : large; font-weight: bold; }
.same   { background-color:lightyellow }
</style>
<script>
    <!-- copy a command with the parameter to the clipboard -->
    function bfc(parm) {
        const txa = document.createElement('textarea');
        txa.value = "perl simseq.pl -a bfc " + parm + "\\n";
        document.body.appendChild(txa);
        txa.select();
        document.execCommand('copy');
        document.body.removeChild(txa);
        return "";
    } // clip
</script>
</head>
GFis
} # get_html_head
#--------------------------------------
__DATA__
https://oeis.org/search?q=id:A007079&fmt=text

# Greetings from The On-Line Encyclopedia of Integer Sequences! http://oeis.org/

Search: id:a007079
Showing 1-1 of 1

%I A007079 M2142
%S A007079 1,2,24,2640,3230080,48251508480,9307700611292160,
%T A007079 24061983498249428379648,855847205541481495117975879680,
%U A007079 427102683126284520201657800159366676480,3035991776725501434069099002640396043332019814400,311112533558482034321687955029997989477274014274150137856000
%N A007079 Number of labeled regular tournaments with 2n+1 nodes.
%D A007079 N. J. A. Sloane and Simon Plouffe, The Encyclopedia of Integer Sequences, Academic Press, 1995 (includes this sequence).
%H A007079 B. D. McKay, <a href="http://cs.anu.edu.au/~bdm/papers/LabelledEnumeration.pdf">Applications of a technique for labeled enumeration</a>, Congress. Numerantium, 40 (1983), 207-221.
%H A007079 B. D. McKay, <a href="http://users.cecs.anu.edu.au/~bdm/papers/rt.pdf">The asymptotic numbers of regular tournaments, Eulerian digraphs and Eulerian oriented graphs</a>, Combinatorica 10 (1990), 367-377.
%H A007079 <a href="/index/To#tournament">Index entries for sequences related to tournaments</a>
%F A007079 a(n) = coefficient of (x1 x2 ... xn)^((n-1)/2) in (x1+x2)(x1+x3)...(x(n-1)+xn) - Jim Ferry (ferry(AT)metsci.com), Sep 29 2005
%t A007079 (* This program is not convenient for more than 5 terms *)
%t A007079 a[n_] := (xx = Sequence @@ Table[ {x[k], 0, n}, {k, 1, 2*n + 1}]; Coefficient[ Normal @ Series[ Product[x[j] + x[k], {j, 1, (2*n + 1) - 1}, {k, j + 1, (2*n + 1)}], xx], Product[x[j] , {j, 1, (2*n + 1)}]^(((2*n + 1) - 1)/2)]); a[0] = 1; Table[a[n], {n, 0, 4}] (* _Jean-François Alcover_, Apr 10 2013 *)
%o A007079 (PARI) /* not convenient for more than 5 terms: */
%o A007079 sym(k)=eval(Str("x" k));
%o A007079 pr(n)=prod(j=1,n-1, prod(k=j+1, n, sym(j) + sym(k) ) );
%o A007079 a(n)=
%o A007079 {
%o A007079     my( p = pr(2*n+1) );
%o A007079     for (k=1, 2*n+1, p = polcoeff(p, n, sym(k) );  );
%o A007079     return( p );
%o A007079 } \\ _Joerg Arndt_, Apr 10 2013
%o A007079 (PARI)
%o A007079 a(n)={ local(M=Map());
%o A007079 my(acc(p, v)=my(z); mapput(M, p, if(mapisdefined(M, p, &z), z+v, v)));
%o A007079 my(recurse(p, i, q, v, e)=if(e<=n, if(i<0, acc(x^e+q, v), my(t=polcoeff(p, i)); for(k=0, if(i==n, 0, t), self()(p, i-1, (t-k+x*k)*x^i+q, binomial(t, k)*v, e+t-k)))));
%o A007079 my(iterate(v, k, f)=for(i=1, k, v=f(v)); v);
%o A007079 iterate(Mat([1, 1]), 2*n, src->M=Map(); for(i=1, matsize(src)[1], my(p=src[i, 1]); recurse(p, poldegree(p), 0, src[i, 2], 0)); Mat(M))[1,2]
%o A007079 } \\ _Andrew Howroyd_, Jan 08 2018
%K A007079 nonn,nice
%O A007079 0,2
%A A007079 _N. J. A. Sloane_, _Mira Bernstein_
%E A007079 a(11) from _Andrew Howroyd_, Jan 08 2018

# Content is available under The OEIS End-User License Agreement: http://oeis.org/LICENSE
#----------------------
regen.date.log:

make[1]: Entering directory '/cygdrive/c/Users/User/work/gits/fasces/oeis/database'
perl simseq.pl -p 2 -min 000000 -max 049999 < stripsort.tmp
320328 sequence names read
128 pairs
256 pairs
384 pairs
512 pairs
A000000-A049999 608 pairs total - 2018-10-11 09:35:26
perl simseq.pl -p 2 -min 050000 -max 099999 < stripsort.tmp
320328 sequence names read
128 pairs
256 pairs
384 pairs
512 pairs
640 pairs
A050000-A099999 762 pairs total - 2018-10-11 09:35:53

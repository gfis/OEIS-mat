#!perl

# Print a line with the first terms
# @(#) $Id$
# 2019-01-12, Georg Fischer
#
# usage:
#   perl keyword.pl [-d level] [-a {split|html}] [-l 256] input > output
#       -d level    debug level: 0 (none), 1 (some), 2 (more)
#       -a split    split %K lines
#       -a html     generate HTML page for statistics
#       -l 256      limit for list of sequences
#---------------------------------
use strict;
use integer;
# get options
my $action = "split";
my $limit  = 256;
my $debug  = 0; # 0 (none), 1 (some), 2 (more)
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{\-d}) {
        $debug    = shift(@ARGV);
    } elsif ($opt =~ m{\-a}) {
        $action   = shift(@ARGV);
    } elsif ($opt =~ m{\-l}) {
        $limit    = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while ARGV

my @nawol; # names without links
&get_names();
#----------------------------------------------
# perform one of the actions
if (0) {
} elsif($action =~ m{^split}) { # preprocess for sort
    while (<>) {
        next if m{\A\s*\#};
        s/\s+\Z//; # chompr
        my ($kk, $aseqno, $list) = split(/\s+/);
        foreach my $keyw (split(/\,/, $list)) {
            print "$aseqno $keyw\n";
        } # foreach
    } # while <>
} elsif($action =~ m{^html}) { # preprocess for sort
    print &get_html_head();
    print <<"GFis";
<body>
<h2><a href="https://oeis.org" target="_blank">OEIS</a> Keyword Statistics
</h2>
<p>
Date: 2018-01-08. 
<br />Questions, suggestions: email <a href="mailto:georg.fischer\@t-online.de">Georg Fischer</a>
<br /><a href="https://oeis.org/wiki/Clear-cut_examples_of_keywords" target="_blank">List of keywords in OEIS Wiki</a>

<table class="bor">
<tr><th class="bor">Keyword</th><th class="bor">Count</th>
<th class="bor" width="80%">Occurrences</th></tr>
GFis
    my $kw_count = 0;
    while (<>) {
        s/^\s+//g;
        s/\s+\Z//g; # chompr
        my ($count, $keyw) = split(/\s+/);
        $kw_count ++;
        print <<"GFis";
<tr><td class="bor">$keyw</td><td class="arr bor">$count</td><td class="bor">
GFis
        if ($count <= $limit) {
            print &get_sequences($keyw) . "\n";
        } else {
            print "<a href=\"https://oeis.org/search?q=keyword:$keyw\""
                . " target=\"_blank\">OEIS search</a>\n";
        }
    print <<"GFis";
</td></tr>
GFis
    } # while <>
    print <<"GFis";
</table>
<p>$kw_count keywords</p>
</body>
</html>
GFis
    # html
} else { 
    die "invalid action \"$action\"\n";
}
exit(0);
#----------------------
sub get_sequences {
    my ($keyw) = @_;
    my $result = "";
    my $cmd = "grep -E \"$keyw\" keyw_split.1.tmp";
    my @seqs = sort(map { substr($_, 0, 7) }
        split(/\r?\n/, `$cmd`));
    $result = join(", ", map {             
    		s{(A)(\d{6})}
             {\<a href\=\"https\:\/\/oeis.org\/$1$2\" title\=\"$nawol[$2]\" target\=\"_new\"\>$1$2\<\/a\>}g;
            $_
        } @seqs);
    return $result;
} # get_sequences
#------------------------------
sub get_names {
    my $seqno;
    open(NAM, "<", "../coincidence/database/names") || die "cannot read names\n";
    while (<NAM>) {
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
    } # while <NAM>
    close(NAM);
    print STDERR scalar(@nawol) . " sequence names preprocessed\n";
} # get_names
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
<meta name="generator" content="https://github.com/gfis/OEIS-mat/blob/master/coincidence/database/simseq.pl" />
<meta name="author"    content="Georg Fischer" />
<style>
body,table,p,td,th
        { font-family: Verdana,Arial,sans-serif; }
table   { border-collapse: collapse; }
td      { padding-right: 4px; }
tr,td,th{ text-align: left; vertical-align: top; }
.arr    { text-align: right; background-color: white; color: black; }
.bor    { border-left  : 1px solid gray    ;
          border-top   : 1px solid gray    ;
          border-right : 1px solid gray    ;                                
          border-bottom: 1px solid gray    ;  }
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
</head>
GFis
} # get_html_head
#--------------------------------------
#-----------------------------
__DATA__
%K A000001 nonn,core,nice,hard
%K A000002 nonn,core,easy,nice
%K A000003 nonn,nice,easy
%K A000004 core,easy,nonn,mult
%K A000005 easy,core,nonn,nice,mult,hear
%K A000006 nonn,easy,nice
%K A000007 core,nonn,mult,cons,easy
%K A000008 nonn,easy,nice
%K A000009 nonn,core,easy,nice,changed
%K A000010 easy,core,nonn,mult,nice,hear,changed
%K A000011 nonn,nice,easy
%K A000012 nonn,core,easy,mult,cofr,cons,tabl,changed
%K A000013 nonn,nice,easy,changed
%K A000014 nonn,easy,core,nice
%K A000015 nonn,easy
%K A000016 nonn,nice,easy

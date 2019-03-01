#!perl

# Extract linear recurrence signatures (and initial terms) from JSON grep
# @(#) $Id$
# 2019-02-28: formula
# 2019-02-25: write also lrindx_spec.txt
# 2019-02-22: tables 'lrindx' and 'lrlink'
# 2019-02-19, Georg Fischer
#
#:# Usage:
#:#   perl extract_linrec.pl -m mode [-f spec_file] [-d debug] infile > outfile
#:#   -m  index    parse https://oeis.org/w/index.php?title=Index_to_OEIS:_Section_Rec?action=raw
#:#                and write lrindx.txt, lrindx_spec.txt
#:#       wrindx   read merged file and lrindx_spec.txt and regenerate the index raw wiki file
#:#       mmacall  parse Mathematica calls: LinearRecurrence[{1, 0, 1, -1}, {2, 3, 5, 10}, 50]
#:#       link     parse links in JSON: "\u003ca href=\"/index/Rec#order_02\"\u003eIndex entries for linear recurrences with constant coefficients\u003c/a\u003e, signature (7,-1)"
#:#                and write lrlink.txt
#:#       lrindx   write CREATE SQL for table 'lrindx'
#:#       lrlink   write CREATE SQL for table 'lrlink'
#:#   -m  formula  scan grepped JSON formulas "a(n) = ..." for lin.rec. syntax
#
# lrindx_spec.txt has the following records:
# fil   0       header
# ord   order   comment
# sig   sign.   comment
# seq   aseqno  comment
# fil   9       trailer
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);

my $debug = 0;
my $mode  = "link";
my $spec_file = "lrindx_spec.txt";
if (scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{f}) {
        $spec_file = shift(@ARGV);
    } elsif ($opt  =~ m{m}) {
        $mode      = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my @parts;
my $line;
my $aseqno;
my $lorder  = 0;
my $signature;
my @signatures;
my $sigorder;
my $initerm = "";
my @initerms;
my $spec    = "";
my $termno  = 0;
my $buffer  = "";
my $type;
my $key;
my $value;
my $state;
my $comment;
my $void_ord = "88888888";
my $void_sig = "88888888";
my $void_sno = "A000000";
my %seqs = ();
my $trunc_len = 240;
my $prefix = ""; # for comment before signature

if (0) { # switch for $mode

} elsif ($mode =~ m{lrindx}) {
    &create_sql("lrindx");

} elsif ($mode =~ m{lrlink}) {
    &create_sql("lrlink");

} elsif ($mode =~ m{wrindx}) {
    open(SPEC, "<", $spec_file) || die "cannot read \"$spec_file\"\n";
    print &read_spec() . "\n"; # print header
    my $separator = ": " ;
    my $old_line  = join("\t", (-1, $void_sig, $void_sno, 0, $void_sig, "#")); # 5 fields in split below
    my $new_line;
    %seqs = ();
    while (<>) {
        $new_line = $_;
        $new_line =~ s/\s+\Z//; # chompr
        if ($new_line !~ m{\A\s*\Z}) { # not blank
            # $new_line =~ s{\'\'}{\'}g;
            # SELECT lorder,  compsig,  aseqno, sigorder, signature, comment FROM lrindx
            if ($debug > 0) {
                print "\n";
                print "# old: $old_line\n";
                print "# new: $new_line\n";
            }
            my ($oord, $ocos, $osno, $osor, $osig, $ocom) = split(/\t/, $old_line);
            my ($nord, $ncos, $nsno, $nsor, $nsig, $ncom) = split(/\t/, $new_line);
            $ocom = substr($ocom, 1); # remove shielding "#"
            $ncom = substr($ncom, 1);
            if (0) {
            } elsif ($oord != $nord) { # new order
                if ($nord != $void_ord) { 
                    &write_seqs("");
                    print "\n====<span id=\"order " . sprintf("%02d", $nord) 
                        . "\"\>recurrence, linear, order $nord:</span>====";
                    if ($ncom ne "") {
                        print "\n$ncom\n";
                    }
                } # != $void_ord
            } elsif (($ocos ne $ncos)) { # new signature
                if (scalar(%seqs) > 0) {
                    &write_seqs("");
                } else {
                    print "\n";
                }
                # print STDERR "ncom=\"$ncom\"\n" if ($debug > 0);
                my $sharp_pos = index($ncom, "?");
                if ($sharp_pos > 0) {
                    print substr($ncom, $sharp_pos + 1) . "\n";  # POSTMATCH
                    $ncom =~ s{\s*\?.*}{}; #  substr($ncom, 0, $sharp_pos - 1); # PREMATCH; the "-1" is empirical
                }
                if ($ncom =~ m{\<strong\>}) {
                    print ":<strong>($nsig)</strong>:";
                    if ($nsno ne $void_sno) { # new aseqno
                       $seqs{"A$nsno"} = $ncom;
                    }
                } else {
                    print ":($nsig)$ncom";
                }
            } elsif ($nsno ne $void_sno) { # new aseqno
                $seqs{"A$nsno"} = $ncom;
            }
            $old_line = $new_line;
        } # not blank
    } # while <>
    &write_seqs("");
    print "\n"; # last line
    print &read_spec() . "\n"; # print trailer
    close(SPEC);
    # wrindx

} elsif ($mode =~ m{index}) {
    open(SPEC, ">", $spec_file) || die "cannot write \"$spec_file\"\n";
    $buffer        = "";
    $state         = 0; # in header
    $prefix        = ""; # passed through
    my $old_line   = "";
    my $new_line;
    $lorder        = -1;
    while (<>) {
        $new_line  = $_;
        $new_line  =~ s/\s+\Z//; # chompr
        $old_line  =~ s/\s+\Z//; # chompr
        $old_line  =~ s/\t/ /g; # precaution for split in 'wrindx'
        # $lorder is passed through
        $aseqno    = $void_sno;
        $signature = - $void_sig;
        $comment   = "";
        if (0) {
        } elsif ($state == 9) {
            $buffer .= $old_line;
        } elsif ($old_line =~ m{\A\s*\Z}) { 
            # ignore blank line
        } elsif ($old_line =~ m{\>recurrence\,\s*linear\,\s*order\s+(\d+)\:?\<}) { # order in index
            # >recurrence, linear, order 2:<
            $lorder = $1; # order from <span> element
            if ($state == 0) { # in header, only once
                &write_spec($buffer); # header
                $buffer = "";
                $state = 1; # in order
            }
            if (0 and ($new_line =~ m{\A[^\:\(\d]})) { # no signature in following line
                $comment = $new_line;
                $new_line = ""; # will be ignored
            }
            &index_output();
        } elsif ($old_line =~ m{\A\:\s*\(([^\)]*)\)}) { # signature in index
            $old_line =~ s{\((total\s+of\s+\d+[^\)]+)\)}{\[$1\]}; # shield, translate () into []
            $old_line =~ m{\A\:\s*\(([^\)]*)\)}; # whole ()
            $signature  = $1;
            $signature  =~ tr{\[\]}{\(\)}; # round () again
            $old_line =~ s{\A\:\s*\(([^\)]*)\)\s*}{}; # remove whole () signature
            $comment = "";
            if ($old_line =~ m{(A\d{6})}) { # something before the first aseqno
                $comment  = $`; # PREMATCH;
                $old_line = substr($old_line, length($comment)); # remove prefix before the ":"
            } else {
                $comment  = $old_line;
                $old_line = "";
            }
            if (length($prefix) > 0) {
                $comment .= "?" . $prefix;
                $prefix = "";
            }
            &index_output();
            my $old_seqno = $void_sno;
            if ($debug > 0) {
                print "split \"$old_line\"\n";
            }
            my @parts = split(/\,\s*/, $old_line); 
            %seqs = ();
            my $ipart = 0;
            while ($ipart < scalar(@parts)) {
                my $part = $parts[$ipart];
                if ($part =~ m{\A(A\d+)(.*)}) { # 
                    my $ano  = $1; 
                    my $cmt  = $2;
                    if ($old_seqno ge $ano) { # non-increasing
                        print STDERR "# non-increasing: $old_seqno ge $ano\n";
                    }
                    $old_seqno  = $ano;
                    $seqs{$ano} = $cmt;
                } else { # no A-number, append comment to previous
                    $seqs{$old_seqno} .= ", $part";
                } # append
                $ipart ++;
            } # while $ipart
            foreach my $key (sort(keys(%seqs))) {
                $aseqno  = $key;
                $comment = $seqs{$key};
                &index_output();
            } # foreach
        } elsif ($old_line =~ m[\{\{Index header\}\}]) {
            if ($state == 0) {
                $buffer .= "$old_line\n";
            } else {
                $buffer  = "$old_line\n"; # start fresh buffer
                $state = 9;
            }
        } elsif ($state == 0) {
            $buffer .= "$old_line\n";
        } elsif ($old_line =~ m{\A\s*\Z}) {
            # ignore blank line
            $prefix = "";
        } else { # <span id="fibo-16"></span>
            if (length($prefix) > 0) {
                $prefix .= "\n";
            }
            $prefix .= $old_line;
        }
        $old_line = $new_line;
    } # while <>
    ($lorder, $signature, $aseqno, $sigorder, $signature, $comment) 
        = ($void_ord, $void_sig, $void_sno, 0, $void_sig, "will be ignored"); 
    &index_output(); # this line is > all $lorder, and will be ignored
    $buffer .= $old_line;
    &write_spec($buffer); # trailer
    close(SPEC);

} else { # other extraction modes
    while (<>) {
        s/\s+\Z//; # chompr
        $line = $_;
        if (0) {
        } elsif ($mode =~ m{link|mmacall}) {
            if ($line =~ m{(A\d{6})\.json\:}) { # link, mmacall
                $aseqno    = $1;
                $initerm   = "";
                $termno    = 0;
                $signature = $void_sig;
                $lorder    = $void_ord;
                if (0) {
                } elsif ($mode eq "link") {
                    if ($line =~ m{signature\s*\(([^\)]+)}i) {
                        $signature = $1;
                    }
                    if ($line =~ m{\#order\D*(\d+)}) {
                        $lorder    = $1;
                    }
                    &output;
                } elsif ($mode eq "mmacall") {
                    if ($line =~ m{LinearRecurrence\s*\[\s*\{([^\}]+)\}\s*\,\s*\{([^\}]+)\}\s*\,\s*(\d+)\s*\]}i) {
                        $signature = $1;
                        $initerm   = $2;
                        $termno    = $3;
                        &output;
                    }
                }
            } # Annnnnn.json
        } elsif ($mode =~ m{xtract}) {
            if ($line =~ m{\A(A\d{6})\t([^\t]+)\t([^\t]+)}) { # xtract
                # A000096   a(n) = +3 * a(n-1) -3 * a(n-2) +1 * a(n-3)  0,2,5,9,14,20,27,35,44,54,65,77,90,104,119,135,152,170,189,209,230,252,275,299
                $aseqno     = $1;
                $signature  = $2;
                $initerm    = $3;
                @signatures = map {
                        s{\+}{};
                        $_
                    } grep {
                        m{[\+\-]\d+}
                    } split(/\s+/, $signature);
                $termno     = scalar(@signatures);
                $signature  = join(",", @signatures);
                @initerms   = split(/\,/, $initerm  );
                $initerm    = join(",", splice(@initerms, 0, $termno));
                $termno = 0;
                &output;
            }
        } elsif ($mode =~ m{form}) {
            # ../common/ajson/A033889.json:                           "a(n) = 7*a(n-1) - a(n-2). - _Floor van Lamoen_, Dec 10 2001",
            $line =~ s{\s}{}g;
            # print "$line\n";
            if ($line =~ m{\/(A\d{6})\.json\:\"(a\(n\)\=(\d+|[\*\-\+]|a\(n\-\d+\))+)}) { 
                $aseqno     = $1;
                my $formula = $2;
                if ($formula =~ m{a\(n\-\d+\)\Z}) {
	                $sigorder   = ($formula =~ s{\)}{\)}g) - 1;
    	            print join("\t", $aseqno, $sigorder, $formula) . "\n";
    	        }
            }
        } # modes
    } # while <>
    # extraction modes

} # switch $mode
#------------------
sub read_spec {
    my $count = "";
    while ($count !~ m{\A\d+}) { # search for line count
        $count = <SPEC>;
    } # search for line count
    $count =~ s{\D}{}g; # keep digits only
    my $buffer = "";
    while ($count > 0) {
        $buffer .= <SPEC>;
        $count --;
    } # while <SPEC>
    return $buffer;
} # read_spec
#----
sub write_spec {
    my ($buffer) = @_;
    my @lines = split(/\n/, $buffer);
    print SPEC scalar(@lines) . "\n" . $buffer . "\n";
} # write_spec
#----
sub write_seqs {
    my ($separator) = @_;
    foreach my $key (sort(keys(%seqs))) {
        my $comt = $seqs{$key};
        if ($comt =~ m{\<strong\>}) {
            print "$separator <strong>$key</strong>"; 
        } else {
            print "$separator $key$comt"; # remove shield
        }
        $separator = ",";
    } # foreach
    if (scalar(%seqs) > 0) {
        print "\n";
    }
    %seqs = ();
} # write_seqs
#------------------
sub compress_signature {
    my ($signature) = @_;
    my $sigorder  = 0;
    my $compsig   = $signature;
    if ($compsig ne $void_sig) {
        if ($compsig =~ m{\(total of (\d+)[^\)]*\)}) {
            my $total = $1 - 1;
            $compsig =~ s{\,\.\.\.\(total of (\d+)[^\)]*\)\.*}{',0'x$total}e;
            # :(1,0,...(total of 27 '0's)...,0,-1,1,0,...): A016126 (1/&Phi;<sub>2117</sub>, also [[#order 2117|2117-periodic]]).
        }
        $compsig  =~ s{[^\.\,\-\d]}{}g; # remove letters and spaces
        my @compsigs  = split(/\,/, $compsig);
        $sigorder = scalar(@compsigs);
        $compsig  = substr(join(" ", @compsigs), 0, $trunc_len); # compressed and abbreviated signature
        if (length($compsig) == 0) {
            $compsig  = $void_sig;
            $sigorder = 1;
        }
    } # ne $void
    return ($sigorder, $compsig);
} # compress_signature;
#------------------
sub index_output {
    # global $lorder
    my ($sigorder, $compsig) = &compress_signature($signature);
    print join("\t"
        , $lorder
        , $compsig
        , substr($aseqno, 1) # make it numeric
        , $sigorder
        , $signature
        , "#" . $comment # must shield it because Dbat trims
        ) . "\n";
} # index_output
#----------
sub output {
    $initerm     =~ s{[^\,\-\d]}{}g; # remove letters
    @initerms    = split(/\,/, $initerm  );
    my ($sigorder, $compsig) = &compress_signature($signature);
    print join("\t"
        , $lorder + 0
        , $compsig
        , substr($aseqno, 1) # make it numeric
        , $sigorder
        , $signature
        , $mode
        , $spec
        , $termno
        , join(",", @initerms  )
        ) . "\n";
}
#-----------------
sub create_sql {
    my ($tabname) = @_;
    if (0) {
    } elsif ($tabname eq "lrlink") {
        print <<"GFis";
--  OEIS-mat: $tabname - working table for index of linear recurrences
--  \@(#) \$Id\$
--  $timestamp, generated by extract_linrec.pl - DO NOT EDIT HERE!
--
DROP    TABLE  IF EXISTS $tabname;
CREATE  TABLE            $tabname
    ( lorder    INT         NOT NULL  -- order = number of right terms
    , compsig   VARCHAR($trunc_len)          -- blank separated, truncated, without "( )"
    , seqno     VARCHAR(8)  NOT NULL  -- 322469 without 'A'
    , sigorder  INT                   -- number of signature elements
    , signature VARCHAR(1020)         -- comma separated, without "( )"
    , mode      VARCHAR(8)
    , spec      VARCHAR(16)
    , termno    INT                   -- number of initial terms
    , initerms  VARCHAR(1024) -- dito
    , PRIMARY KEY(lorder, compsig, seqno, sigorder, mode)
    );
COMMIT;
GFis
#------------------
    } elsif ($tabname eq "lrindx") {
        print <<"GFis";
--  OEIS-mat: $tabname - working table for index of linear recurrences
--  \@(#) \$Id\$
--  $timestamp, generated by extract_linrec.pl - DO NOT EDIT HERE!
--
DROP    TABLE  IF EXISTS $tabname;
CREATE  TABLE            $tabname
    ( lorder    INT         NOT NULL  -- order = number of right terms
    , compsig   VARCHAR($trunc_len)          -- blank separated, truncated, without "( )"
    , seqno     VARCHAR(8)  NOT NULL  -- 322469 without 'A'
    , sigorder  INT                   -- number of signature elements
    , signature VARCHAR(1020)         -- comma separated, without "( )"
    , comment   VARCHAR(1020)         -- behind isgnature, aseqno
    , PRIMARY KEY(lorder, compsig, seqno, sigorder)
    );
COMMIT;
GFis
    }
} # create_sql
#-------------------------------------------------
__DATA__
my $rest = <<GFis";
link
ajson/A033889.json:             "\u003ca href=\"/index/Rec#order_02\"\u003eIndex entries for linear recurrences with constant coefficients\u003c/a\u003e, signature (7,-1)"
ajson/A002530.json:             "\u003ca href=\"/index/Rec#order_04\"\u003eIndex entries for linear recurrences with constant coefficients\u003c/a\u003e, signature (0,4,0,-1).",
ajson/A042407.json:             "\u003ca href=\"/index/Rec\"\u003eIndex entries for linear recurrences with constant coefficients\u003c/a\u003e, signature (0,1460,0,-1)."
ajson/A076736.json:             "\u003ca href=\"/index/Rec#order_02\"\u003eIndex entries for linear recurrences with constant coefficients\u003c/a\u003e, signature (0,2)."
ajson/A037141.json:             "\u003ca href=\"/index/Rec#order_04\"\u003eIndex entries for linear recurrences with constant coefficients\u003c/a\u003e, signature (3,-2,-1,1)."
ajson/A094567.json:             "\u003ca href=\"/index/Rec#order_03\"\u003eIndex entries for linear recurrences with constant coefficients\u003c/a\u003e, signature (6,6,-1)."
ajson/A020979.json:             "\u003ca href=\"/index/Rec#order_03\"\u003eIndex entries for linear recurrences with constant coefficients\u003c/a\u003e, signature (29,-278,880)."
ajson/A013898.json:             "\u003ca href=\"/index/Rec#order_01\"\u003eIndex entries for linear recurrences with constant coefficients\u003c/a\u003e, signature (4084101)."
ajson/A071953.json:             "\u003ca href=\"/index/Rec#order_07\"\u003eIndex entries for linear recurrences with constant coefficients\u003c/a\u003e, signature (7, -21, 35, -35, 21, -7, 1)."

mmcall
ajson/A047604.json:                             "LinearRecurrence[{1, 0, 1, -1}, {2, 3, 5, 10}, 50] (* _G. C. Greubel_,"
ajson/A081138.json:                             "LinearRecurrence[{24,-192,512},{0,0,1},30] (* _Harvey P. Dale_, Jun 08"
ajson/A029898.json:                             "Join[{1},LinearRecurrence[{1,0,-1,1},{1,2,4,8},110]] (* or *) Join[{1},"

xtract
A000044 a(n) = +1 * a(n-1) +1 * a(n-3) +1 * a(n-5) +1 * a(n-7) +1 * a(n-9) +1 * a(n-11) 1,1,1,2,3,5,8,13,21,34,55,89,144,232,375,606,979,1582,2556,4130,6673,10782,17421,28148
A000045 a(n) = +1 * a(n-1) +1 * a(n-2)  0,1,1,2,3,5,8,13,21,34,55,89,144,233,377,610,987,1597,2584,4181,6765,10946,17711,28657
A000051 a(n) = +3 * a(n-1) -2 * a(n-2)  2,3,5,9,17,33,65,129,257,513,1025,2049,4097,8193,16385,32769,65537,131073,262145,524289,1048577,2097153,4194305,8388609
A000062 a(n) = +1 * a(n-1) +1 * a(n-5) -1 * a(n-6)  1,2,4,5,6,8,9,11,12,13,15,16,18,19,20,22,23,25,26,27,29,30,32,33
A000096 a(n) = +3 * a(n-1) -3 * a(n-2) +1 * a(n-3)  0,2,5,9,14,20,27,35,44,54,65,77,90,104,119,135,152,170,189,209,230,252,275,299
GFis

__NOTOC__<!-- TOC looks ugly since all contents are in sect. 1.1.x - It would be nice to have 1 line "jump to [order 2] - [order 3] - ... -->
= Index to [http://oeis.org OEIS]: Section Rec =
'''This is a special index page, which contains the "recurrence, linear" section of [[Index_to_OEIS:_Section_Rea]]'''

{{Index header}}

<span id="recLCC"></span>
===recurrence, linear, constant coefficients,  sequences related to:===
:Index to sections by order: [ [[Index to OEIS: Section Rec#order_01|1]] | [[Index to OEIS: Section Rec#order_02|2]] | [[Index to OEIS: Section Rec#order_03|3]] | [[Index to OEIS: Section Rec#order_04|4]] | [[Index to OEIS: Section Rec#order_05|5]] | [[Index to OEIS: Section Rec#order_06|6]] | [[Index to OEIS: Section Rec#order_07|7]] | [[Index to OEIS: Section Rec#order_08|8]] | [[Index to OEIS: Section Rec#order_09|9]] | [[Index to OEIS: Section Rec#order_10|10]] | [[Index to OEIS: Section Rec#order_11|11]] | [[Index to OEIS: Section Rec#order_12|12]] | [[Index to OEIS: Section Rec#order_13|13]] | [[Index to OEIS: Section Rec#order_14|14]] | [[Index to OEIS: Section Rec#order_15|15]] | [[Index to OEIS: Section Rec#order_16|16]] | [[Index to OEIS: Section Rec#order_17|17]] | [[Index to OEIS: Section Rec#order_18|18]] | [[Index to OEIS: Section Rec#order_19|19]] | [[Index to OEIS: Section Rec#order_20|20]] | [[Index to OEIS: Section Rec#order_21|21]] | [[Index to OEIS: Section Rec#order_22|22]] | [[Index to OEIS: Section Rec#order_23|23]] | [[Index to OEIS: Section Rec#order_24|24]] | [[Index to OEIS: Section Rec#order_25|25]] | [[Index to OEIS: Section Rec#order_26|26]] | [[Index to OEIS: Section Rec#order_27|27]] | [[Index to OEIS: Section Rec#order_28|28]] | [[Index to OEIS: Section Rec#order_29|29]] | [[Index to OEIS: Section Rec#order_30|30]] | [[Index to OEIS: Section Rec#order_31|31]] | [[Index to OEIS: Section Rec#order_32|32]] | [[Index to OEIS: Section Rec#order_33|33]] | [[Index to OEIS: Section Rec#order_34|34]] | [[Index to OEIS: Section Rec#order_35|35]] | [[Index to OEIS: Section Rec#order_36|36]] | [[Index to OEIS: Section Rec#order_37|37]] | [[Index to OEIS: Section Rec#order_38|38]] | [[Index to OEIS: Section Rec#order_39|39]] | [[Index to OEIS: Section Rec#order_40|40]] | [[Index to OEIS: Section Rec#order_41|41]] | [[Index to OEIS: Section Rec#order_42|42]] | [[Index to OEIS: Section Rec#order_43|43]] | [[Index to OEIS: Section Rec#order_44|44]] | [[Index to OEIS: Section Rec#order_45|45]] | [[Index to OEIS: Section Rec#order_46|46]] | [[Index to OEIS: Section Rec#order_47|47]] | [[Index to OEIS: Section Rec#order_48|48]] | [[Index to OEIS: Section Rec#order_49|49]] | [[Index to OEIS: Section Rec#order_50|50]] | [[Index to OEIS: Section Rec#order_51|51]] | [[Index to OEIS: Section Rec#order_52|52]] | [[Index to OEIS: Section Rec#order_53|53]] | [[Index to OEIS: Section Rec#order_54|54]] | [[Index to OEIS: Section Rec#order_55|55]] | [[Index to OEIS: Section Rec#order_56|56]] | [[Index to OEIS: Section Rec#order_57|57]] | [[Index to OEIS: Section Rec#order_58|58]] | [[Index to OEIS: Section Rec#order_60|60]] | [[Index to OEIS: Section Rec#order_61|61]] | [[Index to OEIS: Section Rec#order_62|62]] | [[Index to OEIS: Section Rec#order_63|63]] | [[Index to OEIS: Section Rec#order_64|64]] | [[Index to OEIS: Section Rec#order_65|65]] | [[Index to OEIS: Section Rec#order_66|66]] | [[Index to OEIS: Section Rec#order_67|67]] | [[Index to OEIS: Section Rec#order_68|68]] | [[Index to OEIS: Section Rec#order_70|70]] | [[Index to OEIS: Section Rec#order_71|71]] | [[Index to OEIS: Section Rec#order_72|72]] | [[Index to OEIS: Section Rec#order_74|74]] | [[Index to OEIS: Section Rec#order_76|76]] | [[Index to OEIS: Section Rec#order_77|77]] | [[Index to OEIS: Section Rec#order_78|78]] | [[Index to OEIS: Section Rec#order_79|79]] | [[Index to OEIS: Section Rec#order_80|80]] | [[Index to OEIS: Section Rec#order_81|81]] | [[Index to OEIS: Section Rec#order_82|82]] | [[Index to OEIS: Section Rec#order_84|84]] | [[Index to OEIS: Section Rec#order_85|85]] | [[Index to OEIS: Section Rec#order_87|87]] | [[Index to OEIS: Section Rec#order_88|88]] | [[Index to OEIS: Section Rec#order_90|90]] | [[Index to OEIS: Section Rec#order_91|91]] | [[Index to OEIS: Section Rec#order_92|92]] | [[Index to OEIS: Section Rec#order_93|93]] | [[Index to OEIS: Section Rec#order_95|95]] | [[Index to OEIS: Section Rec#order_96|96]] | [[Index to OEIS: Section Rec#order_97|97]] | [[Index to OEIS: Section Rec#order_100|100]] | [[Index to OEIS: Section Rec#order_101|101]] | [[Index to OEIS: Section Rec#order_104|104]] | [[Index to OEIS: Section Rec#order_105|105]] | [[Index to OEIS: Section Rec#order_108|108]] | [[Index to OEIS: Section Rec#order_112|112]] | [[Index to OEIS: Section Rec#order_120|120]] | [[Index to OEIS: Section Rec#order_127|127]] | [[Index to OEIS: Section Rec#order_128|128]] | [[Index to OEIS: Section Rec#order_132|132]] | [[Index to OEIS: Section Rec#order_144|144]] | [[Index to OEIS: Section Rec#order_145|145]] | [[Index to OEIS: Section Rec#order_146|146]] | [[Index to OEIS: Section Rec#order_154|154]] | [[Index to OEIS: Section Rec#order_160|160]] | [[Index to OEIS: Section Rec#order_162|162]] | [[Index to OEIS: Section Rec#order_168|168]] | [[Index to OEIS: Section Rec#order_176|176]] | [[Index to OEIS: Section Rec#order_177|177]] | [[Index to OEIS: Section Rec#order_180|180]] | [[Index to OEIS: Section Rec#order_185|185]] | [[Index to OEIS: Section Rec#order_186|186]] | [[Index to OEIS: Section Rec#order_191|191]] | [[Index to OEIS: Section Rec#order_192|192]] | [[Index to OEIS: Section Rec#order_207|207]] | [[Index to OEIS: Section Rec#order_216|216]] | [[Index to OEIS: Section Rec#order_220|220]] | [[Index to OEIS: Section Rec#order_224|224]] | [[Index to OEIS: Section Rec#order_231|231]] | [[Index to OEIS: Section Rec#order_240|240]] | [[Index to OEIS: Section Rec#order_252|252]] | [[Index to OEIS: Section Rec#order_255|255]] | [[Index to OEIS: Section Rec#order_256|256]] | [[Index to OEIS: Section Rec#order_264|264]] | [[Index to OEIS: Section Rec#order_276|276]] | [[Index to OEIS: Section Rec#order_280|280]] | [[Index to OEIS: Section Rec#order_288|288]] | [[Index to OEIS: Section Rec#order_300|300]] | [[Index to OEIS: Section Rec#order_304|304]] | [[Index to OEIS: Section Rec#order_307|307]] | [[Index to OEIS: Section Rec#order_312|312]] | [[Index to OEIS: Section Rec#order_320|320]] | [[Index to OEIS: Section Rec#order_336|336]] | [[Index to OEIS: Section Rec#order_341|341]] | [[Index to OEIS: Section Rec#order_348|348]] | [[Index to OEIS: Section Rec#order_352|352]] | [[Index to OEIS: Section Rec#order_360|360]] | [[Index to OEIS: Section Rec#order_368|368]] | [[Index to OEIS: Section Rec#order_384|384]] | [[Index to OEIS: Section Rec#order_396|396]] | [[Index to OEIS: Section Rec#order_400|400]] | [[Index to OEIS: Section Rec#order_416|416]] | [[Index to OEIS: Section Rec#order_420|420]] | [[Index to OEIS: Section Rec#order_432|432]] | [[Index to OEIS: Section Rec#order_440|440]] | [[Index to OEIS: Section Rec#order_448|448]] | [[Index to OEIS: Section Rec#order_460|460]] | [[Index to OEIS: Section Rec#order_464|464]] | [[Index to OEIS: Section Rec#order_468|468]] | [[Index to OEIS: Section Rec#order_480|480]] | [[Index to OEIS: Section Rec#order_481|481]] | [[Index to OEIS: Section Rec#order_492|492]] | [[Index to OEIS: Section Rec#order_504|504]] | [[Index to OEIS: Section Rec#order_511|511]] | [[Index to OEIS: Section Rec#order_512|512]] | [[Index to OEIS: Section Rec#order_520|520]] | [[Index to OEIS: Section Rec#order_528|528]] | [[Index to OEIS: Section Rec#order_532|532]] | [[Index to OEIS: Section Rec#order_540|540]] | [[Index to OEIS: Section Rec#order_552|552]] | [[Index to OEIS: Section Rec#order_560|560]] | [[Index to OEIS: Section Rec#order_576|576]] | [[Index to OEIS: Section Rec#order_580|580]] | [[Index to OEIS: Section Rec#order_600|600]] | [[Index to OEIS: Section Rec#order_616|616]] | [[Index to OEIS: Section Rec#order_624|624]] | [[Index to OEIS: Section Rec#order_640|640]] | [[Index to OEIS: Section Rec#order_648|648]] | [[Index to OEIS: Section Rec#order_656|656]] | [[Index to OEIS: Section Rec#order_660|660]] | [[Index to OEIS: Section Rec#order_672|672]] | [[Index to OEIS: Section Rec#order_696|696]] | [[Index to OEIS: Section Rec#order_700|700]] | [[Index to OEIS: Section Rec#order_704|704]] | [[Index to OEIS: Section Rec#order_720|720]] | [[Index to OEIS: Section Rec#order_736|736]] | [[Index to OEIS: Section Rec#order_756|756]] | [[Index to OEIS: Section Rec#order_768|768]] | [[Index to OEIS: Section Rec#order_780|780]] | [[Index to OEIS: Section Rec#order_792|792]] | [[Index to OEIS: Section Rec#order_800|800]] | [[Index to OEIS: Section Rec#order_820|820]] | [[Index to OEIS: Section Rec#order_828|828]] | [[Index to OEIS: Section Rec#order_832|832]] | [[Index to OEIS: Section Rec#order_840|840]] | [[Index to OEIS: Section Rec#order_864|864]] | [[Index to OEIS: Section Rec#order_880|880]] | [[Index to OEIS: Section Rec#order_896|896]] | [[Index to OEIS: Section Rec#order_900|900]] | [[Index to OEIS: Section Rec#order_920|920]] | [[Index to OEIS: Section Rec#order_924|924]] | [[Index to OEIS: Section Rec#order_928|928]] | [[Index to OEIS: Section Rec#order_936|936]] | [[Index to OEIS: Section Rec#order_945|945]] | [[Index to OEIS: Section Rec#order_960|960]] | [[Index to OEIS: Section Rec#order_984|984]] | [[Index to OEIS: Section Rec#order_1000|1000]] | [[Index to OEIS: Section Rec#order_1008|1008]] | [[Index to OEIS: Section Rec#order_1012|1012]] | [[Index to OEIS: Section Rec#order_1020|1020]] | [[Index to OEIS: Section Rec#order_1023|1023]] | [[Index to OEIS: Section Rec#order_1040|1040]] | [[Index to OEIS: Section Rec#order_1044|1044]] | [[Index to OEIS: Section Rec#order_1056|1056]] | [[Index to OEIS: Section Rec#order_1060|1060]] | [[Index to OEIS: Section Rec#order_1080|1080]] | [[Index to OEIS: Section Rec#order_1104|1104]] | [[Index to OEIS: Section Rec#order_1120|1120]] | [[Index to OEIS: Section Rec#order_1144|1144]] | [[Index to OEIS: Section Rec#order_1152|1152]] | [[Index to OEIS: Section Rec#order_1160|1160]] | [[Index to OEIS: Section Rec#order_1176|1176]] | [[Index to OEIS: Section Rec#order_1188|1188]] | [[Index to OEIS: Section Rec#order_1200|1200]] | [[Index to OEIS: Section Rec#order_1224|1224]] | [[Index to OEIS: Section Rec#order_1232|1232]] | [[Index to OEIS: Section Rec#order_1248|1248]] | [[Index to OEIS: Section Rec#order_1260|1260]] | [[Index to OEIS: Section Rec#order_1272|1272]] | [[Index to OEIS: Section Rec#order_1276|1276]] | [[Index to OEIS: Section Rec#order_1280|1280]] | [[Index to OEIS: Section Rec#order_1288|1288]] | [[Index to OEIS: Section Rec#order_1296|1296]] | [[Index to OEIS: Section Rec#order_1300|1300]] | [[Index to OEIS: Section Rec#order_1312|1312]] | [[Index to OEIS: Section Rec#order_1320|1320]] | [[Index to OEIS: Section Rec#order_1344|1344]] | [[Index to OEIS: Section Rec#order_1360|1360]] | [[Index to OEIS: Section Rec#order_1376|1376]] | [[Index to OEIS: Section Rec#order_1380|1380]] | [[Index to OEIS: Section Rec#order_1392|1392]] | [[Index to OEIS: Section Rec#order_1404|1404]] | [[Index to OEIS: Section Rec#order_1408|1408]] | [[Index to OEIS: Section Rec#order_1440|1440]] | [[Index to OEIS: Section Rec#order_1452|1452]] | [[Index to OEIS: Section Rec#order_1456|1456]] | [[Index to OEIS: Section Rec#order_1476|1476]] | [[Index to OEIS: Section Rec#order_1480|1480]] | [[Index to OEIS: Section Rec#order_1500|1500]] | [[Index to OEIS: Section Rec#order_1512|1512]] | [[Index to OEIS: Section Rec#order_1536|1536]] | [[Index to OEIS: Section Rec#order_1540|1540]] | [[Index to OEIS: Section Rec#order_1560|1560]] | [[Index to OEIS: Section Rec#order_1584|1584]] | [[Index to OEIS: Section Rec#order_1600|1600]] | [[Index to OEIS: Section Rec#order_1620|1620]] | [[Index to OEIS: Section Rec#order_1624|1624]] | [[Index to OEIS: Section Rec#order_1632|1632]] | [[Index to OEIS: Section Rec#order_1656|1656]] | [[Index to OEIS: Section Rec#order_1660|1660]] | [[Index to OEIS: Section Rec#order_1680|1680]] | [[Index to OEIS: Section Rec#order_1696|1696]] | [[Index to OEIS: Section Rec#order_1716|1716]] | [[Index to OEIS: Section Rec#order_1720|1720]] | [[Index to OEIS: Section Rec#order_1728|1728]] | [[Index to OEIS: Section Rec#order_1740|1740]] | [[Index to OEIS: Section Rec#order_1776|1776]] | [[Index to OEIS: Section Rec#order_1780|1780]] | [[Index to OEIS: Section Rec#order_1792|1792]] | [[Index to OEIS: Section Rec#order_1800|1800]] | [[Index to OEIS: Section Rec#order_1804|1804]] | [[Index to OEIS: Section Rec#order_1836|1836]] | [[Index to OEIS: Section Rec#order_1840|1840]] | [[Index to OEIS: Section Rec#order_1848|1848]] | [[Index to OEIS: Section Rec#order_1872|1872]] | [[Index to OEIS: Section Rec#order_1890|1890]] | [[Index to OEIS: Section Rec#order_1900|1900]] | [[Index to OEIS: Section Rec#order_1908|1908]] | [[Index to OEIS: Section Rec#order_1920|1920]] | [[Index to OEIS: Section Rec#order_1932|1932]] | [[Index to OEIS: Section Rec#order_1936|1936]] | [[Index to OEIS: Section Rec#order_1944|1944]] | [[Index to OEIS: Section Rec#order_1960|1960]] | [[Index to OEIS: Section Rec#order_1980|1980]] | [[Index to OEIS: Section Rec#order_1992|1992]] | [[Index to OEIS: Section Rec#order_2016|2016]] | [[Index to OEIS: Section Rec#order_2047|2047]] | [[Index to OEIS: Section Rec#order_2064|2064]] | [[Index to OEIS: Section Rec#order_2080|2080]] | [[Index to OEIS: Section Rec#order_2088|2088]] | [[Index to OEIS: Section Rec#order_2100|2100]] | [[Index to OEIS: Section Rec#order_2112|2112]] | [[Index to OEIS: Section Rec#order_2160|2160]] | [[Index to OEIS: Section Rec#order_2184|2184]] | [[Index to OEIS: Section Rec#order_2800|2800]] | [[Index to OEIS: Section Rec#order_4095|4095]] | [[Index to OEIS: Section Rec#order_4800|4800]] | [[Index to OEIS: Section Rec#order_8191|8191]] | [[Index to OEIS: Section Rec#order_16383|16383]] | [[Index to OEIS: Section Rec#order_32767|32767]] | [[Index to OEIS: Section Rec#order_65535|65535]] | [[Index to OEIS: Section Rec#order_131071|131071]] ]

====<span id="order 01">recurrence, linear, order 1:</span>====
:(-4): A009117, A262710
:(-3): A084244, A141413, A256096
:(-2): A084633, A110164 (3*(-2)^n except for n<2), A122803 (powers of -2), A123344, A141531, A166577, A176414 (3*(-2)^n except for n=0), A279634, A296775
:(-1), i.e., anti-periodic, also 2-periodic: see [[Index_to_OEIS:_Section_Per#periodic_sequences|Index to 2-periodic sequences]]
:(1), i.e., 1-periodic, i.e., (eventually) constant: see [[Index_to_OEIS:_Section_Con#constant|Index to constant (and eventually constant) sequences]]
:(2): A000079 (powers of 2), A003945, A005009, A005010, A005015, A005029, A007283, A011782, A020707, A020714, A081808, A082505, A084215, A087009, A091629, A098011, A101229, A110286, A110287, A110288, A111286, A122391, A125176, A131577, A132479, A135092, A146523, A146541, A155559, A157823, A175805, A198633, A202604, A240951, A257548, A287798
:(3): A000244 (powers of 3), A003946, A005030, A005032, A005051, A005052, A008776, A025192, A025579, A026097, A080923, A082541, A083583, A099856, A116530, A118264, A120354, A133494, A140429, A141495, A176413, A258597, A258598, A293156
:(4): A000302 (powers of 4), A002001, A002023, A002042, A002063, A002066, A002089, A003947, A004171, A055841, A056120, A081294, A081654, A084509, A092898, A164908, A277451, A292540, A292542, A292543, A292545
:(5): A000351 (powers of 5), A003948, A005055, A020699, A020729, A055842, A128625, A141496, A189274, A216491, A235702, A270567
:(6): A000400 (powers of 6), A003949, A052934, A055846, A081341, A084477, A169604, A270576
:(7): A000420 (powers of 7), A003950, A055270, A055272, A109808, A193577, A196661, A270471
:(8): A001018 (powers of 8), A003951, A013730, A013731, A055274, A055847, A083233, A092811, A103333, A270568
:(9): A001019 (powers of 9), A003952, A013708, A055275, A055995, A092810, A100062, A102518, A120353, A270369, A270472, A270473
:(10): A003953, A011557 (powers of 10), A052268, A055996, A090019, A093136, A093138, A093141, A093143, A096363, A105694, A178501, A196662, A216156, A216164
====<span id="order 65535">recurrence, linear, order 65535:</span>====
:(0,...0,1), i.e., 65535-periodic: A011729 (binary m-expansion of reciprocal of ...).

====<span id="order 131071">recurrence, linear, order 131071:</span>====
:(0,...0,1), i.e., 131071-periodic: A011730 (binary m-expansion of reciprocal of ...).
{{Index header}}

(88888888): A109821
(88888888): A110553
(88888888): A070290
(88888888): A070291, A174650

LinearRecurrence[{0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1}, {10, 5, 30, 10, 2, 15, 70, 20, 90, 1, 110, 30, 130, 35, 6, 40, 170, 45, 190, 2}, 60]

LinearRecurrence[{14, -91, 364, -1001, 2002, -3003, 3432, -3003, 2002, -1001, 364, -91, 14, -1},{3004, 19078, 88938, 335612, 1084387, 3109060, 8104089, 19539904, 44141520, 94346102, 192252586, 375787005, 708083995,1291443529},30]

../common/ajson/A033889.json:                           "a(n) = 7*a(n-1) - a(n-2). - _Floor van Lamoen_, Dec 10 2001",

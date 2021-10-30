#!perl

# Extract information from a JSON or b-file, and generate .tsv or SQL
# @(#) $Id$
# 2021-08-07: F -> program field
# 2021-05-02: monotone increasing
# 2020-02-22: -as:program
# 2019-04-12: termno in asdata and in bfdata
# 2019-04-08: evaluate -a x separately
# 2019-03-22: -ax
# 2019-03-16: bfinfo keywords with line numbers only for hard errors
# 2019-01-25: $filesize
# 2019-01-22, Georg Fischer: copied from ../bfcheck/bfanalyze.pl
#
#:# usage:
#:#   perl extract_info.pl [-action] [-l lead] [-d level] [-t tabname] inputdir > outputfile
#:#       action  (default -br)
#:#           a   for sequence JSON
#:#           j   for sequence JSON
#:#           n   only extract names from JSON
#:#           s   only extract data  from JSON
#:#           x   only extract xrefs from JSON
#:#           b   for bfile
#:#           r   TSV for Dbat -r,
#:#           c   generate CREATE SQL
#:#           t   generate bfdata
#:#       -l lead     print so many initial terms (default 8)
#:#       -d level    debug level none(0), some(1), more(2)
#:#       -w width    maximum number of characters in term string
#:#       inputdir    (mandatory)
#
# perl extract_info.pl -asr $(DIR)/ajson > asdata.txt
# perl extract_info.pl -anr $(DIR)/ajson > asname.txt
# perl extract_info.pl -jr  $(DIR)/ajson > asinfo.txt
# perl extract_info.pl -jc  | tee asinfo.create.sql
# perl extract_info.pl -btr $(DIR)/bfile > bfdata.txt
# perl extract_info.pl -br  $(DIR)/bfile > bfinfo.txt
# perl extract_info.pl -bc  | tee bfinfo.create.sql
#---------------------------------
use strict;
use integer;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday) = gmtime (time);
my $utc_stamp = sprintf ("%04d-%02d-%02dT%02d:%02d:%02d\z"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);

# get options
my $action     = "br"; # generate TSV for Dbat -r
my $debug      =  0; # 0 (none), 1 (some), 2 (more)
my $imin       =  0;
my $imax       = -1; # unknown
my $lead       =  8; # so many initial terms are printed
my $tail_width =  8; # length of last digits in last term
my $terms_width= 64;
my $tabname    = "";
my %xhash;           # for &extract_aseqnos
my $in_xref;         # whether in "xref" property
my $do_xref = 0;     # whether in action -ax
my $read_len_max = 100000000; # 100 MB
my $read_len_min =      8000; # stripped has about 960 max.
if (scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{\-d}) {
        $debug    = shift(@ARGV);
    } elsif ($opt =~ m{\-l}) {
        $lead     = shift(@ARGV);
    } elsif ($opt =~ m{\-t}) {
        $tabname  = shift(@ARGV);
    } elsif ($opt =~ m{\-}) {
        $action   = $opt;
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while ARGV
my $inputdir = shift(@ARGV);
if (length($tabname) > 0) {
    # believe this one
} elsif ($action =~ m{b}) {
    $tabname = "bfinfo";

} elsif ($action =~ m{[aj]}) {
    $tabname = "asinfo";
}
if (0) {
} elsif ($action =~ m{n}) {
    $tabname = "asname";
} elsif ($action =~ m{s}) {
    $tabname = "asdata";
} elsif ($action =~ m{x}) {
    $tabname = "asxref";
    $do_xref = 1;
}
my $access = "1971-01-01 00:00:00"; # modification timestamp from the file
my $buffer; # contains the whole file
my $filesize  = 0; # file size in bytes from the operating system
#----------------------------------------------
if (0) {
#--------------------------
} elsif ($action =~ m{b}) {
    if (0) {
    } elsif ($action =~ m{r}) {
        foreach my $file (glob("$inputdir/*")) {
            &extract_from_bfile($file);
        } # foreach $file
    } elsif ($action =~ m{c}) {
        &print_create_bfinfo();
    } else {
        die "invalid action \"$action\"\n";
    }
#--------------------------
} elsif ($action =~ m{[ajnsx]}) {
    if (0) {
    } elsif ($action =~ m{r}) {
        foreach my $file (glob("$inputdir/*")) {
            &extract_from_json($file);
        } # foreach $file
    } elsif ($action =~ m{c}) { # create SQL
        if ($action =~ m{x}) {
            $tabname = "asxref";
            &print_create_asxref();
        } else {
            &print_create_asinfo();
        }
    } else {
        die "invalid action \"$action\"\n";
    }
#--------------------------
} else {
    die "invalid action \"$action\"\n";
} # actions
#----------------------
sub read_file { # returns in global $access, $buffer, $filesize
    my ($filename, $read_len) = @_;
    if ($debug > 0) {
        print STDERR "read_file \"$filename\", $read_len bytes\n";
    }
    open(FIL, "<", $filename) or die "cannot read $filename\n";
    my ($dev, $ino, $mode, $nlink, $uid, $gid, $rdev, $size, $atime
        , $mtime, $ctime, $blksize, $blocks) = stat(FIL);
    ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday) = gmtime ($mtime);
    $access = sprintf ("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec); # in UTC: "2019-01-23 08:07:00"
    read(FIL, $buffer, $read_len); # 100 MB, should be less than 10 MB
    $filesize = $size;
    close(FIL);
} # read_file
#-------------------------------------------------
sub extract_from_json { # read JSON of 1  sequence
    my $result = "";
    my ($filename) = @_;
    &read_file($filename, $read_len_max); # sets $access, $buffer
    $filename =~ m{(A\d{6})\.json}i; # extract seqno
    my $aseqno   = $1;
    my $name     = "";
    my $data     = "";
    my $offset1  = 1;
    my $offset2  = 1;
    my $terms    = "";
    my $datalen  = 0;
    my $termno   = 0;
    my $keyword  = "nokeyword";
    my $program  = "";
    my $author   = "";
    my $revision = 0;
    my $created  = "1974-01-01 00:00:00";
    $access      = $created;
#           "name": "Number of 0..n arrays x(0..4) of 5 elements with zero 3rd differences.",
#           "number": 200083,
#           "data": "2,3,8,17,26,43,64,89,122,163,208,269,334,407,496,597,702,831,968,1117,1286,1471,1664,1889,2122,2371,2648,2945,3250,3595,3952,4329,4738,5171,5616,6109,6614,7143,7712,8309,8918,9583,10264,10973,11726,12511,13312",
#           "keyword": "nonn",
#           "offset": "1,1",
#           "author": "_R. H. Hardin_, Nov 13 2011",
#           "references": 1,
#           "revision": 13,
#           "time": "2018-05-17T13:40:20-04:00",
#           "created": "2011-11-13T12:40:47-05:00"
    my $value;
    my $synth = "synth";
    my $seqno = 0;
    %xhash = (); # bits 1: in xref, bit 0: elsewhere
    foreach my $line (split(/\n/, $buffer)) {
        if ($line !~ m{\A\s*\"}) { # ignore closing brackets
            $in_xref = 0; # but terminate xref mode
        # now the JSON properties
        } elsif ($line =~   m{\A\s*\"number\"\:\s*(\d+)}) {
            $value = $1;
            $seqno = sprintf("%06d", $value);
            $aseqno = "A$seqno";
            $filename =~ m{A(\d{6})\.json}i; # extract seqno
            my $fseqno = "A$1";
            if ($fseqno ne $aseqno) {
                print STDERR "# filename \"$filename\": fseqno \"$fseqno\" ne aseqno \"$aseqno\"\n";
            }
            $aseqno = $fseqno;
        } elsif ($line =~   m{\A\s*\"data\"\:\s*\"([^\"]*)\"}) {
            $value = $1;
            $data  = $value;
            $datalen = length($data);
            ($termno, $terms) = &terms8($value);
        } elsif ($line =~   m{\A\s*\"name\"\:\s*\"(.*)}) {
            $value = $1;
            $value =~ s{\"\,\Z}{};
            # $value =~ s{\\u003c}{\<}g;
            # $value =~ s{\\u003e}{\>}g;
            $name  = $value;
            if ($do_xref == 1) {
                &extract_aseqnos($aseqno, $line);
            }
        } elsif ($line =~   m{\A\s*\"keyword\"\:\s*\"([^\"]*)\"}) {
            $keyword = $1;
        } elsif ($line =~   m{\A\s*\"formula\"}) {
            $program .= "F";
        } elsif ($line =~   m{\A\s*\"maple\"}) {
            $program .= "p";
        } elsif ($line =~   m{\A\s*\"mathematica\"}) {
            $program .= "t";
        } elsif ($line =~   m{\A\s*\"program\"}) {
            $program .= "o";
        } elsif ($line =~   m{\A\s*\"offset\"\:\s*\"([^\"]*)\"}) {
            $value = $1;
            ($offset1, $offset2) = split(/\,/, $value);
            if (length($offset2) == 0) {
                $offset2 = 1;
            }
        } elsif ($line =~   m{\A\s*\"author\"\:\s*\"([^\"]*)\"}) {
            $author = $1;
        } elsif ($line =~   m{\A\s*\"revision\"\:\s*(\d+)}) {
            $revision = $1;
        } elsif ($line =~   m{\A\s*\"time\"\:\s*\"([^\"]*)\"}) {
            $value = $1;
            $access  = &utc($value);
        } elsif ($line =~   m{\A\s*\"created\"\:\s*\"([^\"]*)\"}) {
            $value = $1;
            $created = &utc($value);
        } elsif ($line =~   m{\A\s*\"results\"\:\s*null}) {
            $keyword = "notexist";
        } elsif ($line =~   m{\A\s*\"xref\"\:}) {
            $in_xref = 1; # start xref mode

        } else {
            if ($line =~    m{\/$aseqno\/b$seqno\.txt}) { # link to b-file
                $synth = ""; # not synthesized
            }
            if ($do_xref == 1) {
                &extract_aseqnos($aseqno, $line);
            }
        }
    } # foreach $line
    $keyword .= length($keyword) > 0 ? ",$synth" : $synth;
    if ($keyword =~ m{tabl}) {
        if ($name =~ m{rray|antidiagonals|pper left|quare}) {
            $keyword .= ",tar" . (($name =~ m{ascend}) ? "a" : "d");
        }
    }
    if (0) {
    } elsif ($action =~ m{n}) {
        print join("\t", ($aseqno
            , $name         )) . "\n";
    } elsif ($action =~ m{s}) {
        print join("\t", ($aseqno
            , $termno
            , $data         )) . "\n";
    } elsif ($action =~ m{x}) {
        foreach my $key (keys(%xhash)) {
        print join("\t", ($aseqno
            , $key
            , $xhash{$key}  )) . "\n";
        } # foreach
    } else {
        print join("\t", ($aseqno
            , $offset1, $offset2
            , $terms
            , $termno
            , $datalen
            , substr($keyword, 0, 64)
            , substr($program, 0, 64)
            , substr($author , 0, 64) # allow for apostrophes (up to 80)
            , $revision
            , $created
            , $access       )) . "\n";
    }
} # extract_from_json
#-----------------------
sub extract_aseqnos {
    my ($aseqno, $line) = @_;
    foreach my $aref ($line =~ m{(A\d{6})}g) { # get all referenced A-numbers
        if ($aref eq $aseqno) { # ignore reference to own
        } elsif (! defined($xhash{$aref})) {
            $xhash{$aref}  = ($in_xref == 1 ? 2 : 1);
        } else {
            $xhash{$aref} |= ($in_xref == 1 ? 2 : 1);
        }
    } # foreach
} # extract_aseqnos;
#-----------------------
sub print_create_asinfo {
    print <<"GFis";
--  Table for OEIS - basic information about sequences
--  @(#) \$Id\$
--  $utc_stamp: Georg Fischer - generated by extract_info.pl $action, do not edit here!
--
DROP    TABLE  IF EXISTS $tabname;
CREATE  TABLE            $tabname
    ( aseqno    VARCHAR(10)   -- A322469
    , offset1   BIGINT        -- index of first term, cf. OEIS definition
    , offset2   BIGINT        -- sequential number of first term with abs() > 1, or 1
    , terms     VARCHAR($terms_width)   -- first $lead terms if length <= $terms_width
    , termno    INT           -- number of terms in DATA section
    , datalen   INT           -- length of DATA section
    , keyword   VARCHAR(64)   -- "hard,nice,more" etc.
    , program   VARCHAR(64)   -- "mtp", later also "PARI,Perl,joeis" etc.
    , author    VARCHAR(96)   -- of the sequence; allow for apostrophes
    , revision  INT           -- sequential version number
    , created   TIMESTAMP DEFAULT '1971-01-01 00:00:01'    -- creation     time in UTC
    , access    TIMESTAMP DEFAULT '1971-01-01 00:00:01'    -- modification time in UTC
    , PRIMARY KEY(aseqno)
    );
COMMIT;
GFis
} # print_create_asinfo
#-----------------------
sub print_create_asxref {
    print <<"GFis";
--  Table for OEIS - information about CROSSREFS in sequences
--  @(#) \$Id\$
--  $utc_stamp: Georg Fischer - generated by extract_info.pl $action, do not edit here!
--
DROP    TABLE  IF EXISTS $tabname;
CREATE  TABLE            $tabname
    ( aseqno    VARCHAR(10)   -- A322469
    , rseqno    VARCHAR(10)   -- referenced A-number
    , mask      INT           -- bit 1: in "xref", bit 0: in other properties
    , PRIMARY KEY(aseqno, rseqno, mask)
    );
CREATE  INDEX  ${tabname}a ON $tabname
    (aseqno     ASC
    );
CREATE  INDEX  ${tabname}r ON $tabname
    (rseqno     ASC
    );
COMMIT;
GFis
} # print_create_asinfo
#----
sub terms8 { # keep in sync with code in extract_from_bfile !!!
    my ($value) = @_;
    my @valarray = split(/\,/, $value);
    my $termno = scalar(@valarray);
    my $iterm = 0;
    my $terms = "";
    my $state_lead = $lead;
    while ($iterm < $state_lead and $iterm < scalar(@valarray)) {
        my $term = $valarray[$iterm];
        if (length($terms) + length($term) < $terms_width) { # store the leading ones
           $terms .= ",$term";
        } else {
            $state_lead = 0; # break loop
        }
        $iterm ++;
    } # while $iterm
    return ($termno, substr($terms, 1)); # remove first comma
} # terms8
#----
sub utc {
    my ($value) = @_;
#   2011-11-13T12:40:47-05:00
    $value =~ m{\A(\d+)\D(\d+)\D(\d+)\D(\d+)\D(\d+)(\D)(\d+)\D(\d+)\D(\d+)};
    my (          $year, $month,$day,  $hour, $min,$sec,$tzsign,$tzhour,$tzmin)
        = (       $1,    $2,    $3,    $4,    $5,  $6,  $7,     $8,     $9);
    if ($tzsign == "+") { # subtract; for example 12:00:00+01:00 in Berlin is 12:00:00+00&nbsp;:00 in London (GMT)
        $min -= $tzmin;
        if ($min < 0) {
            $min += 60;
            $hour --;
        }
        $hour -= $tzhour;
        if ($hour < 0) {
            $hour += 24;
            $day --;
            if ($day < 1) {
                $month --;
                if ($month < 1) {
                    $year --;
                    $month = 12;
                    $day   = 31;
                } else {  #    Jan               Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec
                    $day = ("", 31, &feb_last($year), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)[$month];
                }
            } # day < 0
        } # hour < 0
    } else { # "-" add
        $min += $tzmin;
        if ($min > 60) {
            $min -= 60;
            $hour ++;
        }
        $hour += $tzhour;
        if ($hour > 24) {
            $hour -= 24;
            $day ++; #         Jan               Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec
            if ($day >     ("", 31, &feb_last($year), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)[$month]) {
                $month ++;
                if ($month > 12) {
                    $year ++;
                    $month = 1;
                    $day   = 12;
                } else {
                    $day = 1;
                }
            } # day < 0
        } # hour < 0
    } # add
    if ($year < 1970) {
        # OEIS server sometimes sets "0000"
        # MariaDB does not accept timestamps < "1970-01-01 01:01:01"
        $year = 1971;
    }
    return sprintf ("%04d-%02d-%02d %02d:%02d:%02d"
        , $year, $month, $day, $hour, $min, $sec);
} # utc
#----
sub feb_last {
    my ($year) = @_;
    my $result = 28;
    return $result;
} # feb_last
#---------------------------
sub extract_from_bfile {
    my $result = "";
    my ($filename) = @_;
    my $width      = $terms_width;
    my $state_lead = $lead;
    my $long_width = 1024;
    if ($action =~ m{t}) { # bfdata
        &read_file($filename, $read_len_min); # sets $access, $buffer, $filesize
        $width = $long_width; # wc -L stripped -> 970
        $state_lead = 1024;
    } else { # normal bfinfo
        &read_file($filename, $read_len_max); # sets $access, $buffer, $filesize
    }
    my $terms   = "";
    my $termno  = 0;
    my $bfimin  = 0;
    my $bfimax  = 0;
    my $offset2 = 1;
    my $busyof2 = 1; # as long as offset2 is not determined
    my $iline   = 0;
    my %mess    = (); # hash for messages
    my $maxlen  = 0;
    my $index;
    my $term;
    my $isge    = 1; # assume that the terms are monotone (<=)
    my $isgt    = 1; # assume that the terms are strictly increasing (<)
    my $decindex = 0; # last index which was decreasing
    my $old_term = "";
    my $oldlen  = 29061947; # longer than any OEIS number
    my $state   = 0;
    if (substr($buffer, -1) ne "\n") {
        $mess{"neof"} = ""; # ord(substr($buffer, -1));
    }
    foreach my $line (split(/\n/, $buffer)) {
        if ($line =~ m{\A(\-?\d+)\s(\-?\d+)\Z}o) { # index space term
            ($index, $term) = ($1, $2);
            if ($iline == 0) {
                $bfimin   = $index;
                $decindex = $bfimin;
            } elsif ($index != $bfimax + 1) { # check for increasing index
                $mess{"nxinc"} = ($iline + 1); # hard error - index not increasing
            }
            if ($iline < $state_lead and length($terms) + length($term) < $width) { # store the leading ones
                $termno ++;
                $terms .= ",$term";
            } else {
                $state_lead = 0; # never try it again
                last if $width == $long_width;
            }
            if (substr($term, 0, 1) eq "-" and ! defined($mess{"sign"})) { # sign applies to terms only
                $mess{"sign"}  = ""; # ($iline + 1);
            }
            $bfimax = $index;
            $iline ++;
            if ($busyof2 == 1 and ($term !~ m{\A\-?[01]{1}\Z}o)) {
                $offset2 = $iline;
                $busyof2 = 0;
            }
            # line with parseable term
            my $curlen = length($term);
            if ($curlen > $maxlen) {
                $maxlen = $curlen;
            }
            # determine whether it's non-increasing
            if (0) {
            } elsif ($curlen > $oldlen) {
                # ok, increasing
            } elsif ($curlen < $oldlen) {
                $decindex = $index; # decreasing
            } else { # same lengths, must compare both terms (by characters)
                if ($term le $old_term) {
                    $decindex = $index;
                }
            }
            $oldlen = $curlen;
            $old_term = $term;
        } elsif ($line =~ m{\A\#.*}) { # comment
            if ($iline == 0 and ($line =~ m{\A\# A\d{6} \Wb\-file synthesized from seq.*\Z})) {
                $mess{"synth"} = "";
            } elsif ($iline > 0) {
                $mess{"ecomt"} = "";
                $mess{"loose"} = "";
            } else {
                $mess{"comt"}  = "";
            }
            # otherwise ignore comment
        } elsif ($line =~ m{\A\s*\Z}) { # blank line
                $mess{"blank"} = "";
                # otherwise ignore blank line
        } else { # loose format
            if (($line =~ s{\A\s+}{})  > 0) { # leading whitespace
                $mess{"lsp"}   = "";
                $mess{"loose"} = "";
            }
            if (($line =~ s{\s\s+}{ }) > 0) { # middle whitespace
                $mess{"msp"}   = "";
                $mess{"loose"} = "";
            }
            if (($line =~ s{\r\Z}{})   > 0) { # cr
                $mess{"cr"}    = "";
                $mess{"loose"} = "";
            }
            if (($line =~ s{\#.*}{})   > 0) { # comment behind term
                $mess{"tcomt"} = "";
                $mess{"loose"} = "";
            }
            if (($line =~ s{\s+\Z}{})  > 0) { # right whitespace
                $mess{"rsp"}   = "";
                $mess{"loose"} = "";
            }
            if ($line =~ m{\A(\-?\d+)\s(\-?\d+)\Z}o) { # index space term
                redo;
            } else { # really broken - ignore
                $mess{"bad"}   = "$iline"; # hard error
            }
        } # loose
    } # foreach $line
    $filename =~ m{b(\d{6})\.txt}i; # extract seqno
    my $aseqno = "A$1";
    my $message = "";
    if (scalar(keys(%mess) > 0)) { # some message
        foreach my $key (sort(keys(%mess))) {
            $message .= ",$key$mess{$key}"
        } # foreach
    } # some message
    if ($message =~ m{ n(dig|inc)}) {
        print STDERR "# $filename: $aseqno\t$message\n";
    }
    if ($action =~ m{t}) { # bfdata
        print join("\t",
        ($aseqno
                , $termno
        , substr($terms,   1) # remove 1st comma
        )) . "\n";
    } else { # normal bfinfo
        print join("\t",
        ( $aseqno
        , $bfimin
        , $bfimax
        , $decindex # was offset2
        , substr($terms,   1) # remove 1st comma
        , substr($term, -$tail_width)
        , $filesize
        , $maxlen
        , substr($message, 1) # remove 1st comma
        , $access
        )) . "\n";
    }
} # extract_from_bfile
#-----------------------
sub print_create_bfinfo {
    print <<"GFis";
--  Table for OEIS - basic information about b-files
--  @(#) \$Id\$
--  $utc_stamp: Georg Fischer - generated by extract_info.pl $action, do not edit here!
--
DROP    TABLE  IF EXISTS $tabname;
CREATE  TABLE            $tabname
    ( aseqno    VARCHAR(10)   -- A322469
    , bfimin    BIGINT        -- index in first data line
    , bfimax    BIGINT        -- index in last  data line
    , decindex  BIGINT        -- last index where terms were decreasing
--  , offset2   BIGINT           line number of first term with abs(term) > 1, or 1
    , terms     VARCHAR($terms_width)   -- first $lead terms if length <= $terms_width
    , tail      VARCHAR(8)    -- last $tail_width digits of last term
    , filesize  INT           -- size of the file in bytes, from the operating system
    , maxlen    INT           -- maximum length of terms
    , message   VARCHAR(128)  -- "bad<iline>,blank,comt,cr,ecomt,loose,lsp,msp,neof,rsp,sign,nxinc<iline>,synth,tcomt"
    , access    TIMESTAMP DEFAULT '1971-01-01 00:00:01' -- b-file modification time in UTC
    , PRIMARY KEY(aseqno)
    );
COMMIT;
GFis
} # print_create_bfinfo
#------------------------------------
__DATA__
{
	"greeting": "Greetings from The On-Line Encyclopedia of Integer Sequences! http://oeis.org/",
	"query": "id:A144640",
	"count": 1,
	"start": 0,
	"results": [
		{
			"number": 144640,
			"data": "3,17,48,102,185,303,462,668,927,1245,1628,2082,2613,3227,3930,4728,5627,6633,7752,8990,10353,11847,13478,15252,17175,19253,21492,23898,26477,29235,32178,35312,38643,42177,45920,49878,54057,58463,63102,67980,73103",
			"name": "Row sums from A144562.",
			"comment": [
				"Row 2 of the convolution array A213833. - _Clark Kimberling_, Jul 04 2012"
			],
			"link": [
				"Vincenzo Librandi, \u003ca href=\"/A144640/b144640.txt\"\u003eTable of n, a(n) for n = 1..10000\u003c/a\u003e",
				"\u003ca href=\"/index/Rec#order_04\"\u003eIndex entries for linear recurrences with constant coefficients\u003c/a\u003e, signature (4,-6,4,-1)."
			],
			"formula": [
				"a(n) = (2*n^2 + 5*n - 1)*n/2. - _Jon E. Schoenfield_, Jun 24 2010",
				"G.f.: x*(3+5*x-2*x^2)/(1-x)^4. - _Vincenzo Librandi_, Jul 06 2012",
				"a(n) = 4*a(n-1) - 6*a(n-2) + 4*a(n-3) - a(n-4). - _Vincenzo Librandi_, Jul 06 2012"
			],
			"mathematica": [
				"CoefficientList[Series[(3+5*x-2*x^2)/(1-x)^4,{x,0,40}],x] (* _Vincenzo Librandi_, Jul 06 2012 *)"
			],
			"program": [
				"(MAGMA) I:=[3, 17, 48, 102]; [n le 4 select I[n] else 4*Self(n-1)-6*Self(n-2)+4*Self(n-3)-Self(n-4): n in [1..50]]; // _Vincenzo Librandi_, Jul 06 2012"
			],
			"xref": [
				"Cf. A144562."
			],
			"keyword": "nonn,easy",
			"offset": "1,1",
			"author": "_Vincenzo Librandi_, Jan 21 2009, Jun 29 2009",
			"references": 2,
			"revision": 28,
			"time": "2017-06-17T02:59:29-04:00",
			"created": "2009-02-27T03:00:00-05:00"
		}
	]
}
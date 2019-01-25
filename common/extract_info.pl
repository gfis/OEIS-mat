#!perl

# Extract information from a b-file, and generate .tsv or SQL
# @(#) $Id$
# 2019-01-22, Georg Fischer: copied from ../bfcheck/bfanalyze.pl
#
# usage:
#   perl extract_info.pl [-action] [-l lead] [-d level] inputdir > outputfile
#       action  (default -br)
#           a   for sequence JSON
#           b   for bfile
#           r   TSV for Dbat -r,
#           c   generate CREATE SQL
#           i   generate INSERT SQL
#           u   generate UPDATE SQL
#       -l lead     print so many initial terms (default 8)
#       -d level    debug level none(0), some(1), more(2)
#       -w width    maximum number of characters in term string
#       inputdir    default: ./unbf
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
my $width      = 64;
my $tabname    = "bfinfo";
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{\-d}) {
        $debug  = shift(@ARGV);
    } elsif ($opt =~ m{\-l}) {
        $lead  = shift(@ARGV);
    } elsif ($opt =~ m{\-}) {
        $action = $opt;
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while ARGV
my $inputdir = shift(@ARGV);
$tabname = ($action =~ m{b})
    ? "bfinfo"
    : "jsinfo"
    ;
my $access = "1900-01-01 00:00:00"; # modification timestamp from the file
my $buffer; # contains the whole file
#----------------------------------------------
if (0) {
#--------------------------
} elsif ($action =~ m{b}) {
    $tabname = "bfinfo";
    if (0) {
    } elsif ($action =~ m{r}) {
        foreach my $file (glob("$inputdir/*")) {
            print join("\t", &extract_from_bfile($file)) . "\n";
        } # foreach $file
    } elsif ($action =~ m{c}) {
        &print_create_bfinfo();
    } elsif ($action =~ m{i}) {
        die "action $action not yet implementen\n";
    } elsif ($action =~ m{u}) {
        die "action $action not yet implementen\n";
    } else {
        die "invalid action \"$action\"\n";
    }
#--------------------------
} elsif ($action =~ m{j}) {
    $tabname = "asinfo";
    if (0) {
    } elsif ($action =~ m{r}) {
        foreach my $file (glob("$inputdir/*")) {
            print join("\t", &extract_from_json($file)) . "\n";
        } # foreach $file
    } elsif ($action =~ m{c}) {
        &print_create_asinfo();
    } elsif ($action =~ m{i}) {
        die "action $action not yet implementen\n";
    } elsif ($action =~ m{u}) {
        die "action $action not yet implementen\n";
    } else {
        die "invalid action \"$action\"\n";
    }
#--------------------------
} else {
    die "invalid action \"$action\"\n";
} # actions
#----------------------
sub read_file { # returns in global $access, $buffer
    my ($filename) = @_;
    open(FIL, "<", $filename) or die "cannot read $filename\n";
    my ($dev, $ino, $mode, $nlink, $uid, $gid, $rdev, $size, $atime
        , $mtime, $ctime, $blksize, $blocks) = stat(FIL);
    ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday) = gmtime ($mtime);
    $access = sprintf ("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec); # in UTC: "2019-01-23 08:07:00"
    read(FIL, $buffer, 100000000); # 100 MB, should be less than 10
    close(FIL);
} # read_file
#---------------------------
sub extract_from_bfile {
    my ($filename) = @_;
    &read_file($filename); # sets $access, $buffer
    my $terms   = "";
    my $bfimin  = 0;
    my $bfimax  = 0;
    my $offset2 = 1;
    my $busyof2 = 1;
    my $iline   = 0;
    my $message = "";
    my $index;
    my $term;
    foreach my $line (split(/\n/, $buffer)) {
        if ($iline == 0 and ($line =~ m{\A\# A\d{6} \(b\-file synthesized from sequence entry\)\s*\Z})) {
            $message .= " synth"
        }
        $line  =~ s{\A\s*(\#.*)?}{}o; # remove leading whitespace and comments
        if ($line =~ m{\A(-?\d+)\s+(\-?\d{1,})\s*(\#.*)?\Z}o) {
            # loose    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^  format "index term #?"
            ($index, $term) = ($1, $2);
            if ($iline == 0) {
                $bfimin = $index;
            } elsif ($index != $bfimax + 1) { # check for increasing only
                if ($message !~ m{ ninc}) {
                    $message .= " ninc\@" . ($iline + 1);
                }
            } # not increasing
            if ($iline < $lead and length($terms) + length($term) < $width) { # store the leading ones
                $terms .= ",$term";
            }
            if ((substr($index, 0, 1) eq "-" or substr($term, 0, 1) eq "-")
                    and ($message !~ m{ sign})) {
                $message .= " sign";
            }
            $bfimax = $index;
            $iline ++;
            if ($busyof2 == 1 and ($term !~ m{\A\-?[01]{1}\Z}o)) {
                $offset2 = $iline;
                $busyof2 = 0;
            }
            # line with parseable term
        } elsif (length($line) == 0) {
            # was comment or whitespace
        } else { # bad
            $iline ++;
            if ($message !~ m{ ndig}) { # not exactly 2 numbers
               $message .= " ndig\@$iline";
            }
        }
    } # foreach $line
    $filename =~ m{b(\d{6})\.txt}i; # extract seqno
    my $aseqno = "A$1";
    if (length($message) > 0 and ($message =~ m{ n(dig|inc)})) {
        print STDERR "# $filename: $aseqno\t$message\n";
    }
    return ($aseqno
        , $bfimin
        , $bfimax
        , $offset2
        , substr($terms, 1) # remove first comma
        , substr($term, -$tail_width)
        , substr($message , 1) # remove 1st space
        , $access
        );
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
    , offset2   BIGINT        -- line number of first term with abs(term) > 1, or 1
    , terms     VARCHAR($width)   -- first $lead terms if length <= $width
    , tail      VARCHAR(8)    -- last $tail_width digits of last term
    , message   VARCHAR(64)   -- "sign ninc[iline] ndig[iline]"
    , access    TIMESTAMP     -- b-file modification time in UTC
    , PRIMARY KEY(aseqno)
    );
COMMIT;
GFis
} # print_create_bfinfo
#-------------------------------------------------
sub extract_from_json { # read JSON of 1  sequence
    my ($filename) = @_;
    &read_file($filename); # sets $access, $buffer
    $filename =~ m{(A\d{6})\.json}i; # extract seqno
    my $aseqno   = $1;
    my $offset1  = 1;
    my $offset2  = 1;
    my $terms    = "";
    my $keyword  = "nokeyword";
    my $author   = "";
    my $revision = 0;
    my $created  = "1974-01-01 00:00:00";
    $access      = $created;
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
    foreach my $line (split(/\n/, $buffer)) {
        if ($line !~ m{\A\s*\"}) { # ignore
        } elsif ($line =~ m{\A\s*\"number\"\:\s*(\d+)}) {
            $value = $1;
            $seqno = sprintf("%06d", $value);
            $aseqno = "A$seqno";
            $filename =~ m{A(\d{6})\.json}i; # extract seqno
            my $fseqno = "A$1";
            if ($fseqno ne $aseqno) {
                print STDERR "# filename \"$filename\": fseqno \"$fseqno\" ne aseqno \"$aseqno\"\n";
            }
            $aseqno = $fseqno;
        } elsif ($line =~ m{\A\s*\"data\"\:\s*\"([^\"]*)\"}) {
            $value = $1;
            $terms = &get_terms8($value);
        } elsif ($line =~ m{\A\s*\"keyword\"\:\s*\"([^\"]*)\"}) {
            $keyword = $1;
        } elsif ($line =~ m{\A\s*\"offset\"\:\s*\"([^\"]*)\"}) {
            $value = $1;
            ($offset1, $offset2) = split(/\,/, $value);
            if (length($offset2) == 0) {
                $offset2 = 1;
            }
        } elsif ($line =~ m{\A\s*\"author\"\:\s*\"([^\"]*)\"}) {
            $author = $1;
        } elsif ($line =~ m{\A\s*\"revision\"\:\s*(\d+)}) {
            $revision = $1;
        } elsif ($line =~ m{\A\s*\"time\"\:\s*\"([^\"]*)\"}) {
            $value = $1;
            $access  = &get_utc_timestamp($value);
        } elsif ($line =~ m{\A\s*\"created\"\:\s*\"([^\"]*)\"}) {
            $value = $1;
            $created = &get_utc_timestamp($value);
        } elsif ($line =~ m{\A\s*\"results\"\:\s*null}) {
            $keyword = "notexist";
        } elsif ($line =~ m{\/$aseqno\/b$seqno\.txt}) {
            $synth = ""; # not synthesized
        }
    } # foreach $line
    $keyword .= length($keyword) > 0 ? ",$synth" : $synth;
    return ($aseqno
        , $offset1, $offset2
        , $terms
        , substr($keyword, 0, 64)
        , substr($author , 0, 64)
        , $revision
        , $created
        , $access
        );
} # extract_from_json
#-----------------------
sub print_create_asinfo {
    print <<"GFis";
--  Table for OEIS - basic information about b-files
--  @(#) \$Id\$
--  $utc_stamp: Georg Fischer - generated by extract_info.pl $action, do not edit here!
--
DROP    TABLE  IF EXISTS $tabname;
CREATE  TABLE            $tabname
    ( aseqno    VARCHAR(10)   -- A322469
    , offset1   BIGINT        -- index of first term, cf. OEIS definition
    , offset2   BIGINT        -- sequential number of first term with abs() > 1, or 1
    , terms     VARCHAR($width)   -- first $lead terms if length <= $width
    , keyword   VARCHAR(64)   -- "hard,nice,more" etc.
    , author    VARCHAR(80)   -- of the sequence; allow for apostrophes
    , revision  INT           -- sequential version number
    , created   TIMESTAMP     -- creation     time in UTC
    , access    TIMESTAMP     -- modification time in UTC
    , PRIMARY KEY(aseqno)
    );
COMMIT;
GFis
} # print_create_asinfo
#----
sub get_terms8 { # keep in sync with code in extract_from_bfile !!!
    my ($value) = @_;
    my @valarray = split(/\,/, $value);
    my $iterm = 0;
    my $terms = "";
    while ($iterm < $lead and $iterm < scalar(@valarray)) {
        my $term = $valarray[$iterm];
        if (length($terms) + length($term) < $width) { # store the leading ones
           $terms .= ",$term";
        }
        $iterm ++;
    } # while $iterm
    return substr($terms, 1); # remove first comma
} # get_terms8
#----
sub get_utc_timestamp { # keep in sync with code in extract_from_bfile !!!
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
        $year = 1974;
    }
    return sprintf ("%04d-%02d-%02d %02d:%02d:%02d"
        , $year, $month, $day, $hour, $min, $sec);
} # get_utc_timestamp
#----
sub feb_last {
    my ($year) = @_;
    my $result = 28;
    return $result;
} # feb_last
#------------------------------------
__DATA__
{
    "greeting": "Greetings from The On-Line Encyclopedia of Integer Sequences! http://oeis.org/",
    "query": "id:A200083",
    "count": 1,
    "start": 0,
    "results": [
        {
            "number": 200083,
            "data": "2,3,8,17,26,43,64,89,122,163,208,269,334,407,496,597,702,831,968,1117,1286,1471,1664,1889,2122,2371,2648,2945,3250,3595,3952,4329,4738,5171,5616,6109,6614,7143,7712,8309,8918,9583,10264,10973,11726,12511,13312",
            "name": "Number of 0..n arrays x(0..4) of 5 elements with zero 3rd differences.",
            "comment": [
                "Row 4 of A200082."
            ],
            "link": [
                "R. H. Hardin, \u003ca href=\"/A200083/b200083.txt\"\u003eTable of n, a(n) for n = 1..200\u003c/a\u003e"
            ],
            "formula": [
                "Empirical: a(n) = a(n-1) +a(n-3) -a(n-5) +a(n-6) -2*a(n-7) +a(n-8) -a(n-9) +a(n-11) +a(n-13) -a(n-14).",
                "Empirical g.f.: x*(2 + x + 5*x^2 + 7*x^3 + 6*x^4 + 11*x^5 + 5*x^6 + 8*x^7 + 3*x^8 + x^9 + 2*x^10 + x^11 + x^12 - x^13) / ((1 - x)^4*(1 + x)^2*(1 - x + x^2)*(1 + x^2)*(1 + x + x^2)^2). - _Colin Barker_, May 17 2018"
            ],
            "example": [
                "Some solutions for n=6:",
                "..2....1....2....3....0....4....0....5....0....6....6....3....6....0....4....3",
                "..3....3....4....4....4....4....0....6....3....2....3....3....3....1....3....5",
                "..3....4....5....4....6....4....0....6....4....0....2....3....1....2....2....6",
                "..2....4....5....3....6....4....0....5....3....0....3....3....0....3....1....6",
                "..0....3....4....1....4....4....0....3....0....2....6....3....0....4....0....5"
            ],
            "xref": [
                "Cf. A200082."
            ],
            "keyword": "nonn",
            "offset": "1,1",
            "author": "_R. H. Hardin_, Nov 13 2011",
            "references": 1,
            "revision": 13,
            "time": "2018-05-17T13:40:20-04:00",
            "created": "2011-11-13T12:40:47-05:00"
        }
    ]
}
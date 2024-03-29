#!perl

# Extract parameters for of the form a(n) = Qseqno(n) oper Rseqno(n)
# @(#) $Id$
# 2022-12-08, Georg Fischer: copied from anopan.pl
#
#:# Usage:
#:#     grep -Pi "a\(n\) *\= *(min|max|and|xor|or|lcm|gcd)\(n\," $(COMMON)/jcat25.txt \
#:#     | grep -E "^\%" \
#:#     | cut -b 4- | sed -e "s/ /\t/" \
#:#     | perl anopan.pl [-d debug] [-f ofter_file] > $@.tmp 2> $@.rest.tmp
#:#     -d  debugging level (0=none (default), 1=some, 2=more)
#:#     -f  file with aseqno, offset1, terms (default $(COMMON)/joeis_ofter.txt)
#:# Reads ofter_file for implemented jOEIS sequences with their offsets and first terms
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
$timestamp = sprintf ("%04d-%02d-%02d", $year + 1900, $mon + 1, $mday);

my $debug = 0;
if (0 and scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
my $COMMON = "../common";
my $ofter_file = "$COMMON/joeis_ofter.txt";
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt   =~ m{\-d}  ) {
        $debug      = shift(@ARGV);
    } elsif ($opt   =~ m{\-f}  ) {
        $ofter_file = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while options
#----------------
my $aseqno;
my $offset = 1;
my $terms;
my %ofters = ();
open (OFT, "<", $ofter_file) || die "cannot read $ofter_file\n";
while (<OFT>) {
    s{\s+\Z}{};
    ($aseqno, $offset, $terms) = split(/\t/);
    $terms = $terms || "";
    if ($offset < -1) { # offsets -2, -3: strange, skip these
    } else {
        $ofters{$aseqno} = $offset; # "$offset\t$terms";
    }
} # while <OFT>
close(OFT);
print STDERR "# $0: " . scalar(%ofters) . " jOEIS offsets and some terms read from $ofter_file\n";
my $VOID = "VOID";

my $line;
my $name;
my $aofs;   # offset for $aseqno
my $qseqno; # aseqno of the 1st referenced, underlying sequence
my $qshift; # expression is qseqno(n+shift)
my $qofs;   # offset for $qseqno
my $qdisp ; # displacement for qseqno
my $rseqno; # aseqno of the 2nd referenced, underlying sequence
my $rshift; # expression is rseqno(n+shift)
my $rdisp ; # displacement for rseqno
my $rofs;   # offset for $rseqno
my $callcode;
my $skip = "";   # asemble skip instructions here
my $op;
my $modif; # modifier (for pow)
my $initlist;
my $inits;
my $tail;
my $nok;
my $iseq;
my %ophash =
    ( "add", "add"
    , "and", "and"
    , "gcd", "gcd"
    , "lcm", "lcm"
    , "max", "max"
    , "min", "min"
    , "mod", "mod"
    , "or" , "or"
    , "xand", "xand"
    , "xor", "xor"
    );
while (<>) {
    $line = $_;
    $line =~ s/\s+\Z//; # chompr
    ($aseqno, $callcode, $aofs, $initlist, $name) = split(/\t/, $line);
    $name = $name || "";
    $name =~ s{([\.]).*}{$1};
    $nok = ""; # assume all ok
    if ($name =~ m{apparent|empirical|conject}i) {
        $nok = "?conj"; # ignore the unproven
    } else {
        $iseq = 0;
        #                       1  1  2                              2         3    34   5         5   4
        while ($name =~ s{[^\=]*(\=) *(gcd|lcm|min|max|x?and|mod|x?or)\(n\, * *(A\d+)(\(n([\+\-]\d+)?\))?\)}{}i) {
            ($op, $rseqno, $rshift) = ($2, $3, $5 || 0);
            $qshift = 0;
            ($modif, $rdisp, $skip) = ("", "", "", "");
            $qseqno = "mN";
            $nok = "";
            $iseq ++;
            $inits = "";
            if (defined($ophash{$op})) {
                $op = $ophash{$op};
            } else {
                $nok = "?op=$op";
            }
            if ($nok ne "") { # failed already
            } else { # 2 dependant sequences
                if (defined($ofters{$rseqno})) {
                    $callcode = "nopan";
                    $qofs = $ofters{$qseqno} || 0;
                    $rofs = $ofters{$rseqno};
                    # now determine the skip and prepend instructions
                    my $qinx = $qofs - $qshift;
                    my $rinx = $rofs - $rshift;
                    $qinx = &adjust(1, $qinx);
                    $rinx = &adjust(2, $rinx);
                    if ($qinx == $rinx && $rinx == $aofs) {
                        # ok
                    } else {
                        $callcode = "nopap";
                    }
                } else {
                    $nok = "?rseq";
                }
            } # 2 dependant sequences
            if ($skip ne "") {
                # $skip = "~~    $skip"; # prefix with indent spec.
            }
            if (length($inits) > 0) { # pattern with INITS[]
                $callcode = "nopap";
            }
            $inits = "?INITS";
            if (0 && $iseq > 1) {
                $callcode .= $iseq;
            }
            if ($nok eq "") {
                print        join("\t", $aseqno, $callcode, $aofs, $rseqno, $op,  "",   $skip, $name) . "\n";
                #                                                  parm1    parm2 parm3 $parm4  $parm5 $parm6  $parm7 parm8
            }
        } # while "= ... " matches
    }
    if ($nok eq "" && $iseq > 0) {
    } else {
        print STDERR join("\t", $aseqno, $nok, $aofs, $name) . "\n";
    }
} # while <>
#----
sub adjust { 
    my ($iseq, $inx) = @_;
    while ($inx < $aofs) {
        # $skip .= "~~mSeq$iseq.next();";
        $inx ++;
    } # while
    return $inx;
} # adjust
#----------------
__DATA__
A006792	anopan	10	2,0,0,0,0,4,8,0,4	a(n) = A006799(n) - A185959(n). - _Andrew Howroyd_, Nov 27 2018
A007411	anopan	2		a(n) = A003182(n) - A003182(n-1) - 1 = A006602(n) - 1.
A007762	anopan	1	1,8,120,2288,49680,1170968,29206632,759265760,20371816992	a(n) = A006318(n-1) * A104550(n) for all known terms [discovered by Sequence Machine]. - _Andrey Zabolotskiy_, Oct 12 2021
A048289	anopan	0		a(n) = A007565(n) - A007565(n-1), for n > 1. - _M. F. Hasler_, Nov 24 2016
A052443	anopan	1	0,0,1,2,7,39,332,4735,113176	a(n) = A002218(n) - A006290(n) for n > 2. - _Andrew Howroyd_, Sep 04 2019
A054907	anopan	0	1,0,0,0,0,0,0,0,1	If 8|n then a(n) = A054908(n) + A054909(n/8), otherwise a(n) = A054908(n). - _Andrey Zabolotskiy_, Nov 05 2021

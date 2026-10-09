#!perl

# Extract parameters for of the form a(n) = aseqno(n) oper num
# @(#) $Id$
# 2026-10-05: copied from anopan.pl
# 2022-12-08, Georg Fischer: copied from dersimple.pl
#
#:# Usage:
#:#     cat an0.tmp \
#:#     | perl roban1.pl [-d debug] [-f ofter_file] > $@.tmp 2> $@.rest.tmp
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

if (0 and scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
my $COMMON = "../common";
my $ofter_file = "$COMMON/joeis_ofter.txt";
my $debug = 0;
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
my $skip;   # asemble skip instructions here
my $op;
my $modif; # modifier (for pow)
my $initlist;
my $inits;
my $tail;
my $cond;
my $nok;
my $iseq;
my %ophash =
    ( "+",   "add"
    , "-",   "subtract"
    , "*",   "multiply"
    , "/",   "divide"
    , "^",   "pow"
    , "and", "and"
    , "mod", "mod"
    , "or" , "or"
    , "xor", "xor"
    , "xand", "xand"
    );
while (<>) {
    $line = $_;
    $line =~ s/\s+\Z//; # chompr
    ($aseqno, $name, $cond) = split(/\t/, $line);
    $name = $name || "";
    $name =~ s{([\.]).*}{$1};
    $nok = ""; # assume all ok
__DATA__

    if ($name =~ m{apparent|empirical|conject}i) {
        $nok = "?conj"; # ignore the unproven
    } else {
        $iseq = 0;
        #                       1  1  2    23   4         4   3   5                           5  6    67   8         8   7   9                                  9
        while ($name =~ s{[^\=]*(\=) *(A\d+)(\(n([\+\-]\d+)?\))? *([\*\/\+\-\^]|x?and|mod|x?or) *(A\d+)(\(n([\+\-]\d+)?\))? *([\.\;\:\,\=]|for +n *\>\=? *\d+|\Z)}{}i) {
            ($qseqno, $qshift, $op, $rseqno, $rshift, $tail) = ($2, $4 || 0, $5, $6, $8 || 0, $9);
            ($modif, $qdisp, $rdisp, $skip) = ("", "", "", "");
            $nok = "";
            $iseq ++;
            $inits = "";
            if (defined($ophash{$op})) {
                $op = $ophash{$op};
            } else {
                $nok = "?op";
            }
            if ($op eq "pow") {
                $modif = ".intValue()";
            }
            if ($nok ne "") { # failed already
            } elsif ($qseqno eq $rseqno) { # only 1 dependant sequence
                if (defined($ofters{$qseqno})) {
                    $callcode = "anopsn";
                    $qofs = $ofters{$qseqno};
                    # now determine the skip and prepend instructions
                    my $qinx = $qofs + $qshift;
                    $qinx = &adjust(1, $qinx);
                    if ($qinx == $aofs) {
                        # ok
                    } else {
                        $callcode = "anopsp";
                    }
                } else {
                    $nok = "?q2seq";
                }
            } else { # 2 dependant sequences
                if (defined($ofters{$qseqno}) && defined($ofters{$rseqno})) {
                    $callcode = "anopan";
                    $qofs = $ofters{$qseqno};
                    $rofs = $ofters{$rseqno};
                    # now determine the skip and prepend instructions
                    my $qinx = $qofs - $qshift;
                    my $rinx = $rofs - $rshift;
                    $qinx = &adjust(1, $qinx);
                    $rinx = &adjust(2, $rinx);
                    if ($qinx == $rinx && $rinx == $aofs) {
                        # ok
                    } else {
                        $callcode = "anopap";
                    }
                } else {
                    $nok = "?qrseq";
                }
            } # 2 dependant sequences
            if ($skip ne "") {
                $skip = "~~    $skip"; # prefix with indent spec.
            }
            if (length($inits) > 0) { # pattern with INITS[]
                $callcode = "anopap";
            }
            $inits = "?INITS";
            if ($iseq > 1) {
                $callcode .= $iseq;
            }
            if ($nok eq "") {
                print        join("\t", $aseqno, $callcode, $aofs, $qseqno, $rseqno, $op,  $modif, $skip, $inits, "$qofs,$rofs") . "\n";
                #                                                  parm1    parm2    parm3 $parm4  $parm5 $parm6  $parm7 parm8
            }
        } # while "= ... " matches
    }
    if ($nok eq "" && $iseq > 0) {
    } else {
        print STDERR join("\t", $aseqno, $nok     , $name) . "\n";
    }
} # while <>
#----
sub adjust { 
    my ($iseq, $inx) = @_;
    while ($inx < $aofs) {
        $skip .= "~~mSeq$iseq.next();";
        $inx ++;
    } # while
    return $inx;
} # adjust
#----------------
        priorities      = new String[] { "()" 
        // the following defaults are the Java priorities from https://introcs.cs.princeton.edu/java/11precedence/
        /* 01 */ , "->"
        /* 02 */ , "= += -= *= %= /= &= ^= |= <<= >>= >>>="
        /* 03 */ , "? :"          // ternary (???)
        /* 04 */ , "||"
        /* 05 */ , "&&"
        /* 06 */ , "|"
        /* 07 */ , "^"
        /* 08 */ , "&"
        /* 09 */ , "!= =="
        /* 10 */ , "< <= >= >"    // instanceof (???)
        /* 11 */ , "<< >> >>>"
        /* 12 */ , "+ -"          // infix
        /* 13 */ , "* / %"
        /* 14 */ , "( )"          // cast (???)
        /* 15 */ , "! ~ ++ --"    // and unary +, unary -, but post-in/decrement (???)
        /* 16 */ , "++ --"        // post-in/decrement (???)
        /* 17 */ , ". :: [ ] ( )" // and new
        };

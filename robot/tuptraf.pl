#!perl

# Extract for transform.TupleTransformationSequence
# @(#) $Id$
# 2023-10-25, Georg Fischer
#
#:# Usage:
#:#   perl tuptraf.pl [-d debug] [-f ofter_file] input.cut25 > output.seq4
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
if (0 && scalar(@ARGV) == 0) {
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
#--------
my $line;
my ($callcode, $offset, $name, $rest, @rseqnos);

while (<>) { # read infile(s)
    $line = $_;
    $line =~ s/\s+\Z//; # chompr
    $line =~ s/  +/ /g; # only single spaces
    ($aseqno, $name) = split(/ /, $line, 2);
    my %hash = ();
    my @rseqnos = ();
    $name =~ s{^ *a\(n\) *\= *}{}; # remove "a(n) ="
    if ($name =~ m{^((A\d+\(n\)|\d+|n|[\+\-\*\/\^])+)[fiw\.\,\:\;\=]}) { # proper name
        $name = $1;
        $name =~ s{ }{}g;
        my $irs = 0;
        foreach my $rseqno ($name =~ m{(A\d+)}g) { # collect all rseqnos and assign indexes to them
            if (! defined($hash{$rseqno})) {
                $hash{$rseqno} = $irs ++;
            }
        } # foreach $rseqno
        foreach my $rseqno (keys(%hash)) [
            my $index = $hash{$rseqno};
            $rseqnos[$index] = $rseqno;
            $name =~ s{$rseqno\(n\)}{v\[$index\]}g;
        }
        if ($debug >= 1) {
        	print "# $aseqno, name=\"$name\"\n";
        }
        #----
        my $lambda = "(n, v) ->";
        if ($name !~ m[^\-}) {
            $name = "\+$name";
        }

        my $nyi = 0;
        my $rlen = scalar(@rseqnos);
        for (my $rind = 0; $rind < $rlen; $rind ++) {
            my $rseqno = $rseqnos[$rind];
            my $ofter = $ofters{$rseqno};
            $rseqnos[$rind] = "new $rseqno()";
            if (defined($ofter)) {
               my ($roffset, $rterm) = split(/\t/, $ofter);
               if ($roffset < $offset) {
                   $rseqnos[$rind] .= ".skip(" . ($offset - $roffset) . ")";
               }
            } else {
               $nyi ++;
               $rseqnos[$rind] =~ s{A}{€};
            }
        } # foreach $rseqno
        if ($nyi == 0 && $rlen >= 1) {
            print        join("\t", $aseqno, "rgs$rlen" , $offset, @rseqnos, "# " . substr($name, 0, 8) . " $rest") . "\n";
        } else {
            print STDERR join("\t", $aseqno, "rgsnyi"   , $offset, @rseqnos, "# " . substr($name, 0, 8) . " $rest") . "\n";
        }
    } # if proper name
} # while <>
#----
sub sum {
    my ($expr) = @_;
    my @parts = split(/([\+\-])/, $expr); 
    my $result = "";
    my $ip = 0; 
    while ($ip < scalar(@parts)) {
        my $oper = $parts[$is ++];
        my $part = $parts[$is ++];
        $result .= "\t$oper\t" . &product($part);
    } # while
    return $result;
} # sum
#--
sub product {
    my ($expr) = @_;
    my @parts = split(/([\*\/])/, "*$expr"); 
    my $result = "";
    my $ip = 0; 
    while ($ip < scalar(@parts)) {
        my $oper = $parts[$is ++];
        my $part = $parts[$is ++];
        $result .= "\t$oper\t" . &power($part);
    } # while
    return $result;
} # product
#--
sub power {
    my ($expr) = @_;
    my @parts = split(/\^/, "$expr"); 
    if (scalar(@parts) > 2) {
        print STDERR "# $aseqno a^b^c: $name\n";
    } 
    
    if (scalar(@parts) == 1) {
    } else { a^b
    }
    my $result = "";
    my $ip = 0; 
    while ($ip < scalar(@parts)) {
        my $oper = $parts[$is ++];
        my $part = $parts[$is ++];
        $result .= "\t$oper\t" . &power($part);
    } # while
    return $result;
} # product
__DATA__
A286448 rgs 0   Restricted growth sequence computed for A252748 (= A003961(n) - 2*n).
A286449 rgs 0   Restricted growth sequence computed for A033879 (deficiency), or equally, for A033880 (abundance of n).
A286544 rgs 0   Restricted growth sequence of €285333.
A286547 rgs 0   Restricted growth sequence of A286546 (A006068(n) - n).
A291751 rgs 0   Lexicographically earliest such sequence a that a(i) = a(j) => A003557(i) = A003557(j) and A048250(i) = A048250(j), for all i, j.
A295880 rgs 0   Filter combining the number of divisors (A000005) and the sum of divisors (A000203) of n.

#!perl

# Check the example list
# @(#) $Id$
# 2021-07-29, Georg Fischer
#
#:# Usage:
#:#   perl exacheck.pl [-d debug] exalist.tmp > out.txt # suitable for htmlize
#--------------------------------------------------------
use strict;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
$timestamp = sprintf ("%04d-%02d-%02d", $year + 1900, $mon + 1, $mday);

if (0 && scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
my $debug = 0;
my $width = 4; # number of relevant digits for boundaries
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{w}) {
        $width     = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my $aseqno = "";
my $data = "";
my $callcode = "example";
my $offset = 0;
my $example = "";
print join("\t", "aseqno", "callcode", "len", "digits") . "\n";
while (<>) {
    my $line = $_;
    next if $line !~ m{\AA\d\d+};
    $line =~ s/\s+\Z//; # chompr
    ($aseqno, $callcode, $offset, $data, $example) = split(/\t/, $line);
    my $exad = $example || "";
    if (($exad !~ m{\A\s*\Z}) && ($exad !~ m{\?})) {
        $exad =~ s{\*10\^\(?\-?\d+\)?}{}; # remove exponent
        my $expon = $1 || 0;
        if ($exad =~ s{\((\d+\))\Z}{}) { # remove certainity
            my $certain = $1;
            $exad = substr($exad, 0, length($exad) - length($certain) - 2);
        }
        $exad =~ s{\.\.\.\d{4}.*}{}; # 3 dots and anything behind
        $exad =~ s{\A\-}{}; # remove sign
        my $exac = $exad;
        $exad =~ s{\A0\.0*}{}; # remove 0.0*
        $exad =~ s{\D}{}g; # remove all but digits
        if ($data !~ m{$exad}) {
            my $exac = substr($exad, 0, length($exad) - 1); # remove last digit;
            if ($data !~ m{$exac}) {
                print join("\t", $aseqno, "termlist", length($data), $data) . " \n";
                print join("\t", $aseqno, "__nopref", length($exad), $exad) . " \n";
            } else {
                print join("\t", $aseqno, "termlist", length($data), $data) . " \n";
                print join("\t", $aseqno, "____ldif", length($exad), $exad) . " \n";
            }
        } else { # exad is contained in data
            # &expo_test($exac, $expon);
            if (0) {
            } elsif ($offset ==  0 && ($exac !~ m{\A0?\.}  )) {
                &errout($exac);
            } elsif ($offset ==  1 && ($exac !~ m{\A\d\.}  )) {
                &errout($exac);
            } elsif ($offset == -1 && ($exac !~ m{\A0?\.0} )) {
                &errout($exac);
            } elsif ($offset ==  2 && ($exac !~ m{\A\d\d\.})) {
                &errout($exac);
            }
        }
    } # valid exad 
} # while
#----
sub errout {
    my ($exac) = @_;
    print join("\t", $aseqno, "__offs__", $offset, $exac) . " \n";
} # errout
#----
sub expo_test {
    my ($exad, $expon) = @_;
    $exad =~ s{\.\.*}{}g;
    $exad = substr($exad, 0, 12);
    my $dat4 = ("0." . substr($data, 0, 4)) * (10 ** $offset);
    $dat4 = sprintf("%.2f", $dat4);
    $dat4 =~ s{ }{}g;
    $dat4 =~ s{\A\.}{0\.};
    my $exa4 = $exad * (10 ** $expon);
    $dat4 =~ s{\.}{p};
    $exa4 =~ s{\.}{p};
    if ($exa4 !~ m{$dat4}) {
        print join("\t", $aseqno, "____expo", $exa4, $dat4) . " \n";
    }
} # expo_test
__DATA__
A003137	example	1	121011122021221001011021101111121201211222002012022102112122202212221000100110021010101110121020102110221	
A003671	example	0	0000000000529177210	5.29177210903(80)*10^-11
A003672	example	0	0005485799090	
A003673	example	0	00729735256	7.29735256*10^-3
A003675	example	1	100866491	
A003676	example	-33	662607015	??Planck constant 
A003677	example	1	1007276466	
A003678	example	9	299792458	
A003881	example	0	785398163397448309615660845819875721049292349843776455243736148076954101571552249657008706335529266995537	0.785398163397448309615660845819875721049292349843776455243736148

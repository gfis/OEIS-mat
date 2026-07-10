#!perl

# holinits - for HolonomicRecurrence: polish the matrix bva, insert CC, and get initial terms
# @(#) $Id$
# 2026-07-08, Georg Fischer: copied from common/holguess.pl
#
#:# usage:
#:#   perl holinits.pl input.seq4 > output.seq4
#:#       -a  n          additional terms (more than order, default 0)
#:#       -cc callcode   default: holos
#:#
#:# read b-files from $(COMMON)/bfile
#---------------------------------
use strict;
use integer;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday) = gmtime (time);
my $utc_stamp = sprintf ("%04d-%02d-%02dT%02d:%02d:%02d\z", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
print "# processed by $0 at $utc_stamp\n";

my $MAX_LEN  = 4090; # cf. $(COMMON)/seq4.create.sql
my $gits     =  $ENV{'GITS'};
my $debug    = 0;
my $callcode = "holos";
my $mode     = "";
my $bfdir    = "$gits/OEIS-mat/common/bfile";
my $add      = 0; # more than order
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{cc}) {
        $callcode  = shift(@ARGV);
    } elsif ($opt  =~ m{a}) {
        $add       = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my ($aseqno, $cc, $offset, $matrix, $inits, @rest, $termno, $termlist, @terms, $order);
# while(<DATA>) {
while(<>) {
    s/\s+\Z//; # chompr
    my $line = $_;
    if (m{\AA\d{6}\t}) { # valid A-number
        ($aseqno, $cc, $offset, $matrix, $inits, @rest) = split(/\t/, $line);
        $matrix =~ s/[\" ]//g;
        $inits  =~ s/[\" ]//g;
        # determine the number of initial terms from the matrix 
        my @coeffs;
        if ($matrix !~ m{[\[\,]\[\-?\d+\,}) { # constant coefficients, remove square brackets
            $matrix =~ s{\[\[}{\[};
            $matrix =~ s{\]\]}{\]};
            $matrix =~ s{\]\,\[}{\,}g;
            @coeffs = split(/\,/, $matrix);
        } else { # polynomial coefficients
            @coeffs = split(/\]\,\[/, $matrix);
        }
        $order = scalar(@coeffs) - 2 + $add; # without the 0 for constant and the -1 for a(n)
        my $termno = $order;
        if ($inits =~ m{\A\s*\Z}) { # empty
            # $termno == $order, ok
            &read_b_file($aseqno, $order);
        } elsif ($inits =~ m{\,}) { # comma already there, keep this termlist
            @terms  = split(/\, */, $inits);
        #                      1   1    2   2
        } elsif ($inits =~ m{\[(\d+)\.\.(\d+)\]}) { # e.g. "[1..17] -> 18 terms
        	my ($lo, $hi) = ($1, $2);
            &read_b_file($aseqno, $hi - $lo + 1);
        } elsif ($inits =~ m{\A(\d+)\Z}) { # exact number = order
            &read_b_file($aseqno, $inits - $offset + 1);
        }
        my $termlist = join(",", @terms);
        if (length($termlist) > $MAX_LEN) {
            print STDERR "# $aseqno: termlist >= $MAX_LEN\n";
        } else {
            print join("\t", $aseqno, $callcode, $offset, $matrix, $termlist, @rest) . "\n";
        }
    } # valid A-number
} # while <>
#----
sub read_b_file {
    my ($aseqno, $nterm) = @_;
    my $src_file = "$bfdir/b" . substr($aseqno, 1) . ".txt";
    my $buffer;
    open(FIL, "<", "$src_file") or die "cannot read $src_file\n";
    read(FIL, $buffer, 100000000); # 100 MB
    # print "# length of $src_file: " . length($buffer) . "\n";
    close(FIL);
    my $it = 0;
    my @all = grep { m{\S} } # keep non-empty lines only
        map {
            s{\#.*}{};      # remove comments
            s{\A\s+}{};     # remove leading whitespace
            s{\s+\Z}{};     # remove trailing whitespace
            # s{\s\s+}{ };  # make single space
            s{\-?\d+\s+}{}; # remove index
            # $it ++ if (m{\S});
            $_
        } split(/\n/, $buffer);
    @terms = splice(@all, 0, $nterm);
} # read_b_file
__DATA__
A174703	bva	0	[[0],[1],[1],[1],[0],[1],[-3],[-1],[-3],[-1],[-5],[5],[-1],[2],[-1],[6],[-4],[1],[-1],[1],[-2],[1]]	1	0	0				0
A184379	bva	0	[[0],[-362797056],[725594112],[-473651712],[485409024],[-739031040],[475844544],[-264166272],[295472448],[-186268896],[75446640],[-59740416],[36410148],[-12197952],[6578172],[-3788388],[1125036],[-396180],[206001],[-56628],[12447],[-5264],[1380],[-184],[47],[-12],[1]]	1	0	0		0
A185830	bva	0	[[0],[6],[42],[-361],[817],[-2841],[5924],[-2585],[-1156],[11233],[-31595],[50206],[-52709],[64896],[-115994],[117971],[-89028],[111655],[-188247],[164885],[-85004],[87270],[-89957],[56805],[28046],[-15849],[-28694],[-733],[5077],[-920],[351],[672],[70],[-321],[-2],[67],[15],[-9],[-4],[1]]	1	0	0		0
A186598	bva	0	[[0],[3],[-3],[0],[-3],[6],[-3],[0],[1],[-2],[1]]	1	0	0				0

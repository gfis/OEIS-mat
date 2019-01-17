#!perl

# Print a line with the first terms
# @(#) $Id$
# 2019-01-12, Georg Fischer
#
# usage:
#   perl bfhead.pl [-d level] [-w width] b-file.txt > output
#       -d debug
#       -w width of line with terms
#       -b with leading "%b "
#---------------------------------
use strict;
use integer;
# get options
my $width = 260;
my $debug  = 0; # 0 (none), 1 (some), 2 (more)
my $bpercent = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{\-b}) {
        $bpercent  = shift(@ARGV);
    } elsif ($opt =~ m{\-d}) {
        $debug  = shift(@ARGV);
    } elsif ($opt =~ m{\-w}) {
        $width  = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while ARGV
my $filename = shift(@ARGV);
print &get_head($filename) . "\n";
exit(0);
#----------------------
sub get_head {
    # old call: my $otext = &wget("https://oeis.org/search?q=id:$oseqno\\&fmt=text", "$oseqno.text");
    # my ($src_url, $tar_file) = @_;
    my ($src_file) = @_;
    $src_file =~ m{[Ab](\d+)};
    my $aseqno = "A$1";
    my $result;
    if (! -r $src_file) {
        $result = "%b $aseqno file $src_file not found";
    } else {
        my $buffer;
        open(FIL, "<", $src_file) or die "cannot read $src_file\n";
        read(FIL, $buffer, 100000000); # 100 MB
        # print "# length of $src_file: " . length($buffer) . "\n";
        close(FIL);
        my @terms = 
            grep { m{\S} } # keep non-empty lines only
                map { 
                    s{\#.*}{};      # remove comments
                    s{\A\s+}{};     # remove leading whitespace
                    s{\s+\Z}{};     # remove trailing whitespace
                    # s{\s\s+}{ };  # make single space
                    s{\-?\d+\s+}{}; # remove index
                    $_
                } split(/\n/, $buffer);
         
        $result = "$aseqno ";
        if ($bpercent > 0) {
        	$result = "%b $result";
        }
        my $ind = 0;
        while ($ind < scalar(@terms) and length($result) < $width) {
            $result .= ",$terms[$ind]";
            $ind ++;
        } # while $ind
        $ind = scalar(@terms) - $ind;
        if ($ind > 0) {
            $result .= " + $ind more in b-file";
        } else {
            $result .= " end of b-file";
        }
    }
    return $result;
} # get_head
#-----------------------------
__DATA__
%S A007079 1,2,24,2640,3230080,48251508480,9307700611292160,
%T A007079 24061983498249428379648,855847205541481495117975879680,
%U A007079 427102683126284520201657800159366676480,3035991776725501434069099002640396043332019814400,311112533558482034321687955029997989477274014274150137856000
%N A007079 Number of labeled regular tournaments with 2n+1 nodes.

C:\Users\User\work\gits\OEIS-mat\bfcheck>perl linelen.pl
60
66
161
65

C:\Users\User\work\gits\OEIS-mat\bfcheck>perl linelen.pl -a
%S A007079 60
%T A007079 66
%U A007079 161
%N A007079 65

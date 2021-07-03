#!perl

# 2021-06-26, Georg Fischer
# from Antti Karttunen, A050607, A050608, A051382
use strict;
use warnings;
use integer;

my $lim = 100;
my $base = 2;
my $aseqno = "A050608";
if (scalar(@ARGV) > 0) {
    $aseqno = shift(@ARGV);
}
if (scalar(@ARGV) > 0) {
    $lim = shift(@ARGV);
}
my $n = 0;
for (my $i = 0; $i <= $lim; $i++) { 
    my $cc; 
    if (
#       (($cc = &conv_x_base_n($i, 2)) =~ m/^(100(0)*)*(0|1|10)?$/                         ) and ($aseqno eq "A048715") or
#       (($cc = &conv_x_base_n($i, 2)) =~ m/^(1(1)?00(0)*)*(0|1|10|11|110)?$/              ) and ($aseqno eq "A048716") or
#       (($cc = &conv_x_base_n($i, 2)) =~ m/^(11(1)*00(0)*)*(0|11(1)*(0)?)?$/              ) and ($aseqno eq "A048717") or
#       (($cc = &conv_x_base_n($i, 2)) =~ m/^(1000(0)*)*(0|1|10|100)?$/                    ) and ($aseqno eq "A048718") or
#       (($cc = &conv_x_base_n($i, 2)) =~ m/^(1100(0)*)*(0|11(0)?)?$/                      ) and ($aseqno eq "A048719") or
#       (($cc = &conv_x_base_n($i, 5)) =~ m/^(0|1|2)*((0|1)(3|4))?(0|1|2)*|3|4$/           ) and ($aseqno eq "A050607") or
        (($cc = &conv_x_base_n($i, 5)) =~ m/^([012]*([01][34])?|[34])[012]*$/              ) and ($aseqno eq "A050607") or
#       (($cc = &conv_x_base_n($i, 7)) =~ m/^(0|1|2|3)*((0|1|2)(4|5|6))?(0|1|2|3)*$/       ) and ($aseqno eq "A050608") or
#       (($cc = &conv_x_base_n($i, 7)) =~ m/^([0123]*([012][456])?|[456])[0123]*$/         ) and ($aseqno eq "A050608") or
#       (($cc = &conv_x_base_n($i, 3)) =~ m/^(2(0|1)*|(0|1)*(02)?(0|1)*)$/                 ) and ($aseqno eq "A051382") or
        0 ) { 
        print "$n $i # $cc($base)\n"; 
        $n++;
    } 
}
#--
sub conv_x_base_n { 
	my($x, $b) = @_;
	$base = $b; # global
    my ($r, $z) = (0, ''); 
    do { 
        $r = $x % $b; 
        $x = ($x - $r)/$b; 
        $z = "$r" . $z; 
    } while(0 != $x);
    return($z); 
}
__DATA__
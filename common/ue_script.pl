#!perl

# call Ultraedit with some script
# 2025-04-14, Georg Fischer
#----
use strict;
use warnings;
use integer;
use Cwd qw(getcwd);

my $sep = "\\\\";
my $mode = shift(@ARGV);
my $cwd = getcwd();
$cwd =~ s{\s}{}g;
$cwd =~ s{\/cygdrive\/c}{C\:};
$cwd =~ s{\/}{$sep}g;
my $call;
if (0) {
} elsif ($mode =~ m{close}) {
    $call = <<"GFis";
UltraEdit.closeFile("$cwd${sep}joeis_names.txt", 2);
GFis
} elsif ($mode =~ m{open} ) {
    $call = <<"GFis";
UltraEdit.open("$cwd${sep}joeis_names.txt");
UltraEdit.activeDocument.readOnlyOn();
GFis
}
print        "$call";
__DATA__

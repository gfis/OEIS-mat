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
$mode =~ s{\W}{}g; # remove dash
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
UltraEdit.outputWindow.showWindow(false);
GFis
}                                                   
my $file = "joeis_names_$mode.js";
open(CAL, ">", $file) || die "cannot write \"$file\"\n";
print CAL "$call";
close(CAL);
print `uedit64 /s=\"$cwd${sep}$file\"`;
__DATA__

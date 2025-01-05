#!perl

# Call a jOEIS(-lite) program
# @(#) $Id$
# 2025-01-05, Georg Fischer: *IT=80
#
#:# Usage:
#:#   perl calljoeis.pl mainclass arg...
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my $jopt = "-Ddebug=0 -Xmx2800m -Xss800m -Duser.language=en -Dprog.root=./prog -Doeis.verbose=false -Doeis.priority=java,gp -Doeis.timeout=4";
my $sep  = ($ENV{'OS'} =~ m{\AWin}) ? ";" : ":";
my $gits =  $ENV{'GITS'};
my $cp   =  "\"$gits/joeis-lite/dist/joeis-lite.jar$sep$gits/joeis/build.tmp/joeis.jar\"";
$cp =~ s{\\}{\/}g;
my $class = shift(@ARGV);
if ($class !~ m{^irvine\.}) {
    $class = "irvine.oeis.$class";
}
my $cmd  = "java $jopt -cp $cp $class " . join(" ", map { m{[\,\ \;\:\&\=]} ? "$_" : $_ } @ARGV);
print STDERR "$cmd\n";
print `$cmd` ."\n";

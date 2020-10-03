#!perl

# Module for power series
# 2020-01-03, Georg Fischer

package PowerSeries;
use strict;
use warnings;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
use Carp;

$VERSION     = 1.00;
@ISA         = qw(Exporter);
@EXPORT      = ();
@EXPORT_OK   = qw(new toString);
# %EXPORT_TAGS = ( DEFAULT => [qw(&func1)],
#                  Both    => [qw(&func1 &func2)]);

my ($index, @coeffs);

sub new {
	($index, @coeffs) = @_;
} # new

sub toString {
	return "[" . join(",", @coeffs) . "];$index";
}

sub multiply {

} # multiply

1; # package result:
__DATA__


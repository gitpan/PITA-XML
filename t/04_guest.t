#!/usr/bin/perl -w

# Unit tests for the PITA::XML::Request class

use strict;
use lib ();
use File::Spec::Functions ':ALL';
BEGIN {
	$| = 1;
	unless ( $ENV{HARNESS_ACTIVE} ) {
		require FindBin;
		$FindBin::Bin = $FindBin::Bin; # Avoid a warning
		chdir catdir( $FindBin::Bin, updir() );
		lib->import(
			catdir('blib', 'lib'),
			catdir('blib', 'arch'),
			);
	}
}

use Test::More tests => 2;
use PITA::XML ();

sub dies_like {
	my $code   = shift;
	my $regexp = shift;
	eval { &$code() };
	like( $@, $regexp, $_[0] || 'Code dies like expected' );
}





#####################################################################
# Basic tests

# Create a new object
my $dist = PITA::XML::Guest->new(
	driver => 'Local',
	);
isa_ok( $dist, 'PITA::XML::Guest' );
is( $dist->driver, 'Local', '->driver matches expected' );

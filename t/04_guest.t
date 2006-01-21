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

use Test::More tests => 17;
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
SCOPE: {
	my $dist = PITA::XML::Guest->new(
		driver => 'Local',
		);
	isa_ok( $dist, 'PITA::XML::Guest' );
	is( $dist->driver, 'Local', '->driver matches expected' );
	is( $dist->filename, undef, '->filename returns undef'  );
	is( $dist->md5sum, undef,   '->md5sum returns undef'    );
	is_deeply( $dist->config, {}, '->config returns an empty hash' );
}

# Create another one with more details
my @params = (
	driver   => 'ImageTest',
	filename => 'guest.img',
	md5sum   => 'ABCDEFABCD0123456789ABCDEFABCD01',
	memory   => 256,
	snapshot => 1,
	);
SCOPE: {
	my $dist = PITA::XML::Guest->new( @params );
	isa_ok( $dist, 'PITA::XML::Guest' );
	is( $dist->driver,  'ImageTest', '->driver matches expected' );
	is( $dist->filename, 'guest.img', '->filename returns undef'  );
	is( $dist->md5sum,   'abcdefabcd0123456789abcdefabcd01',
		'->md5sum returns undef' );
	is_deeply( $dist->config, { memory => 256, snapshot => 1 },
		'->config returns the expected hash' );
}

# Load the same thing from a file
SCOPE: {
	my $file = catfile( 't', 'samples', 'guest.pita' );
	ok( -f $file, 'Sample Guest file exists' );
	my $dist = PITA::XML::Guest->read( $file );
	isa_ok( $dist, 'PITA::XML::Guest' );
	is( $dist->driver,  'ImageTest', '->driver matches expected' );
	is( $dist->filename, 'guest.img', '->filename returns undef'  );
	is( $dist->md5sum,   'abcdefabcd0123456789abcdefabcd01',
		'->md5sum returns undef' );
	is_deeply( $dist->config, { memory => 256, snapshot => 1 },
		'->config returns the expected hash' );
	is_deeply( $dist, PITA::XML::Guest->new( @params ),
		'File-loaded version exactly matches manually-created one' );
}

exit(0);

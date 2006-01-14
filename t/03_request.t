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

use Test::More tests => 31;
use PITA::XML ();

my $md5sum = '0123456789ABCDEF0123456789ABCDEF';

sub dies_like {
	my $code   = shift;
	my $regexp = shift;
	eval { &$code() };
	like( $@, $regexp, $_[0] || 'Code dies like expected' );
}

sub new_dies_like {
	my $params = shift;
	my $regexp = shift;
	eval { PITA::XML::Request->new(
		scheme    => 'perl5',
		distname  => 'Task-CVSMonitor',
		filename  => 'Task-CVSMonitor-0.006003.tar.gz',
		md5sum    => '5cf0529234bac9935fc74f9579cc5be8',
		authority => 'cpan',
		authpath  => '/authors/id/A/AD/ADAMK/Task-CVSMonitor-0.006003.tar.gz',
		%$params,
		);
	};
	like( $@, $regexp, $_[0] || 'Constructor fails like expected' );			
}





#####################################################################
# Basic tests

# Create a new object
my $dist = PITA::XML::Request->new(
	scheme   => 'perl5',
	distname => 'Foo-Bar',
	filename => 'Foo-Bar-0.01.tar.gz',
	md5sum   => $md5sum,
	);
isa_ok( $dist, 'PITA::XML::Request' );
is( $dist->distname, 'Foo-Bar', '->distname matches expected'             );
is( $dist->filename, 'Foo-Bar-0.01.tar.gz', '->filename matches expected' );
is( $dist->md5sum,    lc($md5sum), '->md5sum is normalised as expected'   );
is( $dist->authority, '', '->authority returns "" as expected'            );
is( $dist->authpath,  '', '->authpath returns "" as expected'             );

# Create a new CPAN dist
my $cpan = PITA::XML::Request->new(
	scheme    => 'perl5',
	distname  => 'Task-CVSMonitor',
	filename  => 'Task-CVSMonitor-0.006003.tar.gz',
	md5sum    => '5cf0529234bac9935fc74f9579cc5be8',
	authority => 'cpan',
	authpath  => '/authors/id/A/AD/ADAMK/Task-CVSMonitor-0.006003.tar.gz',
	);
isa_ok( $cpan, 'PITA::XML::Request' );
is( $cpan->distname, 'Task-CVSMonitor',
	'->distname matches expected' );
is( $cpan->filename, 'Task-CVSMonitor-0.006003.tar.gz',
	'->filename matches expected' );
is( $cpan->md5sum, '5cf0529234bac9935fc74f9579cc5be8',
	'->md5sum matches expected' );
is( $cpan->authority, 'cpan',
	'->authority returns as expected' );
is( $cpan->authpath, '/authors/id/A/AD/ADAMK/Task-CVSMonitor-0.006003.tar.gz',
	'->authpath returns as expected' );

# Check the case where there is no authority
my $noauth = PITA::XML::Request->new(
	scheme    => 'perl5',
	distname  => 'Task-CVSMonitor',
	filename  => 'Task-CVSMonitor-0.006003.tar.gz',
	md5sum    => '5cf0529234bac9935fc74f9579cc5be8',
	);
isa_ok( $noauth, 'PITA::XML::Request' );
is( $noauth->distname, 'Task-CVSMonitor',
	'->distname matches expected' );
is( $noauth->filename, 'Task-CVSMonitor-0.006003.tar.gz',
	'->filename matches expected' );
is( $noauth->md5sum, '5cf0529234bac9935fc74f9579cc5be8',
	'->md5sum matches expected' );
is( $noauth->authority, '',
	'->authority returns as expected' );
is( $noauth->authpath, '',
	'->authpath returns as expected'  );





#####################################################################
# Check for specific errors

# Missing scheme
new_dies_like(
	{ scheme => '' }, 
	qr/Missing, invalid or unsupported scheme/,
	'->new(missing scheme) dies like expected',
);

# Bad scheme
new_dies_like(
	{ scheme => '' },
	qr/Missing, invalid or unsupported scheme/,
	'->new(bad scheme) dies like expected',
);

# X-scheme is ok
isa_ok( PITA::XML::Request->new(
	scheme    => 'x_foo',
	distname  => 'Task-CVSMonitor',
	filename  => 'Task-CVSMonitor-0.006003.tar.gz',
	md5sum    => '5cf0529234bac9935fc74f9579cc5be8',
	authority => 'cpan',
	authpath  => '/authors/id/A/AD/ADAMK/Task-CVSMonitor-0.006003.tar.gz',
	), 'PITA::XML::Request' );

# Missing distname
new_dies_like(
	{ distname => '' },
	qr/Missing or invalid distname/,
	'->new(missing distname) dies like expected',
);

# bad distname
new_dies_like(
	{ distname => 'a bad distname' },
	qr/Missing or invalid distname/,
	'->new(bad distname) dies like expected',
);

# Missing filename
new_dies_like(
	{ filename => '' },
	qr/Missing or invalid filename/,
	'->new(missing filename) dies like expected',
);

# Bad filename
new_dies_like(
	{ filename => \'' },
	qr/Missing or invalid filename/,
	'->new(bad filename) dies like expected',
);

# Missing MD5
new_dies_like(
	{ md5sum => '' },
	qr/Missing or invalid md5sum/,
	'->new(missing md5sum) dies like expected',
);

# Bad MD5
new_dies_like(
	{ md5sum => '123456789012345678901ab' }, # 33 legal chars (not 32)
	qr/Missing or invalid md5sum/,
	'->new(bad md5sum) dies like expected',
);

# Missing authority
new_dies_like(
	{ authority => '' },
	qr/No authority provided with authpath/,
	'->new(missing authority) dies like expected',
);

# Bad authority
new_dies_like(
	{ authority => \"" },
	qr/Invalid authority/,
	'->new(bad authority) dies like expected',
);

# Missing authpath
new_dies_like(
	{ authpath => '' },
	qr/No authpath provided with authority/,
	'->new(missing authpath) dies like expected',
);

# Bad authpath
new_dies_like(
	{ authpath => \"" },
	qr/Invalid authpath/,
	'->new(bad authpath) dies like expected',
);

exit(0);

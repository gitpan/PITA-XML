package PITA::XML::Guest;

=pod

=head1 NAME

PITA::XML::Guest - A testing environment, typically a system image

=head1 SYNOPSIS

  # A simple guest using the local Perl
  # (mostly used for test purposes)
  my $dist = PITA::XML::Guest->new(
  	driver => 'Local',
	params => {},
  	);

=head1 DESCRIPTION

C<PITA::XML::Guest> is an object for holding information about
a testing guest environment. A PITA Guest is a container with specific
operating system and hardware that contains one or more testing contexts,
represented in L<PITA::XML> by L<PITA::XML::Platform> objects.

=head1 METHODS

=cut

use strict;
use base 'PITA::XML::File';
use Carp         ();
use Params::Util '_IDENTIFIER',
                 '_INSTANCE',
                 '_STRING',
                 '_HASH0',
                 '_SET0';

use vars qw{$VERSION};
BEGIN {
	$VERSION = '0.13';
}

sub xml_entity { 'guest' }





#####################################################################
# Constructor and Accessors

my %ALLOWED = (
	driver   => 1,
	filename => 1,
	md5sum   => 1,
	config   => 1,
	);

sub new {
	my $class  = shift;

	# Create the object
	my $self = bless { @_ }, $class;

	# Move the non-core options into the config hash
	unless ( _HASH0($self->{config}) ) {
		$self->{config} = {};
	}
	foreach my $k ( sort keys %$self ) {
		next if $ALLOWED{$k};
		$self->{config}->{$k} = delete $self->{$k};
	}

	# Check the object
	$self->_init;

	$self;
}

# ugh... ugly duplication, but will do for now
sub read {
	my $class = shift;
	my $fh    = PITA::XML->_FH(shift);

	### NOTE: DISABLED TILL WE FINALIZE THE SCHEMA
	# Validate the document and reset the handle
	# $class->validate( $fh );
	# $fh->seek( 0, 0 ) or Carp::croak(
	#	'Failed to reset file after validation (seek to 0)'
	#	);

	# Build the object from the file and validate
	my $self = bless { config => {} }, $class;
	my $parser = XML::SAX::ParserFactory->parser(
		Handler => PITA::XML::SAXParser->new($self),
		);
        $parser->parse_file($fh);

	$self;
}

# Format-check the parameters
sub _init {
	my $self = shift;

	# Requires a driver
	unless ( _IDENTIFIER($self->driver) ) {
		Carp::croak('Missing or invalid driver');
	}

	# Optional image filename
	if ( defined $self->filename ) {
		# Check the filepath
		unless ( _STRING($self->filename) ) {
			Carp::croak('Missing or invalid filename');
		}

		# md5sum is compulsory if the filename is given
		if ( $self->{md5sum} ) {
			$self->{md5sum} = PITA::XML->_MD5SUM($self->{md5sum});
		}
		unless ( PITA::XML->_MD5SUM($self->md5sum) ) {
			Carp::croak('Missing or invalid md5sum');
		}
	} else {
		delete $self->{md5sum};
	}

	# Check the configuration hash
	unless ( _HASH0($self->config) ) {
		Carp::croak('Invalid, missing, or empty config');
	}

	# Optional platforms
	$self->{platforms} ||= [];
	unless ( _SET0($self->{platforms}, 'PITA::XML::Platform') ) {
		Carp::croak('Invalid platforms');
	}

	$self;
}

sub driver {
	$_[0]->{driver};
}

sub filename {
	$_[0]->{filename};
}

sub md5sum {
	$_[0]->{md5sum};
}

sub config {
	$_[0]->{config};
}

sub add_platform {
	my $self     = shift;
	my $platform = _INSTANCE(shift, 'PITA::XML::Platform')
		or Carp::croak('Did not provide a PITA::XML::Platform object');

	# Add it to the array
	$self->{platforms} ||= [];
	push @{$self->{platforms}}, $platform;

	1;
}

sub platforms {
	@{ $_[0]->{platforms} };
}





#####################################################################
# Main Methods

sub discovered {
	!! $_[0]->platforms;
}

1;

=pod

=head1 SUPPORT

Bugs should be reported via the CPAN bug tracker at

L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=PITA-XML>

For other issues, contact the author.

=head1 AUTHOR

Adam Kennedy E<lt>cpan@ali.asE<gt>, L<http://ali.as/>

=head1 SEE ALSO

L<PITA::XML>

The Perl Image-based Testing Architecture (L<http://ali.as/pita/>)

=head1 COPYRIGHT

Copyright 2005, 2006 Adam Kennedy. All rights reserved.

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut

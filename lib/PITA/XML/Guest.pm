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
                 '_HASH0',
                 '_SET0';

use vars qw{$VERSION};
BEGIN {
	$VERSION = '0.12';
}

sub xml_entity { 'guest' }





#####################################################################
# Constructor and Accessors

sub new {
	my $class  = shift;

	# Create the object
	my $self = bless { @_ }, $class;

	# Check the object
	$self->_init;

	$self;
}

# Format-check the parameters
sub _init {
	my $self = shift;

	# Requires a driver
	unless ( _IDENTIFIER($self->driver) ) {
		Carp::croak('Missing or invalid driver');
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

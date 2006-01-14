package PITA::XML::Request;

=pod

=head1 NAME

PITA::XML::Request - A request for the testing of a software package

=head1 SYNOPSIS

  # Create a request specification
  my $dist = PITA::XML::Request->new(
  	scheme    => 'perl5',
  	distname  => 'PITA-XML',
  
  	# File properties
  	filename  => 'Foo-Bar-0.01.tar.gz',
  	md5sum    => '0123456789ABCDEF0123456789ABCDEF',
 
  	# Optional fields for repository-based requests
  	authority => 'cpan',
  	authpath  => '/id/A/AD/ADAMK/Foo-Bar-0.01.tar.gz',
  	);

=head1 DESCRIPTION

C<PITA::XML::Request> is an object for holding information about
a request for a distribution to be tested. It is created most often
as part of the parsing of a L<PITA::XML> XML file.

It holds the testing scheme, name of the distribition, file information,
and authority information (if the distribution was sourced from a
repository such as CPAN)

=head1 METHODS

=cut

use strict;
use base 'PITA::XML::File';
use Carp         ();
use Config::Tiny ();
use Params::Util '_STRING';

use vars qw{$VERSION};
BEGIN {
	$VERSION = '0.11';
}

sub xml_entity { 'request' }





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

	# Check the scheme
	unless ( PITA::XML->_SCHEME($self->scheme) ) {
		Carp::croak('Missing, invalid or unsupported scheme');
	}

	# Arbitrarily apply the normal standard for distributions
	### Might need to change this down the line
	unless ( PITA::XML->_DISTNAME($self->distname) ) {
		Carp::croak('Missing or invalid distname');
	}

	# Check the filepath
	unless ( _STRING($self->filename) ) {
		Carp::croak('Missing or invalid filename');
	}

	# Normalize and check the md5sum
	if ( $self->{md5sum} ) {
		$self->{md5sum} = PITA::XML->_MD5SUM($self->{md5sum});
	}
	unless ( PITA::XML->_MD5SUM($self->md5sum) ) {
		Carp::croak('Missing or invalid md5sum');
	}

	# Is there an authority
	if ( $self->authority ) {
		# Check the authority
		unless ( _STRING($self->authority) ) {
			Carp::croak('Invalid authority');
		}
	} else {
		$self->{authority} = '';
	}

	# Check the cpanpath
	if ( $self->authpath ) {
		# Check the authpath
		unless ( _STRING($self->authpath) ) {
			Carp::croak('Invalid authpath');
		}
	} else {
		$self->{authpath} = '';
	}

	# Authpath and authority are needed together
	if ( $self->authpath and ! $self->authority ) {
		Carp::croak('No authority provided with authpath');
	}
	# Authpath and authority are needed together
	if ( $self->authority and ! $self->authpath ) {
		Carp::croak('No authpath provided with authority');
	}

	$self;
}

=pod

=head2 scheme

The C<scheme> accessor returns the name of the testing scheme that the
distribution is to be tested under.

In this initial implementation, the following schemes are supported.

=over 4

=item perl5

Perl 5 general testing scheme.

Auto-detect the specific sub-scheme (currently either C<perl5.makefile>
or C<perl5.build>)

=item perl5.make

Traditional Perl 5 testing scheme.

Executes C<perl Makefile.PL>, C<make>, C<make test>,
C<make install>.

=item perl5.build

L<Module::Build> Perl 5 testing scheme.

Executes C<perl Build.PL>, C<Build>, C<Build test>,
C<Build install>.

=item perl6

Perl 6 general testing scheme.

Specifics are yet to be determined.

=back

=cut

sub scheme {
	$_[0]->{scheme};
}

=pod

=head2 distname

The C<distname> accessor returns the name of the request as a string.

Most often, this would be something like 'Foo-Bar' with a primary focus on
the class Foo::Bar.

=cut

sub distname {
	$_[0]->{distname};
}

=pod

=head2 filename

The C<filename> accessor returns ...

=cut

sub filename {
	$_[0]->{filename};
}

=pod

=head2 md5sum

The C<md5sum> accessor returns the MD5 sum for package. This is only used
as a CRC and isn't assumed to be cryptographically secure.

=cut

sub md5sum {
	$_[0]->{md5sum};
}

=pod

=head2 authority

If present, the C<authority> accessor returns the name of the package
authority. For example, CPAN distributions use the authority C<'cpan'>.

=cut

sub authority {
	$_[0]->{authority};
}

=pod

=head2 authpath

When testing distributions , the C<authpath> returns the path for
the Request file within the CPAN.

For non-CPAN distributions, returns false (the null string).

=cut

sub authpath {
	$_[0]->{authpath};
}




#####################################################################
# Coercion Methods

sub __as_Config_Tiny {
	my $self   = shift;
	my $config = Config::Tiny->new;
	$config->{_} = { %$self }; # A little hacky, but simple
	$config;
}

sub __from_Config_Tiny {
	my ($class, $config) = @_;
	my $section = $config->{_} || {};
	$class->new( %$section );
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

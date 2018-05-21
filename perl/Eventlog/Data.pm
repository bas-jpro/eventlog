# Manage Data sources for Eventlogs
#
# JPRO 17/05/2018
#

package Eventlog::Data;
use strict;

sub new {
	my ($class, $type) = @_;

	my $self = bless {
		streams = undef,
	}, $class;

	$self->connect_streams($type);
	
	return $self;
}

sub connect_streams {
	my ($self, $type) = shift;
	return undef unless $type;

	require Eventlog::Data::$type;

	$self->{streams} = Eventlog::Data::$type->new();

	return $self->{streams};
}

sub list_streams {
	my $self = shift;
	return undef unless $self->{streams};

	return $self->{streams}->list();
}

1;
__END__

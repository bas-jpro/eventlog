# Manage Data sources for Eventlogs
#
# JPRO 17/05/2018
#

package Eventlog::Data;
use strict;

use Module::Load;

sub new {
	my ($class, $type) = @_;

	my $self = bless {
		streams => undef,
	}, $class;

	$self->connect_streams($type);
	
	return $self;
}

sub connect_streams {
	my ($self, $type) = @_;
	return undef unless $type;

	my $class = "Eventlog::Data::$type";
	
	load $class;

	$self->{streams} = $class->new();

	return $self->{streams};
}

sub list_streams {
	my $self = shift;
	return undef unless $self->{streams};

	return $self->{streams}->list();
}

sub attach {
	my ($self, $stream) = @_;
	return undef unless $self->{streams};

	return $self->{streams}->attach($stream);
}

sub detach {
	my $self = shift;
	return undef unless $self->{streams};

	return $self->{streams}->detach();
}

sub name {
	my $self = shift;
	return undef unless $self->{stream};

	return $self->{stream}->name();
}

sub vars {
	my $self = shift;
	return undef unless $self->{stream};

	return $self->{stream}->vars();
}

1;
__END__

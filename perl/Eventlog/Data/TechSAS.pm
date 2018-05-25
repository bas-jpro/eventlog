# Manage TechSAS Data for Eventlog
#
# JPRO 17/05/2018
#

package Eventlog::Data::TechSAS;
use strict;

use lib '/packages/techsas/current/lib';
use TechSAS;
	
sub new {
	my $class = shift;

	my $self = bless {
		techsas => TechSAS->new(),
	}, $class;

	return $self;
}

sub name {
	my $self = shift;

	return $self->{techsas}->name();
}

sub vars {
	my $self = shift;

	return $self->{techsas}->vars();
}

sub attach {
	my ($self, $stream) = @_;

	return $self->{techsas}->attach($stream);
}

sub detach {
	my ($self, $stream) = @_;

	return $self->{techsas}->detach($stream);
}

sub list_streams {
	my $self = shift;

	return $self->{techsas}->list_streams();
}


1;
__END__

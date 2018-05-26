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

sub get_vars_pos {
	my ($self, @varnames) = @_;

	return $self->{techsas}->get_vars_pos(@varnames);
}

sub attach {
	my ($self, $stream) = @_;

	return $self->{techsas}->attach($stream);
}

sub detach {
	my ($self, $stream) = @_;

	return $self->{techsas}->detach();
}

sub list_streams {
	my $self = shift;

	return $self->{techsas}->list_streams();
}

sub find_time {
	my ($self, $tstamp) = @_;

	return $self->{techsas}->find_time($tstamp);
}

1;
__END__

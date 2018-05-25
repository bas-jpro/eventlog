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

	print STDERR "Eventlog::Data::TechSAS\n";
	
	return $self;
}

sub name {
	my $self = shift;

	print STDERR "TechSAS::name\n";
	
	return $self->{techsas}->name();
}

sub vars {
	my $self = shift;

	print STDERR "TechSAS::var\n";

	return $self->{techsas}->vars();
}

sub attach {
	my ($self, $stream) = @_;

	print STDERR "TechSAS::attach\n";
}

sub detach {
	my ($self, $stream) = @_;

	print STDERR "TechSAS::detach\n";
}

sub list_streams {
	my $self = shift;

	print STDERR "TechSAS::list_streams\n";
	
	return $self->{techsas}->list_streams();
}


1;
__END__

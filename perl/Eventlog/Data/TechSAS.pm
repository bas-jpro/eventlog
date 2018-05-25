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

	return $self->{techsas}->list_streams();
}


1;
__END__

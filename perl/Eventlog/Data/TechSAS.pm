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

1;
__END__

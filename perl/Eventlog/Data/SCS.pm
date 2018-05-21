# Manage SCS Data for Eventlog
#
# JPRO 17/05/2018
#

package Eventlog::Data::SCS;
use strict;

use lib '/packages/scs/current/lib';
use SCS::Compress;

sub new {
	my $class = shift;

	my $self = bless {
		scs => SCS::Compress->new().
	}, $class;

	return $class;
}

1;
__END__

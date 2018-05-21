# Manage Full_NMEA Data for Eventlog
# Used by CCGS Amundsen
#
# JPRO 21/05/2018
#

package Eventlog::Data::Full_NMEA;
@ISA = qw(Eventlog::Data);
use strict;

use File::Basename;
use IO::File;

my $NMEA_DIR = '/data/Full_NMEA';
my %STREAMS = (
	'AAVOS' => { 
		stream => 'AAVOS', format => 'AVRTE', 
		vars => [ { name => 'date',   units => 'YYMMDD' },
				  { name => 'time',   units => 'HHMMSS' },
				  { name => 'serial', units => '' },
				  { name => 'call',   units => '' },
				  { name => 'ws1',    units => 'knots' },
				  { name => 'wd1',    units => 'deg true' },
				  { name => 'rwd1',   units => 'deg rel' },
				  { name => 'ws2',    units => 'knots' },
				  { name => 'wd2',    units => 'deg true' },
				  { name => 'rwd2',   units => 'deg rel' },
				  { name => 'bp1',    units => 'mbar' },
				  { name => 'bp2',    units => 'mbar' },
				  { name => 'at1',    units => 'deg C' },
				  { name => 'rh1',    units => '%' },
				  { name => 'at2',    units => 'deg C' },
				  { name => 'rh2',    units => '%' },
				  { name => 'sst',    units => 'deg C' },
				  { name => 'wg1',    units => 'knots' },
				  { name => 'wg2',    units => 'knots' },
				  { name => 'comp1',  units => 'deg true' },
				  { name => 'comp2',  units => 'deg true' },
				  { name => 'bv',     units => 'volts' },
			]
	},
	);

sub new {
	my $class = shift;

	my $self = bless {
		path   => $NMEA_DIR,
		stream => undef,
		name   => undef,
		year   => undef,
		leg    => undef,
		nmea   => undef,
	}, $class;

	return $self;
}

sub list_streams {
	my $self = shift;

	return sort keys %STREAMS;
}

sub attach {
	my ($self, $stream) = @_;
	die basename($0) . ": Failed to attach $stream - no stream\n" unless $STREAMS{$stream};

	$self->{name} = $stream;

	# Find oldest file to open
	opendir(ND, $NMEA_DIR);
	my @years = sort grep { /^\d{4}$/ && -d "$NMEA_DIR/$_" } readdir(ND);
	closedir(ND);

	$self->{year} = $years[0];
	die basename($0) . ": Failed to attach $stream - no years\n" unless $self->{year};

	# Open oldest year and file oldesk leg
	opendir(ND, "$NMEA_DIR/$self->{year}");
	my @legs = sort grep { /^\d{4}_LEG_\d+$/ && -d "$NMEA_DIR/$self->{year}/$_" } readdir(ND);
	closedir(ND);

	$self->{leg} = $legs[0];
	die basename($0) . ": Failed to attach $stream - no leg\n" unless $self->{leg};

	# Find oldest nmea file
	opendir(ND, "$NMEA_DIR/$self->{year}/$self->{leg}");
	my @nmeas = sort grep { /^nmea_\d{10}.log$/ } readdir(ND);
	closedir(ND);

	$self->{nmea} = $nmeas[0];
	die basename($0) . ": Failed to attached $stream - no file\n" unless $self->{nmea};

	$self->{stream} = new IO::File "$NMEA_DIR/$self->{year}/$self->{leg}/$self->{nmea}", O_RDONLY ;

	die basename($0). ": Failed to attach $stream\n" unless $self->{stream};

	$self->{stream}->blocking(0);

	print STDERR "Opened $self->{nmea}, in $self->{leg} of $self->{year}\n";
}


sub detach {
	my $self = shift;
	return unless $self->{stream};

	$self->{stream} = undef;
}

sub name {
	my $self = shift;

	return $self->{name};
}

sub vars {
	my $self = shift;
	return undef unless $self->{stream};

	return $STREAMS{$self->{stream}}->{vars};
}

# Find record at time tstamp (in unix seconds)
sub find_time {
	my ($self, $tstamp) = @_;
}

1;
__END__

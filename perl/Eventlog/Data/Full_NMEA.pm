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
use Time::Local;

my $NMEA_DIR = '/data/Full_NMEA';
my %STREAMS = (
	'AAVOS' => { 
		stream => 'AAVOS', format => '$AVRTE', 
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
			],
		convert_time => \&_aavos_time,
	},
	);

sub new {
	my $class = shift;

	my $self = bless {
		path       => $NMEA_DIR,
		stream     => undef,
		name       => undef,
		year       => undef,
		leg        => undef,
		nmea       => undef,
		file_start => undef,
		record     => {
			timestamp => undef,
			vals      => undef,
		},
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

	$self->_find_oldest_file();
	die basename($0) . ": Failed to attached $stream - no file\n" unless $self->{nmea};

	$self->_load_file();
}

# Load the file given by $self->{nmea}
sub _load_file {
	my $self = shift;
	return unless $self->{nmea};

	delete $self->{stream};
	
	$self->{stream} = new IO::File "$NMEA_DIR/$self->{year}/$self->{leg}/$self->{nmea}", O_RDONLY ;
	die basename($0). ": Failed to attach $self->{name}\n" unless $self->{stream};
	
	$self->{file_start} = $self->_convert_nmea_time();
	$self->{stream}->blocking(0);
	
#	print STDERR "Opened $self->{nmea}, in $self->{leg} of $self->{year}, start time: $self->{file_start}\n";	
}

# Convert NMEA file name timestamp to unix seconds
sub _convert_nmea_time {
	my $self = shift;
	return undef unless $self->{nmea};

	my ($year, $month, $day, $hour) = undef;
	if ($self->{nmea} =~ /^nmea_(\d{4})(\d{2})(\d{2})(\d{2})/) {
		($year, $month, $day, $hour) = ($1, $2, $3, $4);
	} else {
		return undef;
	}

	return timegm(0, 0, $hour, $day, $month-1, $year - 1900);
}

sub _find_oldest_file {
	my $self = shift;
	
	# Get list of years
	opendir(ND, $NMEA_DIR);
	my @years = sort grep { /^\d{4}$/ && -d "$NMEA_DIR/$_" } readdir(ND);
	closedir(ND);
	die basename($0) . ": Failed to attach $self->{name} - no years\n" unless scalar(@years);

	# Now go through looking for oldest nmea file and return once found
	foreach my $y (@years) {
		$self->{year} = $y;
		
		# Open oldest year and file oldest leg
		opendir(ND, "$NMEA_DIR/$self->{year}");
		my @legs = sort grep { /^\d{4}_LEG_\d+$/ && -d "$NMEA_DIR/$self->{year}/$_" } readdir(ND);
		closedir(ND);
		
		next unless scalar(@legs);

		foreach my $l (@legs) {
			$self->{leg} = $l;
			
			# Find oldest nmea file
			opendir(ND, "$NMEA_DIR/$self->{year}/$self->{leg}");
			my @nmeas = sort grep { /^nmea_\d{10}.log$/ } readdir(ND);
			closedir(ND);
			
			next unless scalar(@nmeas);

			# Found a nmea file
			$self->{nmea} = $nmeas[0];
			return;
		}
	}

	# Failed to find anything
	$self->{nmea} = $self->{leg} = $self->{year} = undef;
}

# Find a file that contains a given timestamp
sub _find_file {
	my ($self, $tstamp) = @_;

	my ($year, $month, $day, $hour) = (gmtime($tstamp))[5, 4, 3, 2];
	$month++;
	$year += 1900;
	
	# Build filename
	my $fname = sprintf("nmea_%04d%02d%02d%02d.log", $year, $month, $day, $hour);

#	print STDERR "Looking for [$fname]\n";

	$self->{year} = $year;
	$self->{leg} = $self->{nmea} = undef;
	
	# Get list of legs
	opendir(ND, "$NMEA_DIR/$self->{year}");
	my @legs = sort grep { /^\d{4}_LEG_\d+$/ && -d "$NMEA_DIR/$self->{year}/$_" } readdir(ND);
	closedir(ND);

	# Search for file
	foreach my $l (@legs) {
		if (-e "$NMEA_DIR/$self->{year}/$l/$fname") {
			$self->{leg} = $l;
			$self->{nmea} = $fname;
			return;
		}
	}
}

sub detach {
	my $self = shift;
	return unless $self->{stream};

	$self->{stream} = undef;
	$self->{name}   = undef;
}

sub name {
	my $self = shift;

	return $self->{name};
}

sub vars {
	my $self = shift;
	return undef unless $self->{stream};

	return $STREAMS{$self->{name}}->{vars};
}

# Find record at time tstamp (in unix seconds)
sub find_time {
	my ($self, $tstamp) = @_;

#	print STDERR "Searching for time: [$tstamp]\n";
	
	# First find oldest file to check if time is before start of data
	$self->_find_oldest_file();
	$self->_load_file();
	
	if ($tstamp <= $self->{file_start}) {
		# At start of file
	#	print STDERR "Before start of first file, returning\n";
		return;
	}

	# Find out if we need to move file
	if ($tstamp >= $self->{file_start} + 3600) {
#		print STDERR "New file needed\n";
		$self->_find_file($tstamp);

		# return if we didn't find a time
		return unless $self->{nmea};
		
		$self->_load_file();
	}

	# Time is current this file
#	print STDERR "Time is in current file\n";

	# Linear search for time
	my $rec = $self->next_record();
	my $prev_rec = undef;
	
	while ($rec && ($rec->{timestamp} < $tstamp)) {
		$prev_rec = $rec;
		$rec = $self->next_record();
	}

	# Return exact time or closest time
	if ($rec->{timestamp} == $tstamp) {
		return $rec;
	}

	if (abs($rec->{timestamp} - $tstamp) < (abs($prev_rec->{timestamp} - $tstamp))) {
		return $rec;
	}
	
	return $prev_rec;
}

sub next_record {
	my $self = shift;
	return undef unless $self->{stream};
	
	# Read file until a match with format string is found
	my $found_string = 0;

	my $fh = $self->{stream};
	my $line = <$fh>;
	my @fs = undef;
	
	while (!$found_string && $line) {
		if ($line !~ /^\s*$/) {
			chomp($line);
			
			@fs = split(',', $line);
			
			if ($fs[0] eq $STREAMS{$self->{name}}->{format}) {
				$found_string = 1;
				next;
			}
		}

		$line = <$fh>;
	}

	return undef unless $found_string;
	
	# Remove format string
	shift @fs;
	$self->{record}->{vals} = \@fs;
	$STREAMS{$self->{name}}->{convert_time}->($self);
	
	return $self->{record};
}

# Convert AAVOS time into a unix timestamp
sub _aavos_time {
	my $self = shift;

	# date & time are fields 0 & 1
	my ($year, $month, $day, $hour, $min, $sec) = undef;

	if ($self->{record}->{vals}->[0] =~ /^(\d{2})(\d{2})(\d{2})$/) {
		($year, $month, $day) = ($1, $2, $3);
	} else {
		die basename($0) . ": invalid date string [" . $self->{record}->{vals}->[0] . "]\n";
	}

	if ($self->{record}->{vals}->[1] =~ /^(\d{2})(\d{2})(\d{2})$/) {
		($hour, $min, $sec) = ($1, $2, $3);
	} else {
		die basename($0) . ": invalid time string [" . $self->{record}->{vals}->[1] . "]\n";
	}

	#print STDERR "Converting $year, $month, $day, $hour, $min, $sec\n";
	# Let timegm deal with Y2K issues - could work it out from self->{file_start}
	$self->{record}->{timestamp} = timegm($sec, $min, $hour, $day, $month-1, $year);
}

1;
__END__

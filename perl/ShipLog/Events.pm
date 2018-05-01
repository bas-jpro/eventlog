# ShipLog Events main class
#
# $Id$
#

package ShipLog::Events;
use strict;

my $DEFAULT_GMT_OFFSET = -3;

sub new {
	my ($class, $db) = @_;

	my $self = bless {
		db => $db,
	}, $class;

	return $self;
}

# Return GMT Offset currently in use
# Assumes the server always runs GMT
sub GMT_Offset {
	my $self = shift;

	$self->{db}->prepare("SELECT description FROM shiplog WHERE type='tz_change' AND gmt_time < now() ORDER BY gmt_time DESC LIMIT 1");
	$self->{db}->execute();

	if ($self->{db}->num_rows() != 1) {
		return $DEFAULT_GMT_OFFSET;
	}

	$self->{db}->next_record();

	if ($self->{db}->f(0) =~ /GMT ([-+\d]+)$/) {
		return $1;
	}

	return $DEFAULT_GMT_OFFSET;
}

sub Add {
	my ($self, $ei) = @_;
	return unless defined($ei);

	$ei->{gmt_time} = undef;
	
	# Check for time zone change
	if ($ei->{type} eq 'tz_change') {
		($ei->{description}, $ei->{gmt_time}) = $self->_setup_tz($ei->{start_time}, $ei->{gmt_offset});
	}

	$self->{db}->prepare("INSERT INTO shiplog VALUES(null, ?, ?, ?, ?, ?)");
	$self->{db}->execute($ei->{type}, $ei->{start_time}, $ei->{description}, $ei->{gmt_time}, $ei->{event_type});
}

sub _setup_tz {
	my ($self, $start_time, $new_offset) = @_;

	# Add in the GMT time to enable automatic calculation of GMT Offset
	my $offset = $self->GMT_Offset();
		
	$self->{db}->prepare("SELECT CONVERT_TZ(?, ?, ?)");
	$self->{db}->execute($start_time, sprintf("%+03d:00", $offset), '+00:00');
	$self->{db}->next_record();
	
	my $gmt_time = $self->{db}->f(0);
	
	return ("Time change to GMT $new_offset", $gmt_time);
}

sub Modify {
	my ($self, $ei) = @_;
	return unless defined($ei);
	return unless defined($ei->{id});

	# Check for time zone change
	if ($ei->{type} eq 'tz_change') {
		($ei->{description}, $ei->{gmt_time}) = $self->_setup_tz($ei->{start_time}, $ei->{gmt_offset});
	}
	
	$self->{db}->prepare("UPDATE shiplog SET type=?, start_time=?, description=?, gmt_time=?, event_type=? WHERE id=?");
	$self->{db}->execute($ei->{type}, $ei->{start_time}, $ei->{description}, $ei->{gmt_time}, $ei->{event_type}, $ei->{id});
}

sub Delete {
	my ($self, @ds) = @_;

	$self->{db}->prepare("DELETE FROM shiplog WHERE id=?");
	foreach my $d (@ds) {
		$self->{db}->execute($d);
	}
}

sub List {
	my ($self, $si) = @_;

	my @vals = ();
	my $query = "SELECT id, type, "; 

	if (defined($si->{timefmt})) {
		$query .= "DATE_FORMAT(start_time, ?), ";
		push(@vals, $si->{timefmt});
	} else { 
		$query .= "start_time, ";
	}
	
	$query .= "description, gmt_time, event_type FROM shiplog";

	my $glue = ' WHERE';
	if (defined($si->{start})) {
		$query .= "$glue start_time >= ?";
		push(@vals, $si->{start});

		$glue = ' AND';
	}
	
	if (defined($si->{end})) {
		$query .= $glue . " start_time <= ?";
		push(@vals, $si->{end});

		$glue = ' AND';
	}

	if (defined($si->{type})) {
		if (ref($si->{type}) eq 'ARRAY') {
			$query .= $glue . " type IN (" . join(",", map { '?' } @{ $si->{type} }) . ")";
			push(@vals, @{ $si->{type} });
		} else {
			$query .= $glue . " type = ?";
			push(@vals, $si->{type});
		}
	}

	if (defined($si->{id})) {
		$query .= $glue . " id = ?";
		push(@vals, $si->{id});
	}
	
	$query .= ' ORDER BY start_time ASC, id ASC';
	
	if (defined($si->{limit})) {
		$query .= ' LIMIT ?';
		push(@vals, $si->{limit})
	}
	
#	print STDERR "Query [$query]\n";
	$self->{db}->prepare($query);
	$self->{db}->execute(@vals);

	my @ls = ();
	while ($self->{db}->next_record()) {
		push(@ls, $self->_info());
	}
	
	return \@ls;
}

sub _info {
	my $self = shift;

	return {
		id          => $self->{db}->f(0),
		type        => $self->{db}->f(1),
		start_time  => $self->{db}->f(2),
		description => $self->{db}->f(3),
		gmt_time    => $self->{db}->f(4),
		event_type  => $self->{db}->f(5),
	};
}

1;
__END__

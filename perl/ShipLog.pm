# Apache::Controller Interface for JCR ShipLog
# 
# Initial request from ETO (Comms)
#
# $Id$
#

package ShipLog;
@ISA = qw(FormSetup);
use strict;

use Apache::Controller::DB;
use POSIX qw(strftime);
use ShipLog::Events;
use Data::Dumper;

my $SECS_PER_DAY  = 86400;
my $SECS_PER_HOUR = 3600;

sub new {
	my ($class, $config) = @_;

	my $self = bless {
		config     => $config,
		gmt_offset => undef,
		user       => $config->{analyst},
		state      => $config->{session},
		events     => ShipLog::Events->new( Apache::Controller::DB->new($config->{locals}->{db}->{name}, $config->{locals}->{db})),
	}, $class;
	
	return $self;
}

sub footer_setup { }
sub error_setup  { }

sub header_setup { 
	my $self = shift;

	$self->{gmt_offset} = $self->{events}->GMT_Offset();
	
	return {
		refresh     => ($self->{config}->{op} eq 'index') ? 'refresh' : '',
		gmt_offset  => $self->{gmt_offset},
		update_time => strftime("%H:%M %d/%m/%Y", gmtime(time() + ($self->{gmt_offset} * $SECS_PER_HOUR))),
	};
}

# Convert a unix time to a datetime
sub _unix_to_datetime {
	my $unix = shift;

	return strftime("%Y-%m-%d %H:%M:%S", gmtime($unix));
}

sub index_setup {
	my $self = shift;

	# Need to correct for ship's timezone
	my $gmt        = time();
	my $today      = $gmt + ($self->{gmt_offset} * $SECS_PER_HOUR);
	my $tomorrow   = $today + $SECS_PER_DAY;
		
	my $vars = {
		today_date    => strftime("%A %d %b %Y", gmtime($today)),
		tomorrow_date => strftime("%A %d %b %Y", gmtime($tomorrow)),
		future        => 'Upcoming',
	};

	my $today_start = $today - ($today % $SECS_PER_DAY);
	my $today_end   = $today_start + $SECS_PER_DAY - 1;

	$vars->{today_events}    = $self->{events}->List({ start   => _unix_to_datetime($today_start),
													   end     => _unix_to_datetime($today_end),
													   timefmt => '%H:%i',
													   type    => [ 'event', 'tz_change' ] });
	$vars->{tomorrow_events} = $self->{events}->List({ start   => _unix_to_datetime($today_start + $SECS_PER_DAY),
													   end     => _unix_to_datetime($today_end   + $SECS_PER_DAY),
													   timefmt => '%H:%i',
													   type    => [ 'event', 'tz_change' ] });
	$vars->{upcoming_events} = $self->{events}->List({ start   => _unix_to_datetime($today_start + 2 * $SECS_PER_DAY), 
													   timefmt => '%d/%m', 
													   limit   => '6',
													   type    => [ 'event', 'tz_change' ] });
	$vars->{general_remarks} = $self->{events}->List({ type    => 'general' });
	
	return $vars;
}

sub edit_setup {
	my ($self, $param_table, $edit_id, $dup) = @_;

	my $vars = undef;
	my $defaults = {};
	my $edit_tz = 0;
	my $edit_general = 0;
	
	# Setup fields
	if (defined($edit_id)) {
		my $es = $self->{events}->List({ id => $edit_id });
		my $event = $es->[0];

		$defaults->{type} = $event->{type};
		
		if ($event->{type} eq 'tz_change') {
			$edit_tz = 1;
			$defaults->{start_time_tz} = $event->{start_time};

			if ($event->{description} =~ /GMT ([+-\d]+)$/) {
				$defaults->{gmt_offset} = $1;
			}

			delete $self->{state}->{add_tz};
		} elsif ($event->{type} eq 'general') {
			$edit_general = 1;

			$defaults->{description_general} = $event->{description};
                      
			delete $self->{state}->{add_general};
		} else {
			$defaults = $event;

			delete $self->{state}->{add};
		}
	}

	if (defined($self->{state}->{add_tz}) || $edit_tz) {
		$vars = $self->form_setup('add_tz', $param_table, $defaults);
	} elsif (defined($self->{state}->{add_general}) || $edit_general) {
		$vars = $self->form_setup('add_general', $param_table, $defaults);
	} else {
		$vars = $self->form_setup('add', $param_table, $defaults);
	}

	# Setup button text / ID if modifying or adding
	$vars->{edit_tz}      = 'Add';
	$vars->{edit}         = 'Add';
	$vars->{edit_general} = 'Add';
	
	if (defined($edit_id)) {
		if ($edit_tz) {
			if (!$dup) {
				$vars->{id_tz} = $edit_id;
				$vars->{edit_tz} = 'Modify';
			}
			$vars->{tz_active_tab} = 'active';
		} elsif ($edit_general) {
			if (!$dup) {
				$vars->{id_general} = $edit_id;
				$vars->{edit_general} = 'Modify';
			}
			$vars->{general_active_tab} = 'active';
		} else {
			if (!$dup) {
				$vars->{id} = $edit_id;
				$vars->{edit} = 'Modify';
			} else {
				$vars->{id} = undef;
			}
			$vars->{event_active_tab} = 'active';
		}
	} else {
		$vars->{event_active_tab} = 'active';
	}

	$self->form_error_setup($param_table, $vars);
	
	my $today       = time() + ($self->{gmt_offset} * 3600);
	my $today_start = $today - ($today % 86400);
 
	# Change tz_change range to HH:MM format
	foreach my $v (@{ $vars->{gmt_offset} }) {
		$v->{option} = sprintf("%+03d:00", $v->{value});
	}

	$vars->{events} = $self->{events}->List({ start   => _unix_to_datetime($today_start),
											  timefmt => '%d/%m/%Y %H:%i' });

	$vars->{general} = $self->{events}->List({ type => 'general' });

	return $vars;
}

sub del_events {
	my ($self, $param_table) = @_;

	# Look for events that are ticked to delete
	my @ds = ();

	foreach my $k (keys %$param_table) {
		if ($k =~ /^event_(\d+)$/) {
			push(@ds, $1);
		}
	}

	$self->{events}->Delete(@ds);
	
	return 0;
}

sub add_event {
	my ($self, $param_table) = @_;

	$self->save_form_state($param_table, 'add');
	$self->form_clean_search('add');
	return -1 if $self->form_param_check('add');

	if (defined($self->{state}->{add}->{id})) {
		$self->{events}->Modify($self->{state}->{add});
	} else {
		$self->{events}->Add($self->{state}->{add});
	}
	
	delete $self->{state}->{add};
	return 0;
}

sub add_general {
	my ($self, $param_table) = @_;
	
	$self->save_form_state($param_table, 'add_general');
	$self->form_clean_search('add_general');
	return -1 if $self->form_param_check('add_general');

	$self->{state}->{add_general}->{description} = $self->{state}->{add_general}->{description_general};
	
	if (defined($self->{state}->{add_general}->{id})) {
		$self->{events}->Modify($self->{state}->{add_general});
	} else {
		$self->{events}->Add($self->{state}->{add_general});
	}
	
	delete $self->{state}->{add};
	return 0;	
}

sub add_tz_change {
	my ($self, $param_table) = @_;

	$self->save_form_state($param_table, 'add_tz');
	$self->form_clean_search('add_tz');
	return -1 if $self->form_param_check('add_tz');

	$self->{state}->{add_tz}->{start_time} = $self->{state}->{add_tz}->{start_time_tz};

	if (defined($self->{state}->{add_tz}->{id})) {
		$self->{events}->Modify($self->{state}->{add_tz});
	} else {
		$self->{events}->Add($self->{state}->{add_tz});
	}
	
	delete $self->{state}->{add_tz};
	return 0;
}

1;
__END__



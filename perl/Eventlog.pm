# Apache::Controller interface for JCR Eventlogs
#
# v4.0 JPR 11/12/2003 Initial Release
# v4.1 JPR 26/12/2004 Science Log added
# v4.2 JPR 27/12/2004 Day/Night Mode added
# v4.3 JPR 17/11/2005 Added duplicate ability to new_event
# v5.0 JPR 26/01/2006 Modified for Apache::Controller v3
# v5.1 JPR 04/02/2006 Added xfer_noonpos to transfer to noonpos
# v5.2 JPR 09/02/2006 Added info_rec
# v5.3 JPR 30/10/2006 Modified to use get_vars_pos instead of get_re_var
#                     to avoing ea600 depth problem
# v5.4 JPR 16/04/2007 Modified to show deg/min for bridgelog
#

package Eventlog;
@ISA = qw(FormSetup);
use strict;

use Eventlog::Log;
use Noonpos::Position;
use Apache::Controller::DB;
use Eventlog::Data;

use Storable qw(dclone);
use POSIX qw(strftime);
use Time::Local;
use Module::Load;

use Data::Dumper;

# Stream name for Built In Stream
my $BUILTIN    = 'Built In';

my $GPS_STREAM = 'POS-MV-gga';
my $GPS_LAT = 'latitude';
my $GPS_LON = 'longitude';

# Eventlog Default Type
my $DEF_TYPE = 'Full_NMEA';

# Dummy functions to prevent errors
sub header_setup             { }
sub footer_setup             { }
sub index_setup              { }
sub error_setup              { }
sub sidebar_setup            { }
sub log_frames_setup         { }
sub log_buttons_setup        { }
sub list_frames_setup        { }
sub sciencelog_frames_setup  { }
sub sciencelog_buttons_setup { }

sub new {
	my ($class, $config) = @_;

	my $data_type = $config->{locals}->{data_logging}->{type} || $DEF_TYPE;
	my $data_class = "Eventlog::Data::$data_type";
	load $data_class;

	my $eventlog = bless {
		config  => $config,
		db      => Apache::Controller::DB->new($config->{locals}->{db}->{name}, $config->{locals}->{db}),
		user    => $config->{analyst},
		state   => $config->{session},
		data    => $data_class->new(),
		gps     => $config->{locals}->{data_logging}->{gps} || $GPS_STREAM,
		gps_lat => $config->{locals}->{data_logging}->{lat} || $GPS_LAT,
		gps_lon => $config->{locals}->{data_logging}->{lon} || $GPS_LON,
	}, $class;
	
	$eventlog->{log} = Eventlog::Log->new($eventlog->{db});

	return $eventlog;
}

sub day_colors_setup {
	my ($eventlog, $param_table) = @_;

	$eventlog->{state}->{_CSS} = 'eventlog.css';

	return { };
}

sub night_colors_setup {
	my ($eventlog, $param_table) = @_;

	$eventlog->{state}->{_CSS} = 'eventlog-night.css';

	return { };
}

sub view_logs {
	my ($eventlog, $type) = @_;

	my %vars = ();

	$vars{logs} = $eventlog->{log}->list($type);

	foreach (@{ $vars{logs} }) {
		$_->{timestamp} = $eventlog->{log}->last_record_time($_->{lognum}, $type);
	}

	$vars{num_logs} = scalar(@{ $vars{logs} });

	return \%vars;
}

sub view_logs_setup {
	my $eventlog = shift;

	# Get eventlogs
	my $vars = $eventlog->view_logs('event');
	
	# Add in sciencelogs
	my $science = $eventlog->{log}->list('science');
	my $slog_num = scalar(@{ $science });
	my $slog = 0;

	my %sciencelogs_seen = ();

	my @group = ();
	my @cruises = ();

	my ($old_sciencelog, $old_title) = (0, "");

	foreach my $l (@{ $vars->{logs} }) {
		if ($l->{sciencelog} != $old_sciencelog) {
			# We're about to switch sciencelogs, are there any we have missed as they have no eventlogs associated ?
			# FIXME: Fill in sciencelogs here

			if (scalar(@group)) {
				push(@cruises, { title => $old_title, sciencelog => $old_sciencelog, logs => dclone(\@group) });

				@group = ();
			}

			$old_sciencelog = $l->{sciencelog};
			$old_title = $l->{sciencelog_title};

			push(@group, $l);
		} else {
			push(@group, $l);
		}
	}

	if (scalar(@group)) {
		push(@cruises, { title => $old_title, sciencelog => $old_sciencelog, logs => dclone(\@group) });
	}

	delete $vars->{logs};
	$vars->{cruises} = \@cruises;

#	print STDERR Dumper($vars), "\n";

	return $vars;
}

sub view_science_logs_setup {
	my $eventlog = shift;

	return $eventlog->view_logs('science');
}

sub new_eventlog {
	my ($eventlog, $param_table) = @_;

	if (!$param_table->{name}) {
		my @errs = ();
		push(@errs, "Name is a mandatory field");

		return \@errs;
	}

	$eventlog->{state}->{name} = $param_table->{name};
	$eventlog->{state}->{cols}->{num_cols} = 1;

	return 0;
}

# Generate option/value/default for streams
sub setup_streams {
	my ($default, $scs_streams) = @_;

	foreach my $stream (@$scs_streams) {
		foreach my $var (@{ $stream->{vars} }) {
			my $selected = '';

			$selected = 'SELECTED' if $default eq join(":", $stream->{stream}, $var->{name});

			$var->{selected} = $selected;
		}
	}
}

sub get_streams { 
	my $eventlog = shift;

	my @streams = $eventlog->{data}->list_streams();
	my @data_streams = ();

	print STDERR "Found " . scalar(@streams) . " streams\n";
	foreach (@streams) {
		$eventlog->{data}->attach($_);

		print STDERR "Stream [$_]\n";
		push(@data_streams, { stream => $eventlog->{data}->name(), vars => $eventlog->{data}->vars() });

		$eventlog->{data}->detach();
	}

	my @ds = sort { $a->{stream} cmp $b->{stream} } @data_streams;

	return \@ds;
}

sub new_eventlog_setup {
	my ($eventlog, $param_table) = @_;

	my %vars = ();

	$vars{name} = $eventlog->{state}->{newlog}->{name};
	$vars{sciencelogs} = $eventlog->{log}->list_science();

	foreach (@{ $vars{sciencelogs} }) {
		if ($_->{lognum} == $eventlog->{state}->{newlog}->{sciencelog}) {
			$_->{selected} = 'SELECTED';
		} else {
			$_->{selected} = '';
		}
	}

	$vars{num_cols} = $eventlog->{state}->{newlog}->{num_cols};

	my $scs_streams = $eventlog->get_streams();

	# Add Aditional field types
	push(@{ $scs_streams }, {
		stream => $BUILTIN,
		vars => [ { name => 'Boolean', units => ''}, { name => 'Integer', units => '' }, { name => 'String', units => '' } ],
	});

	# Setup columns
	$vars{cols} = ();

	for (my $c=0; $c<$eventlog->{state}->{newlog}->{num_cols}; $c++) {
		my $streams = dclone($scs_streams);

		setup_streams($eventlog->{state}->{newlog}->{cols}->[$c]->{field} || '', $streams);

		push(@{ $vars{cols} }, { num => $c, streams => $streams, count => $c + 1,
								 desc => $eventlog->{state}->{newlog}->{cols}->[$c]->{desc} || '' });
	}

	return \%vars;
}

sub new_sciencelog_setup {
	my ($eventlog, $param_table) = @_;

	# Setup date defaults
	my @ds = gmtime();

	my $defaults = {
		start_date => sprintf("%04d-%02d-%02d", $ds[5]+1900, $ds[4]+1, $ds[3]),
		end_date   => sprintf("%04d-%02d-%02d", $ds[5]+1900, $ds[4]+1, $ds[3]),
	};

	my $vars = $eventlog->form_setup('new_sciencelog', $param_table, $defaults);	
	$eventlog->form_error_setup($param_table, $vars);

	return $vars;
}

sub new_sciencelog {
	my ($eventlog, $param_table) = @_;
	
	$eventlog->save_form_state($param_table, 'new_sciencelog');
	$eventlog->form_clean_search('new_sciencelog');
	return -1 if $eventlog->form_param_check('new_sciencelog');

	$eventlog->{state}->{new_sciencelog}->{owner} = $eventlog->{user}->{user};

	$eventlog->{log}->add_science_log($eventlog->{state}->{new_sciencelog});

	delete $eventlog->{state}->{new_sciencelog};

	return 0;
}

# Add column Action
sub add_column {
	my ($eventlog, $param_table) = @_;

	# Save state
	$eventlog->save_column_state($param_table);

	# Update the number of columns
	# Don't just increment to keep in step if user hits browser back button
	$eventlog->{state}->{newlog}->{num_cols} = $param_table->{num_cols} + 1;

	return 0;
}

# Generic save column state 
sub save_column_state {
	my ($eventlog, $param_table) = @_;

	delete $eventlog->{state}->{newlog};
	
	$eventlog->{state}->{newlog}->{name} = $param_table->{name};
	$eventlog->{state}->{newlog}->{sciencelog} = $param_table->{sciencelog};
	$eventlog->{state}->{newlog}->{num_cols} = $param_table->{num_cols};
	$eventlog->{state}->{newlog}->{cols} = ();

	foreach (my $c=0; $c<$eventlog->{state}->{newlog}->{num_cols}; $c++) {
		push(@{ $eventlog->{state}->{newlog}->{cols} }, {
			field => $param_table->{"col_$c"},
			desc  => $param_table->{"col_desc_$c"},
		});
	}
}

# Generic remove column
sub del_column {
	my ($eventlog, $param_table, $column_name) = @_;

	$eventlog->save_column_state($param_table);

	# Remove selected columns
	my @new_cols = ();

	for (my $c=0; $c<$eventlog->{state}->{newlog}->{num_cols}; $c++) {
		if (!exists($param_table->{"col_del_$c"})) {
			push(@new_cols, $eventlog->{state}->{newlog}->{cols}->[$c]);
		}
	}
	
	$eventlog->{state}->{newlog}->{cols} = \@new_cols;
	$eventlog->{state}->{newlog}->{num_cols} = scalar(@new_cols);

	return 0;
}

# Create new eventlog
sub create_log {
	my ($eventlog, $param_table) = @_;

	# Save State
	$eventlog->save_column_state($param_table);

	my $newlog = $eventlog->{state}->{newlog};

	# Generate column description for eventlog table
	my @cols = ();

	for (my $c=0; $c<$newlog->{num_cols}; $c++) {
		if (!$newlog->{cols}->[$c]->{field}) {
			$newlog->{cols}->[$c]->{desc} = join(" ", split(":", $newlog->{cols}->[$c]->{field}));
		}
		  
		push(@cols, join(":", $newlog->{cols}->[$c]->{field}, $newlog->{cols}->[$c]->{desc}));
	}

	$eventlog->{log}->add_log({ 
		owner      => $eventlog->{user}->{user},
		name       => $newlog->{name},
		sciencelog => $newlog->{sciencelog},
		cols       => \@cols,
	});

	# Remove state details
	delete $eventlog->{state}->{newlog};

	return 0;
}

# For list/new event
sub get_eventlog_details {
	my ($eventlog, $lognum) = @_;

	my $vars = $eventlog->{log}->log_info($lognum);

	my $cols = $vars->{cols};

	$vars->{cols} = ();

	my $idx = 0;
	foreach my $c (@{ $cols } ) {
		my @cs = split(":", $c);

		push(@{ $vars->{cols} }, { num => $idx, stream => $cs[0], var => $cs[1], title => $cs[2] });
		
		$idx++;
	}

	return $vars;
}

sub list_recs_setup {
	my ($eventlog, $param_table, $lognum) = @_;

	my $vars = $eventlog->get_eventlog_details($lognum);
	$vars->{vals} = $eventlog->{log}->list_log($lognum);

	# Generate name for CSV download
	$vars->{filename} = $vars->{name} . '.csv';
	$vars->{filename} =~ s/ /_/g;
	$vars->{filename} =~ s/\//_/g;
	$vars->{filename} =~ s/\\/_/g;

	$vars->{download_type} = 'download_recs';

	# Add in nbsp's
   	foreach my $rec (@{ $vars->{vals} }) {
		# Add link if user can modify
		if (($eventlog->{user}->{user} eq $rec->{analyst}) || ($eventlog->{user}->{user} eq $vars->{owner})) {
			# Bit messy - a better way ?
			$rec->{tstamp} = '<a href="' . join("/", $eventlog->{config}->{location}, $eventlog->{user}->{level}, 'modify_rec',
												$lognum, $rec->{id}) . '">' . $rec->{tstamp} . '</a>';
		}

		foreach (@{ $rec->{cols} }) {
			$_->{val} = '&nbsp;' unless defined($_->{val});
		}

		$rec->{comment} = '&nbsp;' unless $rec->{comment};

		$rec->{duplicate} = "$lognum/$rec->{id}";
	}

	return $vars;
}

sub get_sciencelog_details {
	my ($eventlog, $lognum) = @_;

	return $eventlog->{log}->log_info($lognum, 'science');
}

sub list_science_recs_setup {
	my ($eventlog, $param_table, $lognum) = @_;

	delete $eventlog->{state}->{new_science_event};
	delete $eventlog->{state}->{modify_science_rec};

	my $vars = $eventlog->get_sciencelog_details($lognum);
	$vars->{vals} = $eventlog->{log}->list_log($lognum, undef, 'science');

	# Generate name for CSV download
	$vars->{filename} = $vars->{name} . '.csv';
	$vars->{filename} =~ s/ /_/g;
	$vars->{filename} =~ s/\//_/g;
	$vars->{filename} =~ s/\\/_/g;

	# Add in nbsp's
   	foreach my $rec (@{ $vars->{vals} }) {
		# Add link if user can modify
		if (($eventlog->{user}->{user} eq $rec->{analyst}) || ($eventlog->{user}->{user} eq $vars->{owner})) {
			# Bit messy - a better way ?
			$rec->{tstamp} = '<a href="' . join("/", $eventlog->{config}->{location}, $eventlog->{user}->{level}, 
												'modify_science_rec', $lognum, $rec->{id}) . '">' . $rec->{tstamp} . '</a>';
		}

		# Convert to Deg & Min
		$rec->{lat_degmin} = _dec_to_deg_min($rec->{lat}, 'N');
		$rec->{lon_degmin} = _dec_to_deg_min($rec->{lon}, 'E');
		
		foreach (qw(id analyst event_no lat lon comment)) {
			$rec->{$_} = '&nbsp;' unless defined($rec->{$_});
		}
	}

	return $vars;	
}

sub xfer_noonpos {
	my ($eventlog, $param_table) = @_;

	my @ids = ();
	foreach my $p (keys %{ $param_table }) {
		if ($p =~ /^mark_(.*)/) {
			push(@ids, $1);
		}
	}

	my $pos = Noonpos::Position->new($eventlog->{db});
	$pos->add_to_xfer($param_table->{lognum}, @ids);

	return 0;
}

sub list_comments_setup { 
	my ($eventlog, $param_table, $lognum) = @_;

	my $vars = $eventlog->get_eventlog_details($lognum);
	$vars->{vals} = $eventlog->{log}->list_comments($lognum);

	# Generate name for CSV download
	$vars->{filename} = $vars->{name} . '_comments.csv';
	$vars->{filename} =~ s/ /_/g;

	$vars->{download_type} = 'download_comments';

	# Add in nbsp's
	foreach (@{ $vars->{vals} }) {
		# Add link if user can modify
		if (($eventlog->{user}->{user} eq $_->{analyst}) || ($eventlog->{user}->{user} eq $_->{owner})) {
			# Bit messy - a better way ?
			$_->{tstamp} = '<a href="' . join("/", $eventlog->{config}->{location}, $eventlog->{user}->{level}, 'modify_comment',
											  $lognum, $_->{id}) . '">' . $_->{tstamp} . '</a>';
		}
		$_->{comment} = '&nbsp;' unless $_->{comment};
	}
	
	return $vars;
}

sub current_time {
	my ($eventlog, $param_table, $time, $form) = @_;
	$form = 'new_event' unless $form;
	
	delete $eventlog->{state}->{time};

	# Save non scs variables
	my $log_info = $eventlog->get_eventlog_details($param_table->{lognum});

	$eventlog->{state}->{$form}->{cols} = [];
	foreach my $v (@{ $log_info->{cols} }) {
		if ($v->{stream} eq $BUILTIN) {
			push (@{ $eventlog->{state}->{$form}->{cols} }, $param_table->{"col_" . $v->{num}});
		} else {
			push(@{ $eventlog->{state}->{$form}->{cols} }, undef );
		}
	}

	# Save comment
	$eventlog->{state}->{$form}->{comment} = $param_table->{comment};
	
	# If time given, then go to this time
	$eventlog->{state}->{time} = $time if defined($time);
#	print STDERR "End of current_time: " . Dumper($eventlog->{state}) . "\n";
	
	return 0;
}

sub new_event { 
	my ($eventlog, $param_table, $lognum) = @_;

	$eventlog->{state}->{lognum} = $lognum;

	# Configure time
	$eventlog->{state}->{time} = timegm($param_table->{seconds}, $param_table->{minutes}, $param_table->{hours},
										$param_table->{days}, $param_table->{months} - 1, $param_table->{years});

	return 0;
}

sub new_event_setup {
	my ($eventlog, $param_table, $lognum, $dup_id) = @_;

#	print STDERR "New event called at " . scalar(localtime) . "State: " . Dumper($eventlog->{state}) . "\n";
	
#	my $lognum = $eventlog->{state}->{lognum};

	my $vars = $eventlog->get_eventlog_details($lognum);

	# Generate name for CSV download
	$vars->{filename} = $vars->{name} . '.csv';
	$vars->{filename} =~ s/ /_/g;
	$vars->{filename} =~ s/\//_/g;
	$vars->{filename} =~ s/\\/_/g;

	$vars->{download_type} = 'download_recs';

	# Get event time
	$vars->{time} = $eventlog->{state}->{time} || (time() - 2);

	$vars->{tstamp} = strftime("%Y-%m-%d %H:%M:%S", gmtime($vars->{time}));

	my $dup_rec = undef;
	if ($dup_id) {
		$dup_rec = $eventlog->{log}->get_rec($lognum, $dup_id);
		$vars->{time} = $dup_rec->{time};
		$vars->{tstamp} = strftime("%Y-%m-%d %H:%M:%S", gmtime($vars->{time}));

#		print STDERR "Duplicating from $dup_id, time: " . $vars->{time} . ", timestamp: " , $vars->{tstamp} . "\n";
	}

	# Get Values from Data Logging System
	my $c = 0;
	foreach my $v (@{ $vars->{cols} }) {
		if ($v->{stream} ne $BUILTIN) {
			$v->{default} = $eventlog->get_data_val($v->{stream}, $v->{var}, $vars->{time}) || '';
		} else {
			$v->{default} = $eventlog->{state}->{new_event}->{cols}->[$c] || '';
#			$v->{default} = '';
			
			if ($v->{var} eq "Boolean") {
				$v->{default} = "Yes";
			}

			if ($dup_rec) {
				$v->{default} = $dup_rec->{cols}->[$c]->{val};
			}
		}

		$c++;
	}

	if ($dup_rec) {
		$vars->{comment} = $dup_rec->{comment};
	} else {
		$vars->{comment} = $eventlog->{state}->{new_event}->{comment} || '';
	}

	# Setup time for form
	delete $vars->{time};
	$eventlog->form_setup_datetime('time', {}, $vars->{tstamp}, 0, $vars);

	# Delete saved state now used
	delete $eventlog->{state}->{new_event};
	delete $eventlog->{state}->{time};
	
	return $vars;
}

# Get Data Logging System Value for given time/stream/variable
sub get_data_val {
	my ($eventlog, $stream, $var, $tstamp) = @_;

	print STDERR "Getting [$stream], [$var], [$tstamp] ";
	
	eval { $eventlog->{data}->attach($stream); } or return undef;

	my $v = undef;

	# Make sure time is within stream
	# Make sure we are at start of stream
	$eventlog->{data}->find_time(0);
	my $rec = $eventlog->{data}->next_record();
	my $start_time = $rec->{timestamp};
	
#	$rec = $eventlog->{data}->last_record();
#	my $end_time = $rec->{timestamp};
	
	# Don't do end time at moment - just pick last time
	if ($tstamp >= $start_time) {
		my ($var_pos) = $eventlog->{data}->get_vars_pos($var);

		print STDERR "- Vars pos [$var_pos] - ";
		$rec = $eventlog->{data}->find_time($tstamp);
		$rec = $eventlog->{scs}->next_record();
		
		$v = $rec->{vals}->[$var_pos];
	} else {
		$v = undef;
	}

	print STDERR "- Found [" . ($v || 'undef') . "]\n";
	
	$eventlog->{data}->detach();

	return $v;
}

sub add_event {
	my ($eventlog, $param_table) = @_;

	my $lognum = $param_table->{lognum};

	# Configure time
	my $time = timegm($param_table->{seconds}, $param_table->{minutes}, $param_table->{hours},
					  $param_table->{days}, $param_table->{months} - 1, $param_table->{years});

	my $log_info = $eventlog->get_eventlog_details($lognum);

	my @vals = ();

	for (my $c=0; $c < $log_info->{num_cols}; $c++) {
		push(@vals, $param_table->{"col_$c"});
	}
	
	$eventlog->{log}->add_rec($lognum, $param_table->{analyst} || $eventlog->{user}->{user}, $time, 
							  $param_table->{comment} || '', @vals);

	return 0;
}

sub new_science_event_setup { 
	my ($eventlog, $param_table, $lognum) = @_;

	# Use current date/time as default unless we have a user set time
	my $tstamp = $eventlog->{state}->{new_science_event}->{time} || time();

	# Clear so correct format is set from defaults
	delete $eventlog->{state}->{new_science_event}->{time};

	my @ds = gmtime($tstamp);

	# Force defaults (i.e data vals) to be used
	delete $eventlog->{state}->{new_science_event}->{lat};
	delete $eventlog->{state}->{new_science_event}->{lon};

	my $defaults = {
		time   => sprintf("%04d-%02d-%02d %02d:%02d:%02d", $ds[5]+1900, $ds[4]+1, $ds[3], $ds[2], $ds[1], $ds[0]),
		lat    => $eventlog->get_data_val($GPS_STREAM, $GPS_LAT, $tstamp) || '',
		lon    => $eventlog->get_data_val($GPS_STREAM, $GPS_LON, $tstamp) || '',
		lognum => $lognum,
	};

	my $vars = $eventlog->form_setup('new_science_event', $param_table, $defaults);	
	$eventlog->form_error_setup($param_table, $vars);

	# Generate name for CSV download
	my $info = $eventlog->get_sciencelog_details($lognum);
	$vars->{filename} = $info->{name} . '.csv';
	$vars->{filename} =~ s/ /_/g;
	$vars->{filename} =~ s/\//_/g;
	$vars->{filename} =~ s/\\/_/g;

	return $vars;
}

sub science_current_time {
	my ($eventlog, $param_table) = @_;

	$eventlog->save_form_state($param_table, 'new_science_event');

	# Delete so will be set by new_science_event_setup default
	delete $eventlog->{state}->{new_science_event}->{time};

	return 0;
}

sub science_update_time {
	my ($eventlog, $param_table) = @_;

	$eventlog->save_form_state($param_table, 'new_science_event');

	# Convert to timestamp
	$eventlog->clean_search_datetime('time', {}, $eventlog->{state}->{new_science_event});

	return 0;
}

sub new_science_event {
	my ($eventlog, $param_table) = @_;

	$eventlog->save_form_state($param_table, 'new_science_event');
	return (-1, []) if $eventlog->form_param_check('new_science_event');

	$eventlog->{state}->{new_science_event}->{analyst} = $eventlog->{user}->{user};
	$eventlog->{state}->{new_science_event}->{event_no} ||= '';
	$eventlog->{state}->{new_science_event}->{comment}  ||= '';

	$eventlog->{log}->add_science_rec($eventlog->{state}->{new_science_event});

	delete $eventlog->{state}->{new_science_event};

	return 0;
}

sub modify_science_rec_setup {
	my ($eventlog, $param_table, $lognum, $id) = @_;
	return unless $lognum && $id;

	my $defaults = $eventlog->{log}->get_rec($lognum, $id, undef, 'science');

	# Setup time 
	my $tstamp = $eventlog->{state}->{modify_science_rec}->{time} || $defaults->{time};

	my @ds = gmtime($tstamp);
	
	# Force defaults (i.e scs vals) to be used
	delete $eventlog->{state}->{modify_science_rec}->{time};
	delete $eventlog->{state}->{modify_science_rec}->{lat};
	delete $eventlog->{state}->{modify_science_rec}->{lon};

	$defaults->{time}   = sprintf("%04d-%02d-%02d %02d:%02d:%02d", $ds[5]+1900, $ds[4]+1, $ds[3], $ds[2], $ds[1], $ds[0]);
	$defaults->{lat}    = $eventlog->get_data_val($GPS_STREAM, $GPS_LAT, $tstamp) || $defaults->{lat};
	$defaults->{lon}    = $eventlog->get_data_val($GPS_STREAM, $GPS_LON, $tstamp) || $defaults->{lon};
	$defaults->{lognum} = $lognum;

	my $vars = $eventlog->form_setup('modify_science_rec', $param_table, $defaults);
	$eventlog->form_error_setup($param_table, $vars);

	# Generate name for CSV download
	my $info = $eventlog->get_sciencelog_details($lognum);
	$vars->{filename} = $info->{name} . '.csv';
	$vars->{filename} =~ s/ /_/g;
	$vars->{filename} =~ s/\//_/g;
	$vars->{filename} =~ s/\\/_/g;

	return $vars;
}

sub modify_science_current_time {
	my ($eventlog, $param_table) = @_;

	$eventlog->save_form_state($param_table, 'modify_science_rec');

	# Set new time for modify_rec to use
	$eventlog->{state}->{modify_science_rec}->{time} = (time() - 2);

	return 0;
}

sub modify_science_update_time {
	my ($eventlog, $param_table) = @_;

	$eventlog->save_form_state($param_table, 'modify_science_rec');

	# Convert to timestamp
	$eventlog->clean_search_datetime('time', undef, $eventlog->{state}->{modify_science_rec});

	return 0;
}

sub modify_science_rec {
	my ($eventlog, $param_table) = @_;

	$eventlog->save_form_state($param_table, 'modify_science_rec');
	return (-1, []) if $eventlog->form_param_check('modify_science_rec');

	$eventlog->{state}->{modify_science_rec}->{analyst} = $eventlog->{user}->{user};
	$eventlog->{state}->{modify_science_rec}->{event_no} ||= '';
	$eventlog->{state}->{modify_science_rec}->{comment}  ||= '';

	$eventlog->{log}->modify_science_rec($eventlog->{state}->{modify_science_rec});

	delete $eventlog->{state}->{modify_science_rec};

	return 0;
}

sub new_comment {
	my ($eventlog, $param_table) = @_;

	return new_event($eventlog, $param_table);
}

sub new_comment_setup {
	my ($eventlog, $param_table, $lognum) = @_;

	my $vars = $eventlog->get_eventlog_details($lognum);

	# Generate name for CSV download
	$vars->{filename} = $vars->{name} . '_comments.csv';
	$vars->{filename} =~ s/ /_/g;

	$vars->{download_type} = 'download_comments';

	# Setup time for form
	$vars->{tstamp} = strftime("%Y-%m-%d %H:%M:%S", gmtime(time()));
	$eventlog->form_setup_datetime('time', {}, $vars->{tstamp}, 0, $vars);
	
	return $vars;
}

sub add_comment {
	my ($eventlog, $param_table) = @_;

	# Configure time
	my $time = timegm($param_table->{seconds}, $param_table->{minutes}, $param_table->{hours},
					  $param_table->{days}, $param_table->{months} - 1, $param_table->{years});

	$eventlog->{log}->add_comment($param_table->{lognum}, $param_table->{analyst} || $eventlog->{user}->{user}, $time, 
								  $param_table->{comment} || '');

	return 0;
}

sub modify_rec_setup {
	my ($eventlog, $param_table, $lognum, $recnum) = @_;
	return {} unless $lognum && $recnum;

	my $vars = $eventlog->get_eventlog_details($lognum);

	# Generate name for CSV download
	$vars->{filename} = $vars->{name} . '.csv';
	$vars->{filename} =~ s/ /_/g;
	$vars->{filename} =~ s/\//_/g;
	$vars->{filename} =~ s/\\/_/g;

	$vars->{download_type} = 'download_recs';

	my $rec = $eventlog->{log}->get_rec($lognum, $recnum);

	$vars->{comment} = $eventlog->{state}->{modify_rec}->{comment} || $rec->{comment};
	$vars->{time}    = $eventlog->{state}->{time} || $rec->{time};
	$vars->{analyst} = $rec->{analyst};

	$vars->{recnum}  = $recnum;

	my $c = 0;
	foreach my $v (@{ $vars->{cols} }) {
		if ($v->{stream} ne $BUILTIN) {
			$v->{default} = $eventlog->get_data_val($v->{stream}, $v->{var}, $vars->{time}) || 
				$eventlog->{state}->{modify_rec}->{cols}->[$c] || $rec->{cols}->[$c]->{val} || '';
		} else {
			$v->{default} = $eventlog->{state}->{modify_rec}->{cols}->[$c]  || $rec->{cols}->[$c]->{val} || '';
		}
		
		$c++;
	}
   
	delete $eventlog->{state}->{modify_rec};
	delete $eventlog->{state}->{time};

	# Setup time for form
	$vars->{tstamp} = strftime("%Y-%m-%d %H:%M:%S", gmtime($vars->{time}));
	delete $vars->{time};
	$eventlog->form_setup_datetime('time', {}, $vars->{tstamp}, 0, $vars);

	return $vars;
}

sub info_rec_setup {
        my ($eventlog, $param_table, $lognum, $recnum) = @_;
        return {} unless $lognum && $recnum;

        my $vars = $eventlog->get_eventlog_details($lognum);
        my $rec = $eventlog->{log}->get_rec($lognum, $recnum);

        foreach my $c (@{ $vars->{cols} }) {
                $c->{val} = $rec->{cols}->[$c->{num}]->{val};
        }

        convert_deg_min($vars);

        $vars->{tstamp} = $rec->{tstamp};
        $vars->{comment} = $rec->{comment};

        return $vars;
}

sub get_deg_cols {
        my $vars = shift;

        my @cs = ();
        foreach my $c (@{ $vars->{cols} }) {
                if ($c->{var} =~ /lat/i) {
                        push(@cs, { idx => $c->{num}, dir => 'N' });
                }

                if ($c->{var} =~ /lon/i) {
                        push(@cs, { idx => $c->{num}, dir => 'E' });
                }
        }

        return \@cs;
}

sub convert_deg_min {
        my $vars = shift;

        foreach my $c (@{ get_deg_cols($vars) }) {
                $vars->{cols}->[$c->{idx}]->{val} = _dec_to_deg_min($vars->{cols}->[$c->{idx}]->{val}, $c->{dir});
        }
}

sub _dec_to_deg_min {
        my ($val, $dir) = @_;
        $dir = 'N' unless $dir;

        if ($val < 0) {
                $val *= -1;
                $dir = "S" if $dir eq "N";
                $dir = "W" if $dir eq "E";
        }

        my $deg = int($val);
        my $min = ($val - $deg) * 60.0;

        return sprintf("%02d %05.2f $dir", $deg, $min);
}

sub update_time {
	my ($eventlog, $param_table) = @_;

	my $form = 'new_event';
	if ($param_table->{next_page_update_time} =~ /modify_rec/) {
		$form = 'modify_rec';
	}
	
	# Use current_time to update and save non scs variables
	return $eventlog->current_time($param_table, timegm($param_table->{seconds}, $param_table->{minutes}, $param_table->{hours},
														$param_table->{days}, $param_table->{months} - 1, $param_table->{years}), $form);
}

sub modify_rec { 
	my ($eventlog, $param_table) = @_;

	# Delete old record
	$eventlog->{log}->del_rec($param_table->{lognum}, $param_table->{recnum});

	# Add new record
	$eventlog->add_event($param_table);

	return 0;
}

sub remove_rec {
	my ($eventlog, $param_table) = @_;

	$eventlog->{log}->del_rec($param_table->{lognum}, $param_table->{recnum});

	return 0;
}

sub modify_comment_setup {
	my ($eventlog, $param_table, $lognum, $comment_num) = @_;
	return {} unless $lognum && $comment_num;

	my %vars = ();

	my $rec = $eventlog->{log}->get_comment_rec($lognum, $comment_num);

	# Generate name for CSV download
	$vars{filename} = $vars{name} . '_comments.csv';
	$vars{filename} =~ s/ /_/g;

	$vars{download_type} = 'download_comments';

	$vars{comment} = $rec->{comment};
	$vars{time}    = $rec->{time};
	$vars{analyst} = $rec->{analyst};

	$vars{lognum}       = $lognum;
	$vars{comment_num}  = $comment_num;

	$vars{tstamp} = strftime("%Y-%m-%d %H:%M:%S", gmtime($vars{time}));
	delete $vars{time};
	$eventlog->form_setup_datetime('time', {}, $vars{tstamp}, 0, \%vars);
	
	return \%vars;
}

sub modify_comment {
	my ($eventlog, $param_table) = @_;

	# Delete old record
	$eventlog->{log}->del_comment_rec($param_table->{lognum}, $param_table->{comment_num});

	# Add new record
	$eventlog->add_comment($param_table);

	return 0;
}

sub remove_comment {
	my ($eventlog, $param_table) = @_;

	$eventlog->{log}->del_comment_rec($param_table->{lognum}, $param_table->{comment_num});

	return 0;
}

sub modify_log_setup { 
	my ($eventlog, $param_table, $lognum) = @_;

	my $log_info = $eventlog->{log}->log_info($lognum);

	delete $eventlog->{state}->{newlog};

	$eventlog->{state}->{newlog}->{name}     = $log_info->{name};
	$eventlog->{state}->{newlog}->{num_cols} = $log_info->{num_cols};

	$eventlog->{state}->{newlog}->{cols} = ();
	foreach (@{ $log_info->{cols} }) {
		my @cs = split(":", $_);

		push(@{ $eventlog->{state}->{newlog}->{cols} }, {
			field => join(":", @cs[0, 1]),
			desc  => $cs[2],
		});
	}

	my $vars = $eventlog->new_eventlog_setup($param_table);
	
	$vars->{lognum} = $lognum;

	return $vars;
}

sub download_recs_setup {
	my ($eventlog, $param_table, $lognum) = @_;

   	my $vars = get_eventlog_details($eventlog, $lognum);

	# Create CSV string
	$vars->{_CSV} = "Time, ";

	foreach my $c (@{ $vars->{cols} }) {
		$vars->{_CSV} .= $c->{title} . "(" . $c->{stream} . " - " . $c->{var} . "), ";
	}

	$vars->{_CSV} .= "Comment,User\n";

	# Get Values
	$vars->{vals} = $eventlog->{log}->list_log($lognum);

	# Add in nbsp's
   	foreach my $rec (@{ $vars->{vals} }) {
		my @vals = ();

		push(@vals, $rec->{tstamp});

		foreach (@{ $rec->{cols} }) {
			push(@vals, $_->{val});
		}

		push(@vals, $rec->{comment} || '');

		push(@vals, $rec->{analyst});
		
		$vars->{_CSV} .= join(",", map { '"' . $_ . '"' } @vals) . "\n";
	}
	
	return $vars;
}

sub download_science_recs_setup {
	my ($eventlog, $param_table, $lognum) = @_;

   	my $vars = get_sciencelog_details($eventlog, $lognum);

	# Create CSV string
	$vars->{_CSV} = "Time, Event, Lat, Lon, Comment, User\n";

	# Get Values
	$vars->{vals} = $eventlog->{log}->list_log($lognum, undef, 'science');

	# Add in nbsp's
   	foreach my $rec (@{ $vars->{vals} }) {
		my @vals = ();

		foreach (qw(tstamp event_no lat lon comment analyst)) {
			push(@vals, $rec->{$_} || '');
		}

		$vars->{_CSV} .= join(",", @vals) . "\n";
	}
	
	return $vars;
}

sub download_comments_setup {
	my ($eventlog, $param_table, $lognum) = @_;

	my $vars = $eventlog->get_eventlog_details($lognum);
	$vars->{vals} = $eventlog->{log}->list_comments($lognum);

	# Print Title
	$vars->{_CSV} = "Time,Comment,User\n";

	# Add in nbsp's
	foreach (@{ $vars->{vals} }) {
		my @vals = ();
		push(@vals, $_->{tstamp});
		push(@vals, '"' . ($_->{comment} || '') . '"');
		push(@vals, $_->{analyst});

		$vars->{_CSV} .= join(",", @vals) . "\n";
	}

	return $vars;
}


1;
__END__

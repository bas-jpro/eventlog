# Log package for JCR Eventlogs
# Copyright (c) 2004 Jeremy Robst <jpr@robst.org>
#
# This program is free software released under the GPL.
# See the file COPYING included with this release or
# http://www.gnu.org/copyleft/copyleft.html
#
# v1.0 JPR 09/01/2004 Initial Release
# v1.1 JPR 24/12/2004 Added Science Logs
#                   

package Eventlog::Log;
use strict;

use POSIX qw(strftime);

sub new {
	my ($class, $db) = @_;

	my $log = bless {
		db => $db,
	}, $class;

	return $log;
}

sub list {
	my ($log, $type) = @_;
	$type = 'event' unless $type;

	my $query = '';
	if ($type eq 'event') {
		$query = 'SELECT eventlog.lognum, eventlog.owner, eventlog.name, eventlog.sciencelog, eventlog.cols, ' .
			'sciencelog.title, sciencelog.name FROM eventlog,sciencelog WHERE eventlog.sciencelog=sciencelog.lognum ' .
			'ORDER BY sciencelog.start_date DESC, eventlog.lognum DESC';
	}
	
	if ($type eq 'science') {
		$query = 'SELECT * FROM sciencelog ORDER BY start_date DESC';
	}

	my @ls = ();

	$log->{db}->query($query);

	while ($log->{db}->next_record()) {
		push(@ls, $log->_log_info($log->{db}, $type));
	}

	return \@ls;
}

sub list_science {
	my $log = shift;

	return $log->list('science');
}

# Find a science log given a leg number (start date)
sub get_leg_sciencelog {
	my ($self, $leg) = @_;
	return unless $leg;
	return unless $leg =~ /^\d{8}$/;

	my $date = join('-', substr($leg, 0, 4), substr($leg, 4, 2), substr($leg, 6, 2));
	$self->{db}->prepare("SELECT * FROM sciencelog WHERE start_date=?");
	$self->{db}->execute($date);

	return unless $self->{db}->num_rows() == 1;
	$self->{db}->next_record;

	return $self->_log_info($self->{db}, 'science');
}

# Find logs by given info
sub search_logs {
	my ($self, $li, $type) = @_;
	$type = 'event' unless $type && ($type eq 'science');

	my $query = "SELECT * FROM " . $type . "log ";
	my $glue = "WHERE";
	my @ks = ();
	foreach my $k (keys %$li) {
		$query .= $glue . " $k=?";
		$glue = "AND";

		# Save order of keys
		push(@ks, $k);
	}

	$self->{db}->prepare($query);
	$self->{db}->execute(map { $li->{$_} } @ks);

	my @ls = ();
	while ($self->{db}->next_record()) {
		push(@ls, $self->_log_info($self->{db}, $type));
	}
	
	return \@ls;
}

# FIXME: Can only delete eventlogs at the moment
# returns undef on failure & true on success
sub del_log {
	my ($log, $lognum, $type) = @_;
	return undef unless defined($lognum) && $type;
	return undef unless ($type eq 'event') || ($type eq 'science');

	# Check log exists
	$log->{db}->prepare("SELECT * FROM eventlog WHERE lognum=?");
	$log->{db}->execute($lognum);

	return undef unless $log->{db}->num_rows() == 1;	

	$log->{db}->prepare("DELETE FROM eventlog WHERE lognum=?");
	$log->{db}->execute($lognum);

	$log->{db}->query("DROP TABLE log_$lognum");
	$log->{db}->query("DROP TABLE comment_log_$lognum");

	return 1;
}

sub add_log { 
	my ($log, $log_info) = @_;

	# Add to eventlog table
	$log->{db}->prepare("INSERT INTO eventlog VALUES(null, ?, ?, ?, ?)");
	$log->{db}->execute($log_info->{owner}, $log_info->{name}, $log_info->{sciencelog}, join(",", @{ $log_info->{cols} }));

	# Get new log number
	my $lognum = -1;
	$log->{db}->query("SELECT LAST_INSERT_ID()");
	$log->{db}->next_record();
	$lognum = $log->{db}->f(0);

	# Create new table for events
	my $mktable = "CREATE TABLE log_$lognum (id int not null auto_increment primary key, tstamp timestamp, analyst tinytext, ";

	for (my $c = 0; $c < scalar(@{ $log_info->{cols} }); $c++) {
		$mktable .= "col_$c text, "
	}

	$mktable .= "comment text )";

	$log->{db}->query($mktable);

	# Create Comment log
	$log->{db}->query("CREATE TABLE comment_log_$lognum (id int not null auto_increment primary key, tstamp timestamp, " .
					  "analyst tinytext, comment text )");

	return $lognum;
}

sub add_science_log {
	my ($log, $li) = @_;

	# Add to sciencelog table
	$log->{db}->prepare("INSERT INTO sciencelog VALUES(null, ?, ?, ?, ?, ?, ?, ?)");
	$log->{db}->execute($li->{owner}, $li->{title}, $li->{name}, $li->{pso}, $li->{institute}, $li->{start_date}, $li->{end_date});
	
	# Get new log number
	my $lognum = -1;
	$log->{db}->query("SELECT LAST_INSERT_ID()");
	$log->{db}->next_record();
	$lognum = $log->{db}->f(0);

	# Create new table for events
	$log->{db}->query("CREATE TABLE sciencelog_$lognum ( " .
					  "id int not null auto_increment primary key, " .
					  "tstamp timestamp,                           " .
					  "analyst tinytext,                           " .
					  "event_no tinytext,                          " .
					  "lat tinytext,                               " .
					  "lon tinytext,                               " .
					  "comment text                                " .
					  ")");

	return $lognum;
}

# Private db -> hash
sub _log_info {
	my ($log, $db_rec, $type) = @_;
	$type = 'event' unless $type;

	if ($type eq 'event') {
		my @cols = split(",", $db_rec->f(4));
		
		return {
			lognum           => $db_rec->f(0),
			owner            => $db_rec->f(1),
			name             => $db_rec->f(2),
			sciencelog       => $db_rec->f(3),
			sciencelog_title => $db_rec->f(5),
			sciencelog_name  => $db_rec->f(6),
			cols             => \@cols,
			num_cols         => scalar(@cols),
		};
	}

	if ($type eq 'science') {
		return {
			lognum     => $db_rec->f(0),
			owner      => $db_rec->f(1),
			title      => $db_rec->f(2),
			name       => $db_rec->f(3),
			pso        => $db_rec->f(4),
			institute  => $db_rec->f(5),
			start_date => $db_rec->f(6),
			end_date   => $db_rec->f(7),
		};
	}

	die "Unknown log type: $type\n";
}

sub log_info { 
	my ($log, $lognum, $type) = @_;
	$type = 'event' unless $type;

	$log->{db}->query("SELECT * FROM " . $type . "log WHERE lognum='$lognum'");
	$log->{db}->next_record();

	return $log->_log_info($log->{db}, $type);
}

# Extract a list of events from a given science log
sub get_science_events {
	my ($self, $lognum, $format) = @_;
	$format = '%H:%i:%S %d/%m/%Y' unless $format;

	my @es = ();
	$self->{db}->query("SELECT *,DATE_FORMAT(tstamp, '$format'),UNIX_TIMESTAMP(tstamp) FROM sciencelog_$lognum " .
					   "WHERE event_no != '' ORDER BY tstamp ASC");

	my $event = undef;
	while ($self->{db}->next_record()) {
		my $info = $self->_science_rec($self->{db});

		if (!$event || ($event->{event_no} ne $info->{event_no})) {
			if ($event) {
				push(@es, $event);
				$event = undef;
			}
			
			$event = {
				event_no     => $info->{event_no},
				start_tstamp => $info->{time},
				end_tstamp   => $info->{time},
				comments     => $info->{comment},
			};

			next;
		}

		if ($event->{start_tstamp} > $info->{time}) {
			$event->{start_tstamp} = $info->{time};
		}
		
		if ($event->{end_tstamp} < $info->{time}) {
			$event->{end_tstamp} = $info->{time};
		}
		
		$event->{comments} .= "\n" . $info->{comment};
	}

	push(@es, $event) if $event;

	return \@es;
}

sub list_log {
	my ($log, $lognum, $format, $type) = @_;
	$format = '%H:%i:%S %d/%m/%Y' unless $format;
	$type = '' unless $type && ($type eq 'science');
	
	my $log_info = $log->log_info($lognum, $type);

	$log->{db}->query("SELECT *,DATE_FORMAT(tstamp, '$format'),UNIX_TIMESTAMP(tstamp) FROM " . $type . 
					  "log_$lognum ORDER BY tstamp DESC");
	
	my @vals = ();

	while ($log->{db}->next_record()) {
		push(@vals, $log->_rec($log->{db}, $log_info->{num_cols}, $type || 'event'));
	}
		
	return \@vals;
}

# Private db -> record hash
sub _rec {
	my ($log, $dbrec, $num_cols, $type) = @_;
	$type = 'event' unless $type;

	return $log->_event_rec($log->{db}, $num_cols) if $type eq 'event';
	return $log->_science_rec($log->{db}) if $type eq 'science';

	die "Unknown log type '$type'\n";
}

sub _event_rec {
	my ($log, $dbrec, $num_cols) = @_;

	my $rec = { };
	$rec->{cols} = ();
	
	$rec->{id}      = $log->{db}->f(0); 
	$rec->{analyst} = $log->{db}->f(2);
	
	my $idx = 3;
	for (my $c=0; $c < $num_cols; $c++) {
		push(@{ $rec->{cols} }, { val => $log->{db}->f($idx) });
		$idx++;
	}
	
	$rec->{comment} = $log->{db}->f($idx++) || '';

	# Time in given format and unix timestamp
	$rec->{tstamp} = $log->{db}->f($idx++);
	$rec->{time}   = $log->{db}->f($idx);

	return $rec;
}

sub _science_rec {
	my ($log, $dbrec) = @_;

	return {
		id       => $dbrec->f(0),
		analyst  => $dbrec->f(2),
		event_no => $dbrec->f(3),
		lat      => $dbrec->f(4),
		lon      => $dbrec->f(5),
		comment  => $dbrec->f(6),
		tstamp   => $dbrec->f(7),
		time     => $dbrec->f(8),
	};
}

# List records for noonpos xfer
sub get_science_noonpos_recs {
	my ($log, $lognum, @ids) = @_;
	return [] unless $lognum && scalar(@ids) > 0;
	
	$log->{db}->query("SELECT *, DATE_FORMAT(tstamp, '%H:%i:%S %d/%m/%Y'), UNIX_TIMESTAMP(tstamp) FROM sciencelog_$lognum WHERE " .
					  "id IN (" . join(",", @ids) . ") ORDER BY TSTAMP ASC");
	
	my @rs = ();
	while ($log->{db}->next_record()) {
		push(@rs, $log->_science_rec($log->{db}));
	}

	return \@rs;
}

sub last_record_time {
	my ($log, $lognum, $type, $format) = @_;
	$type = '' unless $type && ($type eq 'science');
	$format = '%H:%i:%S %d/%m/%Y' unless $format;
	
	$log->{db}->query("SELECT DATE_FORMAT(tstamp, '$format') FROM " . $type . "log_$lognum ORDER BY tstamp DESC");
	$log->{db}->next_record();

	return ($log->{db}->f(0) || 'No Records');
}

sub list_comments {
	my ($log, $lognum, $format) = @_;
	$format = '%H:%i:%S %d/%m/%Y' unless $format;

	my @cs = ();

	$log->{db}->query("SELECT *,DATE_FORMAT(tstamp, '$format'),UNIX_TIMESTAMP(tstamp) FROM comment_log_$lognum " .
					  "ORDER BY tstamp DESC");

	while ($log->{db}->next_record()) {
		push(@cs, $log->_comment_rec($log->{db}));
	}

	return \@cs;
}

# Private db -> comment hash
sub _comment_rec {
	my ($log, $dbrec) = @_;

	return { 
			id      => $log->{db}->f(0),
			analyst => $log->{db}->f(2),
			comment => $log->{db}->f(3),
			tstamp  => $log->{db}->f(4),
			time    => $log->{db}->f(5),
		};
}

sub add_rec {
	my ($log, $lognum, $analyst, $tstamp, $comment, @vals) = @_;

	my $log_info = $log->log_info($lognum);

	# Insert values into DB
	# Placeholders for each column value
	my $q_str = "null, ?, ?, " . ("?, " x $log_info->{num_cols}). "?";

	$log->{db}->prepare("INSERT INTO log_$lognum VALUES($q_str)");

	my @vs = ();
	push(@vs, strftime("%Y%m%d%H%M%S", gmtime($tstamp)));
	push(@vs, $analyst);
	push(@vs, @vals);
	push(@vs, $comment);

	$log->{db}->execute(@vs);	
}

# ri is rec info hash includeing lognum
sub add_science_rec {
	my ($log, $ri) = @_;
	return unless $ri->{lognum};

#	print STDERR "Adding time [" . $ri->{time} . "]\n";
	$log->{db}->prepare("INSERT INTO sciencelog_" . $ri->{lognum} . " VALUES(null, ?, ?, ?, ?, ?, ?)");
	$log->{db}->execute($ri->{time}, $ri->{analyst}, $ri->{event_no}, $ri->{lat}, $ri->{lon}, $ri->{comment});
}

# ri is rec info has including lognum / id
sub modify_science_rec {
	my ($log, $ri) = @_;
	return unless $ri->{lognum} && $ri->{id};

	$log->{db}->query("DELETE FROM sciencelog_" . $ri->{lognum} . " WHERE id=" . $ri->{id});

	$log->add_science_rec($ri);
}

sub add_comment {
	my ($log, $lognum, $analyst, $tstamp, $comment) = @_;

	$log->{db}->prepare("INSERT INTO comment_log_$lognum VALUES(null, ?, ?, ?)");
	$log->{db}->execute(strftime("%Y%m%d%H%M%S", gmtime($tstamp)), $analyst, $comment);
}

sub get_rec {
	my ($log, $lognum, $recnum, $format, $type) = @_;
	$format = '%H:%i:%S %d/%m/%Y' unless $format;
	$type = '' unless $type && ($type eq 'science');

	my $log_info = $log->log_info($lognum, $type);

	$log->{db}->query("SELECT *,DATE_FORMAT(tstamp, '$format'),UNIX_TIMESTAMP(tstamp) FROM " . $type . 
					  "log_$lognum WHERE id=$recnum");
	$log->{db}->next_record();

	return $log->_rec($log->{db}, $log_info->{num_cols}, $type);
}

sub del_rec {
	my ($log, $lognum, $recnum) = @_;

	$log->{db}->query("DELETE FROM log_$lognum WHERE id=$recnum");

	return 1;
}

sub get_comment_rec { 
	my ($log, $lognum, $comment_num, $format) = @_;
	$format = '%H:%i:%S %d/%m/%Y' unless $format;

	$log->{db}->query("SELECT *,DATE_FORMAT(tstamp, '$format'),UNIX_TIMESTAMP(tstamp) FROM comment_log_$lognum WHERE " .
					  "id=$comment_num");
	$log->{db}->next_record();

	return $log->_comment_rec($log->{db});
}

sub del_comment_rec {
	my ($log, $lognum, $comment_num) = @_;

	$log->{db}->query("DELETE FROM comment_log_$lognum WHERE id=$comment_num");
}

# Only make sense for eventlogs
sub modify_column {
	my ($self, $lognum, $colnum, $col_desc) = @_;
	return unless $lognum && defined($colnum) && $col_desc;

	my $info = $self->log_info($lognum);
	return unless $info;
	return unless $colnum < $info->{num_cols};

	my @new_cols = ();
	for (my $i=0; $i<$info->{num_cols}; $i++) {
		if ($i == $colnum) {
			push(@new_cols, $col_desc);
		} else {
			push(@new_cols, $info->{cols}->[$i]);
		}
	}
	
	$self->{db}->prepare("UPDATE eventlog SET cols=? WHERE lognum=?");
	$self->{db}->execute(join(",", @new_cols), $lognum);

	return 1;
}

# Only make sense for eventlogs
sub add_column {
	my ($self, $lognum, $col_desc) = @_;
	return unless $lognum && $col_desc;
	
	$self->{db}->prepare("SELECT cols FROM eventlog WHERE lognum=?");
	$self->{db}->execute($lognum);

	return unless $self->{db}->num_rows() == 1;

	$self->{db}->next_record();
	my $cols = $self->{db}->f(0);
	my $new_cols = join(",", $cols, $col_desc);

	$self->{db}->prepare("UPDATE eventlog SET cols=? WHERE lognum=?");
	$self->{db}->execute($new_cols, $lognum);

	my $max_col = scalar(split(",", $cols));
	my $old_max = $max_col - 1;
	$self->{db}->query("ALTER TABLE log_$lognum ADD COLUMN col_$max_col text AFTER col_$old_max");
	
	return 1;
}

1;
__END__

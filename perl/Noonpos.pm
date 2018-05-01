# Apache::Controller Interface for JCR Noonpos
# 
# v2.0 JPRO 01/02/2006 Based on PCDL's v1.0 - updated at request of 2nd Mate
#

package Noonpos;
@ISA = qw(FormSetup);
use strict;

use Apache::Controller::DB;
use POSIX qw(strftime);
use Eventlog::Log;
use Noonpos::Position;

use Data::Dumper;

my $SECS_PER_HOUR = 3600;

sub new {
	my ($class, $config) = @_;

	my $noonpos = bless {
		config  => $config,
		db      => Apache::Controller::DB->new($config->{locals}->{db}->{name}, $config->{locals}->{db}),
		user    => $config->{analyst},
		state   => $config->{session},
	}, $class;
	
	$noonpos->{pos} = Noonpos::Position->new($noonpos->{db});

	return $noonpos;
}

sub footer_setup { }
sub error_setup  { }

sub index_setup  { }

sub header_setup {
	my $noonpos = shift;

	return {
		postype => $noonpos->{pos}->LastType(),
	};
}

sub showpos_setup {
	my ($noonpos, $param_table, $type, $date) = @_;
	
	my $vars = $noonpos->form_info_setup($type, $noonpos->{pos}->Get($date));

	# Check Air Temp / Sea Temp for zero values
	$vars->{air_temp} = '0.0' if (!$vars->{air_temp});
	$vars->{sea_temp} = '0.0' if (!$vars->{sea_temp});

	if (!$vars) {
		$vars = { };
	}

	if ($vars->{datestamp} =~ /(\d{4})-(\d{2})-(\d{2})/) {
		$vars->{header_date} = "Date: " . strftime("%d %b %Y", 0, 0, 0, $3, $2-1, $1 - 1900, 0);
		$vars->{header_time} = "Observation Time: 12:00 Local"
	}

	# Added Jan 8, 2011 - dacon
	# Updated to add degree symbol by request of Mike G.
	$vars->{lat} = $noonpos->get_latlon_display_value($vars->{lat});
	$vars->{lon} = $noonpos->get_latlon_display_value($vars->{lon});

	$vars->{Next} = $noonpos->{pos}->Next($vars->{id});
	$vars->{Prev} = $noonpos->{pos}->Prev($vars->{id});


	foreach my $p (qw(Next Prev)) {
		if ($vars->{$p}) {
			$vars->{$p}->{link} = $p;
			
			if ($vars->{$p}->{datestamp} =~ /^(\d{4}-\d{2}-\d{2})/) {
				$vars->{$p}->{date} = $1;
			}
		}
	}

	return $vars;
}

sub reset {
	my ($noonpos, $param_table) = @_;

	my $active = $param_table->{type} || 'transit';

	$noonpos->delete_form_state($active);

	return 0;
}

sub newpos_setup {
	my ($noonpos, $param_table, $type) = @_;

	my $active = $type; 
	
	# Setup time / date defaults
	my @ds = gmtime(time());
	my $today_date = sprintf("%04d-%02d-%02d", $ds[5]+1900, $ds[4]+1, $ds[3]);
	my $today_time = sprintf("%02d:%02d:%02d", $ds[2], $ds[1], $ds[0]);

	my $defaults = $noonpos->{pos}->GetLatest();

	if (!$defaults) {
		$defaults = {
			eta1_date => $today_date,
			eta2_date => $today_date,
			eta1_time => $today_time,
			eta2_time => $today_time,
			timezone  => 0,
		};
	} 

	# Update lat / lon from database to have degree symbols
	#my $lat = $noonpos->get_latlon_display_value(

	# Transfer entries from bridgelog
	my $xfer = $noonpos->{pos}->GetXfer();
	
	if ($xfer) {
		my $log = Eventlog::Log->new($noonpos->{db});
		my $rs = $log->get_science_noonpos_recs($xfer->{lognum}, @{ $xfer->{ids} });

		# Convert timestamps & add to remarks
		foreach my $r (@$rs) {
			$defaults->{remarks} .= strftime("%H:%M", gmtime($r->{time} + ($defaults->{timezone} * $SECS_PER_HOUR))) . 
				" " . $r->{comment} . "\n";
		}

		$noonpos->{pos}->ClearXfer();
	}
	
	if ($param_table->{form_error}) {
		$defaults = undef;
	} 

	my $vars = $noonpos->form_setup($active, $param_table, $defaults);
	$noonpos->form_error_setup($param_table, $vars);

	$vars->{$active . "_active"} = 'sel_active';
	$vars->{header_date} = strftime("%a %b %e %T %Y (%Z)", @ds);
	$vars->{header_time} = '';

	# Check if overwriting existing position
	if ($defaults && (split(/ /, $defaults->{datestamp}))[0] eq $today_date) {
		$vars->{overwrite_message} = [ 'dummy' ];
	} else {
		# Start remarks again
		$defaults->{remarks} = '' if ($defaults);
	}

	return $vars;
}

sub newpos {
	my ($noonpos, $param_table) = @_;
	my $type = $param_table->{type} || 'science';
	
	$noonpos->save_form_state($param_table, $type);
	$noonpos->form_clean_search($type);
	return (-1, []) if $noonpos->form_param_check($type);

	$noonpos->{pos}->Add($noonpos->{state}->{$type});

	$noonpos->delete_form_state($type);

	return 0;
}

sub newpos_addloc {
	my ($noonpos, $param_table) = @_;
	my $type = $param_table->{type} || 'science';

	$noonpos->save_form_state($param_table, $type);

	return 0;
}

sub addloc_setup {
	my ($noonpos, $param_table, $type) = @_;

	$noonpos->{db}->query("SELECT * FROM locations");
	
	my @ls = ();
	while ($noonpos->{db}->next_record()) {
		push(@ls, { id => $noonpos->{db}->f(0), value => $noonpos->{db}->f(1), desc => $noonpos->{db}->f(2) });
	}

	@ls = sort { $a->{desc} cmp $b->{desc} } @ls;

	return {
		header_date => strftime("%a %b %e %T %Y (%Z)", gmtime(time())),
		header_time => '',
		locs => \@ls,
		type => $type,
	};
}

sub add_location {
	my ($noonpos, $param_table) = @_;

	return 0 unless $param_table->{new_location};
	my $newloc = $param_table->{new_location};

	$noonpos->{db}->prepare("SELECT * FROM locations WHERE description=?");
	$noonpos->{db}->execute($newloc);
	return 0 if $noonpos->{db}->num_rows() > 0;

	$noonpos->{db}->query("SELECT MAX(value) FROM locations");
	$noonpos->{db}->next_record();
	my $value = $noonpos->{db}->f(0)+1;
	
	$noonpos->{db}->prepare("INSERT INTO locations VALUES(null, ?, ?)");
	$noonpos->{db}->execute($value, $newloc);
	return 0;
}

sub sel_science {
	my ($noonpos, $param_table) = @_;

	return 0;
}

sub sel_transit {
	my ($noonpos, $param_table) = @_;

	return 0;
}

sub bridgelog_ids_setup {
	my ($noonpos, $default) = @_;

	my $log = Eventlog::Log->new($noonpos->{db});

	my $ls = $log->list('science');

	if ($default) {
		foreach my $l (@$ls) {
			if ($l->{name} eq $default) {
				$l->{selected} = 'selected';
			}
		}
	}

	return $ls;
}

sub bridgelog_id_name {
	my ($noonpos, $id) = @_;

	my $log = Eventlog::Log->new($noonpos->{db});
	my $info = $log->log_info($id, 'science');

	return "Unknown Cruise" unless $info;

	return $info->{title};
}


sub get_latlon_display_value {
	my ($noonpos, $val) = @_;
	
	my @parts = split(/ /, $val);
	my $display = $val;
	
	if(@parts > 0) {
		$display = $parts[0]."&deg; ";		
		$display = $display.$parts[1]." " if(@parts > 1);		
		$display = $display.$parts[2]." " if(@parts > 2);
	}
	
	return $display;
}

1;
__END__



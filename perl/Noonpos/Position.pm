# JCR Noonpos Position Module
#
# v1.0 JPRO 01/02/2006 Initial Release
#

package Noonpos::Position;
use strict;

my $DEFAULT_TYPE = 'transit';

my @COMMON = qw(type lat lon bearing_true bearing_dist bearing_relative_id dest1_id eta1_date eta1_time eta1_spd 
				distance total_distance wind_dir wind_force sea_state air_temp sea_temp pressure tendancy remarks
				timezone);
my $SPECIFIC = {
	science => [ qw(bridgelog_id steam_time total_steam_time avg_spd total_avg_spd) ],
	transit => [ qw(cmg dest2_id eta2_date eta2_time eta2_spd steam_time total_steam_time avg_spd total_avg_spd) ],
};

sub new {
	my ($class, $db) = @_;

	my $pos = bless {
		db => $db,
	}, $class;

	return $pos;
}

# Add list of ids to xfer table for noonpos setup
sub add_to_xfer {
	my ($pos, $lognum, @ids) = @_;
	return unless $lognum;
	return unless scalar(@ids);

	$pos->{db}->query("INSERT INTO xfer VALUES($lognum, '" . join(":", @ids) . "')");
}

sub GetXfer {
	my $pos = shift;

	$pos->{db}->query("SELECT * from xfer");
	return undef unless $pos->{db}->num_rows() > 0;
	$pos->{db}->next_record();

	my @ids = split(":", $pos->{db}->f(1));

	return { lognum => $pos->{db}->f(0), ids => \@ids };
}

sub ClearXfer {
	my $pos = shift;

	$pos->{db}->query("DELETE FROM xfer");
}

# Insert Noonpos into database
# pi is hash of position information
sub Add {
	my ($pos, $pi) = @_;
	return undef unless $pi && (exists $SPECIFIC->{$pi->{type}});
	
	# Check for existing position today & remove
	my @ds = gmtime(time());
	my $today_date = sprintf("%04d-%02d-%02d", $ds[5]+1900, $ds[4]+1, $ds[3]);
	my $info = $pos->Get($today_date);
	
	if ((split(/ /, $info->{datestamp}))[0] eq $today_date) {
		$pos->Delete($info->{id});
	}

	my @cols = ();
	my @vals = ();
	my @holders = ();

	# Build up common fields & type specific fields
	foreach my $c (@COMMON, @{ $SPECIFIC->{$pi->{type}} }) {
		push(@cols, $c);
		push(@vals, $pi->{$c});
		push(@holders, '?');
	}

	$pos->{db}->prepare("INSERT INTO noonpos(id, datestamp, " . join(", ", @cols) . ") " .
						"VALUES(null, now(), " . join(", ", @holders) .  ")");
	$pos->{db}->execute(@vals);

	$pos->{db}->query("SELECT LAST_INSERT_ID()");
	$pos->{db}->next_record();

	return $pos->{db}->f(0);
}

sub Delete {
	my ($pos, $id) = @_;

	$pos->{db}->query("DELETE FROM noonpos WHERE id=$id LIMIT 1");
}

sub LastType {
	my $pos = shift;

	$pos->{db}->query("SELECT type FROM noonpos ORDER BY datestamp DESC LIMIT 1");

	if ($pos->{db}->num_rows() != 1) {
		return $DEFAULT_TYPE;
	}

	$pos->{db}->next_record();

	return $pos->{db}->f(0);
}

sub Get {
	my ($pos, $date) = @_;
	return $pos->GetLatest() unless $date && $date =~ /\d{4}-\d{2}-\d{2}/;

	$pos->{db}->query("SELECT id, type FROM noonpos WHERE datestamp LIKE '$date %'");
	if ($pos->{db}->num_rows() != 1) {
		return $pos->GetLatest();
	}

	$pos->{db}->next_record();

	return $pos->_info($pos->{db}->f(0), $pos->{db}->f(1));	
}

sub Next {
	my ($pos, $id) = @_;
	return undef unless $id;

	$pos->{db}->query("SELECT type, datestamp FROM noonpos WHERE id>$id ORDER BY id ASC LIMIT 1");
	if ($pos->{db}->num_rows() != 1) {
		return undef;
	}

	$pos->{db}->next_record();
	return { type => $pos->{db}->f(0), datestamp => $pos->{db}->f(1) };
}

sub Prev {
	my ($pos, $id) = @_;
	return undef unless $id;

	$pos->{db}->query("SELECT type, datestamp FROM noonpos WHERE id<$id ORDER BY id DESC LIMIT 1");
	if ($pos->{db}->num_rows() != 1) {
		return undef;
	}

	$pos->{db}->next_record();
	return { type => $pos->{db}->f(0), datestamp => $pos->{db}->f(1) };
}

sub GetLatest {
	my $pos = shift;

	$pos->{db}->query("SELECT id, type FROM noonpos ORDER BY datestamp DESC LIMIT 1");
	if ($pos->{db}->num_rows() != 1) {
		return undef;
	}

	$pos->{db}->next_record();

	return $pos->_info($pos->{db}->f(0), $pos->{db}->f(1));
}

sub _info {
	my ($pos, $id, $type) = @_;
	return undef unless $id && $type && exists($SPECIFIC->{$type});

	my @cols = ();
	foreach my $c (qw(id datestamp), @COMMON, @{ $SPECIFIC->{$type} }) {
		push(@cols, $c);
	}

	$pos->{db}->query("SELECT " . join(", ", @cols) . " FROM noonpos WHERE id=$id");
	$pos->{db}->next_record() && do {
		my $rec = {};
		my $i = 0;

		foreach my $c (qw(id datestamp), @COMMON, @{ $SPECIFIC->{$type} }) {
			$rec->{$c} = $pos->{db}->f($i++);
		}
		
		return $rec;
	};
	
	return undef;
}

1;
__END__

#!/usr/local/bin/perl -w
# Test Teschsas
#
# JPRO 22/05/2018
#

use strict;
use lib '/users/jpro/prog/bas/eventlog/perl';

use Eventlog::Data::TechSAS;

my $STREAM = 'GPS-Applanix_GPS_DY1-position';
my @VARS = qw(lat long time);
my $data   = Eventlog::Data::TechSAS->new();

#my @ss = $data->list_streams();

#my @ds = ();

#foreach (@ss) {
#	print STDERR "Stream [$_]\n";
#
#	eval { $data->attach($_); } or next;
#	push(@ds, { stream => $data->name(), vars => $data->vars() });
#	$data->detach();
#}

$data->attach($STREAM);

# Find record at 13:07:01 2018/01/09 
#my $rec = $data->find_time(1515503221);
#my $rec = $data->find_time(1527352300);
#my $rec = $data->find_time(1518354421);
my $rec = $data->find_time(1527669000);

if ($rec && $rec->{timestamp}) {
	print "Found record at $rec->{timestamp}\n";
} else {
	print "Could not find a record\n";
}

if ($rec) {
	my @ps = $data->get_vars_pos(@VARS);
	
	for (my $i=0; $i<scalar(@VARS); $i++) {
		print "Var: $VARS[$i], val: " . $rec->{vals}->[$ps[$i]] . "\n";
	}
}

$data->detach();

0;

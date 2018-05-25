#!/usr/local/bin/perl -w
# Test Teschsas
#
# JPRO 22/05/2018
#

use strict;
use lib '/users/jpro/prog/bas/eventlog/perl';

use Eventlog::Data::TechSAS;

#my $STREAM = 'AAVOS';
#my @VARS = qw(ws1 call rwd2);
#my $STREAM = 'POS-MV-gga';
#my @VARS = qw(time latitude longitude);
my $data   = Eventlog::Data::TechSAS->new();

my @ss = $data->list_streams();

my @ds = ();

foreach (@ss) {
	print STDERR "Stream [$_]\n";

	$data->attach($_);
	push(@ds, { stream => $data->name(), vars => $data->vars() });
	$data->detach($_);
}

#$data->attach($STREAM);

# Find record at 18:27:11 09/07/2017
# Should be $AVRTE,170709,182711,00490,CGDT,6.1,194,142,,,,994.85,,4.9,109,,,3.15,13.5,,51.6,41.2,13.6*48
#my $rec = $data->find_time(1499624831);

#if ($rec && $rec->{timestamp}) {
#	print "Found record at $rec->{timestamp}\n";
#} else {
#	print "Could not find a record\n";
#}

#my @ps = $data->get_vars_pos(@VARS);
#
#for (my $i=0; $i<scalar(@VARS); $i++) {
#	print "Var: $VARS[$i], val: " . $rec->{vals}->[$ps[$i]] . "\n";
#}

#$data->detach();

0;

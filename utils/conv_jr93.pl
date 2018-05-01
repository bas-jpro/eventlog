#!/nerc/packages/perl/5.8.0/bin/perl -w
# Convert v2 logsheets to v3 eventlogs
#
# v1.0 JPR 02/12/2003
#
# Specific to each logsheet
#

use strict;

use POSIX qw(strftime);
use XML::Simple;

use lib '/data/web/webapps/helpdesk/current/perl/helpdesk';
use DB;

my $DATABASE = 'eventlog';

my $dbinfo = {
	host   => 'localhost',
	user   => '',
	passwd => '',
};

if (scalar(@ARGV) != 1) {
	die "Usage: $0 logsheet.xml\n";
}

my $db = DB->new($DATABASE, $dbinfo);

my $logsheet = XMLin($ARGV[0], forcearray => ['sheet']);

# Events
foreach my $event (@{ $logsheet->{event} }) {
	my @vals = ();

	push(@vals, strftime("%Y%m%d%H%M%S", gmtime($event->{tstamp})), $event->{lat}, $event->{lon}, $event->{sst}, 
		 $event->{sal}, $event->{line_num}, $event->{stcm_ok}, $event->{uncdepth}, $event->{cendepth}, $event->{comment});

	$db->prepare("INSERT INTO log_1 VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
	$db->execute(@vals);
}

# Comments
foreach my $comment (@{ $logsheet->{comment} }) {
	my @vals = ();

	push(@vals, strftime("%Y%m%d%H%M%S", gmtime($comment->{tstamp})), $comment->{comment});

	$db->prepare("INSERT INTO comment_log_1 VALUES(?, ?)");
	$db->execute(@vals);
}

0;

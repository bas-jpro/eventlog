#!/usr/local/bin/perl -w
# Lists / deletes eventlog
# 
# $Id$
#

use strict;
use XML::Simple;
use lib '/data/web/webapps/controller/current/perl';
use Apache::Controller::DB;
use lib '/data/web/webapps/eventlog/current/perl';
use Eventlog::Log;

my $CONF = '/data/web/webapps/eventlog/current/data/eventlog.xml';

my $conf = XMLin($CONF);
my $db = Apache::Controller::DB->new($conf->{db}->{name}, $conf->{db});

die "Usage: $0 list | del <lognum> | list_col <lognum> | mod_col <lognum> <colnum> <col string> | add_col <lognum> <col string> | " .
	"list_bridge <lognum> | check_bridgelog <lognum>\n" unless scalar(@ARGV) >= 1;

my $cmd = $ARGV[0];

my $log = Eventlog::Log->new($db);

if ($cmd eq 'list') {
	# List eventlogs
	my $ls = $log->list('event');

	foreach my $l (sort { $a->{lognum} <=> $b->{lognum} } @$ls) {
		print $l->{lognum} . ': ' . $l->{name} . ' (' . $l->{sciencelog_title} . ")\n";
	}

	exit(0);
}

if ($cmd eq 'list_bridge') {
	# List bridge/science logs
	my $ls = $log->list('science');

	foreach my $l (sort { $a->{lognum} <=> $b->{lognum} } @$ls) {
		print $l->{lognum} . ': ' . $l->{name} . ' (' . $l->{title} . ")\n";
	}

	exit(0);
}

if ($cmd eq 'del') {
	if (scalar(@ARGV) != 2) {
		die "Usage: $0 del <lognum>\n";
	}

	if ($ARGV[1] !~ /^\d+$/) {
		die "$0 del invalid lognum [$ARGV[1]]\n";
	}

	print "Deleting log $ARGV[1] - ";
	if ($log->del_log($ARGV[1], 'event')) {
		print "done\n";
	} else {
		print "failed\n";
	}

	exit(0);
}

if ($cmd eq 'list_col') {
	if (scalar(@ARGV) != 2) {
		die "Usage: $0 list_col <lognum>\n";
	}

	if ($ARGV[1] !~ /^\d+$/) {
		die "$0 list_col invalid lognum [$ARGV[1]]\n";
	}
	my $lognum = $ARGV[1];

	my $info = $log->log_info($lognum);
	die "$0 list_col invalid lognum [$lognum]\n" unless $info;

	print "Log $lognum, " . $info->{name} . "\n";
	print "\tOwner: " . $info->{owner} . "\n";
	for (my $i=0; $i<$info->{num_cols}; $i++) {
		print "\tColumn $i:\t" . $info->{cols}->[$i] . "\n";
	}
	print "\n";

	exit(0);
}

if ($cmd eq 'mod_col') {
	if (scalar(@ARGV) != 4) {
		die "Usage: $0 mod_col <lognum> <colnum> <col string>\n";
	}

	if ($ARGV[1] !~ /^\d+$/) {
		die "$0 mod_col invalid lognum [$ARGV[1]]\n";
	}
	my $lognum = $ARGV[1];

	my $info = $log->log_info($lognum);
	die "$0 mod_col invalid lognum [$lognum]\n" unless $info;

	if ($ARGV[2] !~ /^\d+$/) {
		die "$0 mod_col invalid colnum [$ARGV[2]]\n";
	}
	my $colnum = $ARGV[2];

	if ($ARGV[3] =~ /,/) {
		die "$0 mod_col invalid column description [$ARGV[3]]\n";
	}
	
	my ($inst, $var, $desc) = (split(":", $ARGV[3]));
	if (!$inst || !$var || !$desc) {
		die "$0 mod_col invalid column description [$ARGV[3]]\n";
	}

	print "Modifying column $colnum to $ARGV[3] - ";
	if ($log->modify_column($lognum, $colnum, $ARGV[3])) {
		print "done\n";
	} else {
		print "failed\n";
	}
	
	exit(0);
}

if ($cmd eq 'add_col') {
	if (scalar(@ARGV) != 3) {
		die "Usage: $0 add_col <lognum> <column desc>\n";
	}

	if ($ARGV[1] !~ /^\d+$/) {
		die "$0 add_col invalid lognum [$ARGV[1]]\n";
	}
	my $lognum = $ARGV[1];

	if ($ARGV[2] =~ /,/) {
		die "$0 add_col invalid column description [$ARGV[2]]\n";
	}
	
	my ($inst, $var, $desc) = (split(":", $ARGV[2]));
	if (!$inst || !$var || !$desc) {
		die "$0 add_col invalid column description [$ARGV[2]]\n";
	}

	print "Adding column [$ARGV[2]] to lognum $ARGV[1] - ";
	if ($log->add_column($lognum, $ARGV[2])) {
		print "done\n";
	} else {
		print "failed\n";
	}

	exit(0);
}

if ($cmd eq 'del_rec') {
	# FIXME: Need to distinguish between science & event logs
	
#	if ($ARGV[1] !~ /^\d+$/) {
#		die "$0 del_rec invalid lognum [$ARGV[1]]\n";
#	}
#	my $lognum = $ARGV[1];
#
#	if ($ARGV[2] =~ /^\d+$/) {
#		die "$0 dec_rec invalid recnum [$ARGV[2]]\n";
#	}
#	my $recnum = $ARGV[2];
#
#	print "Deleting record $recnum from log $lognum - ";
#	if ($log->del_rec($lognum, $recnum)) {
#		print "done\n";
#	} else {
#		print "failed\n";
#	}
}

die "$0: invalid command [$cmd]\n";

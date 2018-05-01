#!/usr/local/bin/perl -w
# Creates mysqldump of eventlog.
#
# v1.0 DACON 06/12/2012
# v1.1 JPRO  13/03/2014 Modified for new JRLC
#
# Reads eventlog configuration and backs up the eventlog database to the 
# cruise web directory. This will bring back the cruise log with each separate 
# leg.
#
# The script compares the new backup against the last backup with CKSUM and 
# doesn't create a new file if they are the same. Only changes to the database 
# will create new files.
#

use strict;

use POSIX qw(strftime);
use XML::Simple;
use Data::Dumper;

my $MYSQLDUMP = '/packages/mysql/current/bin/mysqldump';
my $DATABASE = 'eventlog';

if (scalar(@ARGV) != 1) {
	die "Usage: $0 eventlog.xml\n";
}

# XML configuration for eventlog - we want DB properties
my $logsheet = XMLin($ARGV[0], forcearray => ['sheet']);

# Storage for later variables
my $cmd;
my $cksum;
my $cksum_previous = 0;

# Backup path
my $path = "/data/cruise/jcr/current/web/eventlog/";

# Check if output path exists. If it doesn't create it.
if(not -e $path) {
    my $cmd = "mkdir ".$path;
    my $out = `$cmd`;
	
    if(not -e $path) {
        print "Backup path does not exist and could not be created.\n";    
		exit(-1);
    }
}

# Step 1: Get previous backup filename and cksum

# Get list of files ordered by modified date descending
my @files =  sort { -M $a <=> -M $b } 
	  grep { -f } 
	  glob("$path/*");

# Get cksum of first entry (if it exists!)
if(@files > 0) {
    $cmd = "cksum ".$files[0];
    $cksum = `$cmd`;
    
    my @cksum_split = split(' ', $cksum);
    
    # This will be compared to the newly created archive later
    $cksum_previous = $cksum_split[0];
    
}

# Step 2: Create current mysqldump
my $archive_time = time();
my $filename = "eventlog.".$archive_time.".sql.bz2";

# Mysql dump command - using XML parameters
$cmd = "$MYSQLDUMP -h ".$logsheet->{db}->{host}." -u ".$logsheet->{db}->{user}." --lock-tables=FALSE --compress=TRUE --compact=TRUE --password=".$logsheet->{db}->{passwd}." ".$logsheet->{db}->{name}." | bzip2 > ".$path.$filename;
my $output = `$cmd`;

# Step 3: Compare files and decide what to do with file.
# Compare cksum results

if(@files > 0) {
    $cmd = "cksum ".$path.$filename ;
    $cksum = `$cmd`;
    my @cksum_split = split(' ', $cksum);
    
    # Checksums are the same, get rid of the new backup.
    if($cksum_previous ==$cksum_split[0]) {
        $cmd = "rm -f ".$path.$filename;
        $output = `$cmd`;
    }
}

0;

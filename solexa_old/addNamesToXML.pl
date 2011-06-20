#!/usr/bin/env perl

# The program is called with arg of Summary.xml. It puts sample names into Summary.xml based on fcid entered at command line and call to ngslims. 
# Madelaine Gogol
# 3/2011

use lib "/qcdata/SIMR_pipeline_scripts";
use warnings; 
use strict;
use Getopt::Long;
use NGSQuery;

my ($results,$fcid,$dbh,$sth,@lines);

my ($verbose, $help);

my $result = GetOptions("verbose" => \$verbose,
								"help" => \$help);

usage() if $help;
usage() if (@ARGV == 0);

sub usage
{
	print "usage: addNamesToXML.pl [-v] [-h] [/path/to/file.xml] [FLOW_CELL_ID]\n";
	print "\n";
	print "/path/to/file.xml     Provide the path to the xml file you want to modify.\n";
	print "                      This field is required.\n";
	print "\n";
	print "FLOW_CELL_ID          Flow cell ID of the current analysis. If this is not\n";
	print "                      provided, the flow cell ID will be extracted from\n";
	print "                      the .xml file.\n";
	print "\n";
	print "-v                    Verbose flag\n";
	print "\n";
	print "-h                    Print this message then exits\n";
	print "\n";
	exit;
}

my $contents = get_file_data($ARGV[0]);

$fcid = $ARGV[1];

@lines = split("\n",$contents);
my $samples = 0;
my $i = 0;

unless(open (OUT, ">$ARGV[0]")) 
{ 
warn "Failed to open $ARGV[0]: $!"; return undef; 
} 


my @samplenames = (1,2,3,4,5,6,7,8);

foreach my $line (@lines)
{
	if($line =~ /<RunFolder/)
	{

		if(! $fcid)
		{
			print "Acquiring Flowcell ID from Summary.xml\n" if $verbose;
			$fcid = $line;
			$fcid =~ s/^.*_//g;
			$fcid =~ s/<.*$//g;
			print "Flowcell ID : $fcid\n" if $verbose;
		}

		$results = ngsquery('fc_lane_library_samples', $fcid);
		@samplenames = ();
		for my $item (@$results)
		{
			push(@samplenames,$item->[3]);
		}
	}

	if($line =~ /<sample/)
	{
		if($samplenames[$i])
		{
			$line = "\t\t<sample>$samplenames[$i]</sample>";
		}
		else
		{
			$line = "\t\t<sample></sample>";
		}
		$i++;
		$samples++;
	}
	print OUT "$line\n";
}


######################################################    
# subroutine get_file_data
# arguments: filename
# purpose: gets data from file given filename;
# returns file contents
######################################################

sub get_file_data
{
        my($filename) = @_;

        my @filedata = ();

        unless( open(GET_FILE_DATA, $filename))
        {
                print STDERR "Cannot open file \"$filename\": $!\n\n";
                exit;
        }
        @filedata = <GET_FILE_DATA>;
        close GET_FILE_DATA;
        return join('',@filedata);
}

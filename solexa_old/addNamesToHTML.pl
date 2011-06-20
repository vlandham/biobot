#!/usr/bin/env perl


# The program is called with arg of Summary.htm. It puts sample names into Summary.htm based on fcid from Summary.htm and call to ngslims. 
# Madelaine Gogol
# 9/2010

use warnings; 
use strict;
use DBI;
use SQL::Library;

my ($results,$fcid,$dbh,$sth,@lines);


my $contents = get_file_data($ARGV[0]);

@lines = split("\n",$contents);
my $tables = 0;
my $tr = 0;
my $td = 0;
my $i=0;
my $fcnext = 'false';

unless(open (OUT, ">$ARGV[0]")) 
{ 
warn "Failed to open $ARGV[0]: $!"; return undef; 
} 


my @samplenames = (1,2,3,4,5,6,7,8);

foreach my $line (@lines)
{
	if($fcnext eq "true")
	{
		$fcid = $line;
		$fcid =~ s/^.*_//g;
		$fcid =~ s/<.*$//g;
		$fcnext = "false";
		$dbh = DBI->connect('dbi:mysql:database=ngslims;host=ngslims',  'webuser', 'welcome323',   { RaiseError => 1, AutoCommit => 0 }) || die "could not connect to ngslims"; 
		$sth = $dbh->prepare(SQL::Library->new({lib => qq{/qcdata/SIMR_pipeline_scripts/qrylib.sql}})->retr(qq{fc_lane_library_samples})); 
		$results = $dbh->selectall_arrayref($sth,{},$fcid);
		@samplenames = ();
		for my $item (@$results)
		{
			push(@samplenames,$item->[3]);
		}
	}

	if($line =~ /<td>Run Folder/)
	{
		$fcnext = "true";
	}

	if($line =~ /<table/)
	{
		$tr = 0;
		$tables++;
	}
	if($tables == 3)
	{
		if($line =~ /<tr>/)
		{
			$td = 0;
			$tr++;
		}
		if($tr >= 2 and $tr < 10)
		{
			if($line =~ /<td/)
			{
				$td++;
			}
			if($td == 2)
			{
				if($samplenames[$i])
				{
					$line = "<td>$samplenames[$i]</td>";
				}
				else
				{
					$line = "<td></td>";
				}
				$i++;
			}
		}
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

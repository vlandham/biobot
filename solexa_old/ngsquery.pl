#! /usr/bin/env perl
use lib "/qcdata/SIMR_pipeline_scripts";
use strict;
use warnings;
use NGSQuery;

my $query = $ARGV[0];
my $fcid = $ARGV[1];

my $results = ngsquery($query, $fcid);
foreach my $row (@$results)
{
	foreach my $col (@$row)
	{
		print $col . "\t";
	}
	print  "\n";
}

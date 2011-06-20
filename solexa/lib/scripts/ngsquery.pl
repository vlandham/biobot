#! /usr/bin/env perl
use File::Basename;
use lib dirname($0);
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

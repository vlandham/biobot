package NGSQuery;

use strict;
use DBI;
use SQL::Library;
use Exporter;

our @ISA = qw( Exporter );

our @EXPORT_OK = qw( ngsquery );
our @EXPORT = qw( ngsquery );

sub ngsquery
{
	my $query_name = shift;
	my $query_value = shift;

	#get sample names from ngslims
	my $dbh = DBI->connect('dbi:mysql:database=ngslims;host=ngslims',  'webuser', 'welcome323',   { RaiseError => 1, AutoCommit => 0 }) || die "could not connect to ngslims";
	my $sth = $dbh->prepare(SQL::Library->new({lib => qq{/qcdata/SIMR_pipeline_scripts/qrylib.sql}})->retr($query_name));
	my $results = $dbh->selectall_arrayref($sth,{},$query_value);
	$dbh->disconnect();
	return $results;
}

1;

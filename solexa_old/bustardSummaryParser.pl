#!/usr/bin/env perl
# The program is called using directory name

use warnings; 
use strict;
use Cwd;
use XML::Simple;
use File::Basename;
use File::Spec;
use Data::Dumper;
open(problemTilesFile, ">problemTiles.tsv");
open(allTilesFile, ">allTiles.tsv");

if (@ARGV < 2){
	die "usage: $0 bustardDir minPF";
}

my $xml = new XML::Simple();
my $xmlData;

sub info
{
    my $message = shift @_;
    print STDERR "Info: ", basename($0), $message, "\n";
}

# Following line enables you to do e.g. "jerboa.pl ."
$ARGV[0]=File::Spec->rel2abs($ARGV[0]);

## Check to see if directory names ends with '/'
if($ARGV[0] !~ m/\/$/){
    $ARGV[0] = $ARGV[0]."/";
}

my $summaryFile=File::Spec->catdir($ARGV[0], "BustardSummary.xml");
my (%xmlData,%laneTileResults)= ();
my $min = $ARGV[1];

my $header = "Lane\tTile\tPF_percent ( < $min % )\n";
if(defined($xmlData=readFileXML($summaryFile)))
{
    print allTilesFile $header;
    print problemTilesFile $header;
    info(": found summary file $summaryFile, trying to parse");
	if (defined($xmlData->{TileResultsByLane})) {
		for(my $lane =1;$lane< 9;$lane++){
			for(my $tile=1;$tile<101;$tile++){
				my $pfPercent = 0;
				my @readRef = ();
				if (ref($xmlData->{TileResultsByLane}->{Lane}[$lane-1]->{Read}) eq 'ARRAY'){
					@readRef = @{$xmlData->{TileResultsByLane}->{Lane}[$lane-1]->{Read}};
					$pfPercent = $readRef[0]->{Tile}[$tile-1]->{percentClustersPF};
				}
				elsif (exists($xmlData->{TileResultsByLane}->{Lane}[$lane-1]->{Read}->{Tile}[$tile-1]->{percentClustersPF})){
					$pfPercent = $xmlData->{TileResultsByLane}->{Lane}[$lane-1]->{Read}->{Tile}[$tile-1]->{percentClustersPF};
				}
				print allTilesFile "$lane\t$tile\t$pfPercent\n";
				if ($pfPercent < $min){
					print problemTilesFile "$lane\t$tile\t$pfPercent\n";
				}
			}	
		}
	}
}
close(allTilesFile);
close(problemTilesFile);
my $cmd =  "R CMD BATCH --vanilla --slave /qcdata/SIMR_pipeline_scripts/bustardSummaryParser.r";
print "$cmd\n";
`$cmd`;

# Read XML file into a hash. Return 1 if successfully completed
# Check for zero padding at end of file
sub readFileXML
{
    my ($fileName)=@_;
    return undef unless (-f $fileName);
    unless(open (FILE, $fileName)) 
    { 
	warn "Failed to open $fileName: $!"; return undef; 
    } 
    my $text="";
    while (<FILE>)
    {
	$text.=$_;
    } # while
    close (FILE);

    my $l=length($text);

    while (($l!=0)&&(substr($text,$l-1,1) eq "\0"))
    {
	$l--;
    } # while

    if ($l==0)
    {
	warn "file $fileName seems to be completely blank";
	return undef;
    } # if   

    $text=substr($text,0,$l) unless ($l==length($text));

    my $data = $xml->XMLin($text);

    return $data;
} # sub readFileXML

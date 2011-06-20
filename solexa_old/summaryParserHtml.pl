#!/usr/bin/env perl


# The program is called using directory name

use warnings; 
use strict;
use Cwd;
use XML::Simple;
use File::Basename;
use File::Spec;
use Data::Dumper;
my @line =();
my @laneData = ();	

my $maxNumLanes=8;

my $xml = new XML::Simple();
my $xmlData;
my $machineName;

sub info
{
    my $message = shift @_;
    print STDERR "Info: ", basename($0), $message, "\n";
}


my $cmd = "sed -e 's/<hr>\$//' Summary.htm | sed -e '/<p><font size=\"-2\">CASAVA-1.6.0<\\/font><\\/p>\$/d' > tmp";
print STDERR "$cmd\n";
`$cmd`;

# Following line enables you to do e.g. "jerboa.pl ."
$ARGV[0]=File::Spec->rel2abs($ARGV[0]);

## Check to see if directory names ends with '/'
if($ARGV[0] !~ m/\/$/){
    $ARGV[0] = $ARGV[0]."/";
}

#my $summaryFile=File::Spec->catdir($ARGV[0], "Summary.htm");
my $summaryFile=File::Spec->catdir($ARGV[0], "tmp");
print STDERR Dumper($summaryFile);

if(defined($xmlData=readFileXML($summaryFile)))
{
    info(": found summary file $summaryFile, trying to parse");
    #print Dumper($xmlData); 
    if (defined($xmlData->{body}->{table})) {
	my $runFolder = $xmlData->{body}->{table}[0]->{tr}[1]->{td}[1];
	my @runFolder = split("_",$runFolder);
	print "Run Date: " . $runFolder[0] . "\n";
	print "Machine Name: " . $runFolder[1] . "\n";
	my $fcID= $runFolder[-1]; 
	print "FC: $fcID\n";
	#print header 
	print "Lane,Sample,Reference,Read Length,Tiles,Reads Per Tile,\%PF,\%Align (PF),Error Rate,Yield (kb)\n";
	#print "Lane,Sample,Reference,Read Length,Tiles,Reads Per Tile,\%PF,\%Align (PF),Error Rate,Yield (kb)\n";
	for (my $i=0;$i < $maxNumLanes;$i++){
	$laneData[$i]=
	#Lane Number
	$xmlData->{body}->{table}[2]->{tr}[$i+1]->{td}[0] . "," .
	#Sample Name
	$xmlData->{body}->{table}[2]->{tr}[$i+1]->{td}[1] . "," .
	#Ref Genome
	$xmlData->{body}->{table}[2]->{tr}[$i+1]->{td}[2] . "," .
	#Read Length
	$xmlData->{body}->{table}[2]->{tr}[$i+1]->{td}[4] . "," .
	#Filter
	#$xmlData->{body}->{table}[2]->{tr}[$i+1]->{td}[5] . "," .
	#Num Tiles
	$xmlData->{body}->{table}[2]->{tr}[$i+1]->{td}[7] .",".
	#Reads (raw)
	$xmlData->{body}->{table}[3]->{tr}[$i+2]->{td}[3] . "," .
	#%PF
	$xmlData->{body}->{table}[3]->{tr}[$i+2]->{td}[6] . "," .
	#%Align PF
	$xmlData->{body}->{table}[3]->{tr}[$i+2]->{td}[7] . "," .
	#Error Rate
	$xmlData->{body}->{table}[3]->{tr}[$i+2]->{td}[9] . "," .
	#Lane Yield
	$xmlData->{body}->{table}[3]->{tr}[$i+2]->{td}[1]; 
	info("lane ". ($i+1) . " data: " . $laneData[$i]);
	}
	}
	#print Dumper(@laneData);
}

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

#my $avgQ = 0;
for (my $i =0;$i<$maxNumLanes;$i++){
	#my $cnt = 0;
	#my %quals = ();
	#my $seqFile =$ARGV[0] . "/s_" . ($i+1) . "_sequence.txt";
	#my $numLines = `wc -l $seqFile | cut -f 1 -d ' '`;
	#chomp($numLines);
	#if (-e $seqFile && $numLines > 0){
	#	info("lane " . ($i+1));
		#get only the qual vals from sequence file
	#	`sed -n '0~4p' $seqFile > seq.tmp`;
	#	open(seqFile,"seq.tmp");
	#	while(<seqFile>){
	#		chomp();
	#		@line = split("",$_);
	#		for (my $j =0;$j < @line;$j++){
	#			$cnt++;
	#			$quals{$line[$j]}++;
	#		}
	#	}
	#	my $total =0;
	#	foreach my $key (keys %quals){
	#		#$total += 10*(log(1+10 ** (ord($key) -64)/10.0)/log(10))*($quals{$key});	
	#		$total += (log(1+10 ** (ord($key) -64)/10.0)/log(10))*($quals{$key});	
	#	}
	#	$avgQ = $total/$cnt;
	#	#$laneData[$i] .= $avgQ;	
	#	print $laneData[$i].",".$avgQ."\n";
		#print $laneData[$i].",0\n";
		print "$laneData[$i]\n";
	#}
}
`rm -f tmp`;

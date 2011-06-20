#!/usr/bin/env perl


# The program is called using full path to Summary.xml (including Summary.xml).

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





# Following line enables you to do e.g. "jerboa.pl ."
$ARGV[0]=File::Spec->rel2abs($ARGV[0]);


## Check to see if directory names ends with '/'
if($ARGV[0] !~ m/\/$/){
    $ARGV[0] = $ARGV[0]."/";
}

my $summaryFile=File::Spec->catdir($ARGV[0]);

#my %globalMeta = ("Run Date","Date","Software","Software","Machine Name","Machine",");
my %globalMeta = ("Software:","Software");
if(defined($xmlData=readFileXML($summaryFile)))
{
    info(": found summary file $summaryFile, trying to parse");
    #print Dumper($xmlData); 
	my $runFolder = $xmlData->{ChipSummary}->{RunFolder};
	my @runFolder = split("_",$runFolder);
	my $fcID= $runFolder[-1]; 
	print "Run Date:" . $runFolder[0] . "\n";	
	print "Machine Name:" . $runFolder[1] . "\n";	
	print "FC:" . $runFolder[-1] . "\n";
    	foreach my $key (keys %globalMeta){
		if (exists($xmlData->{$globalMeta{$key}})){
    			print "$key" . $xmlData->{$globalMeta{$key}} . "\n"; 
		}
	}
	#print Dumper($xmlData->{LaneParameterSummary});
	print "Lane,Sample,Reference,Read Length,Tiles,Reads Per Tile,\%PF,\%Align (PF),Error Rate,Yield (kb)\n";
	for (my $i=0;$i < $maxNumLanes;$i++){
		$laneData[$i]=
		#Lane Number
		($i+1) . "," .
		$xmlData->{LaneParameterSummary}->{Lane}[$i]->{sample} . "," . 
		$xmlData->{LaneParameterSummary}->{Lane}[$i]->{template} . "," . 
		$xmlData->{LaneParameterSummary}->{Lane}[$i]->{originalReadLength} . "," . 
		$xmlData->{LaneParameterSummary}->{Lane}[$i]->{tileCountRaw} . ",";  
		if (ref($xmlData->{LaneResultsSummary}->{Read}) eq 'ARRAY'){
			my $clusterCountRawMean = "";
			my $percenClustersPFMean = "";
			my $percentUniquelyAlignedPFMean = "";
			my $errorPFMean = "";
			my $laneYield = "";
			my $sep = "";
			foreach my $readRef (@{$xmlData->{LaneResultsSummary}->{Read}}){
				#print Dumper($readRef);
				#print "readRef here\n";
				$clusterCountRawMean .= $sep;
				$percenClustersPFMean .= $sep;
				$percentUniquelyAlignedPFMean .= $sep;
				$errorPFMean .= $sep;
				$laneYield .= $sep; 
				if (exists($readRef->{Lane}[$i]->{clusterCountRaw}->{mean})){
					$clusterCountRawMean .= $readRef->{Lane}[$i]->{clusterCountRaw}->{mean};
				}
				if(exists($readRef->{Lane}[$i]->{percentClustersPF}->{mean})){
					$percenClustersPFMean .= $readRef->{Lane}[$i]->{percentClustersPF}->{mean};
				}
				if(exists($readRef->{Lane}[$i]->{percentUniquelyAlignedPF}->{mean})){
					$percentUniquelyAlignedPFMean .= $readRef->{Lane}[$i]->{percentUniquelyAlignedPF}->{mean};
				} 
				if(exists($readRef->{Lane}[$i]->{errorPF}->{mean})){
					$errorPFMean .= $readRef->{Lane}[$i]->{errorPF}->{mean};
				}
				if(exists($readRef->{Lane}[$i]->{laneYield})){
					$laneYield .= $readRef->{Lane}[$i]->{laneYield}; 
				}
				$sep = ";";
			}
			$laneData[$i] .= join(",",$clusterCountRawMean,$percenClustersPFMean,$percentUniquelyAlignedPFMean,$errorPFMean,$laneYield);
		}
		else{
			if (	
			exists($xmlData->{LaneResultsSummary}->{Read}->{Lane}[$i]->{clusterCountRaw}->{mean}) && 
			exists($xmlData->{LaneResultsSummary}->{Read}->{Lane}[$i]->{percentClustersPF}->{mean}) &&
			exists($xmlData->{LaneResultsSummary}->{Read}->{Lane}[$i]->{percentUniquelyAlignedPF}->{mean}) && 
			exists($xmlData->{LaneResultsSummary}->{Read}->{Lane}[$i]->{errorPF}->{mean}) &&
			exists ($xmlData->{LaneResultsSummary}->{Read}->{Lane}[$i]->{laneYield})){
					$laneData[$i] = join(",",$laneData[$i],
					$xmlData->{LaneResultsSummary}->{Read}->{Lane}[$i]->{clusterCountRaw}->{mean},
					$xmlData->{LaneResultsSummary}->{Read}->{Lane}[$i]->{percentClustersPF}->{mean},	
					$xmlData->{LaneResultsSummary}->{Read}->{Lane}[$i]->{percentUniquelyAlignedPF}->{mean},
					$xmlData->{LaneResultsSummary}->{Read}->{Lane}[$i]->{errorPF}->{mean},
					$xmlData->{LaneResultsSummary}->{Read}->{Lane}[$i]->{laneYield})
			}
			else{
				$laneData[$i] .= ",0,0,0,0,0";
			}
			info("lane ". ($i+1) . " data: " . $laneData[$i]);
		}
		#print Dumper(@laneData);
	}
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

my $avgQ = 0;
for (my $i =0;$i<$maxNumLanes;$i++){
#	my $cnt = 0;
#	my %quals = ();
#	my $seqFile =$ARGV[0] . "/s_" . ($i+1) . "*_sequence.txt";
#	my $cmd = "ls -l ". $ARGV[0] . "/s_" . ($i+1) . "*_sequence.txt";
#	my @seqFiles = split("\n",`$cmd`);
#	print STDERR Dumper(@seqFiles);
#	my $numLines = `wc -l $seqFile | cut -f 1 -d ' '`;
#	chomp($numLines);
#	if (-e $seqFile && $numLines > 0){
#		info("lane " . ($i+1));
#		#get only the qual vals from sequence file
#		`sed -n '0~4p' $seqFile > seq.tmp`;
#		open(seqFile,"seq.tmp");
#		while(<seqFile>){
#			chomp();
#			@line = split("",$_);
#			for (my $j =0;$j < @line;$j++){
#				$cnt++;
#				$quals{$line[$j]}++;
#			}
#		}
#		my $total =0;
#		foreach my $key (keys %quals){
#			#$total += 10*(log(1+10 ** (ord($key) -64)/10.0)/log(10))*($quals{$key});	
#			$total += (log(1+10 ** (ord($key) -64)/10.0)/log(10))*($quals{$key});	
#		}
#		$avgQ = $total/$cnt;
#		#$laneData[$i] .= $avgQ;	
#		info("avg qual for lane " . ($i+1) . " is " . $avgQ . " total is $total and count is $cnt");
#	}
#	print $laneData[$i].",".$avgQ."\n";
	print $laneData[$i] . "\n";
}

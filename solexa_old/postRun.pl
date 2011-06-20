#! /usr/bin/env perl 

use lib "/qcdata/SIMR_pipeline_scripts";
use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use Benchmark;
use NGSQuery;

my $scripts_dir = "/qcdata/SIMR_pipeline_scripts";

my $min_pf = 80;
my @emails = ("jfv\@stowers.org", "vlandham\@gmail.com");
my ($no_lims, $verbose, $help, $man);

my $opt_result = GetOptions( "minpf=i" => \$min_pf, #integer
									  "nolims" => \$no_lims, #bool
									  "verbose" => \$verbose, #bool
									  "help" => \$help, 
									  "man" => \$man ) or pod2usage(2); # bool


my ($fcid, $out_dir_string, $lane_sets);
($fcid, $out_dir_string, $lane_sets) = @ARGV;

pod2usage(1) if $help;
pod2usage(-verbose => 2) if $man;

if ((! @ARGV) || (! $no_lims))
{
	print "Querying NGS LIMS for data" if $verbose;
	my $pwd = `pwd`;
	chomp $pwd;
	my $summaryXML = "$pwd/Summary.xml";
	my $perlProg = 'next unless m/<RunFolder>(.*)<\/RunFolder>/; $_ = pop @{[split(qq{_}, qq{$1})]}; s/^FC//; print; close ARGV';
	$fcid = qx{perl -n -e \'$perlProg\' "$summaryXML"} || die "can not determine flowcell ID from: $summaryXML";
	print "Flowcell ID: $fcid\n" if $verbose; 

	my $results = ngsquery('fc_postRunArgs', $fcid);

	$out_dir_string = $$results[0][0]; 
	$lane_sets = $$results[0][1];
} 
elsif (@ARGV < 4) 
{
	die "usage: $0 flow_cell_id out_dirs(':' separated) lane_sets(':' and ',' separated) )\nUse --help flag for more information.\n";
}

# assumption is this will be called in the GERALD directory? 
my $cwd = `pwd`;

my @dirs = split('/',$cwd);
my $baseCallBranchLevel = $#dirs-1;
my $baseCallDirPath = join("/",@dirs[0..$baseCallBranchLevel]);

my $geraldBranchLevel = $#dirs;
my $geraldDir = join("/",@dirs[2..$geraldBranchLevel]); #after run dir
chomp($geraldDir);
print "Gerald Dir: " . $geraldDir . "\n" if $verbose;

my $pre_run_log_name = "start_dir_info.txt";
open(PRE_RUN_LOG,">$pre_run_log_name");
my $ls = `ls -ltrh $cwd`;
print PRE_RUN_LOG "$ls";
print PRE_RUN_LOG "\n\n";
close(PRE_RUN_LOG);

mail_file( "postRun_starting", $pre_run_log_name);

my $runDir = $dirs[2];

open(POST_RUN_LOG,">>postRun.log");
my $total_start = new Benchmark;

my @lane_sets = split(":",$lane_sets);
my @out_dirs = split(":",$out_dir_string);
print POST_RUN_LOG "numOutDirs " . scalar(@out_dirs) . "\n";

execute("perl $scripts_dir/fastqc.pl -v --auto-out $fcid");

execute("md5sum *sequence.txt >> md5sums.txt");
execute("md5sum *export.txt >> md5sums.txt");

#generate tile graphs and list following below threshold of min_pf
execute("$scripts_dir/bustardSummaryParser.pl $baseCallDirPath $min_pf");

#generate summary report
execute("wkhtmltopdf ../IVC.htm ../IVC.pdf");

execute("cp Summary.xml Summary.xml.bak");

execute("$scripts_dir/addNamesToXML.pl -v ./Summary.xml");

execute("cp Summary.htm Summary.htm.bak");

execute("$scripts_dir/addNamesToHTML.pl ./Summary.htm");

execute("$scripts_dir/summaryParserXML.pl ./Summary.xml > runReport.csv");

for(my $i = 0; $i < scalar(@out_dirs); $i++)
{
	my $outDir = $out_dirs[$i];
	unless (-d $outDir)
	{
		execute("mkdir -p $outDir");
	}
	my @lanes = split(",",$lane_sets[$i]);
	print POST_RUN_LOG "numLanes " . scalar(@lanes) . "\n";

	#do md5sums, copy to out dir. Should automate the md5sum -c step too.
	execute("cp md5sums.txt $outDir");

	if($outDir =~ /Blanchette/ or $outDir =~ /Zeitlinger/)
	{
		foreach my $lane(@lanes)
		{
			#* added so as to include the paired end data if exists
			execute("cp -v -f s_" . $lane . "*" . "_export.txt $outDir");
			
			execute("cp -v -f s_" . $lane . "*" . "_sequence.txt $outDir");
			
			execute("gzip $outDir/s_*.txt"); #copy and then gzip is not ideal, but it's easy. This could be streamlined. 
			
		}
	}
	else
	{
		foreach my $lane(@lanes)
		{
			#* added so as to include the paired end data if exists
			execute("cp -v -f s_" . $lane . "*" . "_export.txt $outDir");
			
			execute("cp -v -f s_" . $lane . "*" . "_sequence.txt $outDir");
		}
	}

	execute("cp -v -f runReport.csv $outDir");
	
	execute("cp -v -f Summary.xml $outDir");
	
	execute("cp -v -f Summary.htm $outDir");
	
	execute("cp -v -f ../IVC.pdf $outDir");
	
	execute("cp -v -f ../config.txt $outDir");
	
	execute("mkdir -p $outDir/fastqc");
	
	execute("cp -r /qcdata/$geraldDir/fastqc/* $outDir/fastqc");
	
}


my $basecallBranchLevel = $#dirs-1;
my $basecallDir = join("/",@dirs[2..$basecallBranchLevel]); #after run dir
print $basecallDir . "\n" if $verbose;

#copy some files
execute("mkdir -p /qcdata/$geraldDir");

execute("mkdir -p /qcdata/$runDir");

execute("mkdir -p /qcdata/$runDir/Thumbnail_Images");

execute("mkdir -p /qcdata/$runDir/InterOp");

execute("mkdir -p /qcdata/$runDir/Data/reports");

execute("cp -v -f -r /solexa/$runDir/Thumbnail_Images /qcdata/$runDir/");

execute("cp -v -f -r /solexa/$runDir/InterOp /qcdata/$runDir/");

execute("cp -v -f -r /solexa/$runDir/Data/reports /qcdata/$runDir/Data/reports");

execute("cp -v -f /solexa/$runDir/Data/Log.txt /solexa/$runDir/Data/CopyLog.txt /solexa/$runDir/Data/ErrorLog.txt /qcdata/$runDir/Data");

execute("cp -v -f /solexa/$runDir/RunInfo.xml /solexa/$runDir/Events.log /qcdata/$runDir/");

execute("cp -v -f ./postRun.* ./Summary.htm ./Summary.xml /qcdata/$geraldDir/");

execute("cp -v -f ../IVC.pdf ../config.txt /qcdata/$basecallDir/");


#keep track of disk space on iparkc01, email. only works if you're on iparkc01.
`df -kh /solexa | tail -n +2 > disk_pct`;
my $disk_pct = `df -kh /solexa | tail -n +2`;
my @items = split(/\s+/,$disk_pct);
my $pct = $items[4];
$pct =~ s/%//g;
if($pct > 70)
{
	mail_file("ipardisk", "disk_pct");
}

`df -kh /qcdata | tail -n +2 > disk_pct`;
$disk_pct = `df -kh /qcdata | tail -n +2`;
@items = split(/\s+/,$disk_pct);
$pct = $items[4];
$pct =~ s/%//g;
if($pct > 70)
{
	mail_file("qcdatadisk", "disk_pct");
}

my $post_run_log_name = "end_dir_info.txt";
open(END_RUN_LOG,">$post_run_log_name");
for(my $i = 0; $i < scalar(@out_dirs);$i++)
{
	my $outDir = $out_dirs[$i];
	print END_RUN_LOG "$outDir\n";
	my $ls = `ls -ltrh $outDir`;
	print END_RUN_LOG "$ls";
	print END_RUN_LOG "\n\n";
}
close(END_RUN_LOG);

my $fc_info_file_name = "fc_info.txt";
execute("fc_info $fcid > $fc_info_file_name");

mail_file("postRun_completed", $post_run_log_name);
mail_file("fc_info_for_$fcid", $fc_info_file_name);

print POST_RUN_LOG "finished ....";
my $total_end = new Benchmark;
my $total_diff = timediff($total_end, $total_start);

print POST_RUN_LOG "Total Time, " . timestr($total_diff, 'all') . "\n";
close(POST_RUN_LOG);
`touch finished.txt`;

sub execute
{
	my($command);
	$command = $_[0];	
   print POST_RUN_LOG "$command" . ", ";
	my $start = new Benchmark;
   system($command);
	my $end = new Benchmark;
	my $diff = timediff($end, $start);
	print POST_RUN_LOG timestr($diff, 'all') . " \n";
}

sub mail_file
{
	my($title, $file);
	$title = $_[0];
	$file = $_[1];

	if(-e $file)
	{
		foreach my $email (@emails)
		{
			`mail -s $title $email < $file`
		}
	}
	else
	{
		print "ERROR: cannot mail file: $file\n";
	}
}

__END__

=head1 postRun.pl

script to execute at the end of GERALD alignment for the illumina NGS pipeline

=head1 SYNOPSIS

postRun.pl [options] [flow_cell_id] [out_1:out_2:...] [lane_1:lane_2:...]

 Arguments (only used if --nolims flag is provided):
  [flow_cell_id]  The flow cell ID for the flow cell being analyzed
  [out_1:out_2]   Specify output directories. Each directory is separated by a ':'
  [lane_1:lane_2] Specify lane sets. Each lane set is separated by a ':'

 Options:
  --help          brief help message
  --man           full documentation
  --minpf         minimum threshold for tile graph generation 
  --nolims        do NOT use NGSLIMS system to determine flow cell ID, output directories, and lane sets
  --verbose       enable descriptive output during run

=head1 OPTIONS 

=over 8

=item B<--help>

Print brief help message then exits.

=item B<--man>

Prints manual page then exits.

=item B<--minpf>

Minimum threshold to used for generating tile graphs. This will be used as input to the Bustard Summary script. Default value is 80.

=item B<--nolims>

This flag indicates that the script should NOT attempt to acquire flowcell ID, output directories, and lane sets from the NGSLIMS system. The default option is to attempt to query the NGSLIMS to acquire this information.
Use this if you would like to specify the flowcell ID,  output_dir, and lane_set parameters via the command line. These command line arguments will be ignored if this flag is not  used.

=head1 DESCRIPTION

B<This program> should be run as the final process of the GERALD alignment portion of the illumina pipeline.

=cut

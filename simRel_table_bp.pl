#!/usr/bin/perl
# NaviGO is  released under the terms of the GNU Lesser General Public License Ver.2.1. 
# https://www.gnu.org/licenses/old-licenses/lgpl-2.1.en.html

my ($config) = @ARGV;
require "$config";

my $data_path = get_data_file_path();
open (BP, "<BPpair_commonAncestor_uniq.txt")|| die "Cannot open BP_related_ancestors.txt file.\n";
open (PC, "<".$data_path ."Combined_pc.txt")|| die "Cannot open Combined_pc.txt file.\n";	

open (OUT, ">BP_cursim_table_Rel.txt") || die "Cannot open out";	#Relevance Similarity


my %pc = ();
@max;
%zeros;

while ($line = <PC>){

	chomp $line;
	@line = split("\t", $line);
	$pc{$line[0]} = $line[1];
}

close (PC);

$nl = 0;
while ($line = <BP>){
	$count++;
	chomp $line;
	@line = split("\t", $line);

	print "simRel_table_bp.pl : Computing BPsim $nl\n";
	$nl++;

	$term1 = $line[0];
	$term2 = $line[1];
	$ancestors = $line[2];

	$score1 = $pc{$term1};
	$score2 = $pc{$term2};

	#print "term1 ". $term1. " pc1 ". $score1 . " term2 ". $term2. " pc2 ". $score2 . "\n";
	@anc = split(",", $ancestors);
	if(scalar(@anc) == 0)		#OBSOLETE, push root
	{
		push @anc, "GO:0008150";
	}
	
	foreach (@anc){

		$ancScore = $pc{$_};

		if ($score1 ==0 && $score2 == 0 && $ancScore == 0) {
			$zeros{$term1} = $score1;
			$seros{$term2} = $score2;		
			next;
		}
		if ($score1 != 0 && $score2 != 0 && $ancScore != 0){
			#print "anc term " . $_ ." ancPC " .$ancScore . "\n";
			$top = 2* (log($ancScore)/log(10));
			$a = (log($score1)/log(10));
			$b = (log($score2)/log(10));
			$bottom =  $a + $b;
			next if ($bottom == 0);
			$first = $top/$bottom;
			$final = $first * (1-$ancScore);
			push @max, $final;
			#print "curr_ss $final\n";
		}

		if ($score1 != 0 && $score2 != 0 && $ancScore == 0) {
			next;
		}
		if ($score1 != 0 && $score2 == 0 && $ancScore != 0){
			#print "anc term " . $_ ." ancPC " .$ancScore . "\n";
			$top = 2 * (log($ancScore)/log(10));
			$bottom = (log($score1)/log(10));
			next if ($bottom == 0);
			$first = $top/$bottom;
			$final = $first * (1-$ancScore);
			push @max, $final;
		}

		if ($score1 == 0 && $score2 != 0 && $ancScore != 0){
			$top = 2* (log($ancScore)/log(10));
			$bottom = (log($score2)/log(10));
			next if ($bottom == 0);
			$first = $top/$bottom;
			$final = $first * (1-$ancScore);
			push @max, $final;
		}

		if ($score1 == 0 && $score2 == 0 && $ancScore != 0) {
			$top = 2* (log($ancScore)/log(10));
			$bottom =  1;
			next if ($bottom == 0);
			$first = $top/$bottom;
			$final = $first * (1-$ancScore);
			push @max, $final;
		}

		if ($score1 == 0 && $score2 != 0 && $ancScore == 0){
			next;
		}
		if ($score1 != 0 && $score2 == 0 && $ancScore == 0){
			next;
		
		}
	}
	
	@max = sort {$a <=> $b} @max;
	$maxi = $max[$#max];

	#print "$term1\t$term2\t$maxi\n";
	print OUT "$term1\t$term2\t$maxi\n";
	@max = ();
	#if($count == 1)
	#{
	#	last;
	#}
}


close(OUT);
close(BP);

%pc = ();




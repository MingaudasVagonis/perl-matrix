#!/usr/bin/perl -l
use Data::Dumper;
use strict; 
use warnings;

my $matrixes;
my $input = shift @ARGV;
my %actions = ( m => sub{  multiply($matrixes->[0],$matrixes->[1]); },
                d => sub{  determinant($matrixes->[0], 1); });
my $matrix = 0;

open(my $file, $input) or die "Unable to open file $input";
while( my $line = <$file>)  {   
	$line =~ s/[\n\r]//g;
	# '-'' indicates to read to a new matrix
	if($line eq "-"){
		$matrix ++; next;
	}
	if( not $line =~ /^ *$/){
		push @{$matrixes->[$matrix]}, [(split / /, $line)];    
	}
}
close $file;

print $actions{shift @ARGV}->() ;

sub multiply{

	my ($mat_0, $mat_1) = @_;
	my %dimensions = dim($mat_0,$mat_1);
	my $res;

	die "Dimensions don't match" unless ($dimensions{c1} == $dimensions{r2});

	$mat_1 = rotate($mat_1, \%dimensions);

	for my $row_i (0 .. $dimensions{r1} - 1){
		for (0..$dimensions{c2} - 1){
			$res->[$row_i][$_] = multiply_array(@$mat_0[$row_i], @$mat_1[$_]);
		}
	}
	# Creating pritable matrix string
	my $str = "";
	$str= $str . join(" ", @{$_}, "\n")  for @$res; 
	substr $str, 0, -1;
}

sub determinant{
	my ($mat, $fac) =@_;
	my $sum;
	
	if(scalar @$mat == 2){
		$sum+= ($mat->[0][0]*$mat->[1][1]-$mat->[1][0]*$mat->[0][1]) * $fac; $sum;
	} else {
		#If the matrix size n is bigger than 2, calling determinant n times and passing split matrix 
		$sum+= determinant( split_matrix($_, $mat), $mat->[0][$_])* ($_ % 2 == 0 ? 1: -1) for 0..scalar @$mat - 1 ; 
		$sum*=$fac;
	}

}


sub multiply_array{

	my ($mat_0, $mat_1) = @_;

	my $sum = 0;
	$sum+= $_ for (map { @$mat_0[$_] * @$mat_1[$_] } 0..scalar @{$mat_0} - 1); $sum;
}

# Removes first row and n column from the matrix
sub split_matrix{
	# Copying the matrix so that the original wouldn't be changed
	my @mat = map { [@$_] } @{$_[1]};
	my $tmp = shift;

	splice @{$_}, $tmp, 1 foreach (@mat);
	shift @mat; \@mat;
}


#Rotates the array so that the first dimension is columns 
sub rotate{

	my ($mat, $dim) = @_;
	my $res;

	for my $c (0..$dim->{c2} - 1){
		foreach (0..$dim->{r2} - 1){
			$res->[$c][$_] = $mat->[$_][$c];
		}
	} $res;
}

sub dim{ ( r1 => scalar @{$_[0]}, c1 => scalar @{$_[0]->[0]}, r2 => scalar @{$_[1]}, c2 => scalar @{$_[1]->[0]} ); }

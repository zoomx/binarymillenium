#! /usr/bin/env perl


#Usage:
#> perl extract.pl db.xml db.csv

#use strict;
#use warnings;




open ( INFILE, "<$ARGV[0]") || die ("Can't open db.xml file");
open ( OUTFILE, ">$ARGV[1]") || die ("Can't open db.csv file");

while (<INFILE>){

if ($_ =~ /<id_>(\d+)<\/id_>/){
#print ("index is $1 \n");
 $index = $1;
}

if ($_ =~ /<rotCorrection_>(.*?)<\/rotCorrection_>/){
#print ("rotCorrection is $1 \n");
 $rotCorrection = $1;
}

if ($_ =~ /<vertCorrection_>(.*?)<\/vertCorrection_>/){
#print ("vertCorrection is $1 \n");
 $vertCorrection = $1;
}

if ($_ =~ /<distCorrection_>(.*?)<\/distCorrection_>/){
#print ("distCorrection is $1 \n");
 $distCorrection = $1;
}

if ($_ =~ /<vertOffsetCorrection_>(.*?)<\/vertOffsetCorrection_>/){
#print ("vertOffsetCorrection is $1 \n");
 $vertOffsetCorrection = $1;
}

if ($_ =~ /<horizOffsetCorrection_>(.*?)<\/horizOffsetCorrection_>/){
#print ("horizOffsetCorrection is $1 \n");
 $horizOffsetCorrection = $1;
print OUTFILE "$index,	$rotCorrection,	$vertCorrection,	$distCorrection,	$vertOffsetCorrection,	$horizOffsetCorrection \n";

}



}


close (INFILE);
close (OUTFILE);

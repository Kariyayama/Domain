#!/bin/bash

# first, copy this file and list file
start_time=`date +%s`
# make working directory
mkdir $1
cd $1
ln -s ../list* ./
binpath="PATH"
source $binpath/treat_def.sh
topath=`pwd`
logpath="${topath}/summary"
db="DBPATH"
evalue=$1
c_evalue=1e-5
echo "Start: `date`"
vert="vertebrate"
any_vert="^0,0,0,0,0,0,0,0,"
all_vert="^0,0,0,0,0,0,0,0,1,1,1,1,1,1,1"
gnath="gnathostome"
any_gnath="^0,0,0,0,0,0,0,0,0"
all_gnath="^0,0,0,0,0,0,0,0,0,1,1,1,1,1,1"
animal1="H_sapiens"
animal2="P_marinus"

# make directory ... for make gene table
mkdir -p Make_table/data
cd Make_table/data
# need file synbolic link
ln -s $topath/list  ./
ln -s $db/domtblout ./
# create domcom - animal table
$binpath/create_matrix.rb list $evalue $c_evalue
sleep 1
# count domcom number & make Gnathostome or Vertebrate specific domcom list

echo 'all domain combination' > $logpath
wc -l combi_out.csv           >> $logpath 
count $vert  $any_vert  $all_vert 
count $gnath $any_gnath $all_gnath

# gene clustaring
mkdir $topath/Make_table/Clustaring
cd    $topath/Make_table/Clustaring
# need file synbolic link
ln -s $topath/Make_table/data/${vert}.csv  ./
ln -s $topath/Make_table/data/${gnath}.csv ./
ln -s $topath/Make_table/data/domain_out.csv  ./
# clustaling domcom -> class1 class2 uniq
$binpath/clustering.rb $all_vert  domain_out.csv ${vert}.csv  > ${vert}_classed.csv  
$binpath/clustering.rb $all_gnath domain_out.csv ${gnath}.csv > ${gnath}_classed.csv 
sleep 1

# count each class domcom number
count2 $vert 
count2 $gnath 
sleep 1

# make domcom - gene table prepere
mkdir -p $topath/Make_gene_list/class1
cd $topath/Make_gene_list/class1
ln -s $db/domtblout ./
mkdir -p $topath/Make_gene_list/class2
cd $topath/Make_gene_list/class2
ln -s $db/domtblout ./

# Vertebrate specific
domcom_gene class1 $vert $animal1 &
domcom_gene class2 $vert $animal1 &
domcom_gene class1 $vert $animal2 &
domcom_gene class2 $vert $animal2 &
wait

# Gnathostome specific
domcom_gene class1 $gnath $animal1 &
domcom_gene class2 $gnath $animal1 &
wait

# make gene list from domcom-gene table
annotate class1 $vert  $animal1 &
annotate class1 $gnath $animal1 &
annotate class2 $vert  $animal1 &
annotate class2 $gnath $animal1 &
annotate class1 $vert  $animal2 &
annotate class2 $vert  $animal2 &
wait

end_time=`date +%s`

time=$((end_time - start_time))
echo "End: `date`" >> $logpath 
echo "$time sec"

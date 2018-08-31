#!/bin/bash
count(){
  echo "Only any ${1}"                     >> $logpath
  cat combi_out.csv | grep $2 | wc -l      >> $logpath
  echo "all of ${1}"                       >> $logpath
  cat combi_out.csv | grep $3 > $1.csv
  wc -l $1.csv >> $logpath
  return 0
}

count2(){
    echo "${1} class1 class2"                  >> $logpath
    cat ${1}_classed.csv | grep class1 | wc -l >> $logpath
    cat ${1}_classed.csv | grep class2 | wc -l >> $logpath
}

# make domcom - gene table prepere
domcom_gene(){
    cd $topath/Make_gene_list/$1
    cat $topath/Make_table/Clustaring/$2_classed.csv  | grep $1 > $topath/Make_gene_list/$1/$2_$1.csv
    # make domcom-gene table
    /home/wadaken/Kariyayama/script/Matrix/bin/create_combi_gene_table.rb ${3}.domtblout $2_$1.csv $evalue $c_evalue
    mv $3.csv $3_$2_$1.csv
    return 0
}

# make gene list from domcom-gene table
# same domaincombi means the gene model has same domain combinations like 'PF00049-PF00049'
# In this script, don't distinglish between 'also having same domaincombi' and 'only having same domaincombi'
annotate(){
    mkdir -p $topath/Gene_list/$1/$2 # $1=class1 or class2, $2=gnathostome or vertebrate $3=P_marinus or H_sapiens
    cd       $topath/Gene_list/$1/$2
    # need synbolic link
    ln -s $db/seq/$3     ./
    cat $topath/Make_gene_list/$1/$3_$2_$1.csv  | awk -F, '{if($16 != $17) print}' > ./$3_$2_$1_domaincombi.csv
    ln -s $db/domtblout                         ./
    # make gene list from domcom-gene table
    /home/wadaken/Kariyayama/script/Matrix/bin/gene_list.rb $3_$2_$1_domaincombi.csv | sort | uniq | sort > $3_$2_$1_genelist_domaincombi
    # make annotation in ensembl fasta file comment
    /home/wadaken/Kariyayama/script/Matrix/bin/ensembl_annotation.rb $3_$2_$1_genelist_domaincombi $3/* $3 > $3_$2_$1_ens_annotated_list_domaincombi.csv
    # pick out only gene information
    cat $3_$2_$1_ens_annotated_list_domaincombi.csv | awk -F';' '{print $2";"$3}' | sort | uniq | sort > $3_$2_$1_genelist__domaincombi.csv
    return 0
}

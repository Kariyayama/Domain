=begin
This script is module for getgene.rb
This script for output to file.
=end

module Outputer

  def out_read_file(hash)
    hash.each_key do |group|
      gene_file = File.open("#{group}.dom", "w")
      hash[group].each_key do |gene|
        gene_file.print("#{gene}\t#{hash[group].fetch(gene).join("\t")}\n")
      end
      gene_file.close
    end
    puts "Save domain file."
  end
  
  def out_domcom_to_file(domcom) # output domain conbinations to outfile
    domcom.each_key do |group|
      comb_file = File.open("#{group}.comb", "w")
      domcom[group].each_key do |domain_comb|
        comb_file.print("#{domain_comb.join("\t")}\n")
      end
      comb_file.close
    end
    puts "Save domain conbination hash"
  end

  def out_compare_to_file(matrix, hash, group1, group2, type)     # output domain conbinations to outfile
    conserved = 1
    non_conserved =0
    out_file1 = File.open("#{group1}_spec.#{type}", "w") # domcom1 specific domain combi
    out_file2 = File.open("#{group2}_spec.#{type}", "w") # domcom2 specific domain combi
    out_file_cnsv = File.open("#{group1}_#{group2}_conserved.#{type}", "w") # common domain conbi    
    matrix.each_key do |key|
      if matrix[key] == conserved then  
        out_file_cnsv.print("#{key}\n") 
      elsif matrix[key] == non_conserved && hash[group1].fetch(key, nil) != nil then 
        out_file1.print("#{key}\n")
      elsif matrix[key] == non_conserved && hash[group2].fetch(key, nil) != nil then 
        out_file2.print("#{key}\n")
      else  puts "Unexpected Error in out_compare_to_file."; exit
      end
    end
    out_file_cnsv.close
    out_file1.close
    out_file2.close
  end

  def output_as_table(main, gene_domcom, combination_matrix)
    conserved     = 1
    non_conserved = 0
    if gene_domcom.fetch(main, nil) == nil then 
      puts 'Error: No such Group!'
      exit
    else
      outfile = File.open("result_table.csv", "w")
      outfile.puts("Gene_name,Conserved Domain Combination,Unique Domain Combination")
      gene_domcom[main].each_key do |gene|
        cnsv = Array.new
        noncnsv = Array.new
        gene_domcom[main].fetch(gene, nil).each do |combi|
          if combination_matrix.fetch(combi) == conserved then
            cnsv.push(combi.join("-"))
          elsif combination_matrix.fetch(combi) == non_conserved then
            noncnsv.push(combi.join("-"))
          else
            puts "Error!, Exit"
            return 1
          end
        end
        if cnsv == [] then cnsv = ['-']  end
        if noncnsv == [] then noncnsv = ['-'] end 
        outfile.puts("#{gene},\t#{cnsv.join("\t")},\t#{noncnsv.join("\t")}")
      end
      outfile.close
    end
    return 0
  end

end

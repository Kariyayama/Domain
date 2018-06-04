=begin
This script is module for getgene.rb


=end

module Outerwork

  BELONGS = 0
  FILENAME = 1
  PFAMID = 0
  ALIGNMENTSTART = 1

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
        out_file_cnsv.print("#{key.join}\n") 
      elsif matrix[key] == non_conserved && hash[group1].fetch(key, nil) != nil then 
        out_file1.print("#{key.join}\n")
      elsif matrix[key] == non_conserved && hash[group2].fetch(key, nil) != nil then 
        out_file2.print("#{key.join}\n")
      else  puts "Unexpected Error in out_compare_to_file."; exit
      end
    end
    out_file_cnsv.close
    out_file1.close
    out_file2.close
  end

  def can_compare?(group, group1, group2)
    if group.fetch(group1, nil) == nil ||
        group.fetch(group2, nil) == nil then
      puts 'Error: No such groups'
      return 1
    else
      return 0
    end
  end
  
  def flip(now_group, group1, group2)
    if    now_group == group1 then  return group2
    elsif now_group == group2 then  return group1
    else  puts "Error in flip function"; exit
    end
  end

end

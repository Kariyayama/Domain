=begin
Read from file and deal with domain
=end
class Domain

  attr_reader :gene_hash, :domain_hash, :gene_belong, :domcom, :gene_domcom 
  BELONGS = 0
  FILENAME = 1
  PFAMID = 0
  ALIGNMENTSTART = 1
  EXIST = 1
  NOTEXIST = 0

  def initialize(file_list, thrshld, num) # make domain array for each gene  
    @gene_hash       = Hash.new  # key:gene value:domain hash
    @domain_hash_all = Hash.new  # key:domain value:gene hash
    @gene_belong     = Hash.new # Gene affenity
    @file = file_list
    @member = file_list.length
    mem   = 1
    @num  = num
    
    @file.each do |filename|
      domtblout = File.open("./domtblout/#{filename}", "r") 
      puts "start: make hash #{filename}"

      gene_nowgene = [nil, Array.new(2){Array.new}]
      domtblout.each_line{|x|
        gene_nowgene = store_domain(x, thrshld, mem, gene_nowgene)
      }
 
      puts "Done: make hash #{filename}"
      domtblout.close
      mem += 1
    end
    @domain_hash = set_threshold(@domain_hash_all)
  end

  def make_domain_combi # domain array to domain conbi hash
    @domcom_all  = Hash.new # key:domcomb value:member have or not flag
    @gene_domcom = Hash.new # key:gene value:domcomb hash
    # main part
    @gene_hash.each_key do |gene_key|
      q = @gene_hash.fetch(gene_key).to_a    
      if q.length > 1 then   # exclude one domain gene
        member = @gene_belong[gene_key]
        make_combi(gene_key, q, member)
      end
    end
    @domcom = set_threshold(@domcom_all)
  end
  

  private
  def store_domain(line, threshold, mem, gene_nowgene)
    if line.to_s.include?("#") then
    else
      row = line.split("\s")
      pfamid   = row[1].split('.')[0]
      geneid   = row[3]
      eval     = row[6]
      alistart = row[17].to_i
      gene = gene_nowgene[0]
      nowgene = gene_nowgene[1]

      if eval.to_f < threshold.to_f then # threshold E-value
        if @domain_hash_all.fetch(pfamid, nil) == nil then
          @domain_hash_all.store(pfamid, Array.new(@member){NOTEXIST})
        end
        @domain_hash_all.fetch(pfamid)[mem] = EXIST
       

        if gene != geneid then # other gene
          # store last gene domain data
          if gene != nil then
            nowgene[PFAMID].sort_by!{ |domain| nowgene[ALIGNMENTSTART].shift } 
            @gene_hash.store(gene, nowgene[PFAMID])
            @gene_belong.store(gene, mem)
          end
          # new gene domain memory
          nowgene = Array.new(2){Array.new}
          gene = geneid
          nowgene[PFAMID] = [pfamid]  # pfam accession
          nowgene[ALIGNMENTSTART] = [alistart] # query alignment from

        elsif gene == geneid then # same gene
          nowgene[PFAMID].push(pfamid)  # pfam accession
          nowgene[ALIGNMENTSTART].push(alistart) # query alignment from
        end
        
      end
    end
    return [gene, nowgene]
  end

  def make_combi(key, query, member)
    @gene_domcom.store(key, Array.new)  # store Hash, key=>gene, value=>domain_conbi
    for i in 0..(query.length - 2) do
      for j in (i+1)..(query.length - 1) do
        @gene_domcom.fetch(key).push([query[i], query[j]])
        if @domcom_all.fetch([query[i], query[j]], nil) == nil then
          @domcom_all.store([query[i], query[j]], Array.new(@member){NOTEXIST})
        end
        @domcom_all[[query[i], query[j]]][member - 1] = EXIST
      end
    end
  end

  def set_threshold(hash)
    return_hash = Hash.new
    hash.each_key do |key|
      if hash[key].inject(:+) > (@num - 1) then
        return_hash.store(key, EXIST)
      end
    end
    return return_hash
  end
  
end

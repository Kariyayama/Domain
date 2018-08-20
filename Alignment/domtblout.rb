=begin
Read from file and deal with domain
=end
class Domtblout

  attr_reader :gene_hash, :domain_hash, :gene_belong, :domcom, :gene_domcom 
  BELONGS = 0
  FILENAME = 1
  PFAMID = 0
  ALIGNMENTSTART = 1
  ALIGNMENTINFO  = 2
  EXIST = 1
  NOTEXIST = 0
  SEQ = 'seq'
  ALIGINFO = 'alinment'
  GNLENGTH = 'genelength'

  def initialize(file, evalue, c_evalue) # make domain array for each gene  
    @gene_hash     = Hash.new  # key:gene    value:domain hash
    @domain_hash   = Hash.new  # key:domain  value: EXIST
    @file = file
    mem   = 1
    
    domtblout = File.open(@file, "r") 
    puts "start: make hash #{@file.split('/')[-1]}"
    gene_nowgene = [nil, nil, Array.new(3){Array.new}]
    domtblout.each_line{|x|
      gene_nowgene = store_domain(x, evalue, c_evalue, mem, gene_nowgene)
    }
    puts "Done: make hash #{@file.split('/')[-1]}"
    domtblout.close
    mem += 1
  end

  def create_domain_combi # domain array to domain conbi hash
    @domcom  = Hash.new # key:domcomb value:member have or not flag
    @gene_domcom = Hash.new # key:gene value:domcomb hash
    # main part
    puts "start: create domain combi #{@file.split('/')[-1]}"
    @gene_hash.each_key do |gene_key|
      q = @gene_hash[gene_key][SEQ].to_a    
      if q.length > 1 then   # exclude one domain gene
        create_combi(gene_key, q)
      end
    end
    puts "Done: create domain comb #{@file.split('/')[-1]}"
  end
  
  private
  def store_domain(line, evalue, c_evalue, mem, gene_nowgene)
    if line.to_s.include?("#") then
    else
      row = line.split("\s")
      pfamid   = row[1].split('.')[0]
      pfamleng = row[2]
      geneid   = row[3]
      geneleng = row[5]
      evl      = row[6].to_f
      c_evl    = row[11].to_f
      alistart = row[17].to_i
      aliend   = row[18].to_i
      gene     = gene_nowgene[0]
      nowgnlng = gene_nowgene[1]
      nowgene  = gene_nowgene[2]

      if evl < evalue.to_f && c_evl < c_evalue.to_f then # threshold E-value
        @domain_hash.store(pfamid, EXIST)
        if gene != geneid then # other gene
          # store last gene domain data
          if gene != nil then
            align = Marshal.load(Marshal.dump(nowgene[ALIGNMENTSTART]))
            nowgene[PFAMID].sort_by!{ |domain| nowgene[ALIGNMENTSTART].shift } 
            nowgene[ALIGNMENTINFO].sort_by!{ |domain| align.shift } 
            @gene_hash.store(gene, Hash.new)
            @gene_hash[gene].store(SEQ, nowgene[PFAMID])
            @gene_hash[gene].store(GNLENGTH, nowgnlng)
            @gene_hash[gene].store(ALIGINFO, nowgene[ALIGNMENTINFO])
          end
          # new gene domain memory
          nowgene = Array.new(3){Array.new}
          gene = geneid
          nowgene[PFAMID] = [pfamid]  # pfam accession
          nowgene[ALIGNMENTSTART] = [alistart] # query alignment from
          nowgene[ALIGNMENTINFO]  = ["#{alistart}-#{aliend} / #{pfamleng}"]
        elsif gene == geneid then # same gene
          nowgene[PFAMID].push(pfamid)  # pfam accession
          nowgene[ALIGNMENTSTART].push(alistart) # query alignment from
          nowgene[ALIGNMENTINFO].push("#{alistart}-#{aliend} / #{pfamleng}")
        end
        
      end
    end
    return [gene, geneleng, nowgene]
  end

  def create_combi(key, query) 
    @gene_domcom.store(key, Array.new)  # store Hash, key=>gene, value=>domain_conbi
    for i in 0..(query.length - 2) do
      for j in (i+1)..(query.length - 1) do
        domcom = [query[i],query[j]]
        @gene_domcom[key].push(domcom)
        if @domcom.fetch(domcom, nil) == nil then
          @domcom.store(domcom, Array.new)
        end
        @domcom[domcom].push(key)
      end
    end
  end
  
end

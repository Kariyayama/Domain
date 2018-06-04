=begin
This script makes all combination of domains to each genes and compare
Input file format is domtblout.
marge make_gene_domain_table.rb and make_table_to_hash.rb and make compare function
USAGE: ruby main.rb INPUTFILE

INPUTFILE format
Group1  SP1  sp1.domtblout
Group1  SP2  sp2.domtblout
...
Group2  SP1'  sp1'.domtblout
...

=end
require_relative "outeraction"
require_relative "test_result"

class Domain

  BELONGS = 0
  FILENAME = 1
  CONSERVED = 1
  NON_CONSERVED =0
  PFAMID = 0
  ALIGNMENTSTART = 1
  include Outerwork
  include Compare_test

  def initialize(listfile) # make domain array for each gene  
    list_file = File.open(listfile, "r")  # Input list file
    @group = Hash.new                     # Hash: key => greup, value => [[belongs], [filename]]

    # read input file and make hash gene and domain
    list_file.each_line{ |lst|
      if lst.to_s.include?("#") then # exclude '#' row
      else
        list     = lst.split("\s")
        group    = list[0]
        belongs  = list[BELONGS + 1]
        filename = list[FILENAME + 1]
        if group != nil && belongs != nil && filename != nil then 
          @group.store(group, Array.new(2){Array.new})
          @group.fetch(group)[BELONGS].push(belongs)
          @group.fetch(group)[FILENAME].push(filename)
        end
      end
    }
    @group_number = @group.length
    list_file.close
  end

  def readfile(thrshld)
    @gene_hash   = Hash.new  # key:gene value:domain hash
    @domain_hash = Hash.new  # key:domain value:gene hash
    @gene_belongs = Hash.new # Gene affenity

    @group.each_key do |grp|
      mem = 0
      @gene_hash.store(grp, Hash.new)
      @domain_hash.store(grp, Hash.new)
      file_names = @group.fetch(grp)[FILENAME]
      file_names.each {|domtblout| # Input domtblout file
        file = File.open(domtblout, "r") 
        puts "start: make hash #{grp}, #{domtblout}"
        gene_nowgene = [nil, Array.new(2){Array.new}]
        file.each_line{|x|
          gene_nowgene = store_domain(x, thrshld, grp, mem, gene_nowgene)
        }
        puts "Done: make hash #{grp}, #{domtblout}"
        file.close
      }
      mem += 1
    end
    out_read_file(@gene_hash)
  end

  def make_domain_hash # domain array to domain conbi hash
    @domcom      = Hash.new # key:domcomb value:gene hash
    @gene_domcom = Hash.new # key:gene value:domcomb hash

    # main part
    @gene_hash.each_key do |grp|
      puts "Start: make combi #{grp}"
      @domcom.store(grp, Hash.new)
      @gene_domcom.store(grp, Hash.new)
      @gene_hash[grp].each_key do |gene_key|
        q = @gene_hash[grp].fetch(gene_key).to_a    
        if q.length > 1 then   # exclude one domain gene
          make_combi(gene_key, grp, q)
        end
      end
      puts "Done: make combi #{grp}"
    end

    out_domcom_to_file(@domcom) # output to file
  end

  def compare_domain(group1, group2)
    exit if can_compare?(@group, group1, group2) == 1 # group1 & group2 exist?
    puts "Start: compare domain"

    # main part
    @dom_mat = Hash.new # Hash: key => domain, value => CONSERVED or NON_CONSERVED
    @domain_hash.each_key do |grp1|
      grp2 = flip(grp1, group1, group2)
      @domain_hash[grp1].each_key do |dom|
        if @domain_hash[grp2].fetch(dom, nil) != nil then
          @dom_mat.store(dom, CONSERVED)
        else
          @dom_mat.store(dom, NON_CONSERVED)
        end
      end
    end
    out_domain_compare_file(group1, group2)
    puts "Done: compare domain"
  end

  def compare_combi(group1, group2) # compare domcom1 domain conbination and domcom2 couterpart
    exit if can_compare?(@group, group1, group2) == 1  # group1 & group2 exist?
    @dom_comb_mat = Hash.new # key => 'domain comb', value => CONSERVED or  NON_CONSERVED 

    # main part
    puts "Start: compare domain conbination"
    @domcom.each_key do |grp1|
      grp2 = flip(grp1, group1, group2)
      @domcom[grp1].each_key do |key| 
        if @domcom[grp2].fetch(key, false) then   @dom_comb_mat.store(key, CONSERVED)
        else  @dom_comb_mat.store(key, NON_CONSERVED)
        end
      end
    end
    out_compare_to_file(@dom_comb_mat, @domcom, group1, group2, "comb")
    puts "Done: compare domain conbination"
  end

  def make_gene_table
    puts "Gene_name\tCons_Dom\tUniq_Dom\tCons_DomComb\tUniq_DomCom\n"
    
  end
  
  def combination_test(testfile)
    combi_test(@dom_comb_mat, testfile)
  end

  private
  def store_domain(line, threshold, grp, mem, gene_nowgene)
    if line.to_s.include?("#") then
    else
      row = line.split("\s")
      pfamid   = row[1]
      geneid   = row[3]
      eval     = row[6]
      alistart = row[17].to_i
      gene = gene_nowgene[0]
      nowgene = gene_nowgene[1]
      if eval.to_f < threshold.to_f then # threshold E-value
        if @domain_hash[grp].fetch(pfamid, nil) == nil then
          @domain_hash[grp].store(pfamid, Array.new).push(geneid)
        else
          @domain_hash[grp].fetch(pfamid).push(geneid)
        end

        if gene != geneid then # other gene
          # store last gene domain data
          if gene != nil then
            doms = Array.new
            nowgene[ALIGNMENTSTART].sort.each do |i|
              doms.push(nowgene[PFAMID][nowgene[ALIGNMENTSTART].index(i)].split('.')[0])
            end
            @gene_hash[grp].store(gene, doms)
            @gene_belongs.store(gene, mem)
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

  def make_combi(key, group, query)
    @gene_domcom[group].store(key, Array.new)  # store Hash, key=>gene, value=>domain_conbi
    for i in 0..(query.length - 2) do
      for j in (i+1)..(query.length - 1) do
        @gene_domcom[group].fetch(key).push(query[i], query[j])
        @domcom[group].store([query[i], query[j]], 0)
      end
    end
  end

end

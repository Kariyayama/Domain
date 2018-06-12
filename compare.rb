=begin
 Compare part file
=end
require_relative "output"
require_relative "others"
require_relative "test_result"
require_relative "domain"

class Compare

  CONSERVED = 1
  NON_CONSERVED =0
  DATA = 2
  include Outputer
  include Compare_test
  include Smallwork

  def initialize(listfile) # make domain array for each gene  
    list_file = File.open(listfile, "r")  # Input list file
    @group = Hash.new # Hash: key => greup, value => [[belongs], [filename]]

    # read input file and make hash gene and domain
    list_file.each_line{ |lst|
      if lst.to_s.include?("#") then # exclude '#' row
      else
        list     = lst.split("\s")
        group    = list[0]
        belongs  = list[BELONGS + 1]
        filename = list[FILENAME + 1]
        if group != nil && belongs != nil && filename != nil then
          if @group.fetch(group, nil) == nil then
            @group.store(group, Array.new(3){Array.new})
          end
          @group.fetch(group)[BELONGS].push(belongs)
          @group.fetch(group)[FILENAME].push(filename)
          @group.fetch(group)[DATA].push(nil)
        end
      end
    }
    @group_number = @group.length
    list_file.close
  end

  def readfile(thrshld, group1, group2, group1_num, group2_num)
    @gene_hashs   = Hash.new  # key:gene value:domain hash
    @domain_hashs = Hash.new  # key:domain value:gene hash
    @gene_belongs = Hash.new  # Gene affenity
    @member = {group1 => group1_num, group2 => group2_num}
    @group.each_key do |grp|
      if grp == group1 || grp == group2 then
        data = Domain.new(@group.fetch(grp)[FILENAME], thrshld, @member[grp])
        @gene_hashs.store(grp, data.gene_hash)
        @domain_hashs.store(grp, data.domain_hash)
        @gene_belongs.merge!(data.gene_belong)
        @group[grp][DATA] = data
      end
    end
    out_read_file(@gene_hashs)
    if @gene_hashs.length != 2 then
      puts 'Error: Not enough compare size.'
      exit
    end
  end

  def make_domain_hash # domain array to domain conbi hash
    @domcoms      = Hash.new # key:domcomb value:gene hash
    @gene_domcoms = Hash.new # key:gene value:domcomb hash

    # main part
    @member.each_key do |grp|
      puts "Start: make combi #{grp}"
      @group[grp][DATA].make_domain_combi
      data = @group[grp][DATA]
      @domcoms.store(grp, data.domcom)
      @gene_domcoms.store(grp, data.gene_domcom)
      puts "Done: make combi #{grp}"
    end

    out_domcom_to_file(@domcoms) # output to file
  end

  def compare_domain
    puts "Start: compare domain"

    # main part
    @dom_mat = Hash.new # Hash: key => domain, value => CONSERVED or NON_CONSERVED
    @domain_hashs.each_key do |grp1|
      grp2 = flip(grp1, @member.keys)
      @domain_hashs[grp1].each_key do |dom|
        if @domain_hashs[grp2].fetch(dom, nil) != nil then
          @dom_mat.store(dom, CONSERVED)
        else
          @dom_mat.store(dom, NON_CONSERVED)
        end
      end
    end
    out_compare_to_file(@dom_mat, @domain_hashs, @member.keys, "dom")
    puts "Done: compare domain"
  end

  def compare_combi # compare domcom1 domain conbination and domcom2 couterpart
    @dom_comb_mat = Hash.new # key => 'domain comb', value => CONSERVED or  NON_CONSERVED 

    # main part
    puts "Start: compare domain conbination"
    @domcoms.each_key do |grp1|
      grp2 = flip(grp1, @member.keys)
      @domcoms[grp1].each_key do |key| 
        if @domcoms[grp2].fetch(key, false) then   @dom_comb_mat.store(key, CONSERVED)
        else  @dom_comb_mat.store(key, NON_CONSERVED)
        end
      end
    end
    out_compare_to_file(@dom_comb_mat, @domcoms, @member.keys, "comb")
    puts "Done: compare domain conbination"
  end

  def make_gene_number_table(main)
    r = output_as_number_table(main, [@gene_hashs, @gene_domcoms], [@dom_mat, @dom_comb_mat])
    if r == 0 then puts "Done: Output table (csv file)"
    else puts "Error end"; exit
    end
  end

  def make_gene_table(main)
    r = output_as_table(main, @gene_domcoms, @dom_comb_mat)
    if r == 0 then puts "Done: Output table (csv file)"
    else puts "Error end"; exit
    end
  end
  
  def combination_test(testfile)
    combi_test(@dom_comb_mat, testfile)
  end

end

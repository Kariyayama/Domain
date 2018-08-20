require_relative 'domtblout.rb'
require_relative 'alignment.rb'
require_relative 'analysis_def.rb'
require 'date'

alifile  = ARGV.shift
listfile = ARGV.shift
combfile = ARGV.shift
domfile  = ARGV.shift
spliter = ' '

gnhash   = Hash.new
dmcmhash = Hash.new
listpath  = './domtblout/'
evalue = 10 ** -3
c_evalue = 10 ** -5

File.open(listfile, "r").each_line do |list|
  if list.include?('#') then
  else
    dom = Domtblout.new("#{listpath}#{list.chomp}", evalue, c_evalue)
    dom.create_domain_combi
    gnhash.merge!(dom.gene_hash)
    dmcmhash.merge!(dom.gene_domcom)
    sleep(1)
  end
end

only = "^0,0,0,0,0,0,0,0,1,1,1,1,1,1,1.+"
any  = "^0,0,0,0,0,0,0,0,.+"
target_only_dom  = domain_file(domfile,  only)
target_any_dom   = domain_file(domfile,  any)
target_only_comb = combi_file( combfile, only)
target_any_comb  = combi_file( combfile, any)

# main part
#
file = File.open(alifile, "r")
ofile = File.open('outfile.ali', "w")
ofile.puts "# #{Date.today}"
ofile.puts "# Threshold Evalue: #{evalue}, C_evalue: #{c_evalue}\n"

file.each_line do |line|
  if line.include?('#') then
  else
    l = line.chomp.split("\s")
    query1 = l[0]
    query2 = l[1]
    result = nil; rslt2 = {query1 => Array.new, query2 => Array.new}; domresult = nil; cmbresult = nil; reciprocal = nil
    two = '-'; three = '-'; four = '-'; five = '-'; six = '-'; seven = '-'; eight = '-';

    if gnhash.fetch(query1, nil) != nil && gnhash.fetch(query2, nil) != nil 
      result = alignment(gnhash[query1]['seq'], gnhash[query2]['seq'], query1, query2)
      domresult  = identity(gnhash[query1]['seq'].uniq, gnhash[query2]['seq'].uniq)
    end
    if dmcmhash.fetch(query1, nil) != nil && dmcmhash.fetch(query2, nil) != nil 
      combresult = identity(dmcmhash[query1].uniq, dmcmhash[query2].uniq)
    end

    reci  = 'reciprocal' if l[1] == l[2] && l[1] != '-'
    anyd1 = list_exist?(gnhash[query1]['seq'], target_any_dom,   'dom' ).join(spliter) if gnhash.fetch(query1,   nil) != nil
    anyc1 = list_exist?(dmcmhash[query1],      target_any_comb,  'comb').join(spliter) if dmcmhash.fetch(query1, nil) != nil 
    two   = list_exist?(gnhash[query1]['seq'], target_only_dom,  'dom' ).join(spliter) if gnhash.fetch(query1,   nil) != nil
    three = list_exist?(dmcmhash[query1],      target_only_comb, 'comb').join(spliter) if dmcmhash.fetch(query1, nil) != nil 
    # p gnhash[query1]
    # p target_any_dom
    if result.kind_of?(Hash)
      five = ver2(result, 
                  Marshal.load(Marshal.dump(gnhash[query1]['alinment'])), 
                  Marshal.load(Marshal.dump(gnhash[query2]['alinment'])),
                  gnhash[query1]['genelength'], gnhash[query2]['genelength'])
#      four = "1- #{result['seq1'].join('-')} -#{gnhash[query1]['genelength']}"
#      five = "   #{result['alignment'].join(' ')}"
#      six  = "1- #{result['seq2'].join('-')} -#{gnhash[query2]['genelength']}"
    end
    seven = list_exist?(dmcmhash[query2], target_only_comb, 'comb').join(spliter) if dmcmhash.fetch(query2, nil) != nil 
    eight = list_exist?(gnhash[query2],   target_only_dom,  'dom' ).join(spliter) if gnhash.fetch(query2,   nil) != nil
    anyc2 = list_exist?(dmcmhash[query2], target_any_comb,  'comb').join(spliter) if dmcmhash.fetch(query2, nil) != nil 
    anyd2 = list_exist?(gnhash[query2],   target_any_dom,   'dom' ).join(spliter) if gnhash.fetch(query2,   nil) != nil

    outputer(ofile, spliter, query1, query2, reci, two, three, four, five, six, seven, eight,
             domresult, combresult, anyd1, anyc1, anyd2, anyc2)
  end
  sleep(1)
end
ofile.close
file.close

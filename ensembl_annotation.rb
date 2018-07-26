#!/usr/bin/ruby
require 'date'

gene_list = ARGV.shift
ensdata   = ARGV.shift
animal    = ARGV.shift.chomp
gene_end = 17 if animal == 'human'   # human
gene_end = 20 if animal == 'lamprey' # lamprey

gnhash = Hash.new
gnfile = File.open(gene_list, "r")
gnfile.each_line do |li|
  if li.include?('#') then
  else
    gnhash.store(li.chomp, 0)
  end
end
gnfile.close

puts "##{Date.today}"
ensfile = File.open(ensdata, "r")
ensfile.each_line do |line|
  if line.include?('>') then
    gene = line[1..gene_end]

    if gnhash.fetch(gene, nil) != nil then
      gs = line.index('gene_symbol')
      ds = line.index('description') 
      so = line.index('[Source')
      if gs.nil? || ds.nil? || so.nil? then
        puts "#{gene};;#{line[(gene_end + 1)..-1]}"
      else
        gene_symbol = line[(gs+12)..(ds-2)]
        dscription  = line[(ds+12)..(so-2)]
        puts "#{gene};#{gene_symbol};#{dscription}"
      end
    end
  end
end
ensfile.close

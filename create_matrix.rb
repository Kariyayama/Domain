#!/usr/bin/ruby 
require_relative "domtblout"
require 'date'
if ARGV.length != 3
  puts "Argument Error! (Need 3 argument, listfile, evalue c_evalue)"
  exit
end

listname = ARGV.shift.chomp
evalue = ARGV.shift.chomp
c_evalue = ARGV.shift.chomp
listpath = './domtblout/'
# evalue   = 1e-3
# c_evalue = 1e-5
listhash = Hash.new
domcom = Hash.new
domain = Hash.new

File.open(listname, "r").each_line do |list|
  if list.include?('#') then
  else
    organism = list.split('.')[0]
    listhash.store( organism, Domtblout.new("#{listpath}/#{list.chomp}", evalue, c_evalue))
    listhash[organism].create_domain_combi
    domain.merge!(listhash[list.split('.')[0]].domain_hash)
    domcom.merge!(listhash[list.split('.')[0]].domcom)
  end
end

# Create domain table
outfile1 = File.open('domain_out.csv', "w")
outfile1.puts "##{Date.today}"
outfile1.puts "# Evalue: #{evalue}, C_evalue: #{c_evalue}"
# Header
outfile1.print "#"
listhash.each_key do |key|
  outfile1.print "#{key},"
end
outfile1.puts "domain"

# Main_table
domain.each_key do |key_dom|
  listhash.each_key do |animal|
    if listhash[animal].domain_hash.fetch(key_dom, nil) != nil then
      outfile1.print "1,"
    else
      outfile1.print "0,"
    end
  end
  outfile1.puts "#{key_dom}"
end
outfile1.close


# Create domcom table
outfile2 = File.open('combi_out.csv', "w")
# Header
outfile2.puts "##{Date.today}"
outfile2.puts "# Evalue: #{evalue}, C_evalue: #{c_evalue}"
outfile2.print "#"
listhash.each_key do |key|
  outfile2.print "#{key},"
end
outfile2.puts "domain1,domain2"

# Main Table
domcom.each_key do |key_combi|
  listhash.each_key do |animal|
    if listhash[animal].domcom.fetch(key_combi, nil) != nil then
      outfile2.print "1,"
    else
      outfile2.print "0,"
    end
  end
  outfile2.puts "#{key_combi.join(',')}"
end
outfile2.close


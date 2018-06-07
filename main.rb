#!/usr/bin/ruby
=begin
USAGE: ruby THIS_SCRIPT INPUTFILE
=end

require_relative 'compare'

if ARGV.length != 1 then
  puts "----------------------------------------"
  puts " Error "
  puts " Input domtblout list files as argument. "
  puts "----------------------------------------"
  exit
end

filename = ARGV.shift
threshold = 10 ** -4

gdata = Compare.new(filename)
gdata.readfile(threshold)
gdata.make_domain_hash
gdata.compare_domain('Group1', 'Group2')
gdata.compare_combi('Group1', 'Group2')
gdata.combination_test('TestData.txt')
gdata.make_gene_number_table('Group1')

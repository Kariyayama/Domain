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
gdata.readfile(threshold, 'Teleost', 'Lamprey', 2, 1)
gdata.make_domain_hash
gdata.compare_domain
gdata.compare_combi
gdata.combination_test('TestData.txt')
gdata.make_gene_number_table('Lamprey')

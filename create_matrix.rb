#!/usr/bin/ruby 
require_relative "domtblout"
# require 'date'
require_relative "matrix_def"
if ARGV.length != 3
  puts "Argument Error! (Need 3 argument, listfile, evalue c_evalue)"
  exit
end

listname = ARGV.shift.chomp
evalue = ARGV.shift.chomp
c_evalue = ARGV.shift.chomp
listpath = './domtblout/'
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

domain_table(domain, listhash, evalue, c_evalue)
combi_table(domcom, listhash, evalue, c_evalue)

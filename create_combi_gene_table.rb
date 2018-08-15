#!/usr/bin/ruby
require_relative "domtblout"
require 'date'

if ARGV.length != 4
  puts "Argument Error!. (Too less argment)"
  exit
end

listfile = ARGV.shift.chomp
tablefile = ARGV.shift.chomp
evalue = ARGV.shift
c_evalue = ARGV.shift
#evalue   = 1e-3
#c_evalue = 1e-5

listpath = './domtblout/'
listhash = Hash.new

File.open(listfile, "r").each_line do |list|
  if list.include?('#') then
  else
    organism = list.split('.')[0]
    listhash.store( organism, Domtblout.new(listpath + list.chomp, evalue, c_evalue))
    listhash[organism].create_domain_combi
  end
end

listhash.each_key do |organism|
  domcom  = listhash[organism].domcom
  outfile = File.open("#{organism}.csv", "w")
  infile  = File.open(tablefile, "r")
  outfile.puts "##{Date.today}"
  outfile.puts "#Evalue: #{evalue}, C_evalue: #{c_evalue}"
  infile.each_line do |line|
    unless line.include?('#')
      l = line.chomp.split(",")
      key = [l[-3].chomp, l[-2].chomp]
      if domcom.fetch(key, nil) != nil then
        outfile.puts "#{l[0..-2].join(',')},#{domcom[key].join(',')}"
      else
        outfile.puts line
      end
    end
  end
  infile.close
  outfile.close
end

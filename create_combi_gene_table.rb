#!/usr/bin/ruby
require_relative "domtblout"
require 'date'

if ARGV.length != 4
  puts "Argument Error!. (Too less argment)"
  exit
end

domtblout = ARGV.shift.chomp
tablefile = ARGV.shift.chomp
evalue    = ARGV.shift
c_evalue  = ARGV.shift

listpath = './domtblout/'
organism = domtblout.split('.')[0]
list = Domtblout.new(listpath + domtblout.chomp, evalue, c_evalue)
list.create_domain_combi

domcom  = list.domcom
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


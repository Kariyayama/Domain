#!/usr/bin/ruby
require_relative "domain"
require 'date'

listfile = ARGV.shift.chomp
tablefile = ARGV.shift.chomp
threshold = ARGV.shift.chomp.to_f
listpath = './domtblout/'
# threshold = 10 ** -3
listhash = Hash.new

File.open(listfile, "r").each_line do |list|
  if list.include?('#') then
  else
    organism = list.split('.')[0]
    listhash.store( organism, Domain.new(listpath + list.chomp, threshold))
    listhash[organism].create_domain_combi
  end
end

listhash.each_key do |organism|
  domcom  = listhash[organism].domcom
  outfile = File.open("#{organism}.csv", "w")
  infile  = File.open(tablefile, "r")
  outfile.puts "##{Date.today}"
  outfile.puts "#Threshold value: #{threshold}"
  infile.each_line do |line|
    if line.include?('#')
    else
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


#!/usr/bin/ruby
require 'date'

type       = ARGV.shift
domfile    = ARGV.shift
domcomfile = ARGV.shift

tp = 9 if type.include?('gnath') 
tp = 8 if type.include?('vert')

phash = Hash.new
file = File.open(domfile, "r")
file.each_line do |line1|
  if line1.include?('#') then
  else
    l1 = line1.split(',')
    pf = l1[0]
    if l1[1..tp] == Array.new(tp){"0"} then
      phash.store(l1[0], 0)
    end
  end
end
file.close  

puts "##{Date.today}"
file2 = File.open(domcomfile, "r")
file2.each_line do |linec|
  if linec.include?('#') then
  else
    i = 0
    lc = linec.chomp.split(',')
    if    phash.fetch(lc[-2],nil) == nil && phash.fetch(lc[-1], nil) == nil  then  puts "#{linec.chomp},class2"
    elsif phash.fetch(lc[-2],nil) == nil || phash.fetch(lc[-1], nil) == nil  then  puts "#{linec.chomp},class1"
    else puts "#{linec.chomp},uniq"
    end
  end
end
file2.close

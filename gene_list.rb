#!/usr/bin/ruby
require 'date'

file = ARGV.shift
result_hash = Hash.new

puts Date.today
f = File.open(file, "r")
f.each_line do |line|
  if line.include?('#') then
  else
    l = line.split(',')
    l[17..-1].each do |gene|
      puts gene
    end
  end
end 

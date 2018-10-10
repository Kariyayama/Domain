#!/usr/bin/ruby
require 'date'

# type       = ARGV.shift
pattern    = ARGV.shift
domfile    = ARGV.shift
domcomfile = ARGV.shift

phash = Hash.new
file = File.open(domfile, "r")
file.each_line do |line1|
  if line1.include?('#') then
  else
    l1 = line1.chomp.split(',')
    pf = l1[-1]
#    if line1 =~ /#{pattern}/ then
    if line1.include?(pattern)
      phash.store(pf, 0)
    end
  end
end
file.close  
# p phash
puts "##{Date.today}"
file2 = File.open(domcomfile, "r")
file2.each_line do |linec|
  lc = linec.chomp.split(',')
  if linec.include?('#') then
  elsif lc[15] != lc[16] 
    i = 0
    if    phash.fetch(lc[-2],nil) == nil && phash.fetch(lc[-1], nil) == nil  then  puts "#{linec.chomp},class2"
    else puts "#{linec.chomp},class1"
    end
  end
end
file2.close

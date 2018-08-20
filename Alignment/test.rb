#require_relative 'analysis_def'
list = ARGV.shift
file = ARGV.shift

#ptn = "^0,0,0,0,0,0,0,0,.+"
##target = domain_file(file, ptn)
#target = combi_file(file, ptn)
#p target

a = File.open(file, "r").read
File.open(list, "r").each_line do |line|
  out = line.chomp
  out =  "#{line.chomp}: inlude" if a.include?(line.chomp)
  puts out
end

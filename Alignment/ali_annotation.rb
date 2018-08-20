anofile = ARGV.shift
alifile = ARGV.shift
spliter = ";"

anohash = Hash.new
f = File.open(anofile, "r")
f.each_line do |ano_line|
  unless ano_line.include?('#')
    ano = ano_line.chomp.split(spliter)
    anohash.store(ano[0], ano[1..-1].join("\t"))
  end
end
f.close

f2 = File.open(alifile, "r")
f2.each_line do |ali_file|
  ali = ali_file.chomp
  out = nil
  anohash.each_key do |key|
#    out = anohash[key] if ali.include?(key)
    out = anohash[key] if ali =~ /^#{key}.+/
  end
  puts "#{ali} #{out}"
end

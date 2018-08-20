def domain_file(domfile, pattern)
  target_dom = Hash.new
  df = File.open(domfile, "r")
  df.each_line do |line|
    target_dom.store(line.chomp.split(",")[-1], 0) if line =~ /#{pattern}/
  end
  df.close
  return target_dom
end

def combi_file(combfile, pattern)
  target_comb = Hash.new
  cf = File.open(combfile, "r")
  cf.each_line do |line|
    target_comb.store(line.chomp.split(",")[-2..-1], 0) if line =~ /#{pattern}/
  end
  cf.close
  return target_comb
end
  
def list_exist?(target_hash, list, type)
  rtnary = Array.new
  target_hash.each do |target|
    rtnary.push(target)           if list.fetch(target, nil) != nil && type == 'dom' 
    rtnary.push(target.join("-")) if list.fetch(target, nil) != nil && type == 'comb' 
  end
  return rtnary.uniq
end

def identity(ary1, ary2)
  shared = Array.new
  in_ary1 = Array.new
  in_ary2 = Array.new
  ary1.each do |ele|
    if ary2.include?(ele)
      shared.push(ele)           if ele.kind_of?(String) 
      shared.push(ele.join('-')) if ele.kind_of?(Array)  
      ary2.delete(ele)
    else
      in_ary1.push(ele)           if ele.kind_of?(String)
      in_ary1.push(ele.join('-')) if ele.kind_of?(Array)
    end
  end

  if ary2.kind_of?(Array) 
    if ary2[0].kind_of?(Array)
      ary2.each do |dom|
        in_ary2.push(dom.join('-'))
      end
    else
      in_ary2 = ary2 
    end
  end

  return {'shared' => shared, 'in_one' => in_ary1, 'in_two' => in_ary2}
end

def ver2(align, gnali1, gnali2, gn1leng, gn2leng)
  rslt = "\nAli code\tQuery1\t\tQueery2\tAli code\n\t\t1-\t       \t1-\n"
  for i in 0..(align['seq1'].length - 1) do
    if align['seq1'][i].include?("PF")
      gn1 = gnali1.shift
      rslt << "#{gn1}\t#{align['seq1'][i]}\t"
    else
      rslt << "\t\t   |   \t"
    end
    if align['alignment'][i].include?("|||")
      rslt << "-------\t"
    else
      rslt << "       \t"
    end
    if align['seq2'][i].include?("PF")
      gn2 = gnali2.shift
      rslt << "#{align['seq2'][i]}\t#{gn2}\n"
    else
      rslt << "   |   \n"
    end
  end
  rslt << "\t\t-#{gn1leng}\t       \t-#{gn2leng}\n"
  return rslt
end

def outputer(ofile, splt, query1, query2, reci, two, three, four, five, six, seven, eight,
             domrslt, combrslt, anyd1, anyc1, anyd2, anyc2)
  # OUT FORMAT                                                                                                                           
  ofile.puts "#"
  #  ofile.puts "#{$HEAD['one']} #{query1}"
  ofile.puts "#{query1}"
  ofile.puts "#{$HEAD['reci']} #{reci}"
  ofile.puts "#{$HEAD['anyd1']} #{anyd1}"
  ofile.puts "#{$HEAD['anyc1']} #{anyc1}"
  ofile.puts "#{$HEAD['two']} #{two}"
  ofile.puts "#{$HEAD['three']} #{three}"
  ofile.puts "#{$HEAD['four']} #{four}"
  ofile.puts "#{$HEAD['five']} #{five}"
  ofile.puts "#{$HEAD['six']} #{six}"
  ofile.puts "#{$HEAD['seven']} #{seven}"
  ofile.puts "#{$HEAD['eight']} #{eight}"
  ofile.puts "#{$HEAD['anyc2']} #{anyc2}"
  ofile.puts "#{$HEAD['anyd2']} #{anyd2}"
#  ofile.puts "#{$HEAD['nine']} #{query2}"
  ofile.puts "#{query2}"
  ofile.puts ""
  ofile.puts getpf(domrslt)  if domrslt.kind_of?(Hash)
  ofile.puts ""
  ofile.puts "Shared domain; #{domrslt['shared'].join(splt)}"   if domrslt != nil
  ofile.puts "Query1 domain; #{domrslt['in_one'].join(splt)}"   if domrslt != nil
  ofile.puts "Query2 domain; #{domrslt['in_two'].join(splt)}"   if domrslt != nil
  ofile.puts ""
  ofile.puts "Shared domcom; #{combrslt['shared'].join(splt)}"  if combrslt != nil
  ofile.puts "Query1 domcom; #{combrslt['in_one'].join(splt)}"  if combrslt != nil
  ofile.puts "Query2 domcom; #{combrslt['in_two'].join(splt)}"  if combrslt != nil
  ofile.puts ""
  ofile.puts "#"
end

def getpf(domhash)
  d = Marshal.load(Marshal.dump(domhash))
  rslt = Array.new
  d.each_key do |key|
    rslt.push(d[key].join("\n"))  if d[key].kind_of?(Array)
  end
  return rslt.join("\n")
end

$HEAD = {
  'one'   => 'Query1;',
  'anyd1' => 'Query1 Any vertebrate have domain;',
  'anyc1' => 'Query1 Any vertebrate have domcom;',
  'two'   => 'Query1 All vertebrate have domain;',
  'three' => 'Query1 All vertebrate have domcom;',
  'four'  => 'Query1 domain;',
  'five'  => 'Alignment    ;',
  'six'   => 'Query2 domain;',
  'seven' => 'Query2 All vertebrate have domcom;',
  'eight' => 'Query2 All vertebrate have domain;',
  'anyd2' => 'Query2 Any vertebrate have domain;',
  'anyc2' => 'Query2 Any vertebrate have domcom;',
  'nine'  => 'Query2;',
  'reci'  => 'reciprocal?; '
}

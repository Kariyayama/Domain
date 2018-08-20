def alignment(gn1dom, gn2dom, gap = -2, unmatch = -1, match = 2)
  slant = 0; up = 1; left = 2; init = -1
  pmat   = Array.new(gn1dom.length + 1){Array.new(gn2dom.length + 1){0}} # alignment matrix
  fromat = Array.new(gn1dom.length + 1){Array.new(gn2dom.length + 1){init}} # matrix where came from
  # Dynamic programing
  #
  # initiation
  for j in 1..gn2dom.length  do
    pmat[0][j]   = gap.to_i * j
    fromat[0][j] = left
  end
  for i in 1..gn1dom.length  do
    pmat[i][0]   = gap.to_i * i
    fromat[i][0] = up
  end
  
  # main part
  for i in 1..gn1dom.length do
    for j in 1..gn2dom.length do
      d = unmatch
      d = match if gn1dom[i - 1] == gn2dom[j - 1]
      set = [pmat[i - 1][j - 1] + d.to_i, pmat[i - 1][j] + gap.to_i, pmat[i][j - 1] + gap.to_i]
      pmat[i][j]   = set.max
      fromat[i][j] = set.index(set.max)
    end
  end
  # p pmat
  # p fromat
  
  # Trace back
  gn1rslt = Array.new
  gn2rslt = Array.new
  align   = Array.new
  i = gn1dom.length; j = gn2dom.length
  while i > 0 || j > 0 do
    if fromat[i][j] == slant then
      gn1rslt.push(gn1dom[i - 1])
      gn2rslt.push(gn2dom[j - 1])
      if(gn1dom[i - 1] == gn2dom[j - 1]) then align.push('|||||||')
      else align.push('       ')
      end
      i = i - 1; j = j - 1
    elsif fromat[i][j] == up then
      gn1rslt.push(gn1dom[i - 1])
      gn2rslt.push('-------')
      align.push('       ')
      i = i - 1
    elsif fromat[i][j] == left then
      gn1rslt.push('-------')
      gn2rslt.push(gn2dom[j - 1])
      align.push('       ')
      j = j - 1
    else
      puts 'Unexpected Error!'
      exit(1)
      break
    end
  end

  return {"seq1" => gn1rslt.reverse, "seq2" => gn2rslt.reverse, "alignment" =>  align.reverse}
end

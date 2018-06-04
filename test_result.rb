module Compare_test
  
  def combi_test(domain_comb_matrix, testfile)
    conserved = 1
    testdata = File.open(testfile, "r")
    test_result = File.open("result_test", "w")
    testdata.each_line do |line|
      if line.to_s.include?("#") then
      else
        test = line.split("\s")
        rslt = domain_comb_matrix.fetch(test, nil) 
        rvsr = domain_comb_matrix.fetch(test.reverse, nil) 
        if rslt == conserved then result1 = 'o'
        else  result1 = 'x'
        end
        if rvsr == conserved then result2 = 'o'
        else  result2 = 'x'
        end
        test_result.puts("#{test.join("\t")}\t#{result1}\t#{result2}")
      end
    end
    testdata.close
    test_result.close
    puts "Done: Test"
  end

end

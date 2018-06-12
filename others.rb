=begin
This script is module for getgene.rb
This script is small works
=end

module Smallwork

  BELONGS = 0
  FILENAME = 1
  PFAMID = 0
  ALIGNMENTSTART = 1

  def can_compare?(group, group1, group2)
    if group.fetch(group1, nil) == nil ||
        group.fetch(group2, nil) == nil then
      puts 'Error: No such groups'
      return 1
    else
      return 0
    end
  end
  
  def flip(now_group, group)
    if    now_group == group[0] then  return group[1]
    elsif now_group == group[1] then  return group[0]
    else  puts "Error in flip function"; exit
    end
  end

end

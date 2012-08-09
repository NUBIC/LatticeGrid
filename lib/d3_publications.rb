def generate_chord_member_data (investigator)
  @num_ca = investigator.coauthors.length
  @data_array = Array.new(size = (@num_ca + 1))
  @data_array.each_index{|x| @data_array[x] = Array.new(size = (@num_ca + 1))}
  @individuals_array = {investigator}
  investigator.coauthors.each{|ca| @individuals_array << ca.colleague}
  while $i <= @num_ca do
    $k = 0
    while $k <= @num_ca do
      if $i = $k 
        @data_array[$i][$k] = 0
      else
         @data_array[$i][$k] = (@individuals_array[$i].shared_abstracts_with_investigator(@individuals_array[$k].id)}).length
      $k += 1
    $i += 1
  return @data_array

def CleanNonUTFtext(the_text)
  return if the_text.blank?
  return to_ascii_iconv(the_text)
#  the_text.gsub!(/&\#(\d+);/m) {|s| [$1.to_i].pack('U') }
 # the_text.gsub!(/•|¥||ê/m,'\\\'')
  #the_text.gsub!(/–|”|Ð|Ó/m,'"')
#  the_text.gsub!(/ã||/m,'-')
 # the_text.gsub!(/Í|ê/m,'i')
  #the_text.gsub!(/ô|/m,'u')
#  accents = { 
#  		  ['á','à','â','ä','ã'] => 'a',
#  		  ['Ã','Ä','Â','À','�?'] => 'A',
#  		  ['é','è','ê','ë'] => 'e',
#  		  ['Ë','É','È','Ê'] => 'E',
#  		  ['í','ì','î','ï'] => 'i',
#  		  ['�?','Î','Ì','�?'] => 'I',
#  		  ['ó','ò','ô','ö','õ'] => 'o',
#  		  ['Õ','Ö','Ô','Ò','Ó'] => 'O',
#  		  ['ú','ù','û','ü'] => 'u',
#  		  ['Ú','Û','Ù','Ü'] => 'U',
#  		  ['ç'] => 'c', ['Ç'] => 'C',
#  		  ['ñ'] => 'n', ['Ñ'] => 'N'
#  		  }
#  		accents.each do |ac,rep|
#  		  ac.each do |s|
#  			str = str.gsub(s, rep)
#  		  end
#  		end
  
  the_text
end

def to_ascii_iconv(text)
  ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
  new_text=ic.iconv(text + ' ')[0..-2]
  converter = Iconv.new('ASCII//IGNORE//TRANSLIT', 'UTF-8') 
  text = converter.iconv(new_text).unpack('U*').select{ |cp| cp < 127 }.pack('U*')
  text.gsub(/\022|\023|\024|\030|\031|\034|\035/,' ')
  
end

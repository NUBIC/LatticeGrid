# -*- coding: utf-8 -*-

##
# Class to help maniulate text
class TextUtilities
  ##
  # A method to remove non-UTF characters from the
  # given text parameter.
  #
  # Previous implementations included:
  # the_text.gsub!(/&\#(\d+);/m) {|s| [$1.to_i].pack('U') }
  # the_text.gsub!(/•|¥||ê/m, '\\\'')
  # the_text.gsub!(/–|”|Ð|Ó/m, '"')
  # the_text.gsub!(/ã||/m, '-')
  # the_text.gsub!(/Í|ê/m, 'i')
  # the_text.gsub!(/ô|/m, 'u')
  #  accents = {
  #       ['á','à','â','ä','ã'] => 'a',
  #       ['Ã','Ä','Â','À','�?'] => 'A',
  #       ['é','è','ê','ë'] => 'e',
  #       ['Ë','É','È','Ê'] => 'E',
  #       ['í','ì','î','ï'] => 'i',
  #       ['�?','Î','Ì','�?'] => 'I',
  #       ['ó','ò','ô','ö','õ'] => 'o',
  #       ['Õ','Ö','Ô','Ò','Ó'] => 'O',
  #       ['ú','ù','û','ü'] => 'u',
  #       ['Ú','Û','Ù','Ü'] => 'U',
  #       ['ç'] => 'c', ['Ç'] => 'C',
  #       ['ñ'] => 'n', ['Ñ'] => 'N'
  #     }
  #     accents.each do |ac,rep|
  #       ac.each do |s|
  #       str = str.gsub(s, rep)
  #       end
  #     end
  #
  # FIXME: this method doesn't seem to work as expected
  #        cf. /spec/lib/text_utilities_spec.rb
  def self.clean_non_utf_text(the_text)
    return if the_text.blank?
    the_text.encode('UTF-8', :invalid => :replace, :undef => :replace, :replace => '').force_encoding('UTF-8')
  end
end

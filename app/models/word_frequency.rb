class WordFrequency < ActiveRecord::Base
  attr_accessible :the_type, :word, :frequency
FILLER_WORDS = ["the", "of", "and", "as", "to", "a", "in", "that", "with", "for", "an", "at", "not", "by", "on", "but", "or", "from", "its", "when", "this", "these", "i", "was", "is", "we", "have", "some", "into", "may", "well", "there", "our", "it", "me", "you", "what", "which", "who", "whom", "those", "are", "were", "be", "however","been", "being", "has", "had", "do", "did", "doing", "will", "can", "isn't", "aren't", "wasn't", "weren't", "to", "very", "would", "also", "after", "other", "whose", "upon", "their", "could", "all", "none", "no", "us", "here", "eg", "how", "where", "such", "many", "more", "than", "highly", "annotation", "annotations", "along", "each", "both", "then", "any", "same", "only", "significant", "significantly", "without", "versus", "likely", "while", "later", "whether", "might", "particular", "among", "thus", "every", "through", "over", "thereby", "about", "they", "your", "them", "within", "should", "much", "because", "ie", "between", "aka", "either", "under", "fully", "most", "since", "using", "used", "if", "nor", "yet", "easily", "moreover", "despite", "does", "quite", "less", "her", "found", "via", "type", "review", "age", "last", "purpose"]

named_scope :abstract_words, 
    :conditions => ["word_frequencies.the_type = 'Abstract'"]

named_scope :investigator_words, 
    :conditions => ["word_frequencies.the_type = 'Investigator'"]

named_scope :more_than, lambda { |the_freq|
  {:conditions => ['word_frequencies.frequency >= :the_freq ', {:the_freq => the_freq}] }
}


  def self.get_abstract_words
    Abstract.abstract_words
  end

  def self.get_investigator_words
    Investigator.abstract_words
  end

  def self.save_frequency_map(frequency_map)
    frequency_map.each do |item|
      existing = WordFrequency.find(:first, :conditions=>["word_frequencies.word = :word and word_frequencies.the_type = :the_type", {:word => item[:word], :the_type => item[:the_type] }] )
      if existing.blank?
        the_freq = WordFrequency.create(item)
      elsif existing.frequency != item[:frequency].to_i
        existing.frequency = item[:frequency].to_i
        existing.save!
      end
      #puts "the_freq = #{the_freq.inspect}"
    end
  end
    
  def self.save_investigator_frequency_map
    all_words = get_investigator_words
    frequency_map = generate_frequency_map(all_words, 'Investigator')
    puts "frequency_map: #{frequency_map.length}"
    save_frequency_map(frequency_map)
  end
  
  def self.save_abstract_frequency_map
    all_words = get_abstract_words
    frequency_map = generate_frequency_map(all_words, 'Abstract')
    puts "frequency_map: #{frequency_map.length}"
    save_frequency_map(frequency_map)
  end
    
  
  def self.generate_frequency_map(word_array, the_type, high_frequency_words=[])
    frequency_map = []
    unique_words = word_array.uniq
    
    unique_words.each do  |word|
      unless (FILLER_WORDS.include?(word) or high_frequency_words.include?(word) or word.length < 3 or unique_words.include?(word + "s") )
          frequency_map << { :word => word, :frequency => word_array.count(word).to_i, :the_type => the_type }
      end
    end
    frequency_map
  end
    
  
end

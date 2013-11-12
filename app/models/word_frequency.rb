# == Schema Information
# Schema version: 20130327155943
#
# Table name: word_frequencies
#
#  created_at :timestamp
#  frequency  :integer
#  id         :integer          default(0), not null, primary key
#  the_type   :string(255)
#  updated_at :timestamp
#  word       :string(255)
#

class WordFrequency < ActiveRecord::Base

  require 'utilities'

  attr_accessible :the_type, :word, :frequency
FILLER_WORDS = ["the", "of", "and", "as", "to", "a", "in", "that", "with", "for", "an", "at", "not", "by", "on", "but", "or", "from", "its", "when", "this", "these", "i", "was", "is", "we", "have", "some", "into", "may", "well", "there", "our", "it", "me", "you", "what", "which", "who", "whom", "those", "are", "were", "be", "however","been", "being", "has", "had", "do", "did", "doing", "will", "can", "isn't", "aren't", "wasn't", "weren't", "to", "very", "would", "also", "after", "other", "whose", "upon", "their", "could", "all", "none", "no", "us", "here", "eg", "how", "where", "such", "many", "more", "than", "highly", "annotation", "annotations", "along", "each", "both", "then", "any", "same", "only", "significant", "significantly", "without", "versus", "likely", "while", "later", "whether", "might", "particular", "among", "thus", "every", "through", "over", "thereby", "about", "they", "your", "them", "within", "should", "much", "because", "ie", "between", "aka", "either", "under", "fully", "most", "since", "using", "used", "if", "nor", "yet", "easily", "moreover", "despite", "does", "quite", "less", "her", "found", "via", "type", "review", "age", "last", "purpose", "new", "takes", "own", "easily", "problem", ]

  named_scope :abstract_words, 
      :conditions => ["word_frequencies.the_type = 'Abstract'"]

  named_scope :investigator_words, 
      :conditions => ["word_frequencies.the_type = 'Investigator'"]

  named_scope :more_than, lambda { |the_freq|
    {:conditions => ['word_frequencies.frequency >= :the_freq ', {:the_freq => the_freq}] }
  }

  @@cutoff = (Investigator.count/5) + 10
  @@high_freq_words = WordFrequency.investigator_words.more_than(@@cutoff).map(&:word)



  def self.get_abstract_words
    Abstract.abstracts_last_five_years.abstract_words
  end

  def self.get_investigator_words
    Investigator.abstract_words
  end

  def self.save_frequency_map(frequency_map)
    frequency_map.each do |item|
      save_frequency_hash(item)
    end
  end
  
  def self.save_frequency_hash(item)
    existing = WordFrequency.find(:first, :conditions=>["word_frequencies.word = :word and word_frequencies.the_type = :the_type", {:word => item[:word], :the_type => item[:the_type] }] )
    if existing.blank?
      the_freq = WordFrequency.create(item)
    elsif existing.frequency != item[:frequency].to_i
      existing.frequency = item[:frequency].to_i
      existing.save!
    end
  end
  
  def self.save_investigator_frequency_map
    # takes about 6 hours with Ruby 1.9 and Rails 2.3 for 66K unique words and 1.6M total words, 3K unique investigators
    all_words = get_investigator_words
    unique_words = all_words.sort.uniq
    puts "save_investigator_frequency_map:all_words: #{all_words.length}; unique_words: #{unique_words.length}"
    row_iterator(unique_words, 0, 2000) {|word| create_frequency_word(word,all_words,unique_words,'Investigator')} 
  end
  
  def self.save_abstract_frequency_map
    # takes about 3 hours with Ruby 1.9 and Rails 2.3 for 66K unique words and 1.6M total words, 40K unique publications
    all_words = get_abstract_words
    unique_words = all_words.sort.uniq
    puts "save_abstract_frequency_map:all_words: #{all_words.length}; unique_words: #{unique_words.length}"
    row_iterator(unique_words, 0, 2000) {|word| create_frequency_word(word,all_words,unique_words,'Abstract')} 
  end

  def self.create_frequency_word(word, word_array, unique_words, the_type)
    unless (FILLER_WORDS.include?(word) or word.length < 3 or unique_words.include?(word + "s") )
      frequency_hash = { :word => word, :frequency => word_array.count(word).to_i, :the_type => the_type }
      save_frequency_hash(frequency_hash)
      #puts "frequency_hash: #{frequency_hash.inspect}"
    end
  end
  
  def self.generate_frequency_map(word_array, the_type, high_frequency_words=[], unique_words=[])
    frequency_map = []
    unique_words = word_array.uniq if unique_words.blank?
    
    unique_words.each do  |word|
      unless (FILLER_WORDS.include?(word) or high_frequency_words.include?(word) or word.length < 3 or unique_words.include?(word + "s") )
          frequency_map << { :word => word, :frequency => word_array.count(word).to_i, :the_type => the_type }
      end
    end
    frequency_map
  end
  
  def self.cutoff
    @@cutoff
  end
  def self.high_freq_words
    @@high_freq_words
  end
  
  def self.investigator_wordle_data(investigator)
    # investigator.abstract_words is limited to last 5 years. you can use investigator.abstracts.most_recent(25).abstract_words to get a different cut of the data
    frequency_map =  generate_frequency_map(investigator.abstract_words, 'Abstract', high_freq_words)
    return frequency_map.sort_by{|word| word[:frequency]}
  end
  
  def self.investigators_wordle_data(investigators)
    shared_words =investigators.first.unique_abstract_words
    all_words =[]
    investigators.each do |investigator|
      all_words = all_words + investigator.abstract_words
      shared_words = shared_words & investigator.unique_abstract_words
    end
    frequency_map = generate_frequency_map(all_words, 'Abstract', high_freq_words, shared_words)
    return frequency_map.sort_by{|word| word[:frequency]}
  end
  
  def self.investigators_difference_wordle_data(investigators)
    all_words = investigators.first.abstract_words
    uniq_words = all_words.uniq - investigators[1].unique_abstract_words
    frequency_map = generate_frequency_map(all_words, 'Abstract', high_freq_words, uniq_words)
    return frequency_map.sort_by{|word| word[:frequency]}
  end
  
  def self.wordle_distribution(words, max_words=300)
    words = words[0, max_words/2] + words[words.length - max_words/2, max_words/2]
    words.uniq!
    return words
  end
  
end

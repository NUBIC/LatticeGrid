class CreateWordFrequencies < ActiveRecord::Migration
  def self.up
    create_table :word_frequencies do |t|
      t.integer :frequency
      t.string :word
      t.string :the_type

      t.timestamps
    end
    add_index(:word_frequencies, [:word, :the_type], :unique=>true, :name => 'by_word_type_unique')
    add_index(:word_frequencies, [:word], :name => 'by_word')
  end

  def self.down
    drop_table :word_frequencies
  end
end

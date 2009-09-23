class CreateJournals < ActiveRecord::Migration
  def self.up
    create_table :journals do |t|
      t.string :journal_name
      t.string :journal_abbreviation
      t.string :jcr_journal_abbreviation
      t.string :issn
      t.integer :score_year
      t.integer :total_cites
      t.float :impact_factor
      t.float :impact_factor_five_year
      t.float :immediacy_index
      t.integer :total_articles
      t.float :eigenfactor_score
      t.float :article_influence_score

      t.timestamps
    end
  end

  def self.down
    drop_table :journals
  end
end

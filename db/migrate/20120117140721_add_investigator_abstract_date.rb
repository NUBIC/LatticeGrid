require "migration_helper"
class AddInvestigatorAbstractDate < ActiveRecord::Migration
  extend MigrationHelper
  def self.up
    add_column :investigator_abstracts, :publication_date, :date
    pi_abs = InvestigatorAbstract.all
    puts "setting #{pi_abs.length} publication_dates for pi_ab.publication_date"
    pi_abs.each_with_index do |pi_ab, cnt|
      unless pi_ab.abstract_id.blank? or  pi_ab.abstract.blank?
        pi_ab.publication_date = pi_ab.abstract.publication_date || pi_ab.abstract.electronic_publication_date || pi_ab.abstract.deposited_date
        pi_ab.save
      end
      if (cnt/1000.0) == (cnt/1000).to_i and cnt > 0
        puts "setting pi_ab.publication_date  - #{cnt}"
      end
    end
  end

  def self.down
    remove_column :investigator_abstracts, :publication_date
  end
end

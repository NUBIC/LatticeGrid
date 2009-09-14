class InsertOrgs < ActiveRecord::Migration
  def self.up
        Program.create :program_number => "1", :program_abbrev => "VO",   :program_title => "Viral Oncogenesis", :program_category => "Basic Science", :start_date => "01-SEP-2007"
        Program.create :program_number => "2", :program_abbrev => "TIMA", :program_title => "Tumor Invasion, Metastasis and Angiogenesis", :program_category => "Basic Science", :start_date => "01-SEP-2007"
        Program.create :program_number => "6", :program_abbrev => "BC",   :program_title => "Breast Cancer", :program_category => "Clinical", :start_date => "01-SEP-2007"
        Program.create :program_number => "7", :program_abbrev => "PRO",  :program_title => "Prostate Cancer", :program_category => "Clinical", :start_date => "01-SEP-2007"
        Program.create :program_number => "9", :program_abbrev => "CP",   :program_title => "Cancer Prevention", :program_category => "Clinical", :start_date => "01-SEP-2007"
        Program.create :program_number => "10", :program_abbrev => "CC",  :program_title => "Cancer Control", :program_category => "Clinical", :start_date => "01-SEP-2007"
 
        Program.create :program_number => "13", :program_abbrev => "NP",  :program_title => "Non-Programmatically Aligned", :program_category => "NP", :start_date => "01-SEP-2007"

    #    Program.create :program_number => "12", :program_abbrev => "Assoc",  :program_title => "Associate Members", :program_category => "AM", :start_date => "01-SEP-2007"

  end

  def self.down
    Program.delete_all 
  end
end

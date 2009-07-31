require 'fastercsv'

require 'journal_utilities'
require 'investigator_program_utilities'

# -*- ruby -*-

def ReadInvestigatorData (filename)
  errors = ""

  data = FasterCSV.read(filename, :col_sep => "\t", :headers => :first_row)
  puts Investigator.find(:all).length
  data.each do |data_row|
    begin
      CreateInvestigatorFromHash(data_row)
    rescue
      puts "something happened"+$!.message
      errors += $!.message
      puts data_row.inspect
      throw data_row.inspect
    end
  end
  puts Investigator.find(:all).length
end

def ReadJournalImpactData(filename)
    errors = ""

    data = FasterCSV.read(filename, :col_sep => ";", :headers => :first_row)
    puts Journal.find(:all).length
    data.each do |data_row|
      begin
        CreateJournalImpactFromHash(data_row)
      rescue
        puts "something happened"+$!.message
        errors += $!.message
        puts data_row.inspect
        throw data_row.inspect
      end
    end
    puts Journal.find(:all).length
  end


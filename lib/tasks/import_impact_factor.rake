require 'pubmed_config' #look here to change the default time spans
require 'file_utilities' #specific methods
require 'journal_utilities' #specific methods
require 'utilities' #block_timing

require 'rubygems'
require 'pathname'

task :importJournalImpact => :environment do
   if ENV["file"].nil?
     puts "couldn't find a file in the calling parameters. Please call as 'rake importJournalImpact file=filewithpath'" 
   else
     block_timing("importJournalImpact") {
       puts "file: "+ENV["file"]
       ENV["file"].split(',').each do | filename |
         p1 = Pathname.new(filename) 
         if p1.file? then
           ReadJournalImpactData(filename)
         else
           puts "unable to open file #{filename}"
         end
       end
     }
   end
end

task :importJournalISOnames => :environment do
   if ENV["file"].nil?
     puts "couldn't find a file in the calling parameters. Please call as 'rake importJournalISOnames file=filewithpath'" 
   else
     block_timing("importJournalISOnames") {
       puts "file: "+ENV["file"]
       ENV["file"].split(',').each do | filename |
         p1 = Pathname.new(filename) 
         if p1.file? then
           ReadJournalISOnamesData(filename)
         else
           puts "unable to open file #{filename}"
         end
       end
     }
   end
end

task :cleanJournalISSNentries => :environment do
  block_timing("cleanJournalISSNentries") {
    mismatched = Abstract.mismatched_issns
    puts "mismatched entries: #{mismatched.length}"
    mismatched.each do |x|
      puts "mismatched: #{x.journal_abbreviation}\t#{x.issn}"
    end
    nulled_issns = Abstract.nulled_issns
    puts "nulled_issns entries: #{nulled_issns.length}"
    nulled_issns.each do |x|
      puts "updating records: #{x.journal_abbreviation}\t#{x.issn}"
      Abstract.update_all( "issn = '#{x.issn}'", "journal_abbreviation = '#{x.journal_abbreviation}'" )
    end
  }
end

task :findAbstractswithoutJCRentries => :environment do
  block_timing("findAbstractswithoutJCRentries") {
    without_jcr_entries = Abstract.without_jcr_entries
    puts "without JCR entries: #{without_jcr_entries.length}"
    without_jcr_entries.each do |x|
      puts "without_jcr_entries: #{x.journal_abbreviation}\t#{x.issn}"
    end
    puts "Count of journals without_jcr_entries: #{without_jcr_entries.length}"
  }
end

task :findAbstractswithJCRentries => :environment do
  block_timing("findAbstractswithJCRentries") {
    with_jcr_entries = Abstract.with_jcr_entries
    puts "with JCR entries: #{with_jcr_entries.length}"
    with_jcr_entries.each do |x|
      puts "with_jcr_entries: #{x.journal_abbreviation}\t#{x.issn}"
    end
    puts "Count of journals with_jcr_entries: #{with_jcr_entries.length}"
  }
end

task :updateJournalISSNsFromPubmed => :environment do
  block_timing("UpdateJournalISSNsFromPubmed") {
    UpdateJournalISSNsFromPubmed()
  }
end

task :setPreferredHighImpact => :environment do
  block_timing("setPreferredHighImpact") {
    UpdateJournalHighImpactPreferred()
  }
end



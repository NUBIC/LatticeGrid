require 'pubmed_config' #look here to change the default time spans
require 'file_utilities' #specific methods
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

task :getJournalsWithImpactFactor => :environment do
  block_timing("getJournalsWithImpactFactor") {
    all_journals=CurrentJournals()
    puts "total number of journals: #{all_journals.length}"
    journals_with_impact = CurrentJournalsWithImpactScore(all_journals)
    journals_found = journals_with_impact.collect{|a|a.journal_abbreviation.downcase}  
    journals_found.sort!
    puts "number of journals found with impact factor: #{journals_found.length}"
    journals_found.each do |x|
      puts "found: #{x}"
    end
    not_found = all_journals-journals_found
    not_found.sort!.uniq!
    puts "number of journals not found: #{not_found.length}"
    not_found.each do |x|
      puts "not found: #{x}"
    end
  }
end

task :getAllJournalsWithImpactFactor => :environment do
  block_timing("getAllJournalsWithImpactFactor") {
    all_journals=AllJournalsWithImpact()
    puts "total number of journals: #{all_journals.length}"
    all_journals.each do |x|
      puts "impact: #{x}"
    end
  }
end

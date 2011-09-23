require 'pubmed_config' #look here to change the default time spans
require 'file_utilities' #specific methods
require 'study_utilities' #specific methods
require 'utilities' #block_timing

require 'rubygems'
require 'pathname'

task :importStudies => :environment do
   if ENV["file"].nil?
     puts "couldn't find a file in the calling parameters. Please call as 'rake importStudies file=filewithpath'" 
   else
     block_timing("importStudies") {
       puts "file: "+ENV["file"]
       ENV["file"].split(',').each do | filename |
         p1 = Pathname.new(filename) 
         if p1.file? then
           ReadStudyData(filename)
         else
           puts "unable to open file #{filename}"
         end
       end
     }
   end
end

task :importStudyInvestigators => :environment do
   if ENV["file"].nil?
     puts "couldn't find a file in the calling parameters. Please call as 'rake importStudyInvestigators file=filewithpath'" 
   else
     block_timing("importStudyInvestigators") {
       puts "file: "+ENV["file"]
       ENV["file"].split(',').each do | filename |
         p1 = Pathname.new(filename) 
         if p1.file? then
           ReadStudyInvestigatorData(filename)
         else
           puts "unable to open file #{filename}"
         end
       end
     }
   end
end

task :findStudiesWithoutInvestigators => :environment do
  block_timing("findStudiesWithoutInvestigators") {
    studies_without_investigators = Study.without_investigators()
    puts "studies without investigators: #{studies_without_investigators.length}"
    puts "report\teIRB STU\tApproved on\tReviewed on\tCompleted on\tReview type\tresearch type"
    studies_without_investigators.each do |x|
      puts "studies_without_investigators\t #{x.title}\t#{x.irb_study_number}\t#{x.enotis_study_id}\t#{x.approved_date}\t#{x.next_review_date}\t#{x.completed_date}\t#{x.review_type}\t#{x.research_type}"
    end
    puts "Count of studies without investigators: #{studies_without_investigators.length}"
  }
end

task :deleteStudiesWithoutInvestigators => :environment do
  block_timing("deleteStudiesWithoutInvestigators") {
    studies_without_investigators = Study.without_investigators()
    puts "deleting #{studies_without_investigators.length} studies without investigators"

    studies_without_investigators.each do |study|
      puts "studies_without_investigators: #{study.title}\t#{study.irb_study_number}\t#{study.enotis_study_id}"
      study.delete
    end
    puts "done."
  }
end



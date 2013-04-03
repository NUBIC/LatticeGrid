require 'file_utilities' #specific methods
require 'utilities' # was row_iterator and other methods
require 'format_helper'

require 'rubygems'

namespace :reports do
  study_list = []
  
  desc "useful for taking a list of netids and looking up in the FSM faculty database and resolving against LDAP"
  
  desc "useful for taking an investigator name and breaking into first_name, middle_name, last_name, suffix"
  task :studies_to_pi => :environment do
    puts "username\tname\tSTU\tirb_study_number\tStatus\tApproved date\tNext review date\tTitle"
    study_list.each do |stu|
      study = Study.find_by_irb_study_number(stu)
      if study.blank?
        puts "unable to find STU #{stu}"
      elsif study.pi.blank?
        puts "unable to find PI for #{stu}"
      else
        puts "#{study.pi.username}\t#{study.pi.name}\t#{stu}\t#{study.irb_study_number}\t#{study.status}\t#{study.approved_date}\t#{study.next_review_date}\t#{study.title.gsub(/[\r\n]+/,'')}"
      end
    end
  end

 
 end



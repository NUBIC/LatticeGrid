require 'award_utilities' #specific methods
require 'file_utilities' #specific methods
require 'utilities' #specific methods

require 'rubygems'
require 'pathname'

namespace :awards do
  task :importData => :environment do
    @AllAwards = Proposal.all
    puts "count of all proposals is #{@AllAwards.length}" if LatticeGridHelper.verbose?
    read_file_handler("awards:importData" ) {|filename| ReadAwardData(filename)}
    if defined?(@not_found_employee_messages)
      puts "Number of employees not found: #{@not_found_employee_messages.length}"
      # puts @not_found_employee_messages.join("\n")
    end
    @AllAwards = Proposal.all
    puts "count of all proposals is #{@AllAwards.length}" if LatticeGridHelper.verbose?
  end

  task :clear => :environment do
    puts "count of all proposals is #{Proposal.count} and InvestigatorProposals is #{InvestigatorProposal.count}" if LatticeGridHelper.verbose?
    InvestigatorProposal.delete_all
    Proposal.delete_all
    puts "all deleted"
  end

  task :mergeData => :environment do
    @awards = Proposal.child_awards
    @parent_awards = Proposal.with_children
    puts "Merging awards where parent_institution_award_number does not equal institution_award_number" if LatticeGridHelper.verbose?
    puts "count of child awards is #{@awards.length}" if LatticeGridHelper.verbose?
    puts "count of awards with children is #{@parent_awards.length}" if LatticeGridHelper.verbose?
    @parent_awards.each do |award|
      merge_child_records(award)
    end
    unless @unmatched_parent_awards.blank?
      puts "unable to find #{@unmatched_parent_awards.length} parent awards"
      @unmatched_parent_awards.each do |award_id|
        puts "unable to find parent award #{award_id}"
      end
    end
  end

  task :cleanDates => :getAwards do
    block_timing("awards:cleanDates") {
      @AllAwards.each do |award|
        award.submission_date    = clean_date(award.submission_date)
        award.project_start_date = clean_date(award.project_start_date)
        award.project_end_date   = clean_date(award.project_end_date)
        award.award_start_date   = clean_date(award.award_start_date)
        award.award_end_date     = clean_date(award.award_end_date)
        award.save!
      end
    }
  end

  task :cleanPIassignments => :getAwards do
    block_timing("awards:cleanPIassignments") {
      no_pi_cnt=0
      multiple_pi_cnt=0
      corrected_pi_cnt=0
      @AllAwards.each do |award|
        pis = award.investigator_proposals.pis
        if pis.length == 0
          no_pi_cnt+=1
        end
        if pis.length > 1
          multiple_pi_cnt+=1
          main_pi=0
          has_pi_employee_id = false
          pis.each do |pi|
            main_pi+=1 if pi.is_main_pi
            unless pi.investigator.blank?
              has_pi_employee_id = true if pi.investigator.employee_id.to_i == award.pi_employee_id.to_i
            end
          end
          if main_pi == 0
            puts "no main pi for an award with multiple pis. #{award.inspect}"
          elsif main_pi > 1 and not has_pi_employee_id
            puts "multiple main pi for an award with multiple pis and listed_pi is not a pi. #{award.institution_award_number};  #{award.sponsor_award_number}; #{award.title}; #{award.inspect}"
          elsif main_pi > 1 and has_pi_employee_id
            corrected_pi_cnt+=1
            pis.each do |pi|
              unless pi.investigator.blank?
                if  pi.investigator.employee_id.to_i != award.pi_employee_id.to_i
                  pi.role = 'Co-Investigator'
                  pi.save!
                end
              end
            end
          else
            corrected_pi_cnt+=1
            pis.each do |pi|
              if !pi.is_main_pi
                pi.role = 'Co-Investigator'
                pi.save!
              end
            end
          end
        end
      end
      puts "completed cleanPIassignments. no_pi_cnt=#{no_pi_cnt}; multiple_pi_cnt=#{multiple_pi_cnt}; corrected_pi_cnt=#{corrected_pi_cnt};"
    }
  end
end
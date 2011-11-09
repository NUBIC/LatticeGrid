require 'file_utilities' #specific methods
require 'utilities' # was row_iterator and other methods
require 'app/helpers/format_helper'
include FormatHelper

require 'rubygems'

namespace :reports do

  task :netids_to_orgs => :environment do
    read_file_handler("netids_to_organization" ) {|filename| ReadNetIDgenerateReport(filename)}
  end

  task :name_to_fields => :environment do
    read_file_handler("name_to_fields" ) {|filename| ReadNamesAndSplit(filename)}
  end

  task :abstracts_by_type => :environment do
    abstract_types = Abstract.all(:select=>"distinct publication_type")
    abstract_types.each do |abstract_type|
      publication_type = abstract_type.publication_type
      the_count = Abstract.count(:conditions=>["publication_type = :publication_type", {:publication_type => publication_type}] )
      puts "#{publication_type}\t#{the_count}"
    end
  end

  task :investigator_abstracts_reviewed => :environment do
    ias = InvestigatorAbstract.all(:conditions=>"last_reviewed_id > 0", :order=>"investigator_id, abstract_id")
    puts "investigator_id\tabstract_id\tis_valid\tlast_reviewed_at\tlast_reviewed_id\tlast_reviewed_ip"
    ias.each do |ia|
      puts "#{ia.investigator_id}\t#{ia.abstract_id}\t#{ia.is_valid}\t#{formatted_date(ia.last_reviewed_at)}\t#{ia.last_reviewed_id}\t#{ia.last_reviewed_ip}"
    end
  end

  task :mark_abstracts_approved => :environment do
    approvals = Log.all(:conditions=>"activity = 'profiles:update' and params like '%publications%'", :order=>"created_at desc")
    puts "Number of approvals: #{approvals.length}"
    approvals.each do |approval|
      # created_ip: "99.140.210.25", created_at: "2011-06-12 13:09:03", updated_at: "2011-06-12 13:09:03">, #<Log id: 361, activity: "profiles:update", investigator_id: 118, program_id: nil, controller_name: "profiles", action_name: "update", params: "{\"commit\"=>\"Approve publications list\", \"authentici...", created_ip: "129.105.228.35", created_at: "2011-06-07 23:02:47", updated_at: "2011-06-07 23:02:47">] 
      ias = approval.investigator.investigator_abstracts
      marked = 0
      newer = 0
      abstract_ids = []
      ias.each do |ia|
        newer += 1 if (ia.created_at > approval.created_at)
          
        if (ia.created_at < approval.created_at) then
          if ((ia.last_reviewed_id.blank? or ia.last_reviewed_id == 0) or ia.last_reviewed_at.blank? or (ia.last_reviewed_at < approval.created_at)) then
            if (!ia.last_reviewed_at.blank? and (ia.last_reviewed_at < approval.created_at) and not ia.last_reviewed_id == approval.investigator_id ) then
              puts "overwriting old review with new approval: old: #{ia.last_reviewed_at}; IP:#{ia.last_reviewed_ip}; ID:#{ia.last_reviewed_id}. New: #{approval.created_at}; IP: #{approval.created_ip}; By: #{approval.investigator.name} (#{approval.investigator_id})"
            end
            ia.last_reviewed_at = approval.created_at
            ia.last_reviewed_id = approval.investigator_id
            ia.last_reviewed_ip = approval.created_ip
            ia.save!
            marked+=1
          end
          abstract_ids << ia.abstract_id
        end
      end
      abstract_ids = abstract_ids.sort.uniq
      other_marked=0
      other_ias = InvestigatorAbstract.all(:conditions=>["last_reviewed_id=0 and abstract_id in (:ids)", {:ids=>abstract_ids}])
      other_ias.each do |ia|
        ia.last_reviewed_at = approval.created_at
        ia.last_reviewed_id = approval.investigator_id
        ia.last_reviewed_ip = approval.created_ip
        ia.save!
        other_marked+=1
      end
      abs_cnt=0
      abs = Abstract.all(:conditions=>["(last_reviewed_id=0 or last_reviewed_id is null) and id in (:ids)", {:ids=>abstract_ids}])
      abs.each do |ab|
        ab.last_reviewed_at = approval.created_at
        ab.last_reviewed_id = approval.investigator_id
        ab.last_reviewed_ip = approval.created_ip
        ab.save!
        abs_cnt+=1
      end
      puts "investigator_abstracts: #{ias.length}; Stamped: #{marked}; Newer: #{newer}; Other stamped: #{other_marked}; Abstracts: #{abstract_ids.length}; Abstracts stamped: #{abs_cnt}; Investigator #{approval.investigator.name} (#{approval.investigator_id})."
    end
    # now handle investigator abstracts marked as invalid but not by associated by one of the above
    
    invalid_ias = InvestigatorAbstract.all(:conditions=>"investigator_abstracts.last_reviewed_id=0 and investigator_abstracts.is_valid = false")
    pi = Investigator.find_by_username("wakibbe")
    pi = Investigator.all.first if pi.blank?
    invalid_ias.each do |ab|
      ab.last_reviewed_id = pi.id
      ab.save!
    end
    puts "#{invalid_ias.length} invalid investigator_abstract records were marked as belonging to #{pi.name} (#{pi.id}) since no other information was available." if invalid_ias.length > 0
  end
end



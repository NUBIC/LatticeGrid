require 'csv'

namespace :export do

  task :uuidify => :environment do 
    [Investigator, OrganizationalUnit, InvestigatorAppointment, Abstract, InvestigatorAbstract].each do |cls|
      cls.all.each { |record| record.save! }
    end
  end

  task :abstracts => :environment do 

    if ENV['NET_ID']
      pi = Investigator.find_all_by_username(ENV['NET_ID']).first
      pis = [pi]
      as = pi.abstracts
      filename = "#{ENV['NET_ID']}_abstracts"
    else
      as = Abstract.all
      filename = 'abstracts'
    end

    cols = %w(id uuid title journal journal_abbreviation publication_date publication_status year volume issue pages start_page end_page doi issn isbn pubmed pubmedcentral abstract endnote_citation mesh)
    CSV.open("#{Rails.root}/vivo/#{filename}.csv", 'wb', :col_sep => ',') do |csv|
      csv << cols
      as.each do |a|
        arr = []
        cols.each { |col| arr << a.send(col.to_sym) }
        csv << arr.map(&:to_s)
      end
    end
  end

  task :investigator_abstracts => :environment do 

    if ENV['NET_ID']
      pi = Investigator.find_all_by_username(ENV['NET_ID']).first
      pis = [pi]
      ias = pi.investigator_abstracts
      filename = "#{ENV['NET_ID']}_investigator_abstracts"
    else
      ias = InvestigatorAbstract.all
      filename = 'investigator_abstracts'
    end

    cols = %w(id uuid investigator_uuid abstract_uuid is_first_author is_last_author)
    CSV.open("#{Rails.root}/vivo/#{filename}.csv", 'wb', :col_sep => ',') do |csv|
      csv << cols
      ias.each do |ia|
        next if ia.investigator.blank? || ia.abstract.blank?
        arr = []
        cols.each { |col| arr << ia.send(col.to_sym) }
        csv << arr.map(&:to_s)
      end
    end
  end

  def create_organizational_unit_csv(csv, records)
    cols = %w(id uuid abbreviation campus department_id division_id name organization_classification organization_phone organization_url search_name type)
    csv << cols
    records.each do |ou|
      arr = []
      cols.each { |col| arr << ou.send(col.to_sym) }
      csv << arr.map(&:to_s)
    end
  end

  task :departments => :environment do
    CSV.open("#{Rails.root}/vivo/departments.csv", 'wb', :col_sep => ',') do |csv|
      create_organizational_unit_csv(csv, Department.all)
    end
  end

  task :divisions => :environment do
    CSV.open("#{Rails.root}/vivo/divisions.csv", 'wb', :col_sep => ',') do |csv|
      create_organizational_unit_csv(csv, Division.all)
    end
  end

  task :centers => :environment do
    CSV.open("#{Rails.root}/vivo/centers.csv", 'wb', :col_sep => ',') do |csv|
      create_organizational_unit_csv(csv, Center.all)
    end
  end

  task :investigators => :environment do

    if ENV['NET_ID']
      pi = Investigator.find_all_by_username(ENV['NET_ID']).first
      pis = [pi]
      filename = "#{ENV['NET_ID']}_investigator"
    else
      pis = Investigator.all
      filename = "investigators"
    end

    cols = %w(id uuid appointment_basis appointment_type campus degrees email employee_id end_date era_commons_name faculty_interests faculty_research_summary name display_name first_name last_name middle_name suffix title username)
    CSV.open("#{Rails.root}/vivo/#{filename}.csv", 'wb', :col_sep => ',') do |csv|
      csv << cols
      pis.each do |pi|
        arr = []
        cols.each { |col| arr << pi.send(col.to_sym) }
        csv << arr.map(&:to_s)
      end
    end
  end

  task :investigator_appointments => :environment do

    if ENV['NET_ID']
      pi = Investigator.find_all_by_username(ENV['NET_ID']).first
      pis = [pi]
      ias = pi.investigator_appointments
      filename = "#{ENV['NET_ID']}_investigator_appointments"
    else
      ias = InvestigatorAppointment.all
      pis = Investigator.all
      filename = 'investigator_appointments'
    end

    cols = %w(id uuid investigator_uuid organizational_unit_uuid type)
    CSV.open("#{Rails.root}/vivo/#{filename}.csv", 'wb', :col_sep => ',') do |csv|
      csv << cols
      ias.each do |ia|
        next if ia.investigator.blank? || ia.organizational_unit.blank?
        arr = []
        cols.each { |col| arr << ia.send(col.to_sym)  }
        csv << arr.map(&:to_s)
      end
      pis.each do |i|
        next if i.home_department.blank?
        arr = []
        arr << 100000 + i.id            # id
        arr << 'no_uuid'
        arr << i.uuid                   # investigator_id
        arr << i.home_department.uuid   # organizational_unit_id
        arr << 'Primary'
        csv << arr
      end
    end
  end

end

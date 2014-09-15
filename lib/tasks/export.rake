require 'csv'

namespace :export do

  def create_organizational_unit_csv(csv, records)
    cols = %w(id abbreviation campus department_id division_id name organization_classification organization_phone organization_url search_name type)
    csv << cols
    records.each do |ou|
      arr = []
      cols.each { |col| arr << ou.send(col.to_sym) }
      csv << arr.map(&:to_s)
    end
  end

  task :departments => :environment do
    CSV.open("#{Rails.root}/tmp/departments.csv", 'wb', :col_sep => ',') do |csv|
      create_organizational_unit_csv(csv, Department.all)
    end
  end

  task :divisions => :environment do
    CSV.open("#{Rails.root}/tmp/divisions.csv", 'wb', :col_sep => ',') do |csv|
      create_organizational_unit_csv(csv, Division.all)
    end
  end

  task :centers => :environment do
    CSV.open("#{Rails.root}/tmp/centers.csv", 'wb', :col_sep => ',') do |csv|
      create_organizational_unit_csv(csv, Center.all)
    end
  end

  task :investigators => :environment do
    cols = %w(id appointment_basis appointment_type campus degrees email employee_id faculty_interests faculty_research_summary name first_name last_name middle_name suffix title username)
    CSV.open("#{Rails.root}/tmp/investigators.csv", 'wb', :col_sep => ',') do |csv|
      csv << cols
      Investigator.all.each do |pi|
        arr = []
        cols.each { |col| arr << pi.send(col.to_sym) }
        csv << arr.map(&:to_s)
      end
    end
  end

  task :investigator_appointments => :environment do
    cols = %w(id investigator_id organizational_unit_id type)
    CSV.open("#{Rails.root}/tmp/investigator_appointments.csv", 'wb', :col_sep => ',') do |csv|
      csv << cols
      InvestigatorAppointment.all.each do |ia|
        arr = []
        cols.each { |col| arr << ia.send(col.to_sym)  }
        csv << arr.map(&:to_s)
      end
      Investigator.all.each do |i|
        arr = []
        arr << 100000 + i.id          # id
        arr << i.id                   # investigator_id
        arr << i.home_department_id   # organizational_unit_id
        arr << 'Primary'
        csv << arr
      end
    end
  end

end

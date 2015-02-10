require 'csv'

namespace :export do

  task :uuidify => :environment do 
    [Investigator, OrganizationalUnit, InvestigatorAppointment, Abstract, InvestigatorAbstract].each do |cls|
      cls.all.each { |record| record.save! }
    end
  end

  def headers_and_attributes
    {
      'ID'                                => 'id',
      'uuid'                              => 'uuid',
      'Title'                             => 'title',
      'Journal OR Published proceedings'  => 'journal',
      'journal_abbreviation'              => 'journal_abbreviation',
      'Publication Date1'                 => 'publication_date_csv',
      'publication_status'                => 'publication_status',
      'publication_type'                  => 'publication_type',
      'year'                              => 'year',
      'Volume'                            => 'volume',
      'Issue'                             => 'issue',
      'pages'                             => 'pages',
      'Pagination (start page)'           => 'start_page',
      'Pagination (end page)'             => 'end_page',
      'DOI'                               => 'doi',
      'ISSN'                              => 'issn',
      'isbn'                              => 'isbn',
      'pubmed'                            => 'pubmed',
      'pubmedcentral'                     => 'pubmedcentral',
      'abstract'                          => 'abstract',
      'Full Authors'                      => 'full_authors_csv',
      'Mesh Terms'                        => 'mesh_csv',
    }
  end

  # "Retraction of Publication"
  # "Technical Report"
  def publication_types
    {
      'autobiography'       => "'Autobiography'",
      'bibliography'        => "'Bibliography'",
      'biography'           => "'Biography'",
      'academic_article'    => "'Introductory Journal Article', 'Journal Article', 'JOURNAL ARTICLE', 'Classical Article', 'English Abstract', 'Historical Article', 'In Vitro', 'Meta-Analysis', 'Multicenter Study', 'Overall'",
      'speech'              => "'Addresses'",
      'presentation'        => "'Lectures'",
      'clinical_trial'      => "'Clinical Trial', 'Clinical Trial, Phase I', 'Clinical Trial, Phase II', 'Clinical Trial, Phase III', 'Clinical Trial, Phase IV', 'Controlled Clinical Trial'",
      'editorial_article'   => "'Editorial Article', 'EDITORIAL'",
      'comment'             => "'Comment'",
      'letter'              => "'Letter'",
      'article'             => "'Clinical Conference', 'Congresses', 'Newspaper Article', 'Research Support, U.S. Gov''t, P.H.S.'",
      'events'              => "'Consensus Development Conference', 'Consensus Development Conference, NIH'",
      'directory'           => "'Directory'",
      'comparative_study'   => "'Comparative Study'",
      'evaluation_study'    => "'Evaluation Studies'",
      'clinical_guideline'  => "'Clinical Guideline'",
      'news_release'        => "'News'",
      'erratum'             => "'Published Erratum'",
      'review'              => "'REVIEW'",
      'av_document'         => "'Video-Audio Media'",
    }
  end

  task :abstracts => :environment do 
    publication_types.each do |k, v|
      if ENV['NET_ID']
        pi = Investigator.find_all_by_username(ENV['NET_ID']).first
        abstracts = pi.abstracts.where("publication_type in (#{v})").to_a
        filename = "#{ENV['NET_ID']}_#{k}_abstracts"
      elsif ENV['NET_IDS']
        pis = Investigator.where("username in (?)", ENV['NET_IDS'].split(',')).to_a
        abstracts = [] 
        pis.each { |pi| abstracts << pi.abstracts.where("publication_type in (#{v})").to_a } 
        abstracts = abstracts.flatten
        filename = "subset_#{k}_abstracts"
      else
        abstracts = Abstract.where("publication_type in (#{v})").to_a
        filename = "#{k}_abstracts"
      end

      next if abstracts.blank?
      
      CSV.open("#{Rails.root}/vivo/#{filename}.csv", 'wb', :col_sep => ',') do |csv|
        csv << headers_and_attributes.keys
        abstracts.each do |a|
          arr = []
          headers_and_attributes.values.each { |at| arr << a.send(at.to_sym) }
          csv << arr.map(&:to_s)
        end
      end
    end
  end

  task :investigator_abstracts => :environment do 

    if ENV['NET_ID']
      pi = Investigator.find_all_by_username(ENV['NET_ID']).first
      pis = [pi]
      ias = pi.investigator_abstracts
      filename = "#{ENV['NET_ID']}_investigator_abstracts"
    elsif ENV['NET_IDS']
      pis = Investigator.where("username in (?)", ENV['NET_IDS'].split(',')).to_a
      ias = [] 
      pis.each { |pi| ias << pi.investigator_abstracts } 
      ias = ias.flatten
      filename = "subset_investigator_abstracts"
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
    elsif ENV['NET_IDS']
      pis = Investigator.where("username in (?)", ENV['NET_IDS'].split(',')).to_a
      filename = "subset_investigators"
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
    elsif ENV['NET_IDS']
      pis = Investigator.where("username in (?)", ENV['NET_IDS'].split(',')).to_a
      ias = [] 
      pis.each { |pi| ias << pi.investigator_appointments } 
      ias = ias.flatten
      filename = "subset_investigator_appointments"
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

class Investigator < ActiveRecord::Base
  acts_as_taggable  # for MeSH terms
  acts_as_tsearch :vectors => {:fields => ["first_name","last_name", "username", "title"]}

  has_many :logs
  has_many :investigator_studies
  has_many :studies, 
    :through => :investigator_studies
  has_many :investigator_pi_studies,  
    :class_name => "InvestigatorStudy",
    :conditions => ["investigator_studies.role = 'PI'"]
  
  has_many :investigator_proposals
  has_many :proposals, 
    :through => :investigator_proposals

  has_many :investigator_pi_proposals,  
    :class_name => "InvestigatorProposal",
    :conditions => ["investigator_proposals.role = 'PD/PI'"]

  has_many :pi_proposals, 
    :source => :proposal,
    :through => :investigator_pi_proposals
    
  has_many :investigator_nonpi_proposals,  
    :class_name => "InvestigatorProposal",
    :conditions => ["NOT investigator_proposals.role = 'PD/PI'"]
  
  has_many :nonpi_proposals, 
    :source => :proposal,
    :through => :investigator_nonpi_proposals

  has_many :current_proposals, 
    :source => :proposal,
    :through => :investigator_proposals,
    :conditions => ['proposals.award_end_date >= :now', {:now => Date.today }]

  has_many :current_pi_proposals, 
    :source => :proposal,
    :through => :investigator_pi_proposals,
    :conditions => ['proposals.award_end_date >= :now', {:now => Date.today }]

  has_many :current_nonpi_proposals, 
    :source => :proposal,
    :through => :investigator_nonpi_proposals,
    :conditions => ['proposals.award_end_date >= :now', {:now => Date.today }]


  has_many :investigator_abstracts
  
  has_many :investigator_colleagues
  has_many :colleague_investigators,
    :class_name => "InvestigatorColleague",
    :foreign_key => 'colleague_id'

  has_many :similar_investigators, 
      :class_name => "InvestigatorColleague", 
      :include => [:colleague], 
      :conditions => ['investigator_colleagues.publication_cnt=0 and investigator_colleagues.mesh_tags_ic > 2000'], 
      :order=>'mesh_tags_ic desc'
  has_many :all_similar_investigators, 
      :class_name => "InvestigatorColleague", 
      :include => [:colleague], 
      :conditions => ['investigator_colleagues.mesh_tags_ic > 500'], 
      :order=>'investigator_colleagues.mesh_tags_ic desc'
  has_many :co_authors, 
      :class_name => "InvestigatorColleague", 
      :include => [:colleague], 
      :conditions => ['investigator_colleagues.publication_cnt>0'], 
      :order=>'investigator_colleagues.publication_cnt desc'
  has_many :colleagues, :through => :investigator_colleagues
  has_many :abstracts, :through => :investigator_abstracts,
         :conditions => ['investigator_abstracts.is_valid = true']
#  has_many :investigator_abstracts_meshes
#  has_many :meshes, :through => :investigator_abstracts_meshes
has_many :investigator_appointments,
  :conditions => ['investigator_appointments.end_date is null or investigator_appointments.end_date >= :now', {:now => Date.today }]
  has_many :all_investigator_appointments,
    :class_name => "InvestigatorAppointment"

  has_many :joints, :class_name => "Joint",
    :conditions => ['investigator_appointments.end_date is null or investigator_appointments.end_date >= :now', {:now => Date.today }]
  has_many :secondaries, :class_name => "Secondary",
      :conditions => ['investigator_appointments.end_date is null or investigator_appointments.end_date >= :now', {:now => Date.today }]
  has_many :member_appointments, :class_name => "Member",
        :conditions => ['investigator_appointments.end_date is null or investigator_appointments.end_date >= :now', {:now => Date.today }]
  has_many :appointments, :source => :organizational_unit, :through => :investigator_appointments
  has_many :joint_appointments, :source => :organizational_unit, :through => :joints
  has_many :secondary_appointments, :source => :organizational_unit, :through => :secondaries
  has_many :memberships, :source => :organizational_unit, :through => :member_appointments
  # foreign_key is a fix for an issue in rails 2.3.5 and earlier
  belongs_to :home_department, :class_name => 'OrganizationalUnit', :foreign_key => 'home_department_id'

  accepts_nested_attributes_for :investigator_appointments
  accepts_nested_attributes_for :member_appointments

  named_scope :with_any_role, :include=>[:investigator_proposals], :conditions => "investigator_proposals.percent_effort >= 0"

  named_scope :full_time, :conditions => "appointment_basis = 'FT'"
  named_scope :tenure_track, :conditions => "appointment_type = 'Regular'"
  named_scope :research, :conditions => "appointment_type = 'Research'"
  named_scope :investigator, :conditions => "appointment_track like '%Investigator%'"
  named_scope :investigator_only, :conditions => "appointment_track = 'Investigator'"
  named_scope :clinician, :conditions => "appointment_track like '%Clinician%'"
  named_scope :clinician_only, :conditions => "appointment_track = 'Clinician'"
  named_scope :by_name, :order => "lower(last_name), lower(first_name)"

  named_scope :by_name, :order => "lower(last_name), lower(first_name)"

  named_scope :for_tag_ids, lambda { |*ids|
    {:joins => [:taggings], 
     :conditions => ['taggings.tag_id IN (:ids) ', {:ids => ids.first}] }
  }
  named_scope :complement_of_ids, lambda { |*ids|
    {:conditions => ['investigators.id NOT IN (:ids)', {:ids => ids.first}] }
  }
    
  default_scope :conditions => '(investigators.deleted_at is null and investigators.end_date is null)'
#  default_scope :include => :abstracts
  #default_scope :order => 'lower(investigators.last_name),lower(investigators.first_name)'

  validates_presence_of :username
  validates_uniqueness_of :username

  def self.include_deleted( id=nil )
    with_exclusive_scope do
      if id.blank?
        find(:all)
      else
        find_by_id(id)
      end
    end
  end

  def self.deleted_with_valid_abstracts
    with_exclusive_scope do
      all(:conditions=>"investigators.deleted_at is not null and  investigator_abstracts.is_valid = true and investigators.id = investigator_abstracts.investigator_id and investigator_abstracts.abstract_id = abstracts.id and abstracts.is_valid = true", :include=>[:investigator_abstracts, :abstracts] )
    end
  end

  def self.delete_deleted( id )
    with_exclusive_scope do
        delete(id)
    end
  end


  def self.find_purged( )
    with_exclusive_scope do
      all(:conditions=>["investigators.deleted_at is not null"])
    end
  end

  def self.find_updated( )
    all(:conditions=>["updated_at > :recent", {:recent=>Time.now-10.days}])
  end

  def self.find_not_updated( )
    all(:conditions=>["updated_at is null or updated_at <= :recent", {:recent=>Time.now-10.days}])
  end

  def self.find_by_username_including_deleted( val )
    with_exclusive_scope do
        find_by_username(val)
    end
  end

  def self.find_all_by_username_including_deleted( val )
    with_exclusive_scope do
        find_all_by_username(val)
    end
  end

  def self.find_by_email_including_deleted( val )
    with_exclusive_scope do
        find_by_email(val)
    end
  end

  def self.has_basis_without_connections(basis)
      all(:conditions=>["investigators.appointment_basis = :basis and (not exists(select 'x' from investigator_abstracts where investigator_abstracts.investigator_id = investigators.id) and not exists(select 'x' from investigator_studies where investigator_studies.investigator_id = investigators.id) and not exists(select 'x' from investigator_proposals where investigator_proposals.investigator_id = investigators.id) )", {:basis=>basis}] )
   end
  
  def colleague_coauthors
    co_authors.collect{|ca| ca.colleague}
  end
  
  def direct_coauthors
    coauthor_ids = abstracts.collect{|x| x.investigator_abstracts.remove_invalid.collect(&:investigator_id)}.flatten.uniq
    coauthor_ids.delete(id)
    Investigator.find_all_by_id(coauthor_ids)
  end

  def name
    [first_name, last_name].join(' ')
  end

  def full_name
     (degrees.blank?) ? [first_name, middle_name, last_name].join(' ') : [[first_name, middle_name, last_name].join(' '), degrees].join(', ')
  end

  def sort_name
     [[last_name, first_name].join(', '), middle_name].join(' ')
  end

     # this is annoying to have to spell out every column but * does not work
    # for rails 3.0
        #all.joins("INNER JOIN investigator_proposals ON (investigators.id = investigator_proposals.investigator_id)  INNER JOIN proposals ON (proposals.id = investigator_proposals.proposal_id)  
    #    LEFT JOIN investigator_proposals pi_proposals_investigators_join ON (investigators.id = pi_proposals_investigators_join.investigator_id)  
    #    LEFT JOIN proposals pi_proposals_investigators ON (pi_proposals_investigators.id = pi_proposals_investigators_join.proposal_id) AND investigator_proposals.role = 'PD/PI'  
    #    LEFT JOIN investigator_proposals nonpi_proposals_investigators_join ON (investigators.id = nonpi_proposals_investigators_join.investigator_id)  
    #    LEFT JOIN proposals nonpi_proposals_investigators ON (nonpi_proposals_investigators.id = nonpi_proposals_investigators_join.proposal_id) AND NOT investigator_proposals.role = 'PD/PI' 
    #    ").select( "investigators.id, investigators.username, investigators.home_department_id, investigators.last_name, investigators.first_name, investigators.middle_name, investigators.email, investigators.degrees, investigators.suffix, investigators.employee_id, investigators.title, investigators.campus, investigators.appointment_type, investigators.appointment_track, investigators.appointment_basis, investigators.pubmed_search_name, investigators.pubmed_limit_to_institution, investigators.num_first_pubs_last_five_years, investigators.num_last_pubs_last_five_years, investigators.total_publications_last_five_years, investigators.num_intraunit_collaborators_last_five_years, investigators.num_extraunit_collaborators_last_five_years, investigators.num_first_pubs, investigators.num_last_pubs, investigators.total_publications, investigators.num_intraunit_collaborators, investigators.num_extraunit_collaborators, investigators.last_pubmed_search, investigators.mailcode, investigators.address1, investigators.address2, investigators.city, investigators.state, investigators.postal_code, investigators.country, investigators.business_phone, investigators.home_phone, investigators.lab_phone, investigators.fax, investigators.pager, investigators.ssn, investigators.birth_date, investigators.sex, investigators.nu_start_date, investigators.start_date, investigators.end_date, investigators.faculty_keywords, investigators.faculty_research_summary, investigators.faculty_interests, sum(proposals.direct_amount) as direct_totals, sum(proposals.indirect_amount) as indirect_totals,sum(proposals.total_amount) as proposal_totals, count(proposals.*) as proposals_count, sum(pi_proposals_investigators.direct_amount) as pi_direct_totals, sum(pi_proposals_investigators.indirect_amount) as pi_indirect_totals, sum(pi_proposals_investigators.total_amount) as pi_proposal_totals, count(pi_proposals_investigators.*) as pi_proposals_count, sum(nonpi_proposals_investigators.direct_amount) as nonpi_direct_totals, sum(nonpi_proposals_investigators.indirect_amount) as nonpi_indirect_totals, sum(nonpi_proposals_investigators.total_amount) as nonpi_proposal_totals, count(nonpi_proposals_investigators.*) as nonpi_proposals_count 
    #    ").group("investigators.id, investigators.username, investigators.home_department_id, investigators.last_name, investigators.first_name, investigators.middle_name, investigators.email, investigators.degrees, investigators.suffix, investigators.employee_id, investigators.title, investigators.campus, investigators.appointment_type, investigators.appointment_track, investigators.appointment_basis, investigators.pubmed_search_name, investigators.pubmed_limit_to_institution, investigators.num_first_pubs_last_five_years, investigators.num_last_pubs_last_five_years, investigators.total_publications_last_five_years, investigators.num_intraunit_collaborators_last_five_years, investigators.num_extraunit_collaborators_last_five_years, investigators.num_first_pubs, investigators.num_last_pubs, investigators.total_publications, investigators.num_intraunit_collaborators, investigators.num_extraunit_collaborators, investigators.last_pubmed_search, investigators.mailcode, investigators.address1, investigators.address2, investigators.city, investigators.state, investigators.postal_code, investigators.country, investigators.business_phone, investigators.home_phone, investigators.lab_phone, investigators.fax, investigators.pager, investigators.ssn, investigators.birth_date, investigators.sex, investigators.weekly_hours_min, investigators.nu_start_date, investigators.start_date, investigators.end_date, investigators.faculty_keywords, investigators.faculty_research_summary, investigators.faculty_interests" )
     
  def self.proposal_totals(limit=nil)
    all( :joins => " INNER JOIN (investigator_proposals investigator_proposals1  INNER JOIN proposals proposals1 ON (investigator_proposals1.proposal_id = proposals1.id )) ON (investigators.id = investigator_proposals1.investigator_id) ", 
        :select => "investigators.id, investigators.username, investigators.home_department_id, investigators.last_name, investigators.first_name, investigators.middle_name, investigators.email, investigators.degrees, investigators.suffix, investigators.employee_id, investigators.title, investigators.campus, investigators.appointment_type, investigators.appointment_track, investigators.appointment_basis, investigators.pubmed_search_name, investigators.pubmed_limit_to_institution, investigators.num_first_pubs_last_five_years, investigators.num_last_pubs_last_five_years, investigators.total_publications_last_five_years, investigators.num_intraunit_collaborators_last_five_years, investigators.num_extraunit_collaborators_last_five_years, investigators.num_first_pubs, investigators.num_last_pubs, investigators.total_publications, investigators.num_intraunit_collaborators, investigators.num_extraunit_collaborators, investigators.last_pubmed_search, investigators.mailcode, investigators.address1, investigators.address2, investigators.city, investigators.state, investigators.postal_code, investigators.country, investigators.business_phone, investigators.home_phone, investigators.lab_phone, investigators.fax, investigators.pager, investigators.ssn, investigators.birth_date, investigators.sex, investigators.nu_start_date, investigators.start_date, investigators.end_date, investigators.faculty_keywords, investigators.faculty_research_summary, investigators.faculty_interests, sum(proposals1.direct_amount) as directs_total, sum(proposals1.indirect_amount) as indirects_total,sum(proposals1.total_amount) as proposals_total, count(investigator_proposals1.*) as proposals_count",
        :group => "investigators.id, investigators.username, investigators.home_department_id, investigators.last_name, investigators.first_name, investigators.middle_name, investigators.email, investigators.degrees, investigators.suffix, investigators.employee_id, investigators.title, investigators.campus, investigators.appointment_type, investigators.appointment_track, investigators.appointment_basis, investigators.pubmed_search_name, investigators.pubmed_limit_to_institution, investigators.num_first_pubs_last_five_years, investigators.num_last_pubs_last_five_years, investigators.total_publications_last_five_years, investigators.num_intraunit_collaborators_last_five_years, investigators.num_extraunit_collaborators_last_five_years, investigators.num_first_pubs, investigators.num_last_pubs, investigators.total_publications, investigators.num_intraunit_collaborators, investigators.num_extraunit_collaborators, investigators.last_pubmed_search, investigators.mailcode, investigators.address1, investigators.address2, investigators.city, investigators.state, investigators.postal_code, investigators.country, investigators.business_phone, investigators.home_phone, investigators.lab_phone, investigators.fax, investigators.pager, investigators.ssn, investigators.birth_date, investigators.sex, investigators.weekly_hours_min, investigators.nu_start_date, investigators.start_date, investigators.end_date, investigators.faculty_keywords, investigators.faculty_research_summary, investigators.faculty_interests",
        :order => "proposals_total desc", :limit => limit)
    
  end

  def self.study_totals(limit=nil)
    all( :joins => " LEFT OUTER JOIN investigator_studies investigator_studies1  ON (investigators.id = investigator_studies1.investigator_id) LEFT OUTER JOIN studies studies1  ON (investigator_studies1.study_id = studies1.id)", 
        :select => "investigators.id, investigators.username, investigators.home_department_id, investigators.last_name, investigators.first_name, investigators.middle_name, investigators.email, investigators.degrees, investigators.suffix, investigators.employee_id, investigators.title, investigators.campus, investigators.appointment_type, investigators.appointment_track, investigators.appointment_basis, investigators.pubmed_search_name, investigators.pubmed_limit_to_institution, investigators.num_first_pubs_last_five_years, investigators.num_last_pubs_last_five_years, investigators.total_publications_last_five_years, investigators.num_intraunit_collaborators_last_five_years, investigators.num_extraunit_collaborators_last_five_years, investigators.num_first_pubs, investigators.num_last_pubs, investigators.total_publications, investigators.num_intraunit_collaborators, investigators.num_extraunit_collaborators, investigators.last_pubmed_search, investigators.mailcode, investigators.address1, investigators.address2, investigators.city, investigators.state, investigators.postal_code, investigators.country, investigators.business_phone, investigators.home_phone, investigators.lab_phone, investigators.fax, investigators.pager, investigators.ssn, investigators.birth_date, investigators.sex, investigators.nu_start_date, investigators.start_date, investigators.end_date, investigators.faculty_keywords, investigators.faculty_research_summary, investigators.faculty_interests, investigators.home_department_name, count(distinct investigator_studies1.*) as study_count, count(distinct studies1.investigator_id) as study_collaborators_count",
        :group => "investigators.id, investigators.username, investigators.home_department_id, investigators.last_name, investigators.first_name, investigators.middle_name, investigators.email, investigators.degrees, investigators.suffix, investigators.employee_id, investigators.title, investigators.campus, investigators.appointment_type, investigators.appointment_track, investigators.appointment_basis, investigators.pubmed_search_name, investigators.pubmed_limit_to_institution, investigators.num_first_pubs_last_five_years, investigators.num_last_pubs_last_five_years, investigators.total_publications_last_five_years, investigators.num_intraunit_collaborators_last_five_years, investigators.num_extraunit_collaborators_last_five_years, investigators.num_first_pubs, investigators.num_last_pubs, investigators.total_publications, investigators.num_intraunit_collaborators, investigators.num_extraunit_collaborators, investigators.last_pubmed_search, investigators.mailcode, investigators.address1, investigators.address2, investigators.city, investigators.state, investigators.postal_code, investigators.country, investigators.business_phone, investigators.home_phone, investigators.lab_phone, investigators.fax, investigators.pager, investigators.ssn, investigators.birth_date, investigators.sex, investigators.weekly_hours_min, investigators.nu_start_date, investigators.start_date, investigators.end_date, investigators.faculty_keywords, investigators.faculty_research_summary, investigators.faculty_interests, investigators.home_department_name",
        :order => "study_count desc", :limit => limit)
    
  end


  def pi_directs_total
    pi_proposals.sum('direct_amount')
  end

  def pi_indirects_total
    pi_proposals.sum('indirect_amount')
  end

  def pi_proposals_total
    pi_proposals.sum('total_amount')
  end

  def pi_proposals_count
    pi_proposals.count
  end

  def nonpi_directs_total
    nonpi_proposals.sum('direct_amount')
  end

  def nonpi_indirects_total
    nonpi_proposals.sum('indirect_amount')
  end

  def nonpi_proposals_total
    nonpi_proposals.sum('total_amount')
  end

  def nonpi_proposals_count
    nonpi_proposals.count
  end

  def current_directs_total
    current_proposals.sum('direct_amount')
  end

  def current_indirects_total
    current_proposals.sum('indirect_amount')
  end

  def current_proposals_total
    current_proposals.sum('total_amount')
  end

  def current_proposals_count
    current_proposals.count
  end

  def current_pi_directs_total
    current_pi_proposals.sum('direct_amount')
  end

  def current_pi_indirects_total
    current_pi_proposals.sum('indirect_amount')
  end

  def current_pi_proposals_total
    current_pi_proposals.sum('total_amount')
  end

  def current_pi_proposals_count
    current_pi_proposals.count
  end

  def current_nonpi_directs_total
    current_nonpi_proposals.sum('direct_amount')
  end

  def current_nonpi_indirects_total
    current_nonpi_proposals.sum('indirect_amount')
  end

  def current_nonpi_proposals_total
    current_nonpi_proposals.sum('total_amount')
  end

  def current_nonpi_proposals_count
    current_nonpi_proposals.count
  end


  def self.find_investigators_in_list(terms)
    terms = terms.split(/[, ;\r\n]/).collect{|term| term.downcase.strip}.uniq
    numeric_terms = terms.collect{|term| (term =~ /^[0-9]+$/) ? term : nil }.uniq
    [Investigator.find_all_by_username(terms) + Investigator.all(:conditions=>[ 'lower(email) in (:terms)', {:terms=>terms}] ) + Investigator.find_all_by_employee_id(numeric_terms) ].flatten.uniq
  end
  
  def self.count_all_tsearch(terms)
    investigators = Investigator.find_by_tsearch(terms, :select => 'ID')
    abstract_ids = Abstract.find_by_tsearch(terms, :select => 'ID')
    investigators2 = InvestigatorAbstract.all(:select => 'DISTINCT investigator_id', :conditions=>['investigator_abstracts.abstract_id IN (:abstract_ids)', {:abstract_ids => abstract_ids.collect(&:id)}])
    (investigators.collect(&:id)+investigators2.collect(&:investigator_id)).uniq.length
  end

  def self.investigators_tsearch(terms)
    find_by_tsearch(terms)
  end

  def self.all_tsearch(terms)
    investigators = find_by_tsearch(terms)
    abstract_ids = Abstract.find_by_tsearch(terms, :select => 'ID')
    investigators2 = all(:select => "investigators.id, investigators.username, investigators.home_department_id, investigators.last_name, investigators.first_name, investigators.middle_name, investigators.email, investigators.degrees, investigators.suffix, investigators.employee_id, investigators.title, investigators.campus, investigators.appointment_type, investigators.appointment_track, investigators.appointment_basis, investigators.pubmed_search_name, investigators.pubmed_limit_to_institution, investigators.num_first_pubs_last_five_years, investigators.num_last_pubs_last_five_years, investigators.total_publications_last_five_years, investigators.num_intraunit_collaborators_last_five_years, investigators.num_extraunit_collaborators_last_five_years, investigators.num_first_pubs, investigators.num_last_pubs, investigators.total_publications, investigators.num_intraunit_collaborators, investigators.num_extraunit_collaborators, investigators.last_pubmed_search, investigators.mailcode, investigators.address1, investigators.address2, investigators.city, investigators.state, investigators.postal_code, investigators.country, investigators.business_phone, investigators.home_phone, investigators.lab_phone, investigators.fax, investigators.pager, investigators.birth_date, investigators.nu_start_date, investigators.start_date, investigators.end_date, investigators.faculty_keywords, investigators.faculty_research_summary, investigators.faculty_interests,  count(investigator_abstracts.abstract_id) as the_cnt", :joins=>:investigator_abstracts, :conditions=>['investigator_abstracts.abstract_id IN (:abstract_ids)', {:abstract_ids => abstract_ids, :investigator_ids => investigators.collect(&:id)}], :group => "investigators.id, investigators.username, investigators.home_department_id, investigators.last_name, investigators.first_name, investigators.middle_name, investigators.email, investigators.degrees, investigators.suffix, investigators.employee_id, investigators.title, investigators.campus, investigators.appointment_type, investigators.appointment_track, investigators.appointment_basis, investigators.pubmed_search_name, investigators.pubmed_limit_to_institution, investigators.num_first_pubs_last_five_years, investigators.num_last_pubs_last_five_years, investigators.total_publications_last_five_years, investigators.num_intraunit_collaborators_last_five_years, investigators.num_extraunit_collaborators_last_five_years, investigators.num_first_pubs, investigators.num_last_pubs, investigators.total_publications, investigators.num_intraunit_collaborators, investigators.num_extraunit_collaborators, investigators.last_pubmed_search, investigators.mailcode, investigators.address1, investigators.address2, investigators.city, investigators.state, investigators.postal_code, investigators.country, investigators.business_phone, investigators.home_phone, investigators.lab_phone, investigators.fax, investigators.pager, investigators.birth_date, investigators.nu_start_date, investigators.start_date, investigators.end_date, investigators.faculty_keywords, investigators.faculty_research_summary, investigators.faculty_interests", :order => 'the_cnt desc, investigators.total_publications desc, investigators.last_name')
    (investigators+investigators2).uniq
  end

  def self.top_ten_tsearch(terms)
    investigators = find_by_tsearch(terms, :limit=>10)
    abstract_ids = Abstract.find_by_tsearch(terms, {:select => 'ID', :limit=>10})
    investigators2 = all(:select => "DISTINCT investigators.*", :joins=>:investigator_abstracts, :limit=>10, :conditions=>['investigator_abstracts.abstract_id IN (:abstract_ids)', {:abstract_ids => abstract_ids, :investigator_ids => investigators.collect(&:id)}])
    (investigators+investigators2).uniq
  end


  def self.display_tsearch(terms)
    find_by_tsearch(terms)
  end
  
  def abstract_count
    abstracts.length
  end
 
  def abstract_last_five_years_count
    abstracts.abstracts_last_five_years.length
  end


#  def self.similar_investigators(investigator_id)
#    self.find(:all, :joins=>[:investigator_colleagues], 
#    :conditions=>['investigator_colleagues.publication_cnt=0 and investigator_colleagues.colleague_id=:colleague_id', 
#      {:colleague_id => investigator_id}], :order=>'mesh_tags_ic desc', :limit=>15)
#  end 

#  def self.co_authors(investigator_id)
#    self.find(:all, :joins=>[:investigator_colleagues], 
#    :conditions=>['investigator_colleagues.publication_cnt>0 and investigator_colleagues.colleague_id=:colleague_id', 
#      {:colleague_id => investigator_id}], 
#      :order=>'publication_cnt desc, mesh_tags_ic desc')
#  end 

  def self.generate_date(number_years=5)
    cutoff_date=number_years.years.ago.to_date.to_s(:db)
  end
  
  def unit_list()
     (self.investigator_appointments.collect(&:organizational_unit_id)<<self.home_department_id).uniq
  end
  
  def self.distinct_primary_appointments()
    find(:all, :select => 'DISTINCT home_department_id as organizational_unit_id' ).collect(&:organizational_unit_id)
  end

  def self.distinct_joint_appointments()
    find(:all, :joins => [:investigator_appointments], :select => 'DISTINCT organizational_unit_id', :conditions=>"type='Joint'").collect(&:organizational_unit_id)
  end

  def self.distinct_secondary_appointments()
     find(:all, :joins => [:investigator_appointments], :select => 'DISTINCT organizational_unit_id', :conditions=>"type='Secondary'").collect(&:organizational_unit_id)
  end

  def self.distinct_memberships()
      find(:all, :joins => [:member_appointments], :select => 'DISTINCT organizational_unit_id').collect(&:organizational_unit_id)
  end

  def self.distinct_other_appointments_or_memberships()
    find(:all, :joins => [:investigator_appointments], :select => 'DISTINCT organizational_unit_id' ).collect(&:organizational_unit_id)
  end
  
  def self.distinct_all_appointments_and_memberships()
    (distinct_other_appointments_or_memberships()+distinct_primary_appointments()).uniq.compact
  end

  def self.with_studies()
      all( :joins => [:studies])
  end

  def self.has_studies()
      all( :conditions => ["exists(select 'x' from investigator_studies where investigator_studies.investigator_id = investigators.id )"])
  end

  def self.with_pi_studies()
      all( :joins => [:investigator_pi_studies])
  end
  
  def self.has_pi_studies()
      all( :conditions => ["exists(select 'x' from investigator_studies where investigator_studies.investigator_id = investigators.id and investigator_studies.role = 'PI')"])
  end
  
  def self.all_members()
      all( :joins => [:member_appointments])
  end

  def self.not_members()
    allmembers  = self.all_members()
    all(:conditions=>["id not in (:all)", {:all => allmembers}])
  end
  
  def self.no_appointments()
    all(  :conditions => ["not exists(select 'x' from investigator_appointments where investigator_appointments.investigator_id = investigators.id )"] )
  end

  def self.without_programs()
    all(  :conditions => ["not exists(select 'x' from investigator_appointments where investigator_appointments.investigator_id = investigators.id and investigator_appointments.type = 'Member' and investigator_appointments.end_date is null )"] )
  end

  
# used in the rake tasks to add to the investigator object attributes

  def first_author_publications_cnt()
    self.investigator_abstracts.find(:all,
       :conditions => ["investigator_abstracts.is_first_author = :is_first_author and investigator_abstracts.is_valid = true",
            {:is_first_author => true}] ).length
  end 

  def last_author_publications_cnt()
    self.investigator_abstracts.find(:all,
        :conditions => [" investigator_abstracts.is_last_author = :is_last_author and investigator_abstracts.is_valid = true",
            {:is_last_author => true}] ).length
  end 

  def first_author_publications_since_date_cnt()
   is_first_author = true
   self.investigator_abstracts.find(:all,
      :joins => [:abstract],
      :conditions => ["(publication_date >= :pub_date or electronic_publication_date >= :pub_date) and investigator_abstracts.is_first_author = :is_first_author and investigator_abstracts.is_valid = true",
           {:pub_date => Investigator.generate_date(), :is_first_author => is_first_author}] ).length
  end 

  def last_author_publications_since_date_cnt()
    is_last_author = true
    self.investigator_abstracts.find(:all,
     :joins => [:abstract],
         :conditions => ["(publication_date >= :pub_date or electronic_publication_date >= :pub_date) and investigator_abstracts.is_last_author = :is_last_author and investigator_abstracts.is_valid = true",
             {:pub_date => Investigator.generate_date(), :is_last_author => is_last_author}] ).length
  end 

  def self.collaborators(investigator_id)
    self.find_by_sql("select distinct i2.* " + 
        " FROM abstracts a, investigator_abstracts ia, investigator_abstracts ia2, investigators i2  "+
        " WHERE ia.investigator_id = #{investigator_id} "+
        "  AND ia.abstract_id = a.id "+
         "  AND a.publication_date > '#{generate_date}' "+
         " AND ia.abstract_id = ia2.abstract_id "+
         " AND ia.investigator_id <> ia2.investigator_id " +
         " AND ia2.investigator_id = i2.id" +
         " AND ia.is_valid = true AND ia2.is_valid = true")
   end 

  def self.collaborators_cnt(investigator_id)
     self.collaborators(investigator_id).length
  end 

  def self.intramural_collaborators_cnt(investigator_id)
    self.find_by_sql("select distinct ia2.investigator_id " + 
        "  FROM abstracts a, investigator_abstracts ia, investigator_appointments ip, investigator_abstracts ia2, investigator_appointments ip2 "+
        " WHERE ia.investigator_id  = #{investigator_id} "+
        "  AND ia.abstract_id = a.id "+
        "  AND ia.is_valid = true " +
        "   AND ia.investigator_id = ip.investigator_id  "+
        "   AND ip.organizational_unit_id = ip2.organizational_unit_id "+
        "   AND ip2.investigator_id = ia2.investigator_id "+
        "   AND ia.abstract_id = ia2.abstract_id "+
        "   AND ia.investigator_id <> ia2.investigator_id " +
        "   AND ia2.is_valid = true "
    ).length
  end 
 
  def self.other_collaborators_cnt(investigator_id)
    self.find_by_sql("select distinct ia2.investigator_id " + 
      "  FROM  abstracts a, investigator_abstracts ia, investigator_abstracts ia2 "+
      " WHERE ia.investigator_id = #{investigator_id} "+
      "   AND ia.abstract_id = a.id "+
      "   AND ia.is_valid = true " +
      "   AND ia.abstract_id = ia2.abstract_id "+
      "   AND ia2.is_valid = true " +
      "   AND ia.investigator_id <> ia2.investigator_id "+
      "   AND NOT EXISTS ( SELECT 'X' FROM investigator_appointments ip, investigator_appointments ip2 "+
      "                     WHERE  ip2.investigator_id = ia2.investigator_id "+
      "                       AND  ip.investigator_id = ia.investigator_id "+
      "                       AND  ip.organizational_unit_id = ip2.organizational_unit_id )"
    ).length
  end 

  def self.intramural_collaborators_since_date_cnt(investigator_id)
    self.find_by_sql("select distinct ia2.investigator_id " + 
        "  FROM abstracts a, investigator_abstracts ia, investigator_appointments ip, investigator_abstracts ia2, investigator_appointments ip2 "+
        " WHERE ia.investigator_id  = #{investigator_id} "+
        "  AND ia.abstract_id = a.id "+
        "   AND ia.is_valid = true " +
         "  AND a.publication_date > '#{generate_date}' "+
        "   AND ia.investigator_id = ip.investigator_id  "+
        "   AND ip.organizational_unit_id = ip2.organizational_unit_id "+
        "   AND ip2.investigator_id = ia2.investigator_id "+
        "   AND ia.abstract_id = ia2.abstract_id "+
        "   AND ia2.is_valid = true " +
        "   AND ia.investigator_id <> ia2.investigator_id "
    ).length
  end 
 
  def self.other_collaborators_since_date_cnt(investigator_id)
    self.find_by_sql("select distinct ia2.investigator_id " + 
      "  FROM  abstracts a, investigator_abstracts ia, investigator_abstracts ia2 "+
      " WHERE ia.investigator_id = #{investigator_id} "+
      "   AND ia.abstract_id = a.id "+
      "   AND ia.is_valid = true " +
      "   AND a.publication_date > '#{generate_date}' "+
      "   AND ia.abstract_id = ia2.abstract_id "+
      "   AND ia2.is_valid = true " +
      "   AND ia.investigator_id <> ia2.investigator_id "+
      "   AND NOT EXISTS ( SELECT 'X' FROM investigator_appointments ip, investigator_appointments ip2 "+
      "                     WHERE  ip2.investigator_id = ia2.investigator_id "+
      "                       AND  ip.investigator_id = ia.investigator_id "+
      "                       AND  ip.organizational_unit_id = ip2.organizational_unit_id )"
    ).length
  end 

  # for graphing co-publications
  def self.add_collaboration_hash_to_investigator(investigator ) 
   if investigator["internal_collaborators"].nil?
     investigator["internal_collaborators"]=Hash.new()
     investigator["external_collaborators"]=Hash.new()
   end
  end 

  def self.add_collaboration_hash_to_investigators(investigators ) 
    investigators.each do |investigator|
      add_collaboration_hash_to_investigator(investigator)
    end
  end 

  def self.add_collaboration(collaborator_hash,investigator_abstract)
    collaborator_hash[investigator_abstract.investigator_id.to_s]=Array.new(0) if collaborator_hash[investigator_abstract.investigator_id.to_s].nil?
    if ! collaborator_hash[investigator_abstract.investigator_id.to_s].include?(investigator_abstract.abstract_id)
       collaborator_hash[investigator_abstract.investigator_id.to_s]<<investigator_abstract.abstract_id
    end
  end
  
  def self.add_collaboration_to_investigator(investigator_abstract, investigator, investigators_in_unit)
    if investigator.id.to_i != investigator_abstract.investigator_id.to_i
      internal_investigator = investigators_in_unit.find { |i| i.id == investigator_abstract.investigator_id }
      if internal_investigator.nil? 
        add_collaboration(investigator.external_collaborators,investigator_abstract )
      else 
        add_collaboration(investigator.internal_collaborators,investigator_abstract )
      end
    end
  end

  def self.add_collaborations_to_investigator(investigator_abstracts, investigator, investigators_in_unit ) 
    investigator_abstracts.each do |ia|
      add_collaboration_to_investigator(ia, investigator, investigators_in_unit) if ia.is_valid == true
    end 
  end 

  def self.add_collaborations_to_investigators(investigator_abstracts, input_investigators ) 
    investigator_abstracts.each do |ia|
      investigator = input_investigators.find { |i| i.id == ia.investigator_id }
      # this should enforce that only internal investigators are added!
      if !investigator.nil?
        add_collaborations_to_investigator(investigator_abstracts, investigator, input_investigators)
      end
    end
  end 

  def self.get_connections(investigators, number_years=5)
    add_collaboration_hash_to_investigators(investigators)
    publication_collection = Abstract.investigator_publications(investigators, number_years )
    #iterate over all publications
    publication_collection.each do |pub|
      if pub.investigator_abstracts.length > 1
        add_collaborations_to_investigators(pub.investigator_abstracts, investigators)
      end
    end
  end

  def self.get_investigator_connections(investigator, number_years=5)
    unit_list=investigator.unit_list()
    if unit_list.length == 1 then
      investigators_in_unit = Investigator.find(:all, 
         :include => ["investigator_appointments"],
         :conditions => [" investigator_appointments.organizational_unit_id  = :organizational_unit_id",
          {:organizational_unit_id => unit_list}] ) + Investigator.find(:all,
            :conditions =>  ["home_department_id  = :organizational_unit_id",
              {:organizational_unit_id => unit_list}])
    else
      investigators_in_unit = Investigator.find(:all, 
        :include => ["investigator_appointments"],
        :conditions => [" investigator_appointments.organizational_unit_id IN (:organizational_unit_ids)",
         {:organizational_unit_ids => unit_list}] ) + Investigator.find(:all,
            :conditions =>  ["home_department_id  IN (:organizational_unit_id)",
              {:organizational_unit_id => unit_list}])
    end
    add_collaboration_hash_to_investigator(investigator)
    # publication_collection is a list of all abstracts, investigators and investigator abstracts
    publication_collection = Abstract.investigator_publications(investigator, number_years )
     #iterate over all publications
    publication_collection.each do |pub|
      if pub.investigator_abstracts.length > 1
        add_collaborations_to_investigator(pub.investigator_abstracts, investigator, investigators_in_unit)
      end
    end
  end

  def self.get_mesh_connections(investigators, number_years=5)
    add_collaboration_hash_to_investigators(investigators)
    publication_collection = Abstract.investigator_publications(investigators, number_years )
    #iterate over all publications
    publication_collection.each do |pub|
      if pub.investigator_abstracts.length > 1
        add_collaborations_to_investigators(pub.investigator_abstracts, investigators)
      end
    end
  end

end

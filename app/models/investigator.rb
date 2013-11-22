# == Schema Information
# == Schema Information
# Schema version: 20130327155943
#
# Table name: investigators
#
#  address1                                    :text
#  address2                                    :string(255)
#  appointment_basis                           :string(255)
#  appointment_track                           :string(255)
#  appointment_type                            :string(255)
#  birth_date                                  :date
#  business_phone                              :string(255)
#  campus                                      :string(255)
#  city                                        :string(255)
#  consecutive_login_failures                  :integer          default(0)
#  country                                     :string(255)
#  created_at                                  :timestamp
#  created_id                                  :integer
#  created_ip                                  :string(255)
#  degrees                                     :string(255)
#  deleted_at                                  :timestamp
#  deleted_id                                  :integer
#  deleted_ip                                  :string(255)
#  email                                       :string(255)
#  employee_id                                 :integer
#  end_date                                    :date
#  era_comons_name                             :string(255)
#  faculty_interests                           :text
#  faculty_keywords                            :text
#  faculty_research_summary                    :text
#  fax                                         :string(255)
#  first_name                                  :string(255)      not null
#  home_department_id                          :integer
#  home_department_name                        :string(255)
#  home_phone                                  :string(255)
#  id                                          :integer          default(0), not null, primary key
#  lab_phone                                   :string(255)
#  last_login_failure                          :timestamp
#  last_name                                   :string(255)      not null
#  last_pubmed_search                          :date
#  last_successful_login                       :timestamp
#  mailcode                                    :string(255)
#  middle_name                                 :string(255)
#  nu_start_date                               :date
#  num_extraunit_collaborators                 :integer          default(0)
#  num_extraunit_collaborators_last_five_years :integer          default(0)
#  num_first_pubs                              :integer          default(0)
#  num_first_pubs_last_five_years              :integer          default(0)
#  num_intraunit_collaborators                 :integer          default(0)
#  num_intraunit_collaborators_last_five_years :integer          default(0)
#  num_last_pubs                               :integer          default(0)
#  num_last_pubs_last_five_years               :integer          default(0)
#  pager                                       :string(255)
#  password                                    :string(255)
#  password_changed_at                         :timestamp
#  password_changed_id                         :integer
#  password_changed_ip                         :string(255)
#  postal_code                                 :string(255)
#  pubmed_limit_to_institution                 :boolean          default(FALSE)
#  pubmed_search_name                          :string(255)
#  sex                                         :string(1)
#  ssn                                         :string(9)
#  start_date                                  :date
#  state                                       :string(255)
#  suffix                                      :string(255)
#  title                                       :string(255)
#  total_awards                                :integer          default(0), not null
#  total_awards_collaborators                  :integer          default(0), not null
#  total_pi_awards                             :integer          default(0), not null
#  total_pi_awards_collaborators               :integer          default(0), not null
#  total_pi_studies                            :integer          default(0), not null
#  total_pi_studies_collaborators              :integer          default(0), not null
#  total_publications                          :integer          default(0)
#  total_publications_last_five_years          :integer          default(0)
#  total_studies                               :integer          default(0), not null
#  total_studies_collaborators                 :integer          default(0), not null
#  updated_at                                  :timestamp
#  updated_id                                  :integer
#  updated_ip                                  :string(255)
#  username                                    :string(255)      not null
#  vectors                                     :text
#  weekly_hours_min                            :integer          default(35)
#

class Investigator < ActiveRecord::Base
  acts_as_taggable  # for MeSH terms
  acts_as_tsearch :vectors => {:fields => ["first_name","last_name", "username", "title"]}

  attr_accessor :external_collaborators
  attr_accessor :internal_collaborators

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
    # by default Member includes children classes
  has_many :only_member_appointments, :class_name => "InvestigatorAppointment",
    :conditions => ["(investigator_appointments.end_date is null or investigator_appointments.end_date >= :now) AND investigator_appointments.type = 'Member'", {:now => Date.today }]
  has_many :member_appointments, :class_name => "Member",
    :conditions => ["investigator_appointments.end_date is null or investigator_appointments.end_date >= :now", {:now => Date.today }]
  has_many :associate_member_appointments, :class_name => "AssociateMember",
    :conditions => ['investigator_appointments.end_date is null or investigator_appointments.end_date >= :now', {:now => Date.today }]
  has_many :any_members, :class_name => 'InvestigatorAppointment',
        :conditions => ["investigator_appointments.type LIKE '%%Member'AND (investigator_appointments.end_date is null or investigator_appointments.end_date >= :now )", {:now => Date.today }]
  has_many :appointments, :source => :organizational_unit, :through => :investigator_appointments
  has_many :joint_appointments, :source => :organizational_unit, :through => :joints
  has_many :secondary_appointments, :source => :organizational_unit, :through => :secondaries
  has_many :memberships, :source => :organizational_unit, :through => :member_appointments
  has_many :any_memberships, :source => :organizational_unit, :through => :any_members
  has_many :associate_memberships, :source => :organizational_unit, :through => :associate_member_appointments
  # foreign_key is a fix for an issue in rails 2.3.5 and earlier
  belongs_to :home_department, :class_name => 'OrganizationalUnit', :foreign_key => 'home_department_id'

  # accepts_nested_attributes_for :investigator_appointments, :allow_destroy => true, :reject_if => :all_blank
  accepts_nested_attributes_for :member_appointments

  scope :with_any_role, includes(:investigator_proposals).where('investigator_proposals.percent_effort >= 0')

  scope :full_time, where("appointment_basis = 'FT'")
  scope :tenure_track, where("appointment_type = 'Regular'")
  scope :research, where("appointment_type = 'Research'")
  scope :investigator, where("appointment_track like '%%Investigator%%'")
  scope :investigator_only, where("appointment_track = 'Investigator'")
  scope :clinician, where("appointment_track like '%%Clinician%%'")
  scope :clinician_only, where("appointment_track = 'Clinician'")
  scope :by_name, order("lower(last_name), lower(first_name)")

  scope :for_tag_ids, lambda { |*ids|
    joins(:taggings).where('taggings.tag_id IN (:ids) ', {:ids => ids.first} )
  }
  scope :complement_of_ids, lambda { |*ids|
    where('investigators.id NOT IN (:ids)', { :ids => ids.first })
  }
  scope :with_abstract_ids, lambda { |*ids|
    joins(:investigator_abstracts).where('investigator_abstracts.abstract_id IN (:ids)', { :ids => ids.first })
  }
  scope :with_abstract_ids_and_not_investigator, lambda { |*ids|
    joins(:investigator_abstracts).where('investigator_abstracts.abstract_id IN (:ids) AND NOT investigator_abstracts.investigator_id = :investigator_id', { :ids => ids.first, :investigator_id => ids[1] })
  }

  default_scope where('(investigators.deleted_at is null and investigators.end_date is null)')

  validates_presence_of :username
  validates_uniqueness_of :username

  def self.abstract_words
    all.map(&:unique_abstract_words).flatten
  end

  def investigator_appointments_form=(form)
    unit_ids = form[:organizational_unit_ids]
    type = form[:type]
    return if unit_ids.blank? or type.blank? or self.id.blank?
    ia_unit_ids = self.all_investigator_appointments.map(&:organizational_unit_id)
    # convert text ids to integer ids
    unit_ids = unit_ids.map{|i| i.to_i}
    self.all_investigator_appointments.each do |ia|
      if unit_ids.include?(ia.organizational_unit_id)
        # verify type and end_date is null
        if ia.type != type
          ia.type = type
        end
        unless ia.end_date.blank?
          ia.end_date = nil
        end
      else
        ia.end_date = Time.now - 1.day
      end
      ia.save! if ia.changed?
    end
    unit_ids.each do |id|
      unless ia_unit_ids.include?(id)
        ia = self.investigator_appointments.new(:organizational_unit_id=>id, :start_date => Date.today)
        ia.type = type
        ia.save!
      end
    end
  end

  def abstract_words
    self.abstracts.abstracts_last_five_years.map{|ab| ab.abstract_words}.flatten
  end

  def unique_abstract_words
    self.abstract_words.uniq
  end

  def shared_abstracts_with_investigator(id)
    Abstract.joins(', investigator_abstracts, investigator_abstracts ia2')
            .where('investigator_abstracts.abstract_id = abstracts.id ' +
                   'and ia2.abstract_id = abstracts.id ' +
                   'and investigator_abstracts.is_valid = true ' +
                   'and ia2.is_valid = true ' +
                   'and ia2.investigator_id = :id ' +
                   'and investigator_abstracts.investigator_id = :pi_id',
                  { :id => id, :pi_id => self.id })
            .order('abstracts.year DESC, abstracts.pubmed DESC').to_a
  end

  def self.include_deleted( id=nil )
    unscoped do
      if id.blank?
        order('lower(last_name), lower(first_name)').to_a
      else
        find(id)
      end
    end
  end

  def self.deleted_with_valid_abstracts
    unscoped do
      includes([:investigator_abstracts, :abstracts])
      .where('investigators.deleted_at is not null ' +
             'and investigator_abstracts.is_valid = true ' +
             'and investigators.id = investigator_abstracts.investigator_id ' +
             'and investigator_abstracts.abstract_id = abstracts.id ' +
             'and abstracts.is_valid = true').to_a
    end
  end

  def self.delete_deleted(id)
    unscoped do
      delete(id)
    end
  end

  def self.find_purged
    unscoped do
      where('investigators.deleted_at is not null').to_a
    end
  end

  def self.find_updated
    where('updated_at > :recent', { :recent => Time.now-10.days }).to_a
  end

  def self.find_not_updated
    where('updated_at is null or updated_at <= :recent', { :recent => Time.now-10.days }).to_a
  end

  def self.find_by_username_including_deleted(val)
    unscoped do
      find_by_username(val)
    end
  end

  def self.find_all_by_username_including_deleted(val)
    unscoped do
      find_all_by_username(val)
    end
  end

  def self.find_by_email_including_deleted(val)
    unscoped do
      find_by_email(val)
    end
  end

  def self.has_basis_without_connections(basis)
    where("investigators.appointment_basis = :basis " +
         "and ( not exists (select 'x' from investigator_abstracts where investigator_abstracts.investigator_id = investigators.id and investigator_abstracts.is_valid = true) " +
               " and not exists(select 'x' from investigator_studies where investigator_studies.investigator_id = investigators.id) " +
               " and not exists(select 'x' from investigator_proposals where investigator_proposals.investigator_id = investigators.id) " +
             ")", { :basis => basis })
  end

  def colleague_coauthors
    co_authors.collect{ |ca| ca.colleague }
  end

  def direct_coauthors
    coauthor_ids = abstracts.collect{ |x| x.investigator_abstracts.remove_invalid.collect(&:investigator_id) }.flatten.uniq
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

  def self.all_abstracts_for_investigators(pis)
    abstract_ids = pis.collect{|x| x.abstracts.only_valid}.flatten.sort{|x,y| x.id <=> y.id}.uniq
  end

  def self.publication_count_for_investigators(pis)
    all_abstracts_for_investigators(pis).length
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
    joins('INNER JOIN (investigator_proposals investigator_proposals1 INNER JOIN proposals proposals1 ON (investigator_proposals1.proposal_id = proposals1.id )) ON (investigators.id = investigator_proposals1.investigator_id)')
    .select('investigators.id, ' +
            'investigators.username, ' +
            'investigators.home_department_id, ' +
            'investigators.last_name, ' +
            'investigators.first_name, ' +
            'investigators.middle_name, ' +
            'investigators.email, ' +
            'investigators.degrees, ' +
            'investigators.suffix, ' +
            'investigators.employee_id, ' +
            'investigators.title, ' +
            'investigators.campus, ' +
            'investigators.appointment_type, ' +
            'investigators.appointment_track, ' +
            'investigators.appointment_basis, ' +
            'investigators.pubmed_search_name, ' +
            'investigators.pubmed_limit_to_institution, ' +
            'investigators.num_first_pubs_last_five_years, ' +
            'investigators.num_last_pubs_last_five_years, ' +
            'investigators.total_publications_last_five_years, ' +
            'investigators.num_intraunit_collaborators_last_five_years, ' +
            'investigators.num_extraunit_collaborators_last_five_years, ' +
            'investigators.num_first_pubs, ' +
            'investigators.num_last_pubs, ' +
            'investigators.total_publications, ' +
            'investigators.num_intraunit_collaborators, ' +
            'investigators.num_extraunit_collaborators, ' +
            'investigators.last_pubmed_search, ' +
            'investigators.mailcode, ' +
            'investigators.address1, ' +
            'investigators.address2, ' +
            'investigators.city, ' +
            'investigators.state, ' +
            'investigators.postal_code, ' +
            'investigators.country, ' +
            'investigators.business_phone, ' +
            'investigators.home_phone, ' +
            'investigators.lab_phone, ' +
            'investigators.fax, ' +
            'investigators.pager, ' +
            'investigators.ssn, ' +
            'investigators.birth_date, ' +
            'investigators.sex, ' +
            'investigators.nu_start_date, ' +
            'investigators.start_date, ' +
            'investigators.end_date, ' +
            'investigators.faculty_keywords, ' +
            'investigators.faculty_research_summary, ' +
            'investigators.faculty_interests, ' +
            'sum(proposals1.direct_amount) as directs_total, ' +
            'sum(proposals1.indirect_amount) as indirects_total, ' +
            'sum(proposals1.total_amount) as proposals_total, ' +
            'count(investigator_proposals1.*) as proposals_count')
    .group('investigators.id, ' +
           'investigators.username, ' +
           'investigators.home_department_id, ' +
           'investigators.last_name, ' +
           'investigators.first_name, ' +
           'investigators.middle_name, ' +
           'investigators.email, ' +
           'investigators.degrees, ' +
           'investigators.suffix, ' +
           'investigators.employee_id, ' +
           'investigators.title, ' +
           'investigators.campus, ' +
           'investigators.appointment_type, ' +
           'investigators.appointment_track, ' +
           'investigators.appointment_basis, ' +
           'investigators.pubmed_search_name, ' +
           'investigators.pubmed_limit_to_institution, ' +
           'investigators.num_first_pubs_last_five_years, ' +
           'investigators.num_last_pubs_last_five_years, ' +
           'investigators.total_publications_last_five_years, ' +
           'investigators.num_intraunit_collaborators_last_five_years, ' +
           'investigators.num_extraunit_collaborators_last_five_years, ' +
           'investigators.num_first_pubs, ' +
           'investigators.num_last_pubs, ' +
           'investigators.total_publications, ' +
           'investigators.num_intraunit_collaborators, ' +
           'investigators.num_extraunit_collaborators, ' +
           'investigators.last_pubmed_search, ' +
           'investigators.mailcode, ' +
           'investigators.address1, ' +
           'investigators.address2, ' +
           'investigators.city, ' +
           'investigators.state, ' +
           'investigators.postal_code, ' +
           'investigators.country, ' +
           'investigators.business_phone, ' +
           'investigators.home_phone, ' +
           'investigators.lab_phone, ' +
           'investigators.fax, ' +
           'investigators.pager, ' +
           'investigators.ssn, ' +
           'investigators.birth_date, ' +
           'investigators.sex, ' +
           'investigators.weekly_hours_min, ' +
           'investigators.nu_start_date, ' +
           'investigators.start_date, ' +
           'investigators.end_date, ' +
           'investigators.faculty_keywords, ' +
           'investigators.faculty_research_summary, ' +
           'investigators.faculty_interests')
      .order('proposals_total desc')
      .limit(limit)
      .to_a
  end

  def self.study_totals(limit=nil)
    joins('LEFT OUTER JOIN investigator_studies investigator_studies1  ON (investigators.id = investigator_studies1.investigator_id) LEFT OUTER JOIN studies studies1  ON (investigator_studies1.study_id = studies1.id)')
    .select('investigators.id, ' +
            'investigators.username, ' +
            'investigators.home_department_id, ' +
            'investigators.last_name, ' +
            'investigators.first_name, ' +
            'investigators.middle_name, ' +
            'investigators.email, ' +
            'investigators.degrees, ' +
            'investigators.suffix, ' +
            'investigators.employee_id, ' +
            'investigators.title, ' +
            'investigators.campus, ' +
            'investigators.appointment_type, ' +
            'investigators.appointment_track, ' +
            'investigators.appointment_basis, ' +
            'investigators.pubmed_search_name, ' +
            'investigators.pubmed_limit_to_institution, ' +
            'investigators.num_first_pubs_last_five_years, ' +
            'investigators.num_last_pubs_last_five_years, ' +
            'investigators.total_publications_last_five_years, ' +
            'investigators.num_intraunit_collaborators_last_five_years, ' +
            'investigators.num_extraunit_collaborators_last_five_years, ' +
            'investigators.num_first_pubs, ' +
            'investigators.num_last_pubs, ' +
            'investigators.total_publications, ' +
            'investigators.num_intraunit_collaborators, ' +
            'investigators.num_extraunit_collaborators, ' +
            'investigators.last_pubmed_search, ' +
            'investigators.mailcode, ' +
            'investigators.address1, ' +
            'investigators.address2, ' +
            'investigators.city, ' +
            'investigators.state, ' +
            'investigators.postal_code, ' +
            'investigators.country, ' +
            'investigators.business_phone, ' +
            'investigators.home_phone, ' +
            'investigators.lab_phone, ' +
            'investigators.fax, ' +
            'investigators.pager, ' +
            'investigators.ssn, ' +
            'investigators.birth_date, ' +
            'investigators.sex, ' +
            'investigators.nu_start_date, ' +
            'investigators.start_date, ' +
            'investigators.end_date, ' +
            'investigators.faculty_keywords, ' +
            'investigators.faculty_research_summary, ' +
            'investigators.faculty_interests, ' +
            'investigators.home_department_name, ' +
            'count(distinct investigator_studies1.*) as study_count, ' +
            'count(distinct studies1.investigator_id) as study_collaborators_count')
    .group('investigators.id, ' +
           'investigators.username, ' +
           'investigators.home_department_id, ' +
           'investigators.last_name, ' +
           'investigators.first_name, ' +
           'investigators.middle_name, ' +
           'investigators.email, ' +
           'investigators.degrees, ' +
           'investigators.suffix, ' +
           'investigators.employee_id, ' +
           'investigators.title, ' +
           'investigators.campus, ' +
           'investigators.appointment_type, ' +
           'investigators.appointment_track, ' +
           'investigators.appointment_basis, ' +
           'investigators.pubmed_search_name, ' +
           'investigators.pubmed_limit_to_institution, ' +
           'investigators.num_first_pubs_last_five_years, ' +
           'investigators.num_last_pubs_last_five_years, ' +
           'investigators.total_publications_last_five_years, ' +
           'investigators.num_intraunit_collaborators_last_five_years, ' +
           'investigators.num_extraunit_collaborators_last_five_years, ' +
           'investigators.num_first_pubs, ' +
           'investigators.num_last_pubs, ' +
           'investigators.total_publications, ' +
           'investigators.num_intraunit_collaborators, ' +
           'investigators.num_extraunit_collaborators, ' +
           'investigators.last_pubmed_search, ' +
           'investigators.mailcode, ' +
           'investigators.address1, ' +
           'investigators.address2, ' +
           'investigators.city, ' +
           'investigators.state, ' +
           'investigators.postal_code, ' +
           'investigators.country, ' +
           'investigators.business_phone, ' +
           'investigators.home_phone, ' +
           'investigators.lab_phone, ' +
           'investigators.fax, ' +
           'investigators.pager, ' +
           'investigators.ssn, ' +
           'investigators.birth_date, ' +
           'investigators.sex, ' +
           'investigators.weekly_hours_min, ' +
           'investigators.nu_start_date, ' +
           'investigators.start_date, ' +
           'investigators.end_date, ' +
           'investigators.faculty_keywords, ' +
           'investigators.faculty_research_summary, ' +
           'investigators.faculty_interests, ' +
           'investigators.home_department_name')
    .order('study_count desc')
    .limit(limit)
    .to_a
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
    [
      Investigator.find_all_by_username(terms) +
      Investigator.where('lower(email) in (:terms)', { :terms=>terms } ).to_a +
      Investigator.find_all_by_employee_id(numeric_terms)
    ].flatten.uniq
  end

  def self.count_all_tsearch(terms)
    investigators = Investigator.find_by_tsearch(terms, :select => 'ID')
    abstract_ids = Abstract.find_by_tsearch(terms, :select => 'ID')
    investigators2 = InvestigatorAbstract.select('DISTINCT investigator_id').where('investigator_abstracts.abstract_id IN (:abstract_ids)', { :abstract_ids => abstract_ids.collect(&:id) })
    (investigators.collect(&:id) + investigators2.collect(&:investigator_id)).uniq.length
  end

  def self.all_tsearch(terms)
    investigators = find_by_tsearch(terms)
    abstract_ids = Abstract.find_by_tsearch(terms, :select => 'ID')
    investigators2 = select("investigators.id, investigators.username, investigators.home_department_id, investigators.last_name, investigators.first_name, investigators.middle_name, investigators.email, investigators.degrees, investigators.suffix, investigators.employee_id, investigators.title, investigators.campus, investigators.appointment_type, investigators.appointment_track, investigators.appointment_basis, investigators.pubmed_search_name, investigators.pubmed_limit_to_institution, investigators.num_first_pubs_last_five_years, investigators.num_last_pubs_last_five_years, investigators.total_publications_last_five_years, investigators.num_intraunit_collaborators_last_five_years, investigators.num_extraunit_collaborators_last_five_years, investigators.num_first_pubs, investigators.num_last_pubs, investigators.total_publications, investigators.num_intraunit_collaborators, investigators.num_extraunit_collaborators, investigators.last_pubmed_search, investigators.mailcode, investigators.address1, investigators.address2, investigators.city, investigators.state, investigators.postal_code, investigators.country, investigators.business_phone, investigators.home_phone, investigators.lab_phone, investigators.fax, investigators.pager, investigators.birth_date, investigators.nu_start_date, investigators.start_date, investigators.end_date, investigators.faculty_keywords, investigators.faculty_research_summary, investigators.faculty_interests, count(investigator_abstracts.abstract_id) as the_cnt")
                     .joins(:investigator_abstracts)
                     .where('investigator_abstracts.abstract_id IN (:abstract_ids)', { :abstract_ids => abstract_ids, :investigator_ids => investigators.collect(&:id) })
                     .group("investigators.id, investigators.username, investigators.home_department_id, investigators.last_name, investigators.first_name, investigators.middle_name, investigators.email, investigators.degrees, investigators.suffix, investigators.employee_id, investigators.title, investigators.campus, investigators.appointment_type, investigators.appointment_track, investigators.appointment_basis, investigators.pubmed_search_name, investigators.pubmed_limit_to_institution, investigators.num_first_pubs_last_five_years, investigators.num_last_pubs_last_five_years, investigators.total_publications_last_five_years, investigators.num_intraunit_collaborators_last_five_years, investigators.num_extraunit_collaborators_last_five_years, investigators.num_first_pubs, investigators.num_last_pubs, investigators.total_publications, investigators.num_intraunit_collaborators, investigators.num_extraunit_collaborators, investigators.last_pubmed_search, investigators.mailcode, investigators.address1, investigators.address2, investigators.city, investigators.state, investigators.postal_code, investigators.country, investigators.business_phone, investigators.home_phone, investigators.lab_phone, investigators.fax, investigators.pager, investigators.birth_date, investigators.nu_start_date, investigators.start_date, investigators.end_date, investigators.faculty_keywords, investigators.faculty_research_summary, investigators.faculty_interests")
                     .order('the_cnt desc, investigators.total_publications desc, investigators.last_name').to_a
    (investigators+investigators2).uniq
  end

  def self.top_ten_tsearch(terms)
    investigators = find_by_tsearch(terms, :limit=>10)
    abstract_ids = Abstract.find_by_tsearch(terms, {:select => 'ID', :limit=>10})
    investigators2 = select("DISTINCT investigators.*").joins(:investigator_abstracts).limit(10)
                     .where('investigator_abstracts.abstract_id IN (:abstract_ids)', { :abstract_ids => abstract_ids, :investigator_ids => investigators.collect(&:id) })
    (investigators+investigators2).uniq
  end

  def self.investigators_tsearch(terms)
    find_by_tsearch(terms)
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

  def self.generate_date(number_years=5)
    cutoff_date = number_years.years.ago.to_date.to_s(:db)
  end

  def unit_list
    home_id = self.home_department_id
    home_id = 0 if home_id.blank? # handles the case where no assignment has been made
    (self.investigator_appointments.collect(&:organizational_unit_id) << home_id).uniq
  end

  def self.distinct_primary_appointments
    select('DISTINCT home_department_id as organizational_unit_id')
    .collect(&:organizational_unit_id)
  end

  def self.distinct_joint_appointments
    joins([:investigator_appointments])
    .select('DISTINCT organizational_unit_id')
    .where("type='Joint'")
    .to_a
    .collect(&:organizational_unit_id)
  end

  def self.distinct_secondary_appointments
    joins([:investigator_appointments])
    .select('DISTINCT organizational_unit_id')
    .where("type='Secondary'")
    .to_a
    .collect(&:organizational_unit_id)
  end

  def self.distinct_memberships
    joins([:member_appointments])
    .select('DISTINCT organizational_unit_id')
    .to_a
    .collect(&:organizational_unit_id)
  end

  def self.distinct_associate_memberships
    joins([:associate_member_appointments])
    .select('DISTINCT organizational_unit_id')
    .to_a
    .collect(&:organizational_unit_id)
  end

  def self.distinct_other_appointments_or_memberships
    joins([:investigator_appointments])
    .select('DISTINCT organizational_unit_id')
    .to_a
    .collect(&:organizational_unit_id)
  end

  def self.distinct_all_appointments_and_memberships
    (distinct_other_appointments_or_memberships+distinct_primary_appointments).uniq.compact
  end

  def self.with_studies
    joins([:studies]).to_a
  end

  def self.has_studies
    where("exists(select 'x' from investigator_studies where investigator_studies.investigator_id = investigators.id)").to_a
  end

  def self.with_pi_studies
    joins([:investigator_pi_studies]).to_a
  end

  def self.has_pi_studies
    where("exists(select 'x' from investigator_studies where investigator_studies.investigator_id = investigators.id and investigator_studies.role = 'PI')").to_a
  end

  def self.all_members
    joins([:member_appointments]).to_a
  end

  def self.all_with_membership
    where("exists(select 'x' from investigator_appointments where investigator_appointments.investigator_id = investigators.id and investigator_appointments.type = 'Member')").to_a
  end

  def self.not_members()
    where("id not in (:all)", { :all => self.all_members }).to_a
  end

  def self.no_appointments()
    where("not exists(select 'x' from investigator_appointments where investigator_appointments.investigator_id = investigators.id )").to_a
  end

  def self.without_programs()
    where("not exists(select 'x' from investigator_appointments where investigator_appointments.investigator_id = investigators.id " +
                      "and investigator_appointments.type in ('Member', 'AssociateMember') and investigator_appointments.end_date is null )").to_a
  end

  # used in the rake tasks to add to the investigator object attributes

  def first_author_publications_cnt()
    self.investigator_abstracts.first_author_abstracts.length
  end

  def last_author_publications_cnt()
    self.investigator_abstracts.last_author_abstracts.length
  end

  def first_author_publications_since_date_cnt
    is_first_author = true
    self.investigator_abstracts
      .joins([:abstract])
      .where("investigator_abstracts.publication_date >= :pub_date and investigator_abstracts.is_first_author = :is_first_author and investigator_abstracts.is_valid = true",
        { :pub_date => Investigator.generate_date(), :is_first_author => is_first_author })
      .count
  end

  def last_author_publications_since_date_cnt()
    is_last_author = true
    self.investigator_abstracts
      .joins([:abstract])
      .where("investigator_abstracts.publication_date >= :pub_date and investigator_abstracts.is_last_author = :is_last_author and investigator_abstracts.is_valid = true",
        { :pub_date => Investigator.generate_date(), :is_last_author => is_last_author })
      .count
  end

  def self.collaborators(investigator_id)
    self.find_by_sql(
      "SELECT distinct i2.* " +
      " FROM investigator_abstracts ia, investigator_abstracts ia2, investigators i2  "+
      " WHERE ia.investigator_id = #{investigator_id} "+
      " AND ia.publication_date > '#{generate_date}' "+
      " AND ia.abstract_id = ia2.abstract_id "+
      " AND ia.investigator_id <> ia2.investigator_id " +
      " AND ia2.investigator_id = i2.id" +
      " AND ia.is_valid = true AND ia2.is_valid = true")
  end

  def self.collaborators_cnt(investigator_id)
    self.collaborators(investigator_id).length
  end

  def self.intramural_collaborators_cnt(investigator_id)
    self.find_by_sql(
      "SELECT distinct ia2.investigator_id " +
      " FROM investigator_abstracts ia, investigator_appointments ip, investigator_abstracts ia2, investigator_appointments ip2 "+
      " WHERE ia.investigator_id  = #{investigator_id} "+
      " AND ia.is_valid = true " +
      " AND ia.investigator_id = ip.investigator_id  "+
      " AND ip.organizational_unit_id = ip2.organizational_unit_id "+
      " AND ip2.investigator_id = ia2.investigator_id "+
      " AND ia.abstract_id = ia2.abstract_id "+
      " AND ia.investigator_id <> ia2.investigator_id " +
      " AND ia2.is_valid = true ").length
  end

  def self.other_collaborators_cnt(investigator_id)
    self.find_by_sql(
      "SELECT distinct ia2.investigator_id " +
      " FROM  abstracts a, investigator_abstracts ia, investigator_abstracts ia2 "+
      " WHERE ia.investigator_id = #{investigator_id} "+
      " AND ia.abstract_id = a.id "+
      " AND ia.is_valid = true " +
      " AND ia.abstract_id = ia2.abstract_id "+
      " AND ia2.is_valid = true " +
      " AND ia.investigator_id <> ia2.investigator_id "+
      " AND NOT EXISTS ( SELECT 'X' FROM investigator_appointments ip, investigator_appointments ip2 "+
      "                  WHERE  ip2.investigator_id = ia2.investigator_id "+
      "                  AND  ip.investigator_id = ia.investigator_id "+
      "                  AND  ip.organizational_unit_id = ip2.organizational_unit_id )"
    ).length
  end

  def self.intramural_collaborators_since_date_cnt(investigator_id)
    self.find_by_sql(
      "SELECT distinct ia2.investigator_id " +
      " FROM abstracts a, investigator_abstracts ia, investigator_appointments ip, investigator_abstracts ia2, investigator_appointments ip2 "+
      " WHERE ia.investigator_id  = #{investigator_id} "+
      " AND ia.abstract_id = a.id "+
      " AND ia.is_valid = true " +
      " AND a.publication_date > '#{generate_date}' "+
      " AND ia.investigator_id = ip.investigator_id  "+
      " AND ip.organizational_unit_id = ip2.organizational_unit_id "+
      " AND ip2.investigator_id = ia2.investigator_id "+
      " AND ia.abstract_id = ia2.abstract_id "+
      " AND ia2.is_valid = true " +
      " AND ia.investigator_id <> ia2.investigator_id "
    ).length
  end

  def self.other_collaborators_since_date_cnt(investigator_id)
    self.find_by_sql(
      "SELECT distinct ia2.investigator_id " +
      " FROM  abstracts a, investigator_abstracts ia, investigator_abstracts ia2 "+
      " WHERE ia.investigator_id = #{investigator_id} "+
      " AND ia.abstract_id = a.id "+
      " AND ia.is_valid = true " +
      " AND a.publication_date > '#{generate_date}' "+
      " AND ia.abstract_id = ia2.abstract_id "+
      " AND ia2.is_valid = true " +
      " AND ia.investigator_id <> ia2.investigator_id "+
      " AND NOT EXISTS ( SELECT 'X' FROM investigator_appointments ip, investigator_appointments ip2 "+
      "                  WHERE  ip2.investigator_id = ia2.investigator_id "+
      "                  AND  ip.investigator_id = ia.investigator_id "+
      "                  AND  ip.organizational_unit_id = ip2.organizational_unit_id )"
    ).length
  end

  # for graphing co-publications
  def self.add_collaboration_hash_to_investigator(investigator )
   if investigator.internal_collaborators.nil?
     investigator.internal_collaborators = {}
     investigator.external_collaborators = {}
   end
  end

  def self.add_collaboration_hash_to_investigators(investigators )
    investigators.each do |investigator|
      add_collaboration_hash_to_investigator(investigator)
    end
  end

  def self.add_collaboration(collaborator_hash,investigator_abstract)
    if collaborator_hash[investigator_abstract.investigator_id.to_s].nil?
      collaborator_hash[investigator_abstract.investigator_id.to_s] = Array.new(0)
    end
    if ! collaborator_hash[investigator_abstract.investigator_id.to_s].include?(investigator_abstract.abstract_id)
      collaborator_hash[investigator_abstract.investigator_id.to_s]<<investigator_abstract.abstract_id
    end
  end

  def self.add_collaboration_to_investigator(investigator_abstract, investigator, investigators_in_unit)
    if investigator.id.to_i != investigator_abstract.investigator_id.to_i
      internal_investigator = investigators_in_unit.find { |i| i.id == investigator_abstract.investigator_id }
      if internal_investigator.nil?
        add_collaboration(investigator.external_collaborators,investigator_abstract)
      else
        add_collaboration(investigator.internal_collaborators,investigator_abstract)
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
    unit_list = investigator.unit_list
    if unit_list.length == 1 then
      investigators_in_unit =
        Investigator.includes(["investigator_appointments"])
          .where("investigator_appointments.organizational_unit_id  = :organizational_unit_id",
            { :organizational_unit_id => unit_list }).to_a +
        Investigator.where("home_department_id = :organizational_unit_id",
            { :organizational_unit_id => unit_list }).to_a

    else
      investigators_in_unit =
        Investigator.includes(["investigator_appointments"])
          .where("investigator_appointments.organizational_unit_id IN (:organizational_unit_ids)",
            { :organizational_unit_ids => unit_list }).to_a +
        Investigator.where("home_department_id IN (:organizational_unit_id)",
            { :organizational_unit_id => unit_list }).to_a
    end

    add_collaboration_hash_to_investigator(investigator)

    # publication_collection is a list of all abstracts, investigators and investigator abstracts
    publication_collection = Abstract.investigator_publications(investigator, number_years )

    # iterate over all publications
    publication_collection.each do |pub|
      if pub.investigator_abstracts.length > 1
        add_collaborations_to_investigator(pub.investigator_abstracts, investigator, investigators_in_unit)
      end
    end
  end

  def self.get_mesh_connections(investigators, number_years = 5)
    add_collaboration_hash_to_investigators(investigators)
    publication_collection = Abstract.investigator_publications(investigators, number_years)
    #iterate over all publications
    publication_collection.each do |pub|
      if pub.investigator_abstracts.length > 1
        add_collaborations_to_investigators(pub.investigator_abstracts, investigators)
      end
    end
  end

end

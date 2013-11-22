# == Schema Information
# Schema version: 20130327155943
#
# Table name: organizational_units
#
#  abbreviation                :string(255)
#  appointment_count           :integer          default(0)
#  campus                      :string(255)
#  children_count              :integer          default(0)
#  created_at                  :timestamp
#  department_id               :integer          default(0), not null
#  depth                       :integer          default(0)
#  division_id                 :integer          default(0)
#  end_date                    :date
#  id                          :integer          default(0), not null, primary key
#  lft                         :integer
#  member_count                :integer          default(0)
#  name                        :string(255)      not null
#  organization_classification :string(255)
#  organization_phone          :string(255)
#  organization_url            :string(255)
#  parent_id                   :integer
#  rgt                         :integer
#  search_name                 :string(255)
#  sort_order                  :integer          default(1)
#  start_date                  :date
#  type                        :string(255)      not null
#  updated_at                  :timestamp
#

class OrganizationalUnit < ActiveRecord::Base
  acts_as_nested_set
  attr_accessor :collaboration_matrix

  has_many :investigator_appointments,
      :conditions => ['investigator_appointments.end_date is null or investigator_appointments.end_date >= :today', {:today => Date.today }]
  has_many :joint_appointments,
      :class_name => "InvestigatorAppointment",
      :conditions => ["investigator_appointments.type = 'Joint' and (investigator_appointments.end_date is null or investigator_appointments.end_date >= :today)", {:today => Date.today }]
  has_many :secondary_appointments,
      :class_name => "InvestigatorAppointment",
      :conditions => ["investigator_appointments.type = 'Secondary' and (investigator_appointments.end_date is null or investigator_appointments.end_date >= :today)", {:today => Date.today }]
  has_many :memberships,
      :class_name => "InvestigatorAppointment",
      :conditions => ["investigator_appointments.type IN ('Member', 'PrimaryMember', 'SecondaryMember', 'TertiaryMember') and (investigator_appointments.end_date is null or investigator_appointments.end_date >= :today)", {:today => Date.today }]
  has_many :any_memberships,
      :class_name => "InvestigatorAppointment",
      :conditions => ["investigator_appointments.type LIKE '%%Member' and (investigator_appointments.end_date is null or investigator_appointments.end_date >= :today)", {:today => Date.today }]
  has_many :primary_memberships,
      :class_name => "InvestigatorAppointment",
      :conditions => ["investigator_appointments.type = 'PrimaryMember' and (investigator_appointments.end_date is null or investigator_appointments.end_date >= :today)", {:today => Date.today }]
  has_many :secondary_memberships,
      :class_name => "InvestigatorAppointment",
      :conditions => ["investigator_appointments.type = 'SecondaryMember' and (investigator_appointments.end_date is null or investigator_appointments.end_date >= :today)", {:today => Date.today }]
  has_many :tertiary_memberships,
      :class_name => "InvestigatorAppointment",
      :conditions => ["investigator_appointments.type = 'TertiaryMember' and (investigator_appointments.end_date is null or investigator_appointments.end_date >= :today)", {:today => Date.today }]
  has_many :associate_memberships,
       :class_name => "InvestigatorAppointment",
       :conditions => ["investigator_appointments.type IN ('AssociateMember', 'PrimaryAssociateMember', 'SecondaryAssociateMember', 'TertiaryAssociateMember') and (investigator_appointments.end_date is null or investigator_appointments.end_date >= :today)", {:today => Date.today }]
  has_many :primary_associate_memberships,
      :class_name => "InvestigatorAppointment",
      :conditions => ["investigator_appointments.type = 'PrimaryAssociateMember' and (investigator_appointments.end_date is null or investigator_appointments.end_date >= :today)", {:today => Date.today }]
  has_many :secondary_associate_memberships,
      :class_name => "InvestigatorAppointment",
      :conditions => ["investigator_appointments.type = 'SecondaryAssociateMember' and (investigator_appointments.end_date is null or investigator_appointments.end_date >= :today)", {:today => Date.today }]
  has_many :tertiary_associate_memberships,
      :class_name => "InvestigatorAppointment",
      :conditions => ["investigator_appointments.type = 'TertiaryAssociateMember' and (investigator_appointments.end_date is null or investigator_appointments.end_date >= :today)", {:today => Date.today }]
  has_many :primary_faculty,
    :class_name => "Investigator",
    :foreign_key => "home_department_id"
  has_many :primary_faculty_publications,
    :source => :investigator_abstracts,
    :conditions => ['investigator_abstracts.is_valid = true'],
    :through => :primary_faculty
  has_many :associated_faculty,
    :source => :investigator,
    :through => :investigator_appointments
  has_many :joint_faculty,
    :source => :investigator,
    :through => :joint_appointments
  has_many :secondary_faculty,
    :source => :investigator,
    :through => :secondary_appointments
  has_many :members,
    :source => :investigator,
    :through => :memberships
  has_many :any_members,
    :source => :investigator,
    :through => :any_memberships
  has_many :primary_members,
    :source => :investigator,
    :through => :primary_memberships
  has_many :secondary_members,
    :source => :investigator,
    :through => :secondary_memberships
  has_many :tertiary_members,
    :source => :investigator,
    :through => :tertiary_memberships
  has_many :associate_members,
    :source => :investigator,
    :through => :associate_memberships
  has_many :primary_associate_members,
    :source => :investigator,
    :through => :primary_associate_memberships
  has_many :secondary_associate_members,
    :source => :investigator,
    :through => :secondary_associate_memberships
  has_many :tertiary_associate_members,
    :source => :investigator,
    :through => :tertiary_associate_memberships
  has_many :organization_abstracts,
    :conditions => ['organization_abstracts.end_date is null']
  has_many :abstracts,
    :through => :organization_abstracts

  scope :ordered, order('organizational_units.sort_order, organizational_units.abbreviation')

  scope :abstracts_by_date, lambda { |*dates|
    joins(:abstracts).where('abstracts.publication_date between :start_date and :end_date', { :start_date => dates.first, :end_date => dates.last })
  }

  # cache this query in a class instance
  @@all_units = nil
  @@head_node = nil
  @@menu_nodes = nil

  def self.all_units
    @@all_units ||= OrganizationalUnit.order('sort_order, search_name, name').to_a
  end

  def self.head_node(node_name)
    @@head_node ||= OrganizationalUnit.find_by_abbreviation(node_name) || OrganizationalUnit.find_by_name(node_name)
  end

  def self.menu_nodes(node_name)
    @@menu_nodes ||= (OrganizationalUnit.find_by_abbreviation(node_name) || OrganizationalUnit.find_by_name(node_name)).self_and_descendants
  end

  def all_organization_abstracts
    self.self_and_descendants.collect{ |unit| unit.organization_abstracts }.flatten.sort_by(&:abstract_id).uniq
  end

  def abstract_ids
    self.organization_abstracts.map(&:abstract_id).uniq
  end

  def abstract_ids_by_date(start_date, end_date)
    self.abstracts.abstracts_by_date(start_date, end_date).map(&:id).uniq
  end

  def all_abstract_ids_by_date(start_date, end_date)
    self.self_and_descendants.collect{ |unit| unit.abstracts.abstracts_by_date(start_date, end_date).map(&:id) }.flatten.uniq
  end

  def all_abstract_ids_by_date_count(start_date, end_date)
    self.all_abstract_ids_by_date(start_date, end_date).length
  end

  def proposal_ids_by_date(start_date, end_date)
    (self.primary_faculty + self.members).map{ |inv| inv.proposals.start_in_range(start_date, end_date).map(&:id) }.flatten.uniq
  end

  def all_proposal_ids_by_date(start_date, end_date)
    self.self_and_descendants.collect{ |unit| (unit.primary_faculty + unit.members).map{ |inv| inv.proposals.start_in_range(start_date, end_date).map(&:id) } }.flatten.uniq
  end

  def abstracts_count
    self.abstract_ids.length
  end

  def proposal_ids
    (self.primary_faculty + self.members).map{ |inv| inv.investigator_proposals.map(&:proposal_id) }.flatten.uniq
  end

  def all_abstract_ids
    self.self_and_descendants.collect{ |unit| unit.organization_abstracts.map(&:abstract_id) }.flatten.uniq
  end

  def all_abstracts_count
    self.all_abstract_ids.length
  end

  def all_abstracts
    self.self_and_descendants.collect{ |unit| unit.abstracts }.flatten.sort { |x,y| y.year+y.pubmed <=> x.year+x.pubmed }.uniq
  end

  def all_members
    self.self_and_descendants.collect{ |unit| unit.members }.flatten.sort { |x,y| x.sort_name <=> y.sort_name }.uniq
  end

  def all_any_members
    self.self_and_descendants.collect{ |unit| unit.any_members }.flatten.sort { |x,y| x.sort_name <=> y.sort_name }.uniq
  end

  def all_associate_members
    self.self_and_descendants.collect{ |unit| unit.associate_members }.flatten.sort { |x,y| x.sort_name <=> y.sort_name }.uniq
  end

  def faculty
    (self.primary_faculty + self.associated_faculty).sort { |x,y| x.sort_name <=> y.sort_name }.uniq
  end

  def all_primary_faculty
    self.self_and_descendants.collect(&:primary_faculty).flatten.sort { |x,y| x.sort_name <=> y.sort_name }.uniq
  end

  def all_joint_faculty
    self.self_and_descendants.collect(&:joint_faculty).flatten.sort { |x,y| x.sort_name <=> y.sort_name }.uniq
  end

  def all_secondary_faculty
    self.self_and_descendants.collect(&:secondary_faculty).flatten.sort { |x,y| x.sort_name <=> y.sort_name }.uniq
  end

  # associated_faculty includes joint, secondary and members
  def all_associated_faculty
    self.self_and_descendants.collect(&:associated_faculty).flatten.sort { |x,y| x.sort_name <=> y.sort_name }.uniq
  end

  def primary_or_member_faculty
    (self.primary_faculty + self.members).sort { |x,y| x.sort_name <=> y.sort_name }.uniq
   end

  def all_primary_or_member_faculty
    (all_primary_faculty + all_members).sort { |x,y| x.sort_name <=> y.sort_name }.uniq
  end

  def all_faculty
    (all_primary_faculty + all_associated_faculty).sort { |x,y| x.sort_name <=> y.sort_name }.uniq
  end

  def all_primary_or_member_faculty_count
    all_primary_or_member_faculty.length
  end

  def get_faculty_by_types(affiliation_types=nil, ranks=nil)
    logger.error("affiliation_types: #{affiliation_types.to_s}")
    #have not implemented rank selectors yet
    if affiliation_types.blank? or affiliation_types.length == 0
      faculty = (all_primary_faculty + all_secondary_faculty + all_members).uniq
      faculty.sort { |x,y| x.sort_name <=> y.sort_name }.uniq
    elsif affiliation_types.length == 1
      if affiliation_types.grep(/primary/i).length > 0
        faculty = all_primary_faculty
      elsif affiliation_types.grep(/secondary/i).length > 0
        faculty = all_secondary_faculty
      elsif affiliation_types.grep(/associate/i).length > 0
        faculty = all_associate_members
      elsif affiliation_types.grep(/member/i).length > 0
        faculty = all_members
      else
        faculty = (all_primary_faculty + all_members).uniq
        faculty.sort { |x,y| x.sort_name <=> y.sort_name }.uniq
      end
    else
      faculty = []
      faculty = all_primary_faculty if affiliation_types.grep(/primary/i).length > 0
      faculty += all_secondary_faculty if affiliation_types.grep(/secondary/i).length > 0
      faculty += all_members if affiliation_types.grep(/member/i).length > 0
      faculty += all_associate_members if affiliation_types.grep(/associate/i).length > 0
      faculty.sort { |x,y| x.sort_name <=> y.sort_name }.uniq
    end
    faculty
  end

  def all_faculty_publications
    faculty = (all_primary_faculty + all_associated_faculty).uniq
    faculty.collect(&:abstracts).flatten.uniq
  end

  def abstracts_shared_with_org(org_id)
     abs = self.all_abstracts
     OrganizationalUnit.find(org_id).all_abstracts & abs
  end

  def abstract_ids_shared_with_org_obj(org)
     self.all_abstract_ids & org.all_abstract_ids
  end

  def abstract_ids_by_date_shared_with_org_obj(org, start_date, end_date)
    self.abstract_ids_by_date(start_date, end_date) & org.abstract_ids_by_date(start_date, end_date)
  end

  def all_abstract_ids_by_date_shared_with_org_obj(org, start_date, end_date)
    self.all_abstract_ids_by_date(start_date, end_date) & org.all_abstract_ids_by_date(start_date, end_date)
  end

  def proposal_ids_by_date_shared_with_org_obj(org, start_date, end_date)
    self.proposal_ids_by_date(start_date, end_date) & org.proposal_ids_by_date(start_date, end_date)
  end

  def all_proposal_ids_by_date_shared_with_org_obj(org, start_date, end_date)
    self.all_proposal_ids_by_date(start_date, end_date) & org.all_proposal_ids_by_date(start_date, end_date)
  end

  def proposal_ids_shared_with_org_obj(org)
    self.proposal_ids & org.proposal_ids
  end

  ##
  # In order to paginate an Array it is necessary to require 'will_paginate/array'
  # cf. https://github.com/mislav/will_paginate/wiki/Backwards-incompatibility
  require 'will_paginate/array'
  def abstract_data(page = 1)
    self.all_abstracts.paginate(:page => page, :per_page => 20,
      :order => 'year DESC, abstracts.publication_date DESC, electronic_publication_date DESC, authors ASC')
  end

  def display_year_data(year = 2008)
    self.abstracts.includes([:investigators])
      .where('year = :year', { :year => year })
      .order('investigators.last_name ASC, authors ASC')
      .to_a
  end

  def display_data_by_date(start_date, end_date)
    self.abstracts.includes([:investigators])
      .where('year = :year', { :year => year })
      .order('abstracts.publication_date between :start_date and :end_date',
        { :start_date => start_date, :end_date => end_date })
      .to_a
  end

  def get_minimal_all_data
    self.all_abstracts
  end

  def self.collaborations(start_date = nil, end_date = nil)
    abstracts = nil
    if end_date.blank? and start_date.blank?
      abstracts = Abstract.all
    elsif start_date.blank?
      abstracts = Abstract.where('abstracts.publication_date <= :end_date or electronic_publication_date <= :end_date',
        { :end_date => end_date }).to_a
    elsif end_date.blank?
      abstracts = Abstract.where('abstracts.publication_date >= :start_date or electronic_publication_date >= :start_date',
        { :start_date => start_date }).to_a
    else
      abstracts = Abstract.where('abstracts.publication_date between :start_date and :end_date or electronic_publication_date between :start_date and :end_date',
        { :start_date => start_date, :end_date => end_date }).to_a
    end
    primary_orgs = includes([:primary_faculty]).where('investigators.id > 0').all
    orgs = includes([:primary_faculty_publications])
      .where('id IN (:org_ids)', { :org_ids => primary_orgs.collect(&:id) })
      .order('id')
      .to_a
    init_matrix(orgs, abstracts)
    build_matrix(orgs)
  end

  private

  def self.init_matrix(orgs, abstracts)
    abstractids = abstracts.collect(&:id)
    orgs.each do |org|
      org.collaboration_matrix = Hash.new if org.collaboration_matrix.nil?
      org.collaboration_matrix[org.id] = abstractids & org.all_faculty_publications.collect(&:abstract_id)
    end
  end
  def self.build_matrix(orgs)
    orgs.each do |org_outer|
      orgs.each do |org_inner|
        org_outer.collaboration_matrix[org_inner.id] = org_outer.collaboration_matrix[org_outer.id] & org_inner.collaboration_matrix[org_inner.id]
      end
    end
  end

end

class OrganizationalUnit < ActiveRecord::Base
  acts_as_nested_set
  attr_accessor :collaboration_matrix

  has_many :investigator_appointments,
      :conditions => ['investigator_appointments.end_date is null or investigator_appointments.end_date >= :now', {:now => Date.today }]
  has_many :joint_appointments,
      :class_name => "InvestigatorAppointment",
      :conditions => ["investigator_appointments.type = 'Joint' and (investigator_appointments.end_date is null or investigator_appointments.end_date >= :now)", {:now => Date.today }]
  has_many :secondary_appointments,
      :class_name => "InvestigatorAppointment",
      :conditions => ["investigator_appointments.type = 'Secondary' and (investigator_appointments.end_date is null or investigator_appointments.end_date >= :now)", {:now => Date.today }]
  has_many :memberships,
      :class_name => "InvestigatorAppointment",
      :conditions => ["investigator_appointments.type = 'Member' and (investigator_appointments.end_date is null or investigator_appointments.end_date >= :now)", {:now => Date.today }]
  has_many :primary_faculty,  
    :class_name => "Investigator",
    :order => "lower(last_name), lower(first_name)",
    :foreign_key => "home_department_id"
  has_many :primary_faculty_abstracts,  
    :source => :investigator_abstracts,
    :through => :primary_faculty
  has_many :associated_faculty,  
    :source => :investigator,
    :order => "last_name, first_name",
    :through => :investigator_appointments
  has_many :joint_faculty,  
    :source => :investigator,
    :order => "last_name, first_name",
    :through => :joint_appointments
  has_many :secondary_faculty,  
    :source => :investigator,
    :order => "last_name, first_name",
    :through => :secondary_appointments
  has_many :members,
     :source => :investigator,
     :order => "lower(last_name), lower(first_name)",
     :through => :memberships
  has_many :organization_abstracts,
        :conditions => ['organization_abstracts.end_date is null or organization_abstracts.end_date >= :now', {:now => Date.today }]
  has_many :abstracts,
        :through => :organization_abstracts

    # cache this query in a class instance
    @@all_units = nil
    @@head_node = nil
    @@menu_nodes = nil
    def self.all_units
      @@all_units ||= OrganizationalUnit.find( :all, :order => "sort_order, search_name, name" )
    end
    
    def self.head_node(node_name)
      @@head_node ||= OrganizationalUnit.find_by_abbreviation( node_name ) || OrganizationalUnit.find_by_name( node_name ) 
    end
    
    def self.menu_nodes(node_name)
      @@menu_nodes ||= (OrganizationalUnit.find_by_abbreviation( node_name ) || OrganizationalUnit.find_by_name( node_name )).self_and_descendants
    end
    
    def all_members
      self.self_and_descendants.collect{|unit| unit.members}.flatten.uniq
    end

    def faculty
      (self.primary_faculty + self.associated_faculty).uniq
    end

    def all_primary_faculty
      self.self_and_descendants.collect(&:primary_faculty).flatten
    end

    # associated_faculty includes joint, secondary and members
    def all_associated_faculty
      self.self_and_descendants.collect(&:associated_faculty).flatten
    end

    def all_faculty
      (all_primary_faculty + all_associated_faculty).uniq
    end
    
    
    def abstract_data( page=1 )
       self.abstracts.paginate(:page => page,
        :per_page => 20, 
        :order => "year DESC, publication_date DESC, electronic_publication_date DESC, authors ASC")
    end

    def display_year_data( year=2008 )
      self.abstracts.find(:all,
        :order => "investigators.last_name ASC,authors ASC",
        :include => [:investigator_abstracts, :investigators],
    		:conditions => ['year = :year', 
     		      {:year => year }])
    end

    def display_data_by_date( start_date, end_date )
      self.abstracts.find(:all,
        :order => "year DESC, investigators.last_name ASC,authors ASC",
        :include => [:investigator_abstracts, :investigators],
    		:conditions => [' publication_date between :start_date and :end_date or electronic_publication_date between :start_date and :end_date ', 
     		      {:start_date => start_date, :end_date => end_date }])
    end

    def get_minimal_all_data( )
      self.abstracts.find(:all)
    end

  #    def investigator_abstracts
  #      proxy_target.collect(&:investigator_abstract).uniq
  #      def abstract
  #        proxy_target.collect(&:abstract)
  #      end
  #    end
  #  has_many :investigator_abstracts, :through => :investigators
  #  has_many :abstracts, :through => :investigator_abstracts

  def self.collaborations( start_date=nil, end_date=nil )
    abstracts=nil
    if end_date.blank? and start_date.blank?
      abstracts=Abstract.find(:all)
    elsif start_date.blank?
      abstracts=Abstract.find(:all,
     		:conditions => [' publication_date <= :end_date or electronic_publication_date <= :end_date ', 
     		      {:end_date => end_date }])
    elsif end_date.blank?
      abstracts=Abstract.find(:all,
     		:conditions => [' publication_date >= :start_date or electronic_publication_date >= :start_date ', 
     		      {:start_date => start_date}])
    else
      abstracts=Abstract.find(:all,
     		:conditions => [' publication_date between :start_date and :end_date or electronic_publication_date between :start_date and :end_date ', 
     		      {:start_date => start_date, :end_date => end_date }])
    end
    primary_orgs = find(:all, :include => [:primary_faculty], :conditions => [' investigators.id > 0'])
    orgs=find(:all, :order => "id", 
      :include => [:primary_faculty_abstracts], 
      :conditions => [' id IN (:org_ids) ', 
 		      {:org_ids => primary_orgs.collect(&:id) }])
    init_matrix(orgs,abstracts)
    build_matrix(orgs)
  end
  
  private
  
  def self.init_matrix(orgs, abstracts)
    abstractids=abstracts.collect(&:id)
    orgs.each do |org|
      org.collaboration_matrix = Hash.new if org.collaboration_matrix.nil?
      org.collaboration_matrix[org.id] = abstractids & org.primary_faculty_abstracts.collect(&:abstract_id)
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

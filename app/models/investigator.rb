class Investigator < ActiveRecord::Base
  acts_as_taggable  # for MeSH terms

  has_many :investigator_abstracts,
         :conditions => ['investigator_abstracts.end_date is null or investigator_abstracts.end_date >= :now', {:now => Date.today }]
  has_many :investigator_colleagues
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
  has_many :abstracts, :through => :investigator_abstracts
#  has_many :investigator_abstracts_meshes
#  has_many :meshes, :through => :investigator_abstracts_meshes
  has_many :investigator_appointments,
    :conditions => ['investigator_appointments.end_date is null or investigator_appointments.end_date >= :now', {:now => Date.today }]
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
  belongs_to :home_department, :class_name => 'OrganizationalUnit'

  named_scope :full_time, :conditions => "appointment_basis = 'FT'"
  named_scope :tenure_track, :conditions => "appointment_type = 'Regular'"
  named_scope :research, :conditions => "appointment_type = 'Research'"
  named_scope :investigator, :conditions => "appointment_track like '%Investigator%'"
  named_scope :investigator_only, :conditions => "appointment_track = 'Investigator'"
  named_scope :clinician, :conditions => "appointment_track like '%Clinician%'"
  named_scope :clinician_only, :conditions => "appointment_track = 'Clinician'"
  default_scope :include => :abstracts
  #default_scope :order => 'lower(investigators.last_name),lower(investigators.first_name)'

  validates_uniqueness_of :username
  validates_presence_of :username

  def name
    [first_name, last_name].join(' ')
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
      find(:all, :joins => [:investigator_appointments], :select => 'DISTINCT organizational_unit_id', :conditions=>"type='Member'").collect(&:organizational_unit_id)
  end

  def self.distinct_other_appointments_or_memberships()
    find(:all, :joins => [:investigator_appointments], :select => 'DISTINCT organizational_unit_id' ).collect(&:organizational_unit_id)
  end
  
  def self.distinct_all_appointments_and_memberships()
    (distinct_other_appointments_or_memberships()+distinct_primary_appointments()).uniq.compact
  end
  
  def self.all_members()
      find(:all, :joins => [:investigator_appointments], :conditions=>"type='Member'")
  end

  def self.not_members()
    allmembers  = self.all_members()
    find(:all, :conditions=>["id not in (:all)", {:all => allmembers}])
  end
  
# used in the rake tasks to add to the investigator object attributes

  def first_author_publications_cnt()
    self.investigator_abstracts.find(:all,
       :conditions => ["is_first_author = :is_first_author",
            {:is_first_author => true}] ).length
  end 

  def last_author_publications_cnt()
    self.investigator_abstracts.find(:all,
        :conditions => [" is_last_author = :is_last_author",
            {:is_last_author => true}] ).length
  end 

  def first_author_publications_since_date_cnt()
   is_first_author = true
   self.investigator_abstracts.find(:all,
      :joins => [:abstract],
      :conditions => ["(publication_date >= :pub_date or electronic_publication_date >= :pub_date) and is_first_author = :is_first_author",
           {:pub_date => Investigator.generate_date(), :is_first_author => is_first_author}] ).length
  end 

  def last_author_publications_since_date_cnt()
    is_last_author = true
    self.investigator_abstracts.find(:all,
     :joins => [:abstract],
         :conditions => ["(publication_date >= :pub_date or electronic_publication_date >= :pub_date) and is_last_author = :is_last_author",
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
         " AND ia2.investigator_id = i2.id")
   end 

  def self.collaborators_cnt(investigator_id)
     self.collaborators(investigator_id).length
  end 

  def self.intramural_collaborators_cnt(investigator_id)
    self.find_by_sql("select distinct ia2.investigator_id " + 
        "  FROM abstracts a, investigator_abstracts ia, investigator_appointments ip, investigator_abstracts ia2, investigator_appointments ip2 "+
        " WHERE ia.investigator_id  = #{investigator_id} "+
        "  AND ia.abstract_id = a.id "+
        "   AND ia.investigator_id = ip.investigator_id  "+
        "   AND ip.organizational_unit_id = ip2.organizational_unit_id "+
        "   AND ip2.investigator_id = ia2.investigator_id "+
        "   AND ia.abstract_id = ia2.abstract_id "+
        "   AND ia.investigator_id <> ia2.investigator_id "
    ).length
  end 
 
  def self.other_collaborators_cnt(investigator_id)
    self.find_by_sql("select distinct ia2.investigator_id " + 
      "  FROM  abstracts a, investigator_abstracts ia, investigator_abstracts ia2 "+
      " WHERE ia.investigator_id = #{investigator_id} "+
      "   AND ia.abstract_id = a.id "+
      "   AND ia.abstract_id = ia2.abstract_id "+
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
         "  AND a.publication_date > '#{generate_date}' "+
        "   AND ia.investigator_id = ip.investigator_id  "+
        "   AND ip.organizational_unit_id = ip2.organizational_unit_id "+
        "   AND ip2.investigator_id = ia2.investigator_id "+
        "   AND ia.abstract_id = ia2.abstract_id "+
        "   AND ia.investigator_id <> ia2.investigator_id "
    ).length
  end 
 
  def self.other_collaborators_since_date_cnt(investigator_id)
    self.find_by_sql("select distinct ia2.investigator_id " + 
      "  FROM  abstracts a, investigator_abstracts ia, investigator_abstracts ia2 "+
      " WHERE ia.investigator_id = #{investigator_id} "+
      "   AND ia.abstract_id = a.id "+
      "   AND a.publication_date > '#{generate_date}' "+
      "   AND ia.abstract_id = ia2.abstract_id "+
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
      add_collaboration_to_investigator(ia, investigator, investigators_in_unit)
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

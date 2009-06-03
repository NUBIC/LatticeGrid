class Investigator < ActiveRecord::Base
  has_many :investigator_abstracts
  has_many :investigator_relationships
  has_many :colleagues, :through => :investigator_relationships
  has_many :abstracts, :through => :investigator_abstracts
  has_many :investigator_abstracts_meshes
  has_many :meshes, :through => :investigator_abstracts_meshes
  has_many :investigator_programs,
    :conditions => ['investigator_programs.end_date is null or investigator_programs.end_date >= :now', {:now => Date.today }]
  has_many :programs, :through => :investigator_programs
  has_many :current_programs, 
    :through => :investigator_programs, 
    :source => :program, 
    :conditions => ['investigator_programs.end_date is null or investigator_programs.end_date >= :now', {:now => Date.today }]
  acts_as_taggable  # for MeSH terms

  validates_uniqueness_of :username
  validates_presence_of :username

  def name
    [first_name, last_name].join(' ')
  end

  def self.similar_investigators(investigator_id)
    self.find(:all, :joins=>[:investigator_relationships], :conditions=>['investigator_relationships.publication_cnt=0 and investigator_relationships.colleague_id=:colleague_id', 
      {:colleague_id => investigator_id}], :order=>'mesh_tags_ic desc', :limit=>15)
  end 

  def self.co_authors(investigator_id)
    self.find(:all, :joins=>[:investigator_relationships], 
    :conditions=>['investigator_relationships.publication_cnt>0 and investigator_relationships.colleague_id=:colleague_id', 
      {:colleague_id => investigator_id}], 
      :order=>'publication_cnt desc, mesh_tags_ic desc')
  end 

  def self.generate_date(number_years=5)
    cutoff_date=number_years.years.ago.to_date
    cutoff_date.to_s(:db)
  end
  
  def self.distinct_departments()
    find(:all, :select => 'DISTINCT home_department' )
  end

  def self.distinct_departments_with_divisions()
    find(:all, :select => 'DISTINCT home_department, division' )
  end
  
  def self.program_members(program_id, investigator_id_to_exclude=0) 
    find :all, 
      :joins => [:programs,:investigator_programs],
      :conditions => ['programs.id = :program_id and not investigator_programs.investigator_id = :investigator_id', 
         {:program_id => program_id, :investigator_id =>  investigator_id_to_exclude }] 
  end 

# used in the rake tasks to add to the investigator object attributes
  def self.publications_cnt(investigator_id)
       pi = find(:first, :include => ["abstracts"],
          :conditions => ["abstracts.publication_date > :pub_date and investigators.id = :investigator_id",
              {:pub_date => generate_date().to_date, :investigator_id => investigator_id}] )
       return 0 if pi.nil? || pi.abstracts.nil?
      pi.abstracts.length
   end 

   def self.first_author_publications_cnt(investigator_id)
     is_first_author = true
     pi = find(:first, :include => ["abstracts"],
         :conditions => ["abstracts.publication_date > :pub_date and investigators.id = :investigator_id and is_first_author = :is_first_author",
             {:pub_date => generate_date().to_date, :investigator_id => investigator_id, :is_first_author => is_first_author}] )
      return 0 if pi.nil? || pi.abstracts.nil?
      pi.abstracts.length
    end 

    def self.last_author_publications_cnt(investigator_id)
      is_last_author = true
      pi = find(:first, :include => ["abstracts"],
          :conditions => ["abstracts.publication_date > :pub_date and investigators.id = :investigator_id and is_last_author = :is_last_author",
              {:pub_date => generate_date().to_date, :investigator_id => investigator_id, :is_last_author => is_last_author}] )
       return 0 if pi.nil? || pi.abstracts.nil?
       pi.abstracts.length
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

  def self.publications_with_program_members_cnt(investigator_id)
    self.find_by_sql("select distinct ia.abstract_id " + 
        "  FROM abstracts a, investigator_abstracts ia, investigator_programs ip, investigator_abstracts ia2, investigator_programs ip2 "+
        " WHERE ia.investigator_id  = #{investigator_id} "+
        "  AND ia.abstract_id = a.id "+
         "  AND a.publication_date > '#{generate_date}' "+
        "   AND ia.investigator_id = ip.investigator_id  "+
        "   AND ip.program_id = ip2.program_id "+
        "   AND ip2.investigator_id = ia2.investigator_id "+
        "   AND ia.abstract_id = ia2.abstract_id "+
        "   AND ia.investigator_id <> ia2.investigator_id "
    ).length
  end 

  def self.intramural_collaborators_cnt(investigator_id)
    self.find_by_sql("select distinct ia2.investigator_id " + 
        "  FROM abstracts a, investigator_abstracts ia, investigator_programs ip, investigator_abstracts ia2, investigator_programs ip2 "+
        " WHERE ia.investigator_id  = #{investigator_id} "+
        "  AND ia.abstract_id = a.id "+
         "  AND a.publication_date > '#{generate_date}' "+
        "   AND ia.investigator_id = ip.investigator_id  "+
        "   AND ip.program_id = ip2.program_id "+
        "   AND ip2.investigator_id = ia2.investigator_id "+
        "   AND ia.abstract_id = ia2.abstract_id "+
        "   AND ia.investigator_id <> ia2.investigator_id "
    ).length
  end 
 
  # no longer used
  # need a funky query as the pi can have multiple program ids
  def self.publications_with_other_members_cnt(investigator_id)
    self.find_by_sql("select distinct ia.abstract_id " + 
      "  FROM  abstracts a, investigator_abstracts ia, investigator_abstracts ia2 "+
      " WHERE ia.investigator_id = #{investigator_id} "+
      "   AND ia.abstract_id = a.id "+
      "   AND a.publication_date > '#{generate_date}' "+
      "   AND ia.abstract_id = ia2.abstract_id "+
      "   AND ia.investigator_id <> ia2.investigator_id "+
      "   AND NOT EXISTS ( SELECT 'X' FROM investigator_programs ip, investigator_programs ip2 "+
      "                     WHERE  ip2.investigator_id = ia2.investigator_id "+
      "                       AND  ip.investigator_id = ia.investigator_id "+
      "                       AND  ip.program_id = ip2.program_id )"
     ).length
  end 

  def self.other_collaborators_cnt(investigator_id)
    self.find_by_sql("select distinct ia2.investigator_id " + 
      "  FROM  abstracts a, investigator_abstracts ia, investigator_abstracts ia2 "+
      " WHERE ia.investigator_id = #{investigator_id} "+
      "   AND ia.abstract_id = a.id "+
      "   AND a.publication_date > '#{generate_date}' "+
      "   AND ia.abstract_id = ia2.abstract_id "+
      "   AND ia.investigator_id <> ia2.investigator_id "+
      "   AND NOT EXISTS ( SELECT 'X' FROM investigator_programs ip, investigator_programs ip2 "+
      "                     WHERE  ip2.investigator_id = ia2.investigator_id "+
      "                       AND  ip.investigator_id = ia.investigator_id "+
      "                       AND  ip.program_id = ip2.program_id )"
    ).length
  end 

 # for graphing co-publications
  def self.add_collaboration(collaborator,investigator_abstract)
    collaborator[investigator_abstract.investigator_id.to_s]=Array.new(0) if collaborator[investigator_abstract.investigator_id.to_s].nil?
    has_abstract = collaborator[investigator_abstract.investigator_id.to_s].find { |i| i == investigator_abstract.abstract_id }
    if has_abstract.blank?
       collaborator[investigator_abstract.investigator_id.to_s][collaborator[investigator_abstract.investigator_id.to_s].length]=investigator_abstract.abstract_id
    end
  end
  
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

  def self.add_collaboration_to_investigator(investigator_abstract, investigator, intra_program_investigators)
    if investigator.id.to_i != investigator_abstract.investigator_id.to_i
      internal_investigator = intra_program_investigators.find { |i| i.id == investigator_abstract.investigator_id }
      if internal_investigator.nil? 
        add_collaboration(investigator.external_collaborators,investigator_abstract )
      else 
        add_collaboration(investigator.internal_collaborators,investigator_abstract )
      end
    end
  end

  def self.add_collaborations_to_investigator(investigator_abstracts, investigator, intra_program_investigators ) 
    investigator_abstracts.each do |ia|
      add_collaboration_to_investigator(ia,investigator, intra_program_investigators)
    end 
  end 

  def self.add_collaborations_to_investigators(investigator_abstracts, input_investigators ) 
    investigator_abstracts.each do |ia|
      investigator = input_investigators.find { |i| i.id == ia.investigator_id }
      if !investigator.nil?
        add_collaborations_to_investigator(investigator_abstracts, investigator, input_investigators)
      end
    end
  end 

  def self.get_connections(investigators, number_years=5)
    add_collaboration_hash_to_investigators(investigators)
    program_publications = Abstract.investigator_publications(investigators, number_years )
    #iterate over all publications
    program_publications.each do |pub|
      if pub.investigator_abstracts.length > 1
        add_collaborations_to_investigators(pub.investigator_abstracts, investigators)
      end
    end
  end

  def self.get_investigator_connections(investigator, number_years=5)
    program_list=investigator.investigator_programs.collect(&:program_id).uniq
    if program_list.length == 1 then
      intra_program_investigators = Investigator.find(:all, 
         :include => ["investigator_programs"],
         :conditions => [" investigator_programs.program_id  = :program_id",
          {:program_id => program_list}] )
    else
      intra_program_investigators = Investigator.find(:all, 
        :include => ["investigator_programs"],
        :conditions => [" investigator_programs.program_id IN (:program_ids)",
         {:program_ids => investigator.investigator_programs.collect(&:program_id).uniq}] )
    end
    add_collaboration_hash_to_investigator(investigator)
    # program_publications is a list of all abstracts, investigators and investigator abstracts
    program_publications = Abstract.investigator_publications(investigator, number_years )
     #iterate over all publications
    program_publications.each do |pub|
      if pub.investigator_abstracts.length > 1
        add_collaborations_to_investigator(pub.investigator_abstracts, investigator, intra_program_investigators)
      end
    end
  end

  def self.get_mesh_connections(investigators, number_years=5)
    add_collaboration_hash_to_investigators(investigators)
    program_publications = Abstract.investigator_publications(investigators, number_years )
    #iterate over all publications
    program_publications.each do |pub|
      if pub.investigator_abstracts.length > 1
        add_collaborations_to_investigators(pub.investigator_abstracts, investigators)
      end
    end
  end

end

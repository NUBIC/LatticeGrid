class Study < ActiveRecord::Base
  has_many :investigator_studies
  has_many :investigators, :through => :investigator_studies

  def pi
     pi_study = self.pi_study
     return nil if pi_study.blank?
     return pi_study.investigator
   end

   def pi_study
     pis = self.investigator_studies.pis
     if pis.length > 0
       return pis.first
     end
     return nil
   end

  def self.without_investigators()
    all(  :conditions => ["not exists(select 'x' from investigator_studies where investigator_studies.study_id = studies.id )"] )
  end
  
  def self.without_pi()
    all(  :conditions => ["not exists(select 'x' from investigator_studies where investigator_studies.study_id = studies.id and investigator_studies.role = 'PI' )"] )
  end
  
  def self.belonging_to_pi_ids(ids)
    all(
        :joins => [:investigators],
        :conditions => [ "investigator_studies.role = 'PI' AND investigator_studies.investigator_id in (:ids)", 
     		      {:ids => ids}],
     		:order => "studies.status, lower(investigators.last_name), lower(investigators.first_name)"
    )
  end
  
end

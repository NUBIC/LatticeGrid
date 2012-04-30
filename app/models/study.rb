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
  
  def self.recents_by_pi(pi_ids, start_date, end_date)
     all(
       :joins => [:investigator_studies],
       :conditions => [ " investigator_studies.role = 'PI' AND investigator_studies.investigator_id in (:ids) and ( studies.approved_date < :end_date) and ( studies.next_review_date >= :start_date) and ( studies.closed_date is null or studies.closed_date >= :start_date)", 
    		      {:ids => pi_ids, :start_date=>start_date, :end_date=>end_date }],
    		:order=> "studies.approved_date"
     )
   end
  
  
end

class Proposal < ActiveRecord::Base
  has_many :investigator_proposals
  has_many :investigators, :through => :investigator_proposals
  
  
  def pi
    pi_award = self.pi_award
    return nil if pi_award.blank?
    return pi_award.investigator
  end

  def pi_award
    pis = self.investigator_proposals.pis
    if pis.length > 0
      return pis.first
    end
    return nil
  end
    
  def self.including_investigator_ids(ids)
    all(
        :joins => [:investigator_proposals, :investigators],
        :conditions => [' investigator_proposals.investigator_id in (:ids)', 
     		      {:ids => ids}]
    )
  end
  
  def self.belonging_to_pi_ids(ids)
    all(
        :joins => [:investigator_proposals,:investigators],
        :conditions => [ "investigator_proposals.role = 'PD/PI' AND investigator_proposals.investigator_id in (:ids)", 
     		      {:ids => ids}]
    )
  end
  
  def self.recents_by_type(funding_type, start_date, end_date)

    # Funding_type is one of the following in NU InfoEd
    # ASSOC
    # EDUC
    # FED
    # FORGOV
    # FOUND
    # HOSP
    # ILAGEN
    # INDUS
    # VOLHEAL
    
    
    all(
      :conditions => [ "proposals.sponsor_type_code in (:funding_type) and (proposals.project_start_date between :start_date and :end_date or proposals.award_start_date between :start_date and :end_date)", 
   		      {:funding_type => funding_type, :start_date=>start_date, :end_date=>end_date }],
   		:order=> "proposals.sponsor_code, proposals.award_start_date"
    )
  end
end

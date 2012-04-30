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
  
  def self.recents_by_pi(pi_ids, start_date, end_date)
    all(
      :joins => [:investigator_proposals],
      :conditions => [ " investigator_proposals.role = 'PD/PI' AND investigator_proposals.investigator_id in (:ids) and (proposals.project_start_date between :start_date and :end_date or proposals.award_start_date between :start_date and :end_date)", 
   		      {:ids => pi_ids, :start_date=>start_date, :end_date=>end_date }],
   		:order=> "proposals.sponsor_type_code,proposals.sponsor_code, proposals.award_start_date"
    )
  end
  
  def self.recents_by_type(funding_types, start_date, end_date)

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
    
    if funding_types.blank?
      all(
        :conditions => [ " (proposals.project_start_date between :start_date and :end_date or proposals.award_start_date between :start_date and :end_date)", 
     		      {:start_date=>start_date, :end_date=>end_date }],
     		:order=> "proposals.sponsor_type_code,proposals.sponsor_code, proposals.award_start_date"
      )
    else
      all(
        :conditions => [ "proposals.sponsor_type_code in (:funding_types) and (proposals.project_start_date between :start_date and :end_date or proposals.award_start_date between :start_date and :end_date)", 
     		      {:funding_types => funding_types, :start_date=>start_date, :end_date=>end_date }],
     		:order=> "proposals.sponsor_type_code,proposals.sponsor_code, proposals.award_start_date"
      )
    end
  end
end

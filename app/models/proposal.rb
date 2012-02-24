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
end

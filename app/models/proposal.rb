class Proposal < ActiveRecord::Base
  has_many :investigator_proposals
  has_many :investigators, :through => :investigator_proposals
end

class Study < ActiveRecord::Base
  has_many :investigator_studies
  has_many :investigators, :through => :investigator_studies
  def self.without_investigators()
    all(  :conditions => ["not exists(select 'x' from investigator_studies where investigator_studies.study_id = studies.id )"] )
  end
end

class InvestigatorColleague < ActiveRecord::Base
  belongs_to :investigator
  belongs_to :colleague, :class_name => 'Investigator'
end

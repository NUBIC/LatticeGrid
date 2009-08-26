class ProgramAbstract < ActiveRecord::Base
  belongs_to :program
  belongs_to :abstract
  validates_uniqueness_of :program_id, :scope => "abstract_id"
end

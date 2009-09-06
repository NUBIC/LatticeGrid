class OrganizationAbstract < ActiveRecord::Base
  belongs_to :organizational_unit
  belongs_to :abstract
  validates_uniqueness_of :organizational_unit_id, :scope => "abstract_id"
end

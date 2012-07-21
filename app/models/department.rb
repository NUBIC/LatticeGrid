class Department < OrganizationalUnit
  belongs_to :school
  has_many :divisions
  accepts_nested_attributes_for :divisions
end

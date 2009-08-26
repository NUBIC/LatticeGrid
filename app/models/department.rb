class Department < OrganizationalUnit
  belongs_to :school
  has_many :divisions
end

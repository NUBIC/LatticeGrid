class School < OrganizationalUnit
  has_many :departments
  has_many :centers
end

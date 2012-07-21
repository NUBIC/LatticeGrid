class Center < School
  belongs_to :school
  has_many :programs
  accepts_nested_attributes_for :programs
end

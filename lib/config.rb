def lattice_grid_instance
  #LatticeGrid should be defined in the config/initializers
  return @@lattice_grid_instance if defined?(@@lattice_grid_instance) and ! @@lattice_grid_instance.blank?
  @@lattice_grid_instance = 'defaults' 
  if defined?(LatticeGrid) and !LatticeGrid.blank? and ! LatticeGrid.the_instance.blank?
    @@lattice_grid_instance = LatticeGrid.the_instance
  end
  @@lattice_grid_instance
end

require 'lattice_grid_helper'

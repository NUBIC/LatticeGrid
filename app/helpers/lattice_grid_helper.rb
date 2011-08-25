module LatticeGridHelper
  require 'config/initializers/latticegrid' unless defined?(LatticeGrid) 

  load "latticegrid/defaults.rb"

 # this is where you override the defaults for LatticeGrid
 # change the_instance in config/initializers/latticegrid.rb

 load "latticegrid/#{lattice_grid_instance}.rb"

end


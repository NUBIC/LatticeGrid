module LatticeGridHelper
  require 'latticegrid' unless defined?(LatticeGrid) 

  load "latticegrid/defaults.rb"

 # this is where you override the defaults for LatticeGrid
 # change the_instance in lib/Zlatticegrid.rb

 load "latticegrid/#{lattice_grid_instance}.rb"

end


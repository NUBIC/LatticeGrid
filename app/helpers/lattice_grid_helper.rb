# -*- coding: utf-8 -*-

##
# LatticeGridHelper module definition
# This module loads the defaults and the lattice_grid_instance
# files defining LatticeGrid instance values used throughout
# the application.
module LatticeGridHelper
  require 'lattice_grid' unless defined?(LatticeGrid)

  load 'lattice_grid/defaults.rb'

  # this is where you override the defaults for LatticeGrid
  # change the_instance in lib/Zlatticegrid.rb
  load "lattice_grid/#{lattice_grid_instance}.rb"
end

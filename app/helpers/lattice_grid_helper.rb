# -*- coding: utf-8 -*-

##
# LatticeGridHelper module definition
# This module loads the defaults and the lattice_grid_instance
# files defining LatticeGrid instance values used throughout
# the application.
module LatticeGridHelper
  require 'latticegrid' unless defined?(LatticeGrid)

  load 'latticegrid/defaults.rb'

  # this is where you override the defaults for LatticeGrid
  # change the_instance in lib/Zlatticegrid.rb
  load "latticegrid/#{lattice_grid_instance}.rb"
end

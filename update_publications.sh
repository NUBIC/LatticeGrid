#!/bin/sh
# UNIX shell script. written Warren Kibbe, 2009-2011

#for linux box
source /home/wakibbe/.bashrc
source /etc/profile

cd /home/wakibbe/latticegrid

rake RAILS_ENV=production nightlyBuild >> rake_results.txt

#clean up the database to keep queries running smoothly
vacuumdb -fz latticegrid_production -U latticegrid

# monthly run this in another shell script
# rake RAILS_ENV=production monthlyBuild >> monthly_rake_results.txt

#rebuild the application cache
rake RAILS_ENV=production tmp:cache:clear 
rake RAILS_ENV=production cache:clear
rake RAILS_ENV=production cache:populate taskname=abstracts > buildCache.txt
rake RAILS_ENV=production cache:populate taskname=investigators >> buildCache.txt
rake RAILS_ENV=production cache:populate taskname=orgs >> buildCache.txt
rake RAILS_ENV=production cache:populate taskname=investigator_graphs >> buildCache.txt
rake RAILS_ENV=production cache:populate taskname=investigator_graphviz >> buildCache.txt
rake RAILS_ENV=production cache:populate taskname=investigator_awards >> buildCache.txt
rake RAILS_ENV=production cache:populate taskname=org_graphs >> buildCache.txt
rake RAILS_ENV=production cache:populate taskname=org_graphviz >> buildCache.txt
rake RAILS_ENV=production cache:populate taskname=awards >> buildCache.txt
rake RAILS_ENV=production cache:populate taskname=mesh >> buildCache.txt
rake RAILS_ENV=production cache:populate taskname=investigator_studies >> buildCache.txt
rake RAILS_ENV=production cache:populate taskname=studies >> buildCache.txt
rake RAILS_ENV=production cache:populate taskname=investigator_cytoscape >> buildCache.txt

# in development

rake tmp:cache:clear 
rake cache:clear
rake cache:populate taskname=abstracts > buildCache.txt
rake cache:populate taskname=investigators >> buildCache.txt
rake cache:populate taskname=orgs >> buildCache.txt
rake cache:populate taskname=investigator_graphs >> buildCache.txt
rake cache:populate taskname=investigator_graphviz >> buildCache.txt
rake cache:populate taskname=investigator_awards >> buildCache.txt
rake cache:populate taskname=org_graphs >> buildCache.txt
rake cache:populate taskname=org_graphviz >> buildCache.txt
rake cache:populate taskname=awards >> buildCache.txt
rake cache:populate taskname=mesh >> buildCache.txt
rake cache:populate taskname=investigator_studies >> buildCache.txt
rake cache:populate taskname=studies >> buildCache.txt
rake cache:populate taskname=investigator_cytoscape >> buildCache.txt

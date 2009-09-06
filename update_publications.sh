#!/bin/sh
# UNIX shell script. written Warren Kibbe, 2009

#for linux box
source /home/wakibbe/.bashrc
source /etc/profile

cd /home/wakibbe/fsmpublications

rake RAILS_ENV=production nightlyBuild >> rake_results.txt
vacuumdb -fz fsmpublications_production -U fsmpublications


# monthly run this:
# rake RAILS_ENV=production monthlyBuild >> monthly_rake_results.txt

rake RAILS_ENV=production tmp:cache:clear 
rake RAILS_ENV=production cache:clear
rake RAILS_ENV=production cache:populate taskname=abstracts > buildCache.txt
rake RAILS_ENV=production cache:populate taskname=investigators >> buildCache.txt
rake RAILS_ENV=production cache:populate taskname=orgs >> buildCache.txt
rake RAILS_ENV=production cache:populate taskname=investigator_graphs >> buildCache.txt
rake RAILS_ENV=production cache:populate taskname=org_graphs >> buildCache.txt

# in development

rake tmp:cache:clear 
rake cache:clear
rake cache:populate taskname=abstracts > buildCache.txt
rake cache:populate taskname=investigators >> buildCache.txt
rake cache:populate taskname=orgs >> buildCache.txt
rake cache:populate taskname=investigator_graphs >> buildCache.txt
rake cache:populate taskname=org_graphs >> buildCache.txt

#!/bin/sh
# UNIX shell script. written Warren Kibbe, 2009

#for linux box
source /home/wakibbe/.bashrc
source /etc/profile

cd /home/wakibbe/nucatspublications
/usr/bin/rake environment RAILS_ENV=production insertInstitutionalAbstracts >> rake_results.txt
vacuumdb -fz nucatspublications_production -U nucatspublications

cd /home/wakibbe/cancerpublications

rake RAILS_ENV=production nightlyBuild >> rake_results.txt
vacuumdb -fz cancerpublications_production -U cancerpublications

# monthly run this:
# rake RAILS_ENV=production monthlyBuild >> monthly_rake_results.txt

rake RAILS_ENV=production tmp:cache:clear 
rake RAILS_ENV=production cache:clear
rake RAILS_ENV=production cache:populate taskname=abstracts > buildCache.txt
rake RAILS_ENV=production cache:populate taskname=investigators >> buildCache.txt
rake RAILS_ENV=production cache:populate taskname=programs >> buildCache.txt
rake RAILS_ENV=production cache:populate taskname=investigator_graphs >> buildCache.txt
rake RAILS_ENV=production cache:populate taskname=program_graphs >> buildCache.txt

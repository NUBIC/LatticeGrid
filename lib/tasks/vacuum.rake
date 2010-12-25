namespace :db do
  task :vacuum => :environment do
    ActiveRecord::Base.connection.execute("VACUUM")
  end
end
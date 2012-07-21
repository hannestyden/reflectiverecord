namespace :db do

  desc "Display database schema changes"
  task :status => :environment do
  end

  desc "Migrate database to the current schema"
  task :update => :environment do
  end

end

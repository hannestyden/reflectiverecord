namespace :db do

  desc "Display database schema changes"
  task :status => :environment do
    puts SchemaMigrator.new.migration_contents
  end

  desc "Migrate database to the current schema"
  task :update => :environment do
    schema_migrator = SchemaMigrator.new
    file_path = "#{Rails.root}/db/migrate/#{schema_migrator.migration_file_name}"
    File.open(file_path, 'w') { |migration_file| migration_file.write(schema_migrator.migration_contents) }
    Rake::Task["migrate"].invoke
  end

end

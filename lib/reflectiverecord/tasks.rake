require 'reflectiverecord/schema_builder/active_record'
require 'reflectiverecord/schema_builder/file_contents'
require 'reflectiverecord/schema_builder/variation'
require 'reflectiverecord/migration_builder'
require 'reflectiverecord/schema_migrator.rb'

namespace :db do

  desc "Display database schema changes"
  task :status => :environment do
    puts ReflectiveRecord::SchemaMigrator.new.migration_contents
  end

  desc "Migrate database to the current schema"
  task :update => :environment do
    schema_migrator = ReflectiveRecord::SchemaMigrator.new
    file_path = "#{Rails.root}/db/migrate/#{schema_migrator.migration_file_name}"
    File.open(file_path, 'w') { |migration_file| migration_file.write(schema_migrator.migration_contents) }
    Rake::Task["db:migrate"].invoke
  end

end

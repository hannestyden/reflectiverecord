#
# Automates ActiveRecord migrations.
#
module ReflectiveRecord
  class SchemaMigrator

    def initialize
      Rails.application.eager_load!
      @migration_builder = ReflectiveRecord::MigrationBuilder.new
      @active_record_schema_builder = SchemaBuilder::ActiveRecord.new "#{Rails.root}/app/models"
      @file_contents_schema_builder = SchemaBuilder::FileContents.new IO.read("#{Rails.root}/db/schema.rb")
      @active_record_model_names = @active_record_schema_builder.active_record_model_names
      @source_schema = @file_contents_schema_builder.build_schema
      @target_schema = @active_record_schema_builder.build_schema_from_model_names @active_record_model_names
      @schema_variation = SchemaBuilder::Variation.new @source_schema, @target_schema
      @migrated_model_names = (@schema_variation.additions.keys + @schema_variation.removals.keys).uniq
      @sequence_number = Dir["#{Rails.root}/db/migrate/*.rb"].count + 1
    end

    def migration_contents
      migrations = @migration_builder.migrations_from_schema_variation @source_schema, @target_schema, @schema_variation.additions, @schema_variation.removals
      migration_class_name = @migration_builder.migration_class_name @migrated_model_names, @sequence_number
      @migration_builder.migration_class_definition migration_class_name, migrations
    end

    def migration_file_name
      @migration_builder.migration_file_name @migrated_model_names, @sequence_number
    end

  end
end

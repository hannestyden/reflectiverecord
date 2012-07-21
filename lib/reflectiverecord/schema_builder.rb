#
# Builds schemas both from existing ReflectiveRecord models and schema.rb files.
#
module ReflectiveRecord
  class SchemaBuilder

    def active_record_models
      model_files = Dir["#{Rails.root}/app/models/**/*.rb"]
      model_files.map{ |path| path[/[^\/]+(?=\.rb$)/] }.map(&:to_sym)
    end

  end
end

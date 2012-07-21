#
# Builds a schema from ActiveRecord models using ReflectiveRecord::Extensions.
#
module ReflectiveRecord
  module SchemaBuilder
    class ActiveRecord

      def active_record_model_names
        model_files = Dir["#{Rails.root}/app/models/**/*.rb"]
        model_files.map{ |path| path[/[^\/]+(?=\.rb$)/] }.map(&:to_sym)
      end

    end
  end
end

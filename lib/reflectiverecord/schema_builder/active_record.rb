#
# Builds a schema from ActiveRecord models using ReflectiveRecord::Extensions.
#
module ReflectiveRecord
  module SchemaBuilder
    class ActiveRecord

      def initialize(model_directory)
        @model_directory = model_directory
      end

      def active_record_model_names
        model_files = Dir["#{@model_directory}/**/*.rb"]
        model_files.map{ |path| path[/[^\/]+(?=\.rb$)/] if (IO.read(path) =~ /<\s*ActiveRecord::Base/) }.compact.map(&:to_sym)
      end

      def build_schema_from_model_names(model_names)
        schema = {}
        model_names.each do |model_name|
          model_class = model_name.to_s.camelize.constantize
          add_default_attributes_to! model_class
          table_name = model_name.to_s.tableize.to_sym
          schema[table_name] = model_class.instance_variable_get :@reflective_attributes
        end
        join_relations = ::ActiveRecord::Base.instance_variable_get :@reflective_joins
        schema.merge(join_relations || {})
      end

      private

      def add_default_attributes_to!(model_class)
        model_class.attribute :created_at, :datetime, null: false
        model_class.attribute :updated_at, :datetime, null: false
      end

    end
  end
end

#
# Extracts the changes between two different schemas.
#
module ReflectiveRecord
  module SchemaBuilder
    class Variation

      def initialize(source_schema, target_schema)
        @source_schema, @target_schema = source_schema, target_schema
      end

      def additions
        changes = {}
        (@target_schema.keys - @source_schema.keys).each do |model_name|
          changes.merge! Hash[model_name => @target_schema[model_name]]
        end
        (@source_schema.keys & @target_schema.keys).each do |model_name|
          (@target_schema[model_name].keys - @source_schema[model_name].keys).map do |attribute_name|
            changes.merge! Hash[model_name => { attribute_name => @target_schema[model_name][attribute_name] }]
          end
        end
        changes
      end

    end
  end
end

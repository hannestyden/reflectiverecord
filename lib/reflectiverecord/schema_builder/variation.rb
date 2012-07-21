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
        additions_between @source_schema, @target_schema
      end

      def removals
        additions_between @target_schema, @source_schema
      end

      private

      def additions_between(source_schema, target_schema)
        changes = {}
        (target_schema.keys - source_schema.keys).each do |model_name|
          changes.merge! Hash[model_name => target_schema[model_name]]
        end
        (source_schema.keys & target_schema.keys).each do |model_name|
          (target_schema[model_name].keys - source_schema[model_name].keys).each do |attribute_name|
            merge_changes! changes, model_name, attribute_name, target_schema
          end
          (source_schema[model_name].keys & target_schema[model_name].keys).each do |attribute_name|
            if schemas_differ?(source_schema, target_schema, model_name, attribute_name)
              merge_changes! changes, model_name, attribute_name, target_schema
            end
          end
        end
        changes
      end

      def merge_changes!(changes, model_name, attribute_name, schema)
        if changes[model_name]
          changes[model_name].merge! Hash[attribute_name => schema[model_name][attribute_name]]
        else
          changes.merge! Hash[model_name => { attribute_name => schema[model_name][attribute_name] }]
        end
      end

      def schemas_differ?(source_schema, target_schema, model_name, attribute_name)
        target_schema[model_name][attribute_name][:type] != source_schema[model_name][attribute_name][:type] or
        target_schema[model_name][attribute_name][:options] != source_schema[model_name][attribute_name][:options]
      end

    end
  end
end

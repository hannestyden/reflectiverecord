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
        (target_schema.keys - source_schema.keys).each do |table_name|
          changes.merge! Hash[table_name => target_schema[table_name]]
        end
        (source_schema.keys & target_schema.keys).each do |table_name|
          (target_schema[table_name].keys - source_schema[table_name].keys).each do |attribute_name|
            merge_changes! changes, table_name, attribute_name, target_schema
          end
          (source_schema[table_name].keys & target_schema[table_name].keys).each do |attribute_name|
            if schemas_differ?(source_schema, target_schema, table_name, attribute_name)
              merge_changes! changes, table_name, attribute_name, target_schema
            end
          end
        end
        changes
      end

      def merge_changes!(changes, table_name, attribute_name, schema)
        if changes[table_name]
          changes[table_name].merge! Hash[attribute_name => schema[table_name][attribute_name]]
        else
          changes.merge! Hash[table_name => { attribute_name => schema[table_name][attribute_name] }]
        end
      end

      def schemas_differ?(source_schema, target_schema, table_name, attribute_name)
        (target_schema[table_name][attribute_name][:type] != source_schema[table_name][attribute_name][:type]) ||
        (target_schema[table_name][attribute_name][:options] != source_schema[table_name][attribute_name][:options])
      end

    end
  end
end

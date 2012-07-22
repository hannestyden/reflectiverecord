#
# Builds a schema from schema.rb file contents.
#
module ReflectiveRecord
  module SchemaBuilder
    class FileContents

      def initialize(schema_file_contents)
        @schema_file_contents = schema_file_contents
      end

      def build_schema
        build_schema_from_lines @schema_file_contents.split("\n")
      end

      private

      def build_schema_from_lines(schema_lines)
        schema = {}
        current_table_name = nil
        schema_lines.each do |line|
          table_name = extract_table_name_from_line line
          column_definition = extract_column_definition_from_line line
          current_table_name = table_name if table_name
          if current_table_name and column_definition
            schema[current_table_name] ||= {}
            schema[current_table_name].merge! column_definition
          end
        end
        schema
      end

      def extract_table_name_from_line(line)
        if table_match_data = line.match(/\screate_table\s*"([^"]+)"/)
          table_name = table_match_data[1]
          table_name.to_sym
        end
      end

      def extract_column_definition_from_line(line)
        if table_match_data = line.match(/\s*t\.([^\s]+)\s+"([^"]+)"\s*(,\s*((:([^\s]+)\s*=>\s*([^\s]+),?\s*)*))?/)
          options = {}
          column_type = :"#{table_match_data[1]}"   # e.g. boolean
          column_name = :"#{table_match_data[2]}"   # e.g. confirmed
          if options_line = table_match_data[4]     # e.g. :default => false, :null => false
            options_match_data = options_line.scan /:([^\s]+)\s*=>\s*([^\s]+)\s*/
            options_match_data.each do |option_match|
              option_name  = :"#{option_match[0]}"
              option_value = option_match[1].gsub(/,$/, '')
              option_value[-1] = '' if option_value[-1] == '.'
              options[option_name] = option_value
            end
          end
          { column_name => { type: column_type, options: options } }
        end
      end

    end
  end
end

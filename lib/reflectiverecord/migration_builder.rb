#
# Automates ActiveRecord migrations.
#
module ReflectiveRecord
  class MigrationBuilder

    def table_migration(model_name, attributes, drop_table=false)
      create_instruction = create_table_instruction model_name, attributes
      drop_instruction = drop_table_instruction model_name
      up_or_down_migration create_instruction, drop_instruction, drop_table
    end

    private

    def create_table_instruction(model_name, attributes)
      instruction = "    create_table :#{model_name.to_s.tableize} do |t|\n"
      attributes.each do |attribute_name, attribute_description|
        formatted_options = format_options attribute_description[:options]
        instruction += "      t.#{attribute_description[:type]} :#{attribute_name}#{formatted_options}\n"
      end
      instruction += "    end\n"
    end

    def drop_table_instruction(model_name)
      "    drop_table :#{model_name.to_s.tableize}\n"
    end

    def up_or_down_migration(up_instruction, down_instruction, reverse_migration=false)
      if reverse_migration
        { up: down_instruction, down: up_instruction }
      else
        { up: up_instruction, down: down_instruction }
      end
    end

    def format_options(options)
      options_string = ""
      options.each { |option_name, option_value| options_string += ", :#{option_name} => #{option_value}" }
      options_string
    end

  end
end

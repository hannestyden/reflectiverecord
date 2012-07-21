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

    def column_migration(model_name, attribute_name, attribute_description, remove_column=false)
      add_instruction = add_column_instruction model_name, attribute_name, attribute_description
      remove_instruction = remove_column_instruction model_name, attribute_name
      up_or_down_migration add_instruction, remove_instruction, remove_column
    end

    def migration_class_definition(class_name, migrations=[])
      migration = "class #{class_name} < ActiveRecord::Migration\n"
      migration += up_instruction migrations
      migration += down_instruction migrations
      migration += "end\n"
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

    def add_column_instruction(model_name, attribute_name, attribute_description)
      formatted_options = format_options attribute_description[:options]
      "    add_column :#{model_name.to_s.tableize}, :#{attribute_name}, :#{attribute_description[:type]}#{formatted_options}\n"
    end

    def remove_column_instruction(model_name, attribute_name)
      "    remove_column :#{model_name.to_s.tableize}, :#{attribute_name}\n"
    end

    def up_instruction(migrations=[])
      instruction = "  def up\n"
      migrations.each{ |migration| instruction += migration[:up] }
      instruction += "  end\n\n"
    end

    def down_instruction(migrations=[])
      instruction = "  def down\n"
      migrations.each{ |migration| instruction += migration[:down] }
      instruction += "  end\n"
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

#
# Allows ActiveRecord models to reflect their attributes.
#
#   class User
#     has_string :email
#     has_attribute :confirmed, :boolean, default: false
#     attribute :username, :string
#   end
#
module ReflectiveRecord
  module Extensions

    ATTRIBUTE_TYPES = [:primary_key, :string, :text, :integer, :float, :decimal, :datetime, :timestamp, :time, :date, :binary, :boolean]

    def attribute(attribute_name, type, options={})
      handle_validation_option attribute_name, options.delete(:validates)
      handle_index_options attribute_name, [[options.delete(:index)], options.delete(:indexes)].flatten.compact
      reflective_attributes = instance_variable_get(:@reflective_attributes) || {}
      reflective_attributes[attribute_name] = { type: type, options: stringify_options(options) }
      instance_variable_set :@reflective_attributes, reflective_attributes
    end

    alias_method :has_attribute, :attribute

    ATTRIBUTE_TYPES.each do |type|
      define_method :"has_#{type}" do |attribute_name, options={}|
        has_attribute attribute_name, type, options
      end
    end

    def belongs_to(model_name, options={})
      handle_validation_option model_name, options.delete(:validates)
      foreign_key = (options[:foreign_key] || "#{model_name}_id").to_sym
      indexes = [[options.delete(:index)], options.delete(:indexes)].flatten.compact
      attribute_options = indexes.present? ? { indexes: indexes } : {}
      if options[:polymorphic]
        attribute foreign_key, :integer, attribute_options
        attribute :"#{model_name}_type", :string
        add_index self.model_name.to_s.tableize, [foreign_key, :"#{model_name}_type"]
      else
        attribute foreign_key, :integer, attribute_options
        add_index self.model_name.to_s.tableize, foreign_key
      end
      super model_name, options
    end

    def has_one(name, options={})
      handle_validation_option name, options.delete(:validates)
      super name, options
    end

    def has_many(name, options={}, &extension)
      handle_validation_option name, options.delete(:validates)
      super name, options, &extension
    end

    def has_and_belongs_to_many(relation_name, options={}, &extension)
      handle_validation_option relation_name, options.delete(:validates)
      reflective_joins = ActiveRecord::Base.instance_variable_get(:@reflective_joins) || {}
      reflective_joins[join_relation_name(relation_name, options)] ||= join_relation_attributes(relation_name, options)
      ActiveRecord::Base.instance_variable_set :@reflective_joins, reflective_joins
      super relation_name, options, &extension
    end

    def serialize(attribute_name, class_name = Object, options={})
      attribute attribute_name, :text, options
      super attribute_name, class_name
    end

    def has_secure_password
      attribute :password_digest, :string
      super
    end

    private

    def add_index(table_name, index_definition)
      reflective_indexes = ActiveRecord::Base.instance_variable_get(:@reflective_indexes) || {}
      reflective_indexes[table_name.to_sym] ||= []
      reflective_indexes[table_name.to_sym] << index_definition
      ActiveRecord::Base.instance_variable_set :@reflective_indexes, reflective_indexes
    end

    def handle_validation_option(name, validations)
      validates name, validations if validations
    end

    def handle_index_options(attribute_name, indexes)
      indexes.map{ |index| index == true ? attribute_name : index }.each do |index|
        add_index self.model_name.to_s.tableize, index
      end
    end

    def join_relation_name(relation_name, options)
      table_name = options[:join_table] || [
        self.name.tableize.to_s,
        (options[:class_name].to_s.tableize if options[:class_name]) || relation_name.to_s
      ].sort.join('_')
      table_name.to_sym
    end

    def join_relation_attributes(relation_name, options)
      first_foreign_key = options[:foreign_key] || "#{self.name.underscore}_id"
      second_foreign_key = options[:association_foreign_key] ||
                           ("#{options[:class_name].underscore}_id" if options[:class_name]) ||
                           "#{relation_name.to_s.singularize}_id"
      {
        first_foreign_key.to_sym  => { :type => :integer, options: { null: 'false' } },
        second_foreign_key.to_sym => { :type => :integer, options: { null: 'false' } }
      }
    end

    def stringify_options(options)
      new_options = {}
      options.each do |name, value|
        new_options[name] = value.kind_of?(String) ? "\"#{value}\"" : value.to_s
      end
      new_options
    end

  end
end

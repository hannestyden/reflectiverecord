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

    ATTRIBUTE_TYPES = begin
      ActiveRecord::Base.connection.native_database_types.keys
    rescue
      [:primary_key, :string, :text, :integer, :float, :decimal, :datetime, :timestamp, :time, :date, :binary, :boolean]
    end

    def attribute(attribute_name, type, options={})
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
      super model_name, options
      foreign_key = options[:foreign_key] || :"#{model_name}_id"
      attribute foreign_key, :integer
      attribute :"#{model_name}_type", :string if options[:polymorphic] == true
    end

    def has_and_belongs_to_many(name, options={}, &extension)
      super name, options, &extension
      reflective_habtm_relationships = instance_variable_get(:@reflective_habtm_relationships) || {}
      reflective_habtm_relationships[name.to_s.singularize.to_sym] = {
        foreign_key: options[:foreign_key] || "#{self.name.underscore}_id",
        association_foreign_key: options[:association_foreign_key] || ("#{options[:class_name].underscore}_id" if options[:class_name]) || "#{name.to_s.singularize}_id",
        join_table: options[:join_table] || [self.name.tableize, (options[:class_name].tableize if options[:class_name]) || name.to_s].sort.join('_')
      }
      instance_variable_set :@reflective_habtm_relationships, reflective_habtm_relationships
    end

    def serialize(attribute_name, class_name = Object, options={})
      super attribute_name, class_name
      attribute attribute_name, :text, options
    end

    def has_secure_password
      super
      attribute :password_digest, :string
    end

    private

    def stringify_options(options)
      new_options = {}
      options.each do |name, value|
        new_options[name] = value.kind_of?(String) ? "\"#{value}\"" : value.to_s
      end
      new_options
    end

  end
end

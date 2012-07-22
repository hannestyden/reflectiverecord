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

    def has_and_belongs_to_many(relation_name, options={}, &extension)
      super relation_name, options, &extension
      reflective_join_relations = ActiveRecord::Base.instance_variable_get(:@reflective_join_relations) || {}
      reflective_join_relations[join_relation_name(relation_name, options)] ||= join_relation_attributes(relation_name, options)
      ActiveRecord::Base.instance_variable_set :@reflective_join_relations, reflective_join_relations
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

    def join_relation_name(relation_name, options)
      table_name = options[:join_table] || [
        self.name.tableize,
        (options[:class_name].tableize if options[:class_name]) || relation_name
      ].sort.join('_')
      table_name.to_sym
    end

    def join_relation_attributes(relation_name, options)
      first_foreign_key = options[:foreign_key] || "#{self.name.underscore}_id"
      second_foreign_key = options[:association_foreign_key] ||
                           ("#{options[:class_name].underscore}_id" if options[:class_name]) ||
                           "#{relation_name.to_s.singularize}_id"
      {
        first_foreign_key.to_sym  => { type: 'integer', options: { null: 'false' } },
        second_foreign_key.to_sym => { type: 'integer', options: { null: 'false' } }
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

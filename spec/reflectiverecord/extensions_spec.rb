require File.expand_path('../../../lib/reflectiverecord.rb', __FILE__)

class ExtensionsTestModel < ActiveRecord::Base
  extend ReflectiveRecord::Extensions

  attribute :name, :string, null: false, default: 'text'
  attribute :number, :integer

  has_attribute :title, :string

  has_decimal :amount
  has_integer :count, null: false

  has_and_belongs_to_many :other_models, join_table: 'my_join_table', association_foreign_key: 'association_id'
  has_and_belongs_to_many :even_more_models, class_name: 'Another', foreign_key: 'some_id'

  belongs_to :associated, class_name: 'OtherModel'
  belongs_to :polymorphic, polymorphic: true

  serialize :complex, Object, null: false, default: {}

  has_secure_password
end

describe ReflectiveRecord::Extensions do
  let(:reflective_attributes)          { ExtensionsTestModel.instance_variable_get(:@reflective_attributes) }
  let(:reflective_habtm_relationships) { ExtensionsTestModel.instance_variable_get(:@reflective_habtm_relationships) }

  it "recognizes string attributes" do
    reflective_attributes[:name][:type].should be(:string)
  end

  it "recognizes integer attributes" do
    reflective_attributes[:number][:type].should be(:integer)
  end

  it "recognizes and stringifies options with attributes" do
    reflective_attributes[:name][:options].should == { null: 'false', default: '"text"' }
  end

  it "recognizes the alias has_attribute" do
    reflective_attributes[:title][:type].should be(:string)
  end

  it "recognizes dynamic attribute type definitions" do
    reflective_attributes[:amount][:type].should be(:decimal)
  end

  it "recognizes and stringifies options with dynamic attribute type definitions" do
    reflective_attributes[:count][:options].should == { null: 'false' }
  end

  it "recognizes belongs_to relationships" do
    reflective_attributes[:associated_id][:type].should be(:integer)
  end

  it "recognizes polymorphic relationships" do
    reflective_attributes[:polymorphic_type][:type].should be(:string)
  end

  it "recognizes has_and_belongs_to_many relationships" do
    reflective_habtm_relationships[:other_model].should be_kind_of(Hash)
  end

  it "generates has_and_belongs_to_many options foreign_key, association_foreign_key, and join_table correctly" do
    reflective_habtm_relationships[:other_model].should == { join_table: 'my_join_table', foreign_key: 'extensions_test_model_id', association_foreign_key: 'association_id' }
    reflective_habtm_relationships[:even_more_model].should == { join_table: 'anothers_extensions_test_models', foreign_key: 'some_id', association_foreign_key: 'another_id' }
  end

  it "recognizes serialized attributes" do
    reflective_attributes[:complex][:type].should be(:text)
  end

  it "recognizes and stringifies options with serialized attributes" do
    reflective_attributes[:complex][:options].should == { null: 'false', default: '{}' }
  end

  it "recognizes secure password attributes" do
    reflective_attributes[:password_digest][:type].should be(:string)
  end

  it "ignores options with belongs_to relationships" do
    reflective_attributes[:associated_id][:options].should be_empty
  end

  it "includes the right number of attributes" do
    reflective_attributes.count.should be(10)
  end

end

require File.expand_path('../../../lib/reflectiverecord.rb', __FILE__)

class ExtensionsTestModel < ActiveRecord::Base
  extend ReflectiveRecord::Extensions

  attribute :name, :string, null: false, default: 'text'
  attribute :number, :integer

  has_attribute :title, :string

  has_decimal :amount
  has_integer :count, null: false

  belongs_to :associated, class_name: 'OtherModel'
  belongs_to :polymorphic, polymorphic: true

  serialize :complex, Object, null: false, default: {}

  has_secure_password
end

describe ReflectiveRecord::Extensions do
  let(:reflective_attributes) { ExtensionsTestModel.instance_variable_get(:@reflective_attributes) }

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

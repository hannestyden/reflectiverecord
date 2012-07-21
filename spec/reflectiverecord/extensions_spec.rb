require File.expand_path('../../../lib/reflectiverecord.rb', __FILE__)

class TestModel < ActiveRecord::Base
  extend ReflectiveRecord::Extensions

  attribute :name, :string, null: false, default: 'text'
  attribute :number, :integer

  has_attribute :title, :string

  belongs_to :other, class_name: 'OtherClass'
  belongs_to :polymorphic_target, polymorphic: true

  serialize :complex_property, Object, null: false, default: {}

  has_secure_password
end

describe ReflectiveRecord::Extensions do

  let(:reflective_attributes) { TestModel.instance_variable_get(:@reflective_attributes) }

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

  it "recognizes belongs_to relationships" do
    reflective_attributes[:other_id][:type].should be(:integer)
  end

  it "recognizes polymorphic relationships" do
    reflective_attributes[:polymorphic_target_type][:type].should be(:string)
  end

  it "recognizes serialized attributes" do
    reflective_attributes[:complex_property][:type].should be(:text)
  end

  it "recognizes and stringifies options with serialized attributes" do
    reflective_attributes[:complex_property][:options].should == { null: 'false', default: '{}' }
  end

  it "recognizes secure password attributes" do
    reflective_attributes[:password_digest][:type].should be(:string)
  end

  it "ignores options with belongs_to relationships" do
    reflective_attributes[:other_id][:options].should be_empty
  end

  it "includes the right number of attributes" do
    reflective_attributes.count.should be(8)
  end

end

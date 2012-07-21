require File.expand_path('../../../lib/reflectiverecord.rb', __FILE__)

class TestUser < ActiveRecord::Base
  extend ReflectiveRecord::Extensions

  attribute  :name,   :string
  attribute  :number, :integer
  belongs_to :other, class_name: 'OtherClass'
  belongs_to :polymorphic_target, polymorphic: true

  serialize  :complex_property
  has_secure_password
end

describe ReflectiveRecord::Extensions do

  let(:reflective_attributes) { TestUser.instance_variable_get(:@reflective_attributes) }

  it "recognizes string attributes" do
    reflective_attributes[:name][:type].should be(:string)
  end

  it "recognizes integer attributes" do
    reflective_attributes[:number][:type].should be(:integer)
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

  it "recognizes secure password attributes" do
    reflective_attributes[:password_digest][:type].should be(:string)
  end

  it "ignores options with belongs_to relationships" do
    reflective_attributes[:other_id][:options].should be_empty
  end

  it "sets the right number of attributes" do
    reflective_attributes.count.should be(7)
  end

end

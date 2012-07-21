require File.expand_path('../../../lib/reflectiverecord.rb', __FILE__)

class Rails
  def self.root; '/some/path'; end
end

describe ReflectiveRecord::SchemaBuilder do
  let(:schema_builder) { ReflectiveRecord::SchemaBuilder.new }

  describe "#active_record_models" do
    it "calls Dir[] with the correct path to ActiveRecord models" do
      Dir.should_receive(:[]).with('/some/path/app/models/**/*.rb').and_return []
      schema_builder.active_record_models
    end

    it "returns all ActiveRecord model names as symbols" do
      Dir.stub(:[]).and_return ['/some/path/to/first.rb', '/some/other/path/to/second_model.rb']
      schema_builder.active_record_models.should == [:first, :second_model]
    end
  end

end

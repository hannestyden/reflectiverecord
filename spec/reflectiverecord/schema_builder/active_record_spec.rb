require File.expand_path('../../../../lib/reflectiverecord.rb', __FILE__)

class ActiveRecordTestModel < ActiveRecord::Base
  extend ReflectiveRecord::Extensions

  has_integer :number, null: false, default: 5
end

class AnotherActiveRecordTestModel < ActiveRecord::Base
  extend ReflectiveRecord::Extensions

  has_string :title
  has_text :description
end

describe ReflectiveRecord::SchemaBuilder::ActiveRecord do
  let(:schema_builder) { ReflectiveRecord::SchemaBuilder::ActiveRecord.new('/some/path/to/models') }

  describe "#active_record_model_names" do
    it "calls Dir[] with the correct path to ActiveRecord models" do
      Dir.should_receive(:[]).with('/some/path/to/models/**/*.rb').and_return []
      schema_builder.active_record_model_names
    end

    it "reads the ActiveRecord model files to check whether they are indeed ActiveRecord::Base subclasses" do
      Dir.stub(:[]).and_return ['/some/path/to/first.rb', '/some/other/path/to/second_model.rb']
      IO.should_receive(:read).with('/some/path/to/first.rb')
      IO.should_receive(:read).with('/some/other/path/to/second_model.rb')
      schema_builder.active_record_model_names
    end

    it "excludes models which are not subclasses of ActiveRecord::Base" do
      Dir.stub(:[]).and_return ['/some/path/to/first.rb', '/some/other/path/to/second_model.rb']
      IO.stub(:read).and_return ''
      schema_builder.active_record_model_names.should == []
    end

    it "returns all ActiveRecord model names as symbols" do
      Dir.stub(:[]).and_return ['/some/path/to/first.rb', '/some/other/path/to/second_model.rb']
      IO.stub(:read).and_return 'Class < ActiveRecord::Base'
      schema_builder.active_record_model_names.should == [:first, :second_model]
    end
  end

  describe "#build_schema_from_model_names" do
    let(:model_names)  { [:active_record_test_model, :another_active_record_test_model] }
    let(:built_schema) { schema_builder.build_schema_from_model_names(model_names) }

    it "returns a hash with the model names as keys" do
      built_schema.keys.should =~ model_names
    end

    it "retrieves the reflective attributes from the given models" do
      built_schema[:another_active_record_test_model].keys.should include(:title, :description)
    end

    it "adds the default attributes created_at and updated_at to each model" do
      built_schema[:another_active_record_test_model].keys.should include(:created_at, :updated_at)
    end

    describe "attribute format" do
      it "has type and options" do
        built_schema[:active_record_test_model][:number].keys.should =~ [:type, :options]
      end

      describe "type" do
        it "is correct and a symbol" do
          built_schema[:active_record_test_model][:number][:type].should == :integer
        end
      end

      describe "options" do
        it "are correct and a hash" do
          built_schema[:active_record_test_model][:number][:options].should be_kind_of(Hash)
        end

        it "have symbols as keys" do
          built_schema[:active_record_test_model][:number][:options].keys.should =~ [:null, :default]
        end

        it "have strings as values" do
          built_schema[:active_record_test_model][:number][:options].values.should =~ ['false', '5']
        end
      end
    end
  end

end

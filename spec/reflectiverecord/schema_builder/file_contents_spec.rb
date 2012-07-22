require File.expand_path('../../../../lib/reflectiverecord.rb', __FILE__)

FILE_CONTENTS_TEST_SCHEMA = <<EOF
ActiveRecord::Schema.define(:version => 10000000000000) do

  create_table "cars", :force => true do |t|
    t.integer  "weight"
    t.boolean  "speedy"
    t.integer  "owner_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "people", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "wheels", :force => true do |t|
    t.integer  "color", :null => false, :default => 123
    t.text     "options"
    t.integer  "car_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end
EOF

describe ReflectiveRecord::SchemaBuilder::FileContents do
  let(:schema_builder) { ReflectiveRecord::SchemaBuilder::FileContents.new(FILE_CONTENTS_TEST_SCHEMA) }

  describe "#build_schema" do
    let(:built_schema) { schema_builder.build_schema }

    it "returns a hash with the table names as keys" do
      built_schema.keys.should =~ [:cars, :people, :wheels]
    end

    it "retrieves the correct attributes from the given models" do
      built_schema[:wheels].keys.should =~ [:color, :options, :car_id, :created_at, :updated_at]
    end

    describe "attribute format" do
      it "has type and options" do
        built_schema[:cars][:speedy].keys.should =~ [:type, :options]
      end

      describe "type" do
        it "is correct and a symbol" do
          built_schema[:cars][:speedy][:type].should == :boolean
        end
      end

      describe "options" do
        it "are correct and a hash" do
          built_schema[:wheels][:created_at][:options].should be_kind_of(Hash)
        end

        it "have symbols as keys" do
          built_schema[:wheels][:created_at][:options].keys.should =~ [:null]
        end

        it "have strings as values" do
          built_schema[:wheels][:created_at][:options].values.should =~ ['false']
        end
      end
    end
  end

end

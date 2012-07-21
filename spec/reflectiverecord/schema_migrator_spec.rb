require File.expand_path('../../../lib/reflectiverecord.rb', __FILE__)

class Car < ActiveRecord::Base
  extend ReflectiveRecord::Extensions

  attribute :weight, :integer
  attribute :speedy, :boolean
  belongs_to :owner, class_name: 'Person'
  has_many :wheels
end

class Person < ActiveRecord::Base
  extend ReflectiveRecord::Extensions

  attribute :name, :string
  has_one :car
end

class Wheel < ActiveRecord::Base
  extend ReflectiveRecord::Extensions

  attribute :color, :integer, default: 123, null: false
  serialize :options
  belongs_to :car
end

IDENTICAL_SCHEMA_FILE = <<EOF
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

DIFFERENT_SCHEMA_FILE = <<EOF
ActiveRecord::Schema.define(:version => 10000000000000) do

  create_table "cars", :force => true do |t|
    t.integer  "weight"
    t.string   "nickname"
    t.integer  "owner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "wheels", :force => true do |t|
    t.integer  "color"
    t.text     "options", :null => false, :default => "{}"
    t.integer  "car_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tools", :force => true do |t|
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

EOF

describe ReflectiveRecord::SchemaMigrator do
  before :each do
    IO.stub(:read).and_return IDENTICAL_SCHEMA_FILE
    Dir.stub(:[]).and_return ['/some/path/car.rb', '/some/path/person.rb', '/some/path/wheel.rb']
    active_record_schema_builder = ReflectiveRecord::SchemaBuilder::ActiveRecord.new '/some/path'
    active_record_schema_builder.stub(:active_record_model_names).and_return [:car, :person, :wheel]
    ReflectiveRecord::SchemaBuilder::ActiveRecord.stub(:new).and_return active_record_schema_builder
  end

  describe "#initialize" do
    it "does not produce any errors" do
      ReflectiveRecord::SchemaMigrator.new
    end
  end

  describe "#migration_contents" do
    let(:empty_contents) do <<EOF
class MigrateNothingNo00004 < ActiveRecord::Migration
  def up
  end

  def down
  end
end
EOF
    end

    context "given an identical schema file" do
      it "returns an empty migration" do
        ReflectiveRecord::SchemaMigrator.new.migration_contents.should == empty_contents
      end
    end

    context "given a different schema file" do
      before :each do
        IO.stub(:read).and_return DIFFERENT_SCHEMA_FILE
      end

      let(:migration)      { ReflectiveRecord::SchemaMigrator.new.migration_contents }
      let(:up_migration)   { migration.gsub(/def down.*\z/, '') }
      let(:down_migration) { migration.gsub(/\A.*def down/, '') }

      it "names the migration correctly" do
        migration.should match(/class MigratePeopleAndCarsAndWheelsAndMoreNo00004/)
      end

      it "recognizes table additions in up part" do
        up_migration.should match(/create_table :people/)
      end

      it "recognizes table additions in down part" do
        down_migration.should match(/drop_table :people/)
      end

      it "recognizes dropped tables in up part" do
        up_migration.should match(/drop_table :tools/)
      end

      it "recognizes dropped tables in down part" do
        down_migration.should match(/create_table :tools/)
      end

      it "recognizes attribute additions in up part" do
        up_migration.should match(/add_column :cars, :speedy, :boolean/)
      end

      it "recognizes attribute additions in down part" do
        up_migration.should match(/remove_column :cars, :speedy/)
      end

      it "recognizes removed attributes in up part" do
        up_migration.should match(/remove_column :cars, :nickname/)
      end

      it "recognizes removed attributes in down part" do
        up_migration.should match(/add_column :cars, :nickname, :string/)
      end

      it "recognizes added options in up part" do
        up_migration.should match(/remove_column :wheels, :color.*add_column :wheels, :color, :integer, :default => 123, :null => false/m)
      end

      it "recognizes added options in down part" do
        up_migration.should match(/remove_column :wheels, :color.*add_column :wheels, :color, :integer/m)
      end

      it "recognizes removed options in up part" do
        up_migration.should match(/remove_column :wheels, :color.*add_column :wheels, :options, :text/m)
      end

      it "recognizes removed options in up part" do
        up_migration.should match(/remove_column :wheels, :color.*add_column :wheels, :options, :text, :null => false, :default => "{}"/m)
      end
    end
  end

  describe "#migration_file_name" do
    it "calls the appropriate MigrationBuilder method" do
      ReflectiveRecord::MigrationBuilder.any_instance.should_receive :migration_file_name
      ReflectiveRecord::SchemaMigrator.new.migration_file_name
    end
  end

end

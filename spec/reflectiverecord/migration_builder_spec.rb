require File.expand_path('../../../lib/reflectiverecord.rb', __FILE__)

describe ReflectiveRecord::MigrationBuilder do
  let(:migration_builder) { ReflectiveRecord::MigrationBuilder.new }

  describe "#table_migration" do
    let(:attributes) { Hash[:title => Hash[:type => :string, :options => { null: 'false' }]] }

    let(:create_table_migration) do <<EOF
    create_table :some_models do |t|
      t.string :title, :null => false
    end
EOF
    end

    let(:drop_table_migration) do <<EOF
    drop_table :some_models
EOF
    end

    describe "creating a table" do
      let (:table_migration) { migration_builder.table_migration(:some_models, attributes) }

      it "builds the correct up migration" do
        table_migration[:up].should == create_table_migration
      end

      it "builds the correct down migration" do
        table_migration[:down].should == drop_table_migration
      end
    end

    describe "dropping a table" do
      let (:table_migration) { migration_builder.table_migration(:some_models, attributes, true) }

      it "builds the correct up migration" do
        table_migration[:up].should == drop_table_migration
      end

      it "builds the correct down migration" do
        table_migration[:down].should == create_table_migration
      end
    end
  end

  describe "#column_migration" do
    describe "without an index" do
      let(:attribute_description) { Hash[:type => :string, :options => { null: 'false' }] }

      let(:add_column_migration) do <<EOF
    add_column :some_models, :title, :string, :null => false
EOF
      end

      let(:remove_column_migration) do <<EOF
    remove_column :some_models, :title
EOF
      end

      let (:column_migration) { migration_builder.column_migration(:some_models, :title, attribute_description) }

      it "builds the correct up migration" do
        column_migration[:up].should == add_column_migration
      end

      it "builds the correct down migration" do
        column_migration[:down].should == remove_column_migration
      end
    end

    describe "with a single-column index" do
      let(:attribute_description) { Hash[:type => :string, :options => { :index => :title }] }

      let(:add_column_migration) do <<EOF
    add_column :some_models, :title, :string
    add_index :some_models, :title, :name => "some_models_title_index"
EOF
      end

      let(:remove_column_migration) do <<EOF
    remove_column :some_models, :title
    remove_index :some_models, :name => "some_models_title_index"
EOF
      end

      let (:column_migration) { migration_builder.column_migration(:some_models, :title, attribute_description) }

      it "builds the correct up migration" do
        column_migration[:up].should == add_column_migration
      end

      it "builds the correct down migration" do
        column_migration[:down].should == remove_column_migration
      end
    end

    describe "with a compound index" do
      let(:attribute_description) { Hash[:type => :string, :options => { :index => [:some_other_column, :title] }] }

      let(:add_column_migration) do <<EOF
    add_column :some_models, :title, :string
    add_index :some_models, [:some_other_column, :title], :name => "some_models_some_other_column_title_index"
EOF
      end

      let(:remove_column_migration) do <<EOF
    remove_column :some_models, :title
    remove_index :some_models, :name => "some_models_some_other_column_title_index"
EOF
      end

      let (:column_migration) { migration_builder.column_migration(:some_models, :title, attribute_description) }

      it "builds the correct up migration" do
        column_migration[:up].should == add_column_migration
      end

      it "builds the correct down migration" do
        column_migration[:down].should == remove_column_migration
      end
    end

    describe "with multiple indexes" do
      let(:attribute_description) { Hash[:type => :string, :options => { :indexes => [[:title, :another_column], [:some_other_column, :title]] }] }

      let(:add_column_migration) do <<EOF
    add_column :some_models, :title, :string
    add_index :some_models, [:title, :another_column], :name => "some_models_title_another_column_index"
    add_index :some_models, [:some_other_column, :title], :name => "some_models_some_other_column_title_index"
EOF
      end

      let(:remove_column_migration) do <<EOF
    remove_column :some_models, :title
    remove_index :some_models, :name => "some_models_title_another_column_index"
    remove_index :some_models, :name => "some_models_some_other_column_title_index"
EOF
      end

      let (:column_migration) { migration_builder.column_migration(:some_models, :title, attribute_description) }

      it "builds the correct up migration" do
        column_migration[:up].should == add_column_migration
      end

      it "builds the correct down migration" do
        column_migration[:down].should == remove_column_migration
      end
    end
  end

  describe "#migration_class_definition" do
    context "given no migrations" do
      let(:expected_class_definition) do <<EOF
class UpdateTables < ActiveRecord::Migration
  def up
  end

  def down
  end
end
EOF
      end

      it "generates a class with empty up and down methods" do
        migration_builder.migration_class_definition('UpdateTables').should == expected_class_definition
      end
    end

    context "given migrations" do
      let(:attributes) { Hash[:title => Hash[:type => :string, :options => { null: 'false' }]] }

      let(:migrations) do
        [
          migration_builder.table_migration(:some_models, attributes),
          migration_builder.column_migration(:other_models, :title, :type => :string, :options => { null: 'false' })
        ]
      end

      let(:expected_class_definition) do <<EOF
class UpdateTables < ActiveRecord::Migration
  def up
    create_table :some_models do |t|
      t.string :title, :null => false
    end
    add_column :other_models, :title, :string, :null => false
  end

  def down
    drop_table :some_models
    remove_column :other_models, :title
  end
end
EOF
      end

      it "generates a class with appropriate up and down methods" do
        migration_builder.migration_class_definition('UpdateTables', migrations).should == expected_class_definition
      end
    end
  end

  describe "#migrations_from_schema_variation" do
    let(:source_schema) do
      {
        users: {
          id: {
            :type => :integer,
            :options => { null: 'false' }
          },
          name: {
            :type => :string,
            :options => { null: 'false' }
          },
          age: {
            :type => :integer,
            :options => {}
          }
        }
      }
    end

    let(:target_schema) do
      {
        users: {
          id: {
            :type => :integer,
            :options => { null: 'false' }
          },
          name: {
            :type => :string,
            :options => { null: 'false', default: 'user' }
          },
          email: {
            :type => :string,
            :options => { null: 'false' }
          }
        },
        projects: {
          title: {
            :type => :string,
            :options => {}
          }
        }
      }
    end

    let(:variation)  { ReflectiveRecord::SchemaBuilder::Variation.new(source_schema, target_schema) }
    let(:additions)  { variation.additions }
    let(:removals )  { variation.removals }
    let(:migrations) { migration_builder.migrations_from_schema_variation(source_schema, target_schema, additions, removals) }

    it "returns an array of migrations" do
      migrations.should be_kind_of(Array)
    end

    it "returns the correct migrations" do
      migrations.should =~ [
        {
          up: "    create_table :projects do |t|\n      t.string :title\n    end\n",
          down: "    drop_table :projects\n"
        },
        {
          up: "    add_column :users, :email, :string, :null => false\n",
          down: "    remove_column :users, :email\n",
        },
        {
          up: "    add_column :users, :name, :string, :null => false, :default => user\n",
          down: "    remove_column :users, :name\n"
        },
        {
          up: "    remove_column :users, :age\n",
          down: "    add_column :users, :age, :integer\n"
        },
        {
          up: "    remove_column :users, :name\n",
          down: "    add_column :users, :name, :string, :null => false\n"
        }
      ]
    end
  end

  describe "#migration_class_name" do
    context "given no model names and no sequence number" do
      it "returns the correct class name" do
        migration_builder.migration_class_name.should == 'MigrationV001'
      end
    end

    context "given no model names and a sequence number" do
      it "uses that sequence number correctly" do
        migration_builder.migration_class_name([], 423).should == 'MigrationV423'
      end
    end

    context "given just one model name" do
      it "uses just that model name in the class name" do
        migration_builder.migration_class_name([:articles]).should == 'MigrationOfArticlesV001'
      end
    end

    context "given up to two model names" do
      it "uses these model names in the class name" do
        migration_builder.migration_class_name([:users, :projects]).should == 'MigrationOfUsersAndProjectsV001'
      end
    end

    context "given more than two model names" do
      it "does not use more than two model names in the class name" do
        migration_builder.migration_class_name([:users, :projects, :organizations, :anothers]).should == 'MigrationOfUsersAndProjectsAndMoreV001'
      end
    end
  end

  describe "#migration_file_name" do
    let(:timestamp) { Time.now.strftime("%Y%m%d%H%M%S") }

    it "uses the migration_class_name method" do
      migration_builder.should_receive(:migration_class_name).and_return 'something'
      migration_builder.migration_file_name.should match(/something/)
    end

    it "prepends the current timestamp" do
      migration_builder.migration_file_name.should match(/^#{timestamp}_/)
    end

    it "tableizes the class names and builds a correct file name" do
      migration_builder.migration_file_name([:users, :projects]).should == "#{timestamp}_migration_of_users_and_projects_v001.rb"
    end
  end

  describe "#migration_class_definition" do
    let(:migrations) do
      [
        { up: "    # something up\n", down: "    # something down\n" }
      ]
    end

    let(:expected_class_definition) do <<EOF
class ClassName < ActiveRecord::Migration
  def up
    # something up
  end

  def down
    # something down
  end
end
EOF
    end

    it "builds a correct class migration defintion" do
      migration_builder.migration_class_definition('ClassName', migrations).should == expected_class_definition
    end
  end

end

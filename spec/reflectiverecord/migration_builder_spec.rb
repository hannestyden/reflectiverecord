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
      let (:table_migration) { migration_builder.table_migration(:some_model, attributes) }

      it "builds the correct up migration" do
        table_migration[:up].should == create_table_migration
      end

      it "builds the correct down migration" do
        table_migration[:down].should == drop_table_migration
      end
    end

    describe "dropping a table" do
      let (:table_migration) { migration_builder.table_migration(:some_model, attributes, true) }

      it "builds the correct up migration" do
        table_migration[:up].should == drop_table_migration
      end

      it "builds the correct down migration" do
        table_migration[:down].should == create_table_migration
      end
    end
  end

  describe "#column_migration" do
    let(:attribute_description) { Hash[:type => :string, :options => { null: 'false' }] }

    let(:add_column_migration) do <<EOF
    add_column :some_models, :title, :string, :null => false
EOF
    end

    let(:remove_column_migration) do <<EOF
    remove_column :some_models, :title
EOF
    end

    describe "adding a column" do
      let (:column_migration) { migration_builder.column_migration(:some_model, :title, attribute_description) }

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
          migration_builder.table_migration(:some_model, attributes),
          migration_builder.column_migration(:other_model, :title, :type => :string, :options => { null: 'false' })
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

end

require File.expand_path('../../../../lib/reflectiverecord.rb', __FILE__)

describe ReflectiveRecord::SchemaBuilder::Variation do
  let(:source_schema) do
    {
      user: {
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
      user: {
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
      project: {
        title: {
          :type => :string,
          :options => {}
        }
      }
    }
  end

  let(:variation) { ReflectiveRecord::SchemaBuilder::Variation.new(source_schema, target_schema) }

  describe "#additions" do
    it "returns a hash with the added models and attributes" do
      variation.additions.should == {
        user: {
          name: {
            :type => :string,
            :options => { null: 'false', default: 'user' }
          },
          email: {
            :type => :string,
            :options => { null: 'false' }
          }
        },
        project: {
          title: {
            :type => :string,
            :options => {}
          }
        }
      }
    end
  end

  describe "#removals" do
    it "returns a hash with the added models and attributes" do
      variation.removals.should == {
        user: {
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
  end

end

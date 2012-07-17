Smarter ActiveRecord models
===========================

ReflectiveRecord makes ActiveRecord objects expose their attributes explicitly, rendering the database schema irrelevant and adding a number of powerful Rake tasks to automate database migrations.

A ReflectiveRecord object looks like this:

```ruby
class Article < ActiveRecord::Base
  extend ReflectiveRecord::Attributes

  has_string :title
  has_string :category, null: false, default: 'Uncategorized'
  has_integer :page_count
  has_text :contents

  serialize :meta_data

  belongs_to :user
end
```

You can now update the database schema automatically using:

```
rake db:update
```

This will generate the following migration and migrate the database:

```ruby
class CreateArticles < ActiveRecord::Migration
  def up
    create_table :articles do |t|
      t.string :title
      t.string :category, :null => false, :default => "Uncategorized"
      t.integer :page_count
      t.text :contents
      t.text :meta_data
      t.integer :user_id
      t.datetime :created_at, :null => false
      t.datetime :updated_at, :null => false
      # Add missing indexes here
    end
  end

  def down
    drop_table :articles
  end
end
```

You can just preview the changes to the database schema using:

```
rake db:status
```

Installation
------------

Installing the ReflectiveRecord gem is as simple as adding
```
  gem 'relectiverecord'
```

to your Gemfile and running:
```
  bundle install
```

Usage and Features
------------------

ReflectiveRecord lets you work with smarter ActiveRecord models.

* **Write self-contained ActiveRecord models.**
No more peeking at ```schema.rb```. ReflectiveRecord objects expose their attributes explicitly within the model file.

* **Use powerful Rake tasks to automate migrations.**
Use ```rake db:status``` to see schema changes.
Use ```rake db:update``` to migrate to the updated schema version.
Use ```rake db:update --rebuild``` to merge schema changes into the previous migration and re-migrate.

* **Let database indexes be generated automatically.**
ReflectiveRecord makes educated guesses about which tables need indexing. It scans your model files for foreign keys and database queries and adds appropriate indexes automatically.

* **Use table row options right in your attribute definition.**
Just include them as you would in your migration or schema file:
```ruby
  has_integer :magic_number, null: false, default: 42
```

* **Be flexible in your attribute definitions.**
The following attribute definitions are all equivalent:
```ruby
  has_text :description
  has_attribute :description, :text
  attribute :description, :text
```

* **Use automatic parameter filters for sensitive attributes.**
Add the filter option to your attribute definition to add it to ```config.filter_parameters```:
```ruby
  has_string :password, filter: true
```

* **Combine attribute definitions and validations.**
Use one single line for your attribute definitions and ActiveRecord validations using the inline validation option:
```
  has_string :title, validates: { presence: true, length: { maximum: 80 } }
```

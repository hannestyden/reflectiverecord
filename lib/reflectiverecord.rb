require 'reflectiverecord/version'
require 'active_record'

require "reflectiverecord/extensions"
require "reflectiverecord/schema_builder/active_record.rb"
require "reflectiverecord/schema_builder/file_contents.rb"

require "reflectiverecord/railtie" if defined?(Rails)

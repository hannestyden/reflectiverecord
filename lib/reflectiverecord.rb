require 'reflectiverecord/version'
require 'active_record'

require "reflectiverecord/extensions"
require "reflectiverecord/schema_builder"

require "reflectiverecord/railtie" if defined?(Rails)

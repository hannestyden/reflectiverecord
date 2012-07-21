require 'rails'

module ReflectiveRecord
  class Railtie < Rails::Railtie
    rake_tasks do
      load 'reflectiverecord/tasks.rake'
    end
  end
end

ENV['RAILS_ENV'] ||= 'test'

$LOAD_PATH.unshift File.dirname(__FILE__)

require 'dummy/config/environment'
require 'rspec/rails'
require 'rspec/autorun'
require 'database_cleaner'

Rails.logger.info "====> Doorkeeper.orm = #{Doorkeeper.configuration.orm.inspect}"
Rails.logger.info "====> Rails version: #{Rails.version}"
Rails.logger.info "====> Ruby version: #{RUBY_VERSION}"

Dir["#{File.dirname(__FILE__)}/support/{dependencies,helpers,shared}/*.rb"].each { |f| require f }

# load schema to in memory sqlite
ActiveRecord::Migration.verbose = false
load Rails.root + 'db/schema.rb'

RSpec.configure do |config|
  config.mock_with :rspec

  config.infer_base_class_for_anonymous_controllers = false

  config.before { DatabaseCleaner.start }
  config.after { DatabaseCleaner.clean }

  config.order = 'random'
end

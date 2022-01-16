# Rails 5以降はapplication.rbに以降

require "carrierwave"
require "carrierwave/orm/activerecord"

# Load the Rails application.
require_relative "application"

# Initialize the Rails application.
Rails.application.initialize!

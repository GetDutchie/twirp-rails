# frozen_string_literal: true


require 'active_support'
require 'active_support/ordered_options'
require "rails/railtie"

module Twirp
  module Rails
    class Railtie < ::Rails::Railtie
      config.twirp = ActiveSupport::OrderedOptions.new
      config.twirp.logging = ActiveSupport::OrderedOptions.new
      config.twirp.logging.enabled = true
      config.twirp.logging.log_exceptions = false
      config.twirp.logging.log_params = false
      config.twirp.logging.log_formatter = Twirp::Rails::Logging::Formatters::KeyValue.new


      config.after_initialize do |app|
        Twirp::Rails.load_hooks
        Twirp::Rails.load_handlers
        Twirp::Rails::Routes.install!
        Twirp::Rails.setup_logging(app) if app.config.twirp.logging.enabled
      end
    end
  end
end

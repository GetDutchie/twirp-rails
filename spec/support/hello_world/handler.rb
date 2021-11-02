# frozen_string_literal: true

require_relative 'service_twirp'

class HelloWorldHandler
  include Twirp::Rails::Helpers::Services

  twirp_namespace :test

  bind Example::HelloWorld::HelloWorldService

  def hello(req, env)
    puts ">> Hello #{req.name}"
    {message: "Hello #{req.name}"}
  end
end

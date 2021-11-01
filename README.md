# Twirp::Rails [![Build Status](https://travis-ci.org/nikushi/twirp-rails.svg?branch=master)](https://travis-ci.org/nikushi/twirp-rails) [![Gem Version](https://badge.fury.io/rb/twirp-rails.svg)](https://badge.fury.io/rb/twirp-rails)

Twirp for Rails

## Features

[twirp-ruby](https://github.com/twitchtv/twirp-ruby) with Ruby on Rails. It provides auto routing installation, by using the `bind` helper method to bind a handler and a service.

```
$ bin/rails routes

Prefix Verb URI Pattern                           Controller#Action
            /twirp/HelloService/Greet             hello
            /twirp/HelloService/Hi                hello
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'twirp-rails'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install twirp-rails

## Configuration

After installation, create the following configuration file:

```ruby
# config/initializers/twirp_rails.rb

Twirp::Rails.configuration do |c|
  # Define additional handlers using add_handlers_path
  c.add_handlers_path(Rails.root.join('app', 'controllers', 'rpc'))

  # Define additional handlers using add_hooks_path
  c.add_hooks_path(Rails.root.join('app', 'hooks'))
end
```

### Routes

Add the line `use_twirp` in `config/routes.rb` using a namespace.  By this, you can tell Rails app what endpoints to be served.

```ruby
# config/routes.rb

Rails.application.routes.draw do
  use_twirp(:some_namespace)
end
```

### Binding

Next, let's link handlers(a.k.a controllers) with services.

First we define a `twirp_namespace` matching the namespace defined in `use_twirp` above.

Once we define a namespace, we can bind service handlers to a service using `bind`

```ruby
class HelloHandler
  include Twirp::Rails::Helpers::Services

  twirp_namespace :some_namespace

  bind HelloService

  def greet(_req, _env)
    HelloResponse.new(message: 'hello')
  end
end
```

So now corresponding routes will be defined.

```
$ bin/rails routes

Prefix Verb URI Pattern                           Controller#Action
            /twirp/HelloService/Greet             hello
            /twirp/HelloService/Hi                hello
```

## Service Hooks

Twirp Service Hooks can be defined like this:

```ruby
# app/hooks/authentication_hook.rb

class AuthenticationHook
  include Twirp::Rails::Helpers::Hooks

  # Registers the hook at a namespace with a key
  register_hook :some_namespace, :authentication

  # Service is passed to an attach method
  def self.attach(service)
    # Typical Twirp service hooks
    svc.before do |rack_env, env|
      env[:user_id] = authenticate(rack_env)
      env[:enviornment] = (ENV['ENVIRONMENT'] || :local).to_sym
    end

    svc.on_success do |env|
      Stats.inc("requests.success")
    end

    svc.on_error do |twerr, env|
      Stats.inc("requests.error.#{twerr.code}")
    end

    svc.exception_raised do |e, env|
      if env[:environment] == :local
        puts "[Exception] #{e}"
        puts e.backtrace.join("\n")
      else
        ExceptionTracker.send(e)
      end
    end
  end
end
```

Hooks can be attached in the following ways.

Via a parent class:

```ruby
class ApplicationHandler
  include Twirp::Rails::Helpers::Services

  twirp_hooks :authentication
end
```

Then, all handlers that extend from this base handler will use the hooks.

Via the `bind` method as an option:

```ruby
class HelloHandler
  include Twirp::Rails::Helpers::Services

  bind HelloService, hooks: [:authentication]

  def greet(_req, _env)
    HelloResponse.new(message: 'hello')
  end
end
```

Only this service will have the hooks attached.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/twirp-rails.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

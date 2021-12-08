# frozen_string_literal: true

module Twirp
  module Rails
    class Routes # :nodoc:
      module Helper
        def use_twirp(namespace, options = {})
          services = Twirp::Rails.services
          Twirp::Rails::Routes.new(self, services).generate_routes!(namespace, options)
        end
      end

      # A module to modify the output of the controller part on `rails routes`
      module Inspectable
        REMOVABLE_SUFFIX_RE = /(_handler|_controller)\z/

        def inspect
          instance_variable_get(:@handler).class.name.underscore.sub(REMOVABLE_SUFFIX_RE, '')
        end
      end

      # A null hanlder to cause a bad_route error by unexpected rpc call, instead of raising a routing error by Rails.
      class CatchAllHandler; end

      def self.install!
        ActionDispatch::Routing::Mapper.send :include, Twirp::Rails::Routes::Helper
      end

      attr_reader :routes

      def self.on_create_service(&block)
        Twirp::Rails.global_service_hooks ||= []
        Twirp::Rails.global_service_hooks << block
      end

      def self.run_create_hooks(service_wrapper)
        return unless Twirp::Rails.global_service_hooks.present?

        Twirp::Rails.global_service_hooks.each do |hook|
          hook.call service_wrapper
        end
      end

      def initialize(routes, services)
        @routes = routes
        @services = services
      end

      def generate_routes!(namespace, options)
        routes.scope options[:scope] || 'twirp' do
          @services.each do |service_wrapper, bind_namespace, _context|
            next unless namespace.to_sym == bind_namespace

            service = service_wrapper.service

            service.extend Inspectable
            self.class.run_create_hooks service_wrapper
            service.class.rpcs.values.each do |h|
              rpc_method = h[:rpc_method]
              path = service.full_name + '/' + rpc_method.to_s
              @routes.match path, to: service_wrapper, format: false, via: :all
            end
          end

          # Set catch-all route
          null_service = ::Twirp::Service.new(CatchAllHandler.new)
          null_service.extend Inspectable
          routes.mount null_service, at: '/'
        end
      end
    end
  end
end

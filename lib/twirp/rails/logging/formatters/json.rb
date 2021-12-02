# frozen_string_literal: true

require "json"

module Twirp
  module Rails
    module Logging
      module Formatters
        class Json
          def call(data)
            ::JSON.dump(data)
          end
        end
      end
    end
  end
end

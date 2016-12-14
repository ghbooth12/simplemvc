require "simplemvc/version"
require "simplemvc/controller"
require "simplemvc/utils"
require "simplemvc/dependencies"
require "simplemvc/routing"

module Simplemvc
  class Application
    def call(env)
      if env["PATH_INFO"] == "/favicon.ico"
        return [ 500, {}, [] ]
      end

      # Check routes if url exist. If there is a match, it returns a corresponding action.
      # get_rack_app(env) returns the action.
      get_rack_app(env).call(env)
    end
  end
end

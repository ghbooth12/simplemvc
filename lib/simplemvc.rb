require "simplemvc/version"

module Simplemvc
  class Application
    def call(env)
      if env["PATH_INFO"] == "/"
        # 302 is redirect status.
        return [ 302, { "Location" => "/pages/about" }, [] ]
      end
      if env["PATH_INFO"] == "/favicon.ico"
        return [ 500, {}, [] ]
      end

      # env["PATH_INFO"] = "/pages/about" --> PagesController.send(:about)
      controller_class, action = get_controller_and_action(env)
      response = controller_class.new.send(action) # action is a string.

      [ 200, { "Content-Type" => "text/html" }, [ response ] ]
    end

    def get_controller_and_action(env)
      # "/pages/about".split("/") = ["", "pages", "about"]
      _, controller_name, action = env["PATH_INFO"].split("/") # _ is a dump variable.
      # We need a controller constant, not a string.
      controller_name = controller_name.capitalize + "Controller" # Still it's a string.
      # We can't use "PagesController" string to instantiate. So we need Constant.
      # const_get finds Constant and return it by given string.
      [ Object.const_get(controller_name), action ]
    end
  end
end

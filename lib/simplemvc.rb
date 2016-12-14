require "simplemvc/version"
require "simplemvc/controller"
require "simplemvc/utils"
require "simplemvc/dependencies"

module Simplemvc
  class Application
    def call(env)
      if env["PATH_INFO"] == "/"
        # 302 is redirect status.
        return [ 302, { "Location" => "/my_pages/about" }, [] ]
      end
      if env["PATH_INFO"] == "/favicon.ico"
        return [ 500, {}, [] ]
      end

      # env["PATH_INFO"] = "/pages/about" --> PagesController.send(:about)
      controller_class, action = get_controller_and_action(env)
      controller = controller_class.new(env) # PagesController's instance
      response = controller.send(action) # action is a string. This will trigger method in pages_controller.rb

      if controller.get_response  # If the response is formed
        controller.get_response  # get_response returns @reponse from Controller.
      else
        # If method in pages_controller.rb returns nil, just render action manually here.
        controller.render(action)
        controller.get_response
        # [ 200, { "Content-Type" => "text/html" }, [ response ] ]
      end
    end

    def get_controller_and_action(env)
      # "/pages/about".split("/") = ["", "pages", "about"]
      _, controller_name, action = env["PATH_INFO"].split("/") # _ is a dump variable.
      # We need a controller constant, not a string.
      controller_name = controller_name.to_camel_case + "Controller" # Still it's a string.
      # We can't use "PagesController" string to instantiate. So we need Constant.
      # const_get finds Constant and return it by given string.
      [ Object.const_get(controller_name), action ]
    end
  end
end

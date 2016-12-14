module Simplemvc
  class Router
    def initialize
      # regexp, target
      @routes = []
    end
    # Parse routes and info provided by user, create collection of routes against which applications can check urls from parse info.
    def match(url, *args)
      # puts *args # check if "@router.instance_eval(&block)" is working
      target = nil
      target = args.shift if args.size > 0

      # url = "/:controller/:action"
      url_parts = url.split("/")  # url_parts = ["", ":controller", ":action"]
      url_parts.select! { |part| !part.empty? }

      placeholders = []
      regexp_parts = url_parts.map do |part|
        if part[0] == ":"
          placeholders << part[1..-1]
          "([A-Za-z0-9_]+)" # Matches any character and "_"
        else
          part
        end
      end

      regexp = regexp_parts.join("/")
      @routes << {
        regexp: Regexp.new("^/#{regexp}$"),
        target: target, # "pages#about"
        placeholders: placeholders # ["controller", "action"]
      }
    end

    def check_url(url)
      @routes.each do |route|
        match = route[:regexp].match(url) #url: "/pages/about"
        if match
          placeholders = {}  # { controller: "pages", action: "about" }
          # route[:placeholder] = ["controller", "action"]
          route[:placeholders].each_with_index do |placeholder, index|
            # match.captures[0] is "pages" and match.captures[1] is "about".
            placeholders[placeholder] = match.captures[index]
          end

          if route[:target]  # route[:target] = "home#index"
            return convert_target(route[:target])
          else  # route[:target] = nil (not specified)
            controller = placeholders["controller"]
            action = placeholders["action"]
            return convert_target("#{controller}##{action}")
          end
        end
      end
    end

    def convert_target(target)
      if target =~ /^([^#]+)#([^#]+)$/  # [^#]+ means any character except #
        controller_name = $1.to_camel_case
        controller = Object.const_get("#{controller_name}Controller")
        return controller.action($2)
      end
    end
  end

  class Application
    def route(&block)
      @router ||= Simplemvc::Router.new
      # Evaluate the "block" in the context of the Router.
      @router.instance_eval(&block) # instnace_eval runs the code inside "block".
    end

    # Check routes if url exist. If there is a match, it returns a corresponding action.
    # get_rack_app(env) returns the action.
    def get_rack_app(env)
      @router.check_url(env["PATH_INFO"])
    end
  end
end

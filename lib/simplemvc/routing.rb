module Simplemvc
  class Router
    def initialize
      # regexp, target
      @routes = []
    end
    # Parse routes and info provided by user, create collection of routes against which applications can check urls from parse info.
    def match(url, *args)
      # puts *args # check if "@router.instance_eval(&block)" is working
      target = args.shift if args.size > 0

      @routes << {
        regexp: Regexp.new("^#{url}$"),
        target: target
      }
    end

    def check_url(url)
      @routes.each do |route|
        match = route[:regexp].match(url)
        if match
          if route[:target] =~ /^([^#]+)#([^#]+)$/  # [^#]+ means any character except #
            controller_name = $1.to_camel_case
            controller = Object.const_get("#{controller_name}Controller")
            return controller.action($2)
          end
        end
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

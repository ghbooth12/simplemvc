require 'erubis'

module Simplemvc
  class Controller
    attr_reader :request

    def initialize(env)
      @request ||= Rack::Request.new(env)
    end

    def params
      request.params
    end

    def get_response
      @response
    end

    def response(body, status=200, header={})
      @response = Rack::Response.new(body, status, header)
    end

    # render(:tell_me, name: params["name"])
    def render(*args)
      response(render_template(*args))
      # This will call "response("Hello, Gahee", 200, {})"
    end

    def render_template(view_name, locals = {})
      filename = File.join("app", "views", controller_name, "#{view_name}.erb")
      template = File.read(filename)

      vars = {}  # { name: "Foo Bar" }
      instance_variables.each do |var| # Person.new.instance_variables => [:@name, :@age]
        # var = :@name
        key = var.to_s.gsub("@", "").to_sym  # :@name.to_s => "@name"
        vars[key] = instance_variable_get(var)
        # Person.new.instance_variable_get(:@name) => "Apple"
      end

      # locals = { name: "Apple", age: "20" } This hash is from pages_controller.rb
      Erubis::Eruby.new(template).result(locals.merge(vars))  # returns string
      # Erubis::Eruby.new("Hello, <%= name %>").result(name: "Gahee")
      # => "Hello, Gahee"
    end

    def controller_name
      self.class.to_s.gsub(/Controller$/, "").to_snake_case
    end
  end
end

ActiveRecord::Base.send :include, Pdcawley::ActiveRecord::Acts::Resource
ActionController::Base.send :include, Pdcawley::ActionController::Resourceful

class ActionController::Routing::RouteSet::NamedRouteCollection
  def define_url_helper(route, name, kind, options)
    selector = url_helper_name(name,kind)

    # The segment keys used for positional parameters
    segment_keys = route.segments.collect do |segment|
      segment.key if segment.respond_to? :key
    end.compact
    hash_access_method = hash_access_name(name, kind)

    @module.send(:module_eval, <<-end_eval)
      def #{selector}(*args)
        opts = if args.empty? || Hash === args.first
          args.first || {}
        else
          if (args.size == 1) && args.first.respond_to?(:resource_chain)
            args = args.first.resource_chain
          end
          args.zip(#{segment_keys.inspect}).inject({}) {|h, (v,k)| h.merge!(k => v)}
        end

        url_for(#{hash_access_method}(opts))
      end
    end_eval
    @module.send(:protected, selector)
    helpers << selector
  end
end

class ActionController::Routing::Route
  def parameter_shell_with_current_route
    @parameter_shell ||= returning(parameter_shell_without_current_route) do |params|
      # Make sure we grab a unique key
      params[[:resource_key_chain]] = segments.collect do |segment|
        segment.key if segment.respond_to? :key
      end.compact
    end
  end
  alias_method_chain :parameter_shell, :current_route
end

class ActionController::Routing::RouteSet
  def options_as_params_with_current_route_removed(options)
    returning(options_as_params_without_current_route_removed(options)) do |opts|
      opts.delete [:resource_key_chain]
    end
  end
  alias_method_chain :options_as_params, :current_route_removed
end

class ActionController::AbstractRequest
  attr_accessor :resource_key_chain
  def path_parameters_with_current_route=(parameters)
    if key_chain = parameters.delete([:resource_key_chain])
      self.resource_key_chain = key_chain
    else
      self.resource_key_chain = []
    end
    self.path_parameters_without_current_route = parameters
  end
  alias_method_chain :path_parameters=, :current_route
end


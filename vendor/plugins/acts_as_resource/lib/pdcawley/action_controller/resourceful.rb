module Pdcawley
  module ActionController
    module Resourceful
      def self.included(base)
        base.extend(ClassMethods)
        base.send(:attr_reader, :resource_chain)
        base.send(:protected, :resource_chain)
      end

      module ClassMethods
        def resource_class(key = nil)
          case key
          when nil
            name.sub(/Controller$/,'').classify.constantize
          when Class
            @resource_class = key
          when Symbol, String
            key.to_s.sub!(/_id$/, '').classify.constantize
          else
            raise "Don't know how to find the resource class for #{key}"
          end
        end
      end

      protected

      def resource_class(*args)
        self.class.resource_class(*args)
      end

      def instance_var_name_for(klass, plural = false)
        base_name = klass.to_s.underscore.sub(/_id$/,'')
        if plural
          base_name = base_name.singularize.pluralize # Belt & Braces. Don't want 'childrens'
        end
        "@#{base_name}"
      end

      def set_instance_var_for(key, obj)
        key = key.to_s
        if key == 'id'
          instance_variable_set(instance_var_name_for(obj.class), obj)
        else
          instance_variable_set(instance_var_name_for(key), obj)
        end
      end

      def set_instance_variables_for_chain(resources)
        resources.zip(request.resource_key_chain).each do |(obj, key)|
          set_instance_var_for(key, obj)
        end
        @resource_chain = resources
      end

      def fetch_resources
        key_chain = request.resource_key_chain
        if params[:id]
          set_instance_variables_for_chain(resource_class.find_resource(params).resource_chain)
        elsif params[key_chain.last]
          res_finder = params.merge("id" => params[key_chain.last])
          parent = resource_class(key_chain.last).find_resource(res_finder)

          set_instance_variables_for_chain(parent.resource_chain)
          @resource_chain << instance_variable_set(instance_var_name_for(resource_class, :plural),
                                                   parent.send(resource_class.name.underscore.pluralize))
        elsif key_chain.empty?
          @resource_chain << instance_variable_set(instance_var_name_for(resource_class, :plural),
                                                   resource_class.find(:all))
        end
      end
    end
  end
end

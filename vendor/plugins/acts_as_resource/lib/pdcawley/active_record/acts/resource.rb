module Pdcawley
  module ActiveRecord
    module Acts
      module Resource
        def self.included(base)
          base.extend(ClassMethods)
        end

        # This act provides support for models which will be treated as
        # resources in a RESTful/Resourceful application.
        #
        # Simple resource example
        #
        #   class Resource < ActiveRecord::Base
        #     acts_as_resource
        #   end
        #
        # Slightly more complicated example, when the resource will be nested
        # in a resource chain:
        #
        #   class NestedResource < ActiveRecord::Base
        #     belongs_to :resource
        #     acts_as_resource :parent => :resource
        #   end
        #
        module ClassMethods
          def acts_as_resource(options = { })
            write_inheritable_attribute(:acts_as_resource_options,
                                        { :parent => options[:parent] })

            class_inheritable_reader :acts_as_resource_options

            include Pdcawley::ActiveRecord::Acts::Resource::InstanceMethods
            extend Pdcawley::ActiveRecord::Acts::Resource::SingletonMethods
          end
        end

        module SingletonMethods
          def find_resource(params)
            params = params.stringify_keys
            returning(find(params["id"]))  { |res| res.validate_params(params) }
          end
        end

        module InstanceMethods
          def resource_chain
            @resource_chain ||=
              if acts_as_resource_options[:parent]
                parent = self.send(acts_as_resource_options[:parent])
                parent.blank? ? [] : parent.resource_chain
              else
                []
              end + [self]
          end

          def validate_params(params)
            resource_chain[0..-2].each do |obj|
              obj_key = obj.class.name.demodulize.underscore + "_id"
              unless obj.id == params[obj_key].to_i
                raise ::ActiveRecord::RecordNotFound,
                "Resource #{obj_key} = #{params[obj_key]} does not contain #{self.class}:#{to_param}"
              end
            end
          end
        end

        def resource_chain
          [self]
        end
      end
    end
  end
end

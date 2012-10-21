module Padrino
  module Responders
    module Helpers
      module ControllerHelpers
        ##
        # Shortcut for <code>notifier.say</code> method.
        #
        def notify(kind, message, *args, &block)
          settings.notifier.say(self, kind, message, *args, &block) if settings.notifier
        end

        ##
        # Trys to render and then falls back to to_format
        #
        def try_render(object, detour_name=nil, responder)
          begin             
            if responder.layout 
              render "#{controller_name}/#{detour_name || action_name}", :strict_format => true, :layout => responder.layout  
            else 
              render "#{controller_name}/#{detour_name || action_name}", :strict_format => true
            end 
          rescue Exception => e
            if content_type == :json or mime_type(:json) == request.preferred_type
              return object.to_json if object.respond_to?(:to_json)
            end

            if content_type == :xml or mime_type(:xml) == request.preferred_type
              return object.to_xml if object.respond_to?(:to_xml)
            end

            raise ::Padrino::Responders::ResponderError, e.message
          end
        end

        ##
        # Returns name of current action
        #
        def action_name
          name = self.request.route_obj.instance_variable_get('@named').to_s
          name.gsub!(/^#{controller_name}_?/, '')
          name = 'index' if name == ''
          name
        end

        ##
        # Returns name of current controller
        #
        def controller_name
          self.request.route_obj.instance_variable_get('@controller')
        end

        ##
        # Returns translated, human readable name for specified model.
        #
        def human_model_name(object)
          if object.class.respond_to?(:human)
            object.class.human
          elsif object.class.respond_to?(:human_name)
            object.class.human_name
          else
            t("models.#{object.class.to_s.underscore}", :default => object.class.to_s.humanize)
          end
        end

        ##
        # Returns url
        #
        def back_or_default(default)
          return_to = session.delete(:return_to)
          return_to || default
        end
      end # ControllerHelpers
    end # Helpers
  end # Responders
end # Padrino
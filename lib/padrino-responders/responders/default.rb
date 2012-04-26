module Padrino
  module Responders
    class ResponderError < RuntimeError
    end
    class Default
      include Padrino::Responders::StatusCodes
      attr_accessor :options, :object, :class

      def initialize()
        @options = {}
      end

      def respond()
        if self.class.request.put?
          put()
        elsif self.class.request.post?
          post()
        elsif self.class.request.delete?
          delete()
        else
          default()
        end
      end

      def put_or_post(message_type, error_detour)
        message = message( message_type )
        if valid?
          if request.xhr?
            ajax_obj = {
              :status => :success,
              :data => {
                object.class.to_s.singularize.downcase => object
              }
            }
          end
          if location
            if request.xhr?
              ajax_obj[:data][:redirect] = location
              return ajax_obj.to_json
            else
              notify(:notice, message)
              redirect location
            end
          else
            try_render
          end
        else
          if request.xhr?
            ajax_obj = {
              :status => :fail,
              :data => {
                :errors => object.errors
              }
            }
            ajax_obj[:data][:redirect] = location if location
            return ajax_obj.to_json
          else
            notify(:error, message)
            try_render error_detour
          end
        end
      end


      def put()
        put_or_post :update, 'edit'
      end

      def post()
        put_or_post :create, 'new'
      end

      def delete()
        message = message(:destroy)

        if request.xhr?
          ajax_obj = {
            :status => :success,
            :data => {
              :message => message
            }
          }
        end

        if location
          if request.xhr?
            ajax_obj[:data][:redirect] = location
            return ajax_obj.to_json
          else
            notify(:notice, message)
            redirect location
          end
        else
          try_render
        end
      end

      def default()
        if location
          if request.xhr?
            {:status => :success, :data => { :redirect => location } }.to_json
          else
            redirect location
          end
        else
          try_render
        end
      end

      def message(type)
        return object.errors.full_messages if !valid?
        object_notice      = "responder.messages.#{controller_name}.#{type}"
        alternative_notice = "responder.messages.default.#{type}"
        object_notice = self.class.t(object_notice, :model => human_model_name)
        alternative_notice = self.class.t(alternative_notice, :model => human_model_name)
        return object_notice unless object_notice.blank?
        return alternative_notice unless alternative_notice.blank?
        return 'No message found in locale'
      end

      def valid?()
        valid = true
        # `valid?` method may override existing errors, so check for those first
        valid &&= (object.errors.length == 0) if object.respond_to?(:errors)
        valid &&= object.valid? if object.respond_to?(:valid?)
        return valid
      end

      def request()
        self.class.request
      end

      def notify(kind, message, *args, &block)
        self.class.notify(kind, message, *args, &block)
      end

      def try_render(detour_name=nil)
        self.class.try_render(object, detour_name)
      end

      def redirect(args)
        self.class.redirect(args)
      end

      def human_model_name()
        self.class.human_model_name(object)
      end

      def controller_name()
        self.class.controller_name
      end

      def action_name()
        self.class.action_name
      end

      def location()
        @options[:location]
      end

      def set_status()
        self.class.status = interpret_status(options.status) if options.status
      end
    end
  end
end
module Padrino
  module Responders
    class Default             
      include Padrino::Responders::StatusCodes
      attr_accessor :options, :object
      
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
      
      def put() 
        message = message(:update)
        if valid?   
          if request.xhr?
            ajax_obj = {
              :status => :success, 
              :data => { 
                'object.singularize' => object.to_hash
              } 
            }
          end  
          if location
            if request.xhr?
              ajax_obj[:data][:redirect] = location
              return ajax_obj.to_json 
            else
              self.class.notify(:notice, message)
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
            return ajax_object.to_json
          else     
            if location   
              self.class.notify(:error, message)  
              redirect location 
            else
              try_render
            end
          end
        end
      end
      
      def post()
        message = message(:save) 
        if valid?   
          if request.xhr?
            ajax_obj = {
              :status => :success, 
              :data => { 
                'object.singularize' => object.to_hash
              } 
            }
          end  
          if location
            if request.xhr?
              ajax_obj[:data][:redirect] = location
              return ajax_obj.to_json 
            else
              self.class.notify(:notice, message)
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
            return ajax_object.to_json
          else     
            if location   
              self.class.notify(:error, message)  
              redirect location 
            else
              try_render
            end  
          end
        end   
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
            self.class.notify(:notice, message)
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
      
      def try_render()  
        begin
          render "#{controller_name}/#{action_name}"
        rescue
          case self.class.content_type
          when :json  
            return object.to_json if object.respond_to?(:to_json)
          when :xml      
            return object.to_xml if object.respond_to?(:to_xml)       
          end      
          raise ResponderError, "Couldn't figure out a way to respond to this."
        end
      end  
      
      def valid?()
        valid = false
        valid = object.valid? if object.respond_to?(:valid?)  
        if object.respond_to?(:errors) && if !object.respond_to?(:valid?)
          valid = true if object.errors.length == 0
        end 
        return valid
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
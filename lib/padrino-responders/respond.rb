module Padrino
  module Responders
    ##
    # Default responder is responsible for exposing a resource to different mime 
    # requests, usually depending on the HTTP verb. The responder is triggered when
    # <code>respond</code> is called. The simplest case to study is a GET request:
    #
    #   SampleApp.controllers :examples do 
    #     provides :html, :xml, :json
    #
    #     get :index do 
    #       respond(@examples = Example.find(:all))
    #     end
    #   end
    #
    # When a request comes in, for example for an XML response, three steps happen:
    #
    #   1) the responder searches for a template at extensions/index.xml;
    #   2) if the template is not available, it will invoke <code>#to_xml</code> on the given resource;
    #   3) if the responder does not <code>respond_to :to_xml</code>, call <code>#to_format</code> on it.
    #
    # === Builtin HTTP verb semantics
    #
    # Using this responder, a POST request for creating an object could
    # be written as:
    #
    #   post :create do 
    #     @user = User.new(params[:user])
    #     @user.save
    #     respond(@user, url(:users_show, :id => @user.id))
    #   end
    #
    # Which is exactly the same as:
    #
    #   post :create do 
    #     @user = User.new(params[:user])
    #
    #     if @user.save
    #       flash[:notice] = 'User was successfully created.'
    #       case content_type
    #         when :html then redirect url(:users_show, :id => @user.id)
    #         when :xml  then render :xml => @user, :status => :created, :location => url(:users, :show, :id => @user.id)
    #       end 
    #     else
    #       case content_type
    #         when :html then render 'index/new'
    #         when :xml  then render :xml => @user.errors, :status => :unprocessable_entity 
    #       end
    #     end
    #   end
    #
    # The same happens for PUT and DELETE requests.
    #
    module Respond
      
      def respond(object, *options)  
        if Padrino::Responders.const_defined?("#{controller_name.capitalize}")
          responder = Padrino::Responders.const_get("#{controller_name.capitalize}").new        
        else
          responder = Padrino::Responders::Default.new
        end  
        responder.options = options.extract_options!   
        responder.object  = object  
        responder.class   = self
        return responder.respond    
      end
    end # Default
  end # Responders  
end # Padrino 

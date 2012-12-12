require 'padrino-core'
require 'padrino-gen'

FileSet.glob_require('padrino-responders/*.rb', __FILE__)
FileSet.glob_require('padrino-responders/{helpers,notifiers,responders}/*.rb', __FILE__)

module Padrino
  ##
  # This component is used to create slim controllers without unnecessery
  # and repetitive code.
  #
  module Responders
    ##
    # Method used by Padrino::Application when we register the extension
    #
    class << self
      def registered(app)
        app.enable :sessions
        app.enable :flash
        app.helpers Padrino::Responders::Helpers::ControllerHelpers   
        app.helpers Padrino::Responders::Helpers::ResponseHelpers
        app.set :notifier, Padrino::Responders::Notifiers::FlashNotifier
        app.send :include, Padrino::Responders::Respond
      end
      alias :included :registered
    end
  end
end

##
# Load our Padrino::Responders locales
#
I18n.load_path += Dir["#{File.dirname(__FILE__)}/padrino-responders/locale/**/*.yml"]


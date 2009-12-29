if defined?(Curl::Easy)
  require "fake_web/ext/curb/curb_extensions"

  module Curl
    class Multi

      def perform_with_fakeweb
        requests.each do |easy|
          
          if FakeWeb.registered_uri?(:get, easy.url)
            
            FakeWeb.response_for(:get, easy.url).as_curl_response do |options|
              easy.response_code = options[:response_code] if options[:response_code]
              easy.body_str = options[:body_str] if options[:body_str]
              easy.header_str = options[:header_str] if options[:header_str]
            end
            FakeWeb::CurbExtensions.process(easy)
          elsif FakeWeb.allow_net_connect?
            perform_without_fakeweb
          else
            raise FakeWeb::NetConnectNotAllowedError,
                  "Real HTTP connections are disabled. Unregistered request: GET #{easy.url}"
          end
          remove(easy)
        end
        
        #Always return true
        true
      end
      
      alias_method :perform_without_fakeweb, :perform
      alias_method :perform, :perform_with_fakeweb
    end
    
    class Easy
      attr_accessor :body_str, :header_str, :response_code
    end
  end
end

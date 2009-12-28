if defined?(Curl::Easy)
  require "fake_web/ext/curb/curb_extensions"

  module Curl
    class Multi

      def perform_with_fakeweb
        requests.each do |easy|
          
          if FakeWeb.registered_uri?(:get, easy.url)
            r = FakeWeb.response_for(:get, easy.url).as_curl_response
            FakeWeb::CurbExtensions.process_body(easy, r[:body_str])
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
      attr_accessor :body_str, :header_str
    end
  end
end

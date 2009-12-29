module FakeWeb
  module CurbExtensions
      def self.process(curb)
        body_handler = curb.on_body
        
        unless body_handler.nil?
          #body_str must be nil when a body_handler is present
          body, curb.body_str = curb.body_str, nil
          
          curb.on_body(&body_handler)
          handler_return_value = body_handler.call(body)
        
          if !handler_return_value.is_a?(Integer)
            FakeWeb::Utility.rb_warn "Curl data handlers should return the number of bytes read as an Integer", caller[5]
          elsif handler_return_value != body.length
            # NOTE: Curb docs claim this should be an AbortedByCallbackError, but it raises a WriteError
            raise Curl::Err::WriteError, "Failed writing received data to disk/application"
          end
        end
        
        complete_handler = curb.on_complete

        unless complete_handler.nil?
          complete_handler.call(curb)
        end
      end
  end
end
module FakeWeb
  module CurbExtensions
      def self.process_body(curb, body)
        body_handler = curb.on_body
        
        if body_handler.nil?
          curb.body_str = body
        else
          handler_return_value = body_handler.call(body)
          
          if !handler_return_value.is_a?(Integer)
            FakeWeb::Utility.rb_warn "Curl data handlers should return the number of bytes read as an Integer", caller[5]
          elsif handler_return_value != body.length
            # NOTE: Curb docs claim this should be an AbortedByCallbackError, but it raises a WriteError
            raise Curl::Err::WriteError, "Failed writing received data to disk/application"
          end
        end
      end
  end
end
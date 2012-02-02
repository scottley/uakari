require 'json'

class ApiResponseParser
  
  class << self
  
    def parse(response)
      parse_questionable_json(response.body)
    end
  
    private
  
    def parse_questionable_json(json)
      begin
        parsed = JSON.parse(json)
      rescue JSON::ParserError
        parsed = JSON.parse('['+json+']').first
      end
    end

  end
  
end
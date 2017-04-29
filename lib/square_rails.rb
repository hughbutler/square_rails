require "square_rails/version"
require "square_rails/engine"
require 'unirest'

module SquareRails

    #TODO: error handling

    def self.locations(token)
      @url = "#{SQUARE_CONNECT_HOST}/v1/me/locations"
      @token = token
      self.get_data_from_square
    end

    def self.payments(token,location,args={})
      if location.is_a?(Hash)
        loc_id = location['id']
      else
        loc_id = location
      end

      query = self.hash_to_query_string args

      @url    = "#{SQUARE_CONNECT_HOST}/v1/#{loc_id}/payments?#{query}"
      @token  = token
      self.get_data_from_square
    end

    def self.merchant(token)
      @url = "#{SQUARE_CONNECT_HOST}/v1/me"
      @token = token
      self.get_data_from_square
    end

    def self.get_data_from_square
      headers = {'Authorization' => 'Bearer ' + @token, 'Accept' => 'application/json', "Content-Type"=> "application/json"}
      res = Unirest.get @url, headers: headers
      res.body
    end

    def self.hash_to_query_string args
      if args.is_a?(Hash)
        return args.collect{ |key,val| [key,val].join('=') }.join('&')
      end
    end

end

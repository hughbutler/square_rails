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

    def self.renew_token(token, callback)
      @token = token

      # Provide the code in a request to the Obtain Token endpoint
      oauth_request_body = {
        'client_id' => SQUARE_APP_ID,
        'client_secret' => SQUARE_APP_SECRET,
        'access_token' => @token
      }

      Rails.logger.debug '################### SQUARE_RAILS ### Trying to get reponse'
      Rails.logger.debug "#{SQUARE_CONNECT_HOST}/oauth2/clients/#{@token}/access_token/new"
      Rails.logger.debug oauth_request_body

      response = Unirest.post "#{SQUARE_CONNECT_HOST}/oauth2/clients/#{@token}/access_token/new",
                              headers: SQUARE_OAUTH_REQUEST_HEADERS,
                              parameters: oauth_request_body

      Rails.logger.debug response
      Rails.logger.debug '#####################'
      # Extract the returned access token from the response body
      if response.body.key?('access_token')

          # Here, instead of printing the access token, your application server should store it securely
          # and use it in subsequent requests to the Connect API on behalf of the merchant.
          auth_response =  "Access token received and assigned to session[:square_access_token]. The token is: <br><br>#{response.body['access_token']}"

          @token = response.body['access_token']
          session[:square_access_token] = @token

      # The response from the Obtain Token endpoint did not include an access token. Something went wrong.
      else
        @token = nil
        auth_response = 'Code exchange failed!'
      end

      callback.call(@token, auth_response)

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

# frozen_string_literal: true

require 'net/http'
require 'json'

module Revbits
  module PuppetModule
    # Module responsible for fetching data from 'PAM'.
    module HTTP
      class << self
        def get(appliance_url, variable_id, api_key, public_key_a, public_key_b)
          uri = URI.parse("#{appliance_url}/api/v1/secretman/GetSecretV2/#{variable_id}")
          request = Net::HTTP::Get.new(uri)
          request['Apikey'] = api_key.unwrap
          request['Publickeya'] = public_key_a.to_s
          request['Publickeyb'] = public_key_b.to_s

          req_options = {
            use_ssl: uri.scheme == 'https',
          }

          response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
            http.request(request)
          end

          unless response.code.match?(%r{^2})
            raise Net::HTTPError.new("Server error: #{JSON.parse(response.body).dig('errorMessage')}", response)
          end

          JSON.parse(response.body)
        end
      end
    end
  end
end

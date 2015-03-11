require 'knackhq/client/version'
require 'blanket'
require 'hashie'

module Knackhq
  class Client
    attr_accessor :base_uri, :x_knack_application_id, :x_knack_rest_api_key

    def initialize(base_uri, x_knack_application_id, x_knack_rest_api_key)
      @base_uri = base_uri
      @x_knack_application_id = x_knack_application_id
      @x_knack_rest_api_key = x_knack_rest_api_key
    end

    def objects
      hash_request = request.objects.get.to_h[:objects]
      hash_request.map { |hash| symbolize_hash_keys(hash) }
    end

    def object(key)
      hash_request = request.objects.get(key).to_h
      return [] if hash_request.empty?
      transform_hash_keys = hash_request[:object]['fields']

      transform_hash_keys.map { |hash| symbolize_hash_keys(hash) }
    end

    private

    def request
      headers = { 'x-knack-application-id' => @x_knack_application_id.dup,
                  'Content-Type' => 'application/json',
                  'x-knack-rest-api-key' => @x_knack_rest_api_key.dup }
      Blanket.wrap(@base_uri.dup,
                   :headers => headers)
    end

    def symbolize_hash_keys(hash)
      Hashie.symbolize_keys!(hash)
    end
  end
end

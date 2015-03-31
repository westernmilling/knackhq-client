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
      return [] if hash_request.empty?
      symbolize_hash_keys!(hash_request)
    end

    def object(key)
      hash_request = request.objects.get(key).to_h
      return [] if hash_request.empty?
      transform_hash_keys = hash_request[:object]['fields']
      symbolize_hash_keys!(transform_hash_keys)
    end

    def fields(object)
      hash_request = request_object(object, :fields)
      return [] if hash_request.empty?
      transform_hash_keys = hash_request[:fields]
      symbolize_hash_keys!(transform_hash_keys)
    end

    def records(object)
      hash_request = request_object(object, :records)
      return [] if hash_request.empty?
      transform_hash_keys = hash_request[:records]
      symbolize_hash_keys!(transform_hash_keys)
    end

    def records_by_page(object, page_number)
      hash_request = request.objects(object).records
                     .get(:params => { :page => page_number,
                                       :rows_per_page => 500 }).to_h
      return [] if hash_request.empty?
      transform_hash_keys = hash_request[:records]
      symbolize_hash_keys!(transform_hash_keys)
    end

    def records_info(object)
      hash_request = request.objects(object).records
                     .get(:params => { :rows_per_page => 500 }).to_h
      return [] if hash_request.empty?
      hash_request.delete(:records)
      [hash_request]
    end

    private

    def request
      headers = { 'x-knack-application-id' => @x_knack_application_id.dup,
                  'Content-Type' => 'application/json',
                  'x-knack-rest-api-key' => @x_knack_rest_api_key.dup }
      Blanket.wrap(@base_uri.dup,
                   :headers => headers)
    end

    def request_object(object, function)
      request.objects(object).send(function).get.to_h
    end

    def symbolize_hash_keys!(transform_hash_keys)
      transform_hash_keys.map do |hash|
        Hashie.symbolize_keys!(hash)
      end
    end
  end
end

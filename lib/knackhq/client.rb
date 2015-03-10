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

    def fields(object)
      hash_request = request.objects(object).fields.get.to_h
      return [] if hash_request.empty?
      transform_hash_keys = hash_request[:fields]
      transform_hash_keys.map { |hash| symbolize_hash_keys(hash) }
    end

    def records(object)
      hash_request = request.objects(object).records.get.to_h
      return [] if hash_request.empty?
      transform_hash_keys = hash_request[:records]
      transform_hash_keys.map { |hash| symbolize_hash_keys(hash) }
    end

    def records_by_page(object, page_number)
      hash_request = request.objects(object).records
                     .get(:params => { :page => page_number,
                                       :rows_per_page => 500 }).to_h
      return [] if hash_request.empty?
      transform_hash_keys = hash_request[:records]
      transform_hash_keys.map { |hash| symbolize_hash_keys(hash) }
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

    def symbolize_hash_keys(value)
      Hashie.symbolize_keys!(value)
    end
  end
end

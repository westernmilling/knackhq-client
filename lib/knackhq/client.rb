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
      hash_request = request
                     .objects
                     .get
      payload = payload_hash(hash_request)
      translate_payload(payload) { payload[:objects] }
    end

    def object(key)
      hash_request = request
                     .objects
                     .get(key)
      payload = payload_hash(hash_request)
      translate_payload(payload) { payload[:object][:fields] }
    end

    def fields(object)
      hash_request = request
                     .objects(object)
                     .fields
                     .get
      payload = payload_hash(hash_request)
      translate_payload(payload) { payload[:fields] }
    end

    def records(object, options = {})
      rows_per_page = options[:rows_per_page] || 25
      page_number = options[:page_number] || 1
      hash_request = request
                     .objects(object)
                     .records
                     .get(:params => { :page => page_number,
                                       :rows_per_page => rows_per_page })
      payload = payload_hash(hash_request)
      translate_payload(payload) { payload }
    end

    def record(object, record_knackhq_id)
      hash_request = request
                     .objects(object)
                     .records(record_knackhq_id)
                     .get
      payload = payload_hash(hash_request)
      translate_payload(payload) { payload }
    end

    def update_record(object, knackhq_id, json)
      hash_request = request
                     .objects(object)
                     .records(knackhq_id)
                     .put(:body => json)
      !payload_hash(hash_request).empty?
    end

    private

    def request
      headers = { 'x-knack-application-id' => @x_knack_application_id.dup,
                  'Content-Type' => 'application/json',
                  'x-knack-rest-api-key' => @x_knack_rest_api_key.dup }
      Blanket.wrap(@base_uri.dup,
                   :headers => headers)
    end

    def payload_hash(hash_request)
      payload = hash_request.first.to_h
      Hashie.symbolize_keys!(payload)
    end

    def translate_payload(payload, &block)
      return [] if payload.empty?
      block.call
    end
  end
end

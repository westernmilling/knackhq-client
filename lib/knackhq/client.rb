require 'knackhq/client/version'
require 'blanket'
require 'hashie'
require 'rest_client'

module Knackhq
  # Client is the Knack API Client
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
                     .get(params: { page: page_number,
                                    rows_per_page: rows_per_page })
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
                     .put(body: json)
      !payload_hash(hash_request).empty?
    end

    def create(object, json)
      hash_request = request
                     .objects(object)
                     .records
                     .post(body: json)
      payload = payload_hash(hash_request)
      translate_payload(payload) { payload }
    rescue Blanket::Exception => e
      e.body
    end

    def file_upload(data)
      response =
        RestClient.post(
          "#{@base_uri}/applications/#{@x_knack_application_id}/assets/file/upload",
          data, file_headers
        )
      JSON.parse(response)
    end

    def image_upload(data)
      response =
        RestClient.post(
          "#{@base_uri}/applications/#{@x_knack_application_id}/assets/image/upload",
          data, file_headers
        )
      JSON.parse(response)
    end

    private

    def request
      headers = { 'x-knack-application-id' => @x_knack_application_id.dup,
                  'Content-Type' => 'application/json',
                  'x-knack-rest-api-key' => @x_knack_rest_api_key.dup }
      Blanket.wrap(@base_uri.dup,
                   headers: headers)
    end

    def file_headers
      {
        'Content-Type' => 'multipart/form-data',
        'x-knack-rest-api-key' => @x_knack_rest_api_key.dup
      }
    end

    def payload_hash(hash_request)
      Hashie.symbolize_keys!(hash_request.to_h)
    end

    def translate_payload(payload)
      return [] if payload.empty?
      yield
    end
  end
end

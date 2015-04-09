require 'spec_helper'

describe Knackhq::Client do
  let(:client) { knack_client }
  let(:base_uri) { 'https://api.knackhq.com/v1' }
  let(:x_knack_application_id) { '123456789' }
  let(:x_knack_rest_api_key) { '123-456-789' }

  let(:knack_client) do
    Knackhq::Client.new(base_uri,
                        x_knack_application_id,
                        x_knack_rest_api_key)
  end

  describe '#new' do
    it { expect(knack_client).to be_a Knackhq::Client }
  end

  describe '#request' do
    let(:cassette) { 'request' }
    subject(:knack_client_request) { client.send(:request) }
    it { is_expected.to be_a Blanket::Wrapper }
    it { is_expected.to respond_to (:get) }
    it { is_expected.to respond_to (:post) }
    it { is_expected.to respond_to (:put) }

    context 'when Knack receives wrong application id' do
      let(:x_knack_application_id) { '000000000' }
      let(:cassette) { 'wrong_application_id' }
      subject(:request_get) do
        VCR.use_cassette(cassette) do
          knack_client_request.objects.get
        end
      end

      it 'fails with /500 Internal Server Error/' do
        expect { request_get }
          .to raise_error.with_message(/500 Internal Server Error/)
      end
    end

    context 'when Knack receives wrong api key' do
      let(:x_knack_rest_api_key) { '999999' }
      let(:cassette) { 'wrong_api_key' }
      subject(:request_get) do
        VCR.use_cassette(cassette) do
          knack_client_request.objects.get
        end
      end

      it 'fails with /401 Unauthorized/' do
        expect { request_get }
          .to raise_error.with_message(/401 Unauthorized/)
      end
    end
  end

  describe '#objects' do
    subject do
      VCR.use_cassette('all_objects') do
        client.objects
      end
    end

    it { is_expected.not_to be_empty }
    it { is_expected.to be_a Array }
    its('first.keys') { is_expected.to eq [:name, :key] }
  end

  describe '#object' do
    let(:cassette) { 'object' }
    subject do
      VCR.use_cassette(cassette) do
        client.object(key)
      end
    end

    context 'when object exists' do
      let(:key) { 'object_1' }
      it { is_expected.to be_an Array }
    end

    context 'when object does not exist' do
      let(:cassette) { 'invalid_object' }
      let(:key) { 'invalid_object' }

      it { is_expected.to eq [] }
    end
  end

  describe '#fields' do
    let(:cassette) { 'fields_object_1' }
    subject do
      VCR.use_cassette(cassette) do
        client.fields(object)
      end
    end

    context 'when object fields exists' do
      let(:object) { 'object_1' }
      it { is_expected.to be_an Array }
      its('first.keys') do
        is_expected.to eq [:label,
                           :key,
                           :type,
                           :required,
                           :field_type]
      end
    end

    context 'when object fields do not exist' do
      let(:cassette) { 'invalid_fields_object' }
      let(:object) { 'invalid_object' }

      it { is_expected.to eq [] }
    end
  end
  describe '#records' do
    let(:cassette) { 'records_object_4' }
    subject do
      VCR.use_cassette(cassette) do
        client.records(object)
      end
    end

    context 'when object records exist' do
      let(:object) { 'object_4' }
      it { is_expected.to be_an Array }
      its('first.keys') do
        is_expected.to eq [:id,
                           :account_status,
                           :approval_status,
                           :profile_keys,
                           :profile_keys_raw,
                           :field_32,
                           :field_32_raw,
                           :field_33,
                           :field_33_raw,
                           :field_34,
                           :field_34_raw,
                           :field_188,
                           :field_188_raw]
      end
    end
    # TODO: Knackhq Needs to fix the malformed json before this test will pass.
    # context 'when object records do not exist' do
    #   let(:cassette) { 'invalid_record_object' }
    #   let(:object) { 'invalid_object' }
    #
    #   it { is_expected.to eq [] }
    # end
  end

  describe '#records_by_page' do
    subject(:records_by_page_1) do
      VCR.use_cassette('records_by_page1_object_4') do
        client.records_by_page(object, 1)
      end
    end
    let(:records_by_page_2) do
      VCR.use_cassette('records_by_page2_object_4') do
        client.records_by_page(object, 2)
      end
    end

    context 'when object has two pages' do
      let(:object) { 'object_4' }
      it { is_expected.to be_an Array }
      its('first.keys') do
        is_expected.to eq records_by_page_2.first.keys
      end
      its (:size) { is_expected.not_to eq records_by_page_2.size }
    end

    context 'when page is out of scope' do
      let(:object) { 'object_4' }
      subject(:records_by_page_1) do
        VCR.use_cassette('invalid_records_by_page1_object_4') do
          client.records_by_page(object, 999)
        end
      end

      it { is_expected.to eq [] }
    end
  end

  describe '#records_info' do
    let(:object) { 'object_4' }
    let(:cassette) { 'records_info_object_4' }
    subject do
      VCR.use_cassette(cassette) do
        client.records_info(object)
      end
    end

    context 'when object records exist' do
      let(:object) { 'object_4' }
      it { is_expected.to be_an Array }
      its('first.keys') do
        is_expected.to eq [:total_pages,
                           :current_page,
                           :total_records]
      end
    end
    # TODO: Knackhq Needs to fix the malformed json before this test will pass.
    # context 'when object records do not exist' do
    #   let(:cassette) { 'invalid_record_object' }
    #   let(:object) { 'invalid_object' }
    #
    #   it { is_expected.to eq [] }
    # end
  end

  describe '#update_record' do
    let(:object) { 'object_4' }
    let(:knackhq_id) { '99999' }
    let(:cassette) { 'update_records_object_4' }
    let(:change) { { :account_status => 'active' } }
    let(:json) { change.to_json }
    subject do
      VCR.use_cassette(cassette) do
        client.update_record(object, knackhq_id, json)
      end
    end

    context 'when object records exist' do
      let(:object) { 'object_4' }
      it { is_expected.to eq true }
    end

    context 'when object records do not exist' do
      let(:object) { 'object_4' }
      let(:cassette) { 'update_records_object_4_empty' }
      it { is_expected.to eq false }
    end

    context 'when object does not exist' do
      let(:cassette) { 'invalid_record_update' }
      let(:object) { 'invalid_object' }

      it 'fails with /500 Internal Server Error/' do
        expect { subject }
          .to raise_error.with_message(/500 Internal Server Error/)
      end
    end
  end
end

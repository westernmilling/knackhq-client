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

  describe '#request.get' do
    let(:cassette) { 'request' }
    subject(:knack_client_request) do
      VCR.use_cassette(cassette) do
        request = client.send(:request)
        request.objects.get
      end
    end

    context 'when Knack receives wrong application id' do
      let(:x_knack_application_id) { '000000000' }
      let(:cassette) { 'wrong_application_id' }

      it 'fails with /500 Internal Server Error/' do
        expect { knack_client_request }
          .to raise_error.with_message(/500 Internal Server Error/)
      end
    end

    context 'when Knack receives wrong api key' do
      let(:x_knack_rest_api_key) { '999999' }
      let(:cassette) { 'wrong_api_key' }

      it 'fails with 401 Unauthorized' do
        expect { knack_client_request }
          .to raise_error.with_message(/401 Unauthorized/)
      end
    end

    it { is_expected.to be_a Blanket::Response }
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
end

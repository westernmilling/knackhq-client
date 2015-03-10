require 'spec_helper'

describe Knackhq::Client do
  let(:client) { knack_client }
  let(:base_uri) { 'http://example.com' }
  let(:x_knack_application_id) { '00000000' }
  let(:x_knack_rest_api_key) { '99999999' }

  let(:knack_client) do
    Knackhq::Client.new(base_uri,
                        x_knack_application_id,
                        x_knack_rest_api_key)
  end

  describe '#new' do
    it { expect(knack_client).to be_a Knackhq::Client }
  end

  describe '#request.get' do
    subject(:knack_client_request) do
      VCR.use_cassette('request') do
        client.request.get
      end
    end
    context 'when Knack recieves wrong application id' do
      subject(:knack_client_request) do
        VCR.use_cassette('wrong_application_id') do
          client.request.get
        end
      end
      it 'fails with /500 Internal Server Error/' do
        expect { knack_client_request }
          .to raise_error.with_message(/500 Internal Server Error/)
      end
    end
    context 'when Knack recieves wrong api key' do
      subject(:knack_client_request) do
        VCR.use_cassette('wrong_api_key') do
          client.request.get
        end
      end
      it 'fails with 401 Unauthorized' do
        expect { knack_client_request }
          .to raise_error.with_message(/401 Unauthorized/)
      end
    end

    it { is_expected.to be_a Blanket::Response }
  end

  describe '#objects' do
    subject do
      VCR.use_cassette('request') do
        client.objects
      end
    end
    it { is_expected.not_to be_empty }
    it { is_expected.to be_a Array }
    its('first.keys') { is_expected.to eq [:name, :key] }
  end
end

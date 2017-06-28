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
    it { is_expected.to respond_to :get }
    it { is_expected.to respond_to :post }
    it { is_expected.to respond_to :put }

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

    context 'when object fields exist' do
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
    let(:object) { 'object_4' }
    let(:cassette) { 'records_object_4' }
    subject do
      VCR.use_cassette(cassette) do
        client.records(object, options)
      end
    end
    let(:options) { { no_options: nil } }

    context 'when records do not have options' do
      let(:first_records_keys) { subject[:records].first.keys }
      its(:keys) do
        is_expected.to eq [:total_pages,
                           :current_page,
                           :total_records,
                           :records]
      end
      its([:total_pages]) { is_expected.to be 2 }
      its([:current_page]) { is_expected.to be 1 }
      its([:total_records]) { is_expected.to be 28 }
      it do
        expect(first_records_keys).to include :id,
                                              :field_32,
                                              :field_33,
                                              :field_34,
                                              :field_188
      end
    end

    context 'when records have options' do
      let(:cassette) { 'records_object_options_4' }
      let(:options) { { rows_per_page: 10, page_number: 2 } }

      its([:total_pages]) { is_expected.to be 3 }
      its([:current_page]) { is_expected.to eq '2' }
      its([:total_records]) { is_expected.to be 28 }
    end

    context 'when object records do not exist' do
      let(:object) { 'object_9' }
      it { is_expected.to eq [] }
    end

    context 'when object does not exist' do
      let(:object) { 'object_99' }

      it 'fails with /500 Internal Server Error/' do
        expect { subject }
          .to raise_error.with_message(/500 Internal Server Error/)
      end
    end
  end

  describe '#record' do
    let(:object) { 'object_4' }
    let(:record_knackhq_id) { '999999' }
    let(:cassette) { 'record_object_4' }
    subject do
      VCR.use_cassette(cassette) do
        client.record(object, record_knackhq_id)
      end
    end

    context 'when record exists' do
      its(:keys) do
        is_expected.to include :id,
                               :account_status,
                               :approval_status,
                               :profile_keys
      end
    end

    context 'when record does not exist' do
      let(:cassette) { 'invalid_record_knackhq_id' }
      let(:record_knackhq_id) { '99999' }
      it 'fails with /500 Internal Server Error/' do
        expect { subject }
          .to raise_error.with_message(/500 Internal Server Error/)
      end
    end
  end

  describe '#update_record' do
    let(:object) { 'object_2' }
    let(:knackhq_id) { '999999999' }
    let(:cassette) { 'update_records_object_2' }
    subject do
      VCR.use_cassette(cassette) do
        client.update_record(object, knackhq_id,
                             { field_21: '1116' }.to_json)
      end
    end

    context 'when object records exist' do
      it { is_expected.to be true }
    end

    context 'when object records do not exist' do
      let(:knackhq_id) { '77777777' }
      it { is_expected.to be false }
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

  describe '#create' do
    let(:object) { 'object_3' }
    let(:cassette) { 'create_valid_record' }
    let(:params) { { field_21: '1115' } }
    subject do
      VCR.use_cassette(cassette) do
        client.create(object, params.to_json)
      end
    end

    context 'when object record is created' do
      it { is_expected.to be true }
    end

    context 'when object record is not created' do
      let(:cassette) { 'record_not_created' }
      let(:object) { 'invalid_object' }

      it 'fails with /500 Internal Server Error/' do
        expect { subject }
          .to raise_error.with_message(/500 Internal Server Error/)
      end
    end
  end

  describe '#file_upload' do
    let(:cassette) { 'file_upload' }
    let(:file) { File.new(File.join('spec', 'fixtures', 'files', 'test_document.pdf')) }
    let(:params) { { files: file } }

    subject(:response) do
      VCR.use_cassette(cassette) do
        client.file_upload(params)
      end
    end
    context 'when file is uploaded' do
      it { expect(response['id']).to eq('595384046fa0b656cec2e5d3') }
      it { expect(response['type']).to eq('file') }
      it { expect(response['filename']).to eq('test_document.pdf') }
      it { expect(response['size']).to eq(8200) }
    end
  end

  describe '#image_upload' do
    let(:cassette) { 'image_upload' }
    let(:file) { File.new(File.join('spec', 'fixtures', 'files', 'test_image.png')) }
    let(:params) { { files: file } }

    subject(:response) do
      VCR.use_cassette(cassette) do
        client.image_upload(params)
      end
    end
    context 'when image is uploaded' do
      it { expect(response['id']).to eq('595385902a4223570f432a25') }
      it { expect(response['type']).to eq('image') }
      it { expect(response['filename']).to eq('test_image.png') }
      it { expect(response['size']).to eq(104107) }
    end
  end
end

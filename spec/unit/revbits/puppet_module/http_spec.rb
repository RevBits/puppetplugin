# frozen_string_literal: true

require 'spec_helper'
require 'json'
require 'revbits/puppet_module/http'

# Unit testing 'HTTP' Module
describe Revbits::PuppetModule::HTTP do
  let(:host) { 'some_url.com' }
  let(:port) { 443 }
  let(:appliance_url) { "https://#{host}/" }
  let(:api_key) { 'SoMeRanDomApIKey' }
  let(:variable_id) { 'TEST_KEY' }
  let(:public_key_a) { '8' }
  let(:public_key_b) { '4' }
  let(:response_json) { { value: 'SomeVeRySecRetValue', keyA: '5', keyB: '9' } }

  let(:mock_response) { double('my_response_data') }
  let(:mock_connection) { double('connection') }
  let(:sensitive_api_key) { double('sensitive_api_key') }

  before(:each) do
    allow(Net::HTTP).to receive(:start).with(host, port, use_ssl: true)
                                       .and_yield(mock_connection)

    allow(mock_connection).to receive(:request).with(Net::HTTP::Get)
                                               .and_return(mock_response)

    allow(sensitive_api_key).to receive(:unwrap).and_return(api_key)
  end

  describe 'get()' do
    it 'can successfully get data' do
      allow(mock_response).to receive(:code).and_return(Integer)

      allow(Integer).to receive(:match?).with(Regexp).and_return(true)

      allow(mock_response).to receive(:body).and_return(response_json.to_json)

      response = subject.get(appliance_url,
                             variable_id,
                             sensitive_api_key,
                             public_key_a,
                             public_key_b)

      expect(response).to be_a(Hash)

      response.each do |key, value|
        expect(value).to eq(response_json.dig(key.to_sym))
      end
    end

    it 'raises Net::HTTPError when response code is not 200' do
      allow(mock_response).to receive(:code).and_return(Integer)

      allow(Integer).to receive(:match?).with(Regexp).and_return(false)

      allow(mock_response).to receive(:body).and_return(response_json.to_json)

      expect {
        subject.get(appliance_url, variable_id, sensitive_api_key, public_key_a, public_key_b)
      }.to raise_error(Net::HTTPError)
    end
  end
end

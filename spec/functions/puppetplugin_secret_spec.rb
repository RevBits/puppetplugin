# frozen_string_literal: true

require 'spec_helper'
require 'revbits/puppet_module/http'
require 'revbits/puppet_module/secure'

describe 'puppetplugin::secret', puppetplugin: :mock do
  ['RedHat', 'Ubuntu', 'Debian', 'Centos', 'Windows', 'Alpine'].each do |os_family|
    context "with #{os_family} platform" do
      let(:facts) do
        { os: { family: os_family } }
      end

      let(:appliance_url) { 'https://someurl.com' }
      let(:api_key) { Puppet::Pops::Types::PSensitiveType::Sensitive.new('SomESecUreAPiKeY') }
      let(:variable_id) { 'TEST_KEY' }
      let(:secret_creators) { { prime: 23, generated: 9 } }
      let(:private_key_a) { 4 }
      let(:private_key_b) { 9 }
      let(:public_key_a) { 6 }
      let(:public_key_b) { 2 }
      let(:pam_response) { { 'value' => 'U2FsdGVkX18c30ZCbaTmkXSK3znBWg5QQHIRetughpQ=', 'keyA' => 9, 'keyB' => 16 } }
      let(:secret_value) { 'SomeVeRySecRetValue' }

      describe 'expected behaviour of function' do
        before(:each) do
          allow(Revbits::PuppetModule::Secure).to receive(:private_keys)
            .and_return([private_key_a, private_key_b])

          allow(Revbits::PuppetModule::Secure).to receive(:public_keys)
            .with(private_key_a, private_key_b, secret_creators)
            .and_return([public_key_a, public_key_b])

          allow(Revbits::PuppetModule::Secure).to receive(:secret)
            .with(pam_response, private_key_a, private_key_b, secret_creators)
            .and_return('16')

          encrypted_value = AES256.encrypt(secret_value, '16')

          pam_response['value'] = encrypted_value

          allow(Revbits::PuppetModule::Secure).to receive(:decrypt)
            .with('16', encrypted_value)
            .and_return(secret_value)
        end

        it 'fetches correct variable value from PAM' do
          expect(Revbits::PuppetModule::HTTP).to receive(:get)
            .with(appliance_url,
                  variable_id,
                  api_key,
                  public_key_a,
                  public_key_b)
            .and_return(pam_response)

          sensitive_value = subject.execute(variable_id, 'appliance_url' => appliance_url, 'api_key' => api_key)
          expect(sensitive_value.unwrap).to eq(secret_value)
        end
      end
    end
  end
end

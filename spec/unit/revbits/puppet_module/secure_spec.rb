# frozen_string_literal: true

require 'spec_helper'
require 'json'
require 'revbits/puppet_module/secure'
require 'aes-everywhere'

# Unit testing 'Secure' module
describe Revbits::PuppetModule::Secure do
  let(:secret_creators) { { prime: 23, generated: 9 } }
  let(:private_key_a) { 4 }
  let(:private_key_b) { 9 }
  let(:public_key_a) { 6 }
  let(:public_key_b) { 2 }
  let(:encrypted_values) { { value: 'SomeVeRySecRetValue', keyA: 5, keyB: 9 } }

  describe 'private_keys()' do
    it 'returns random private keys' do
      private_keys = subject.private_keys

      expect(private_keys).to be_an(Array)
      expect(private_keys.first).to be_an(Integer)
      expect(private_keys.last).to be_an(Integer)
      expect(private_keys.first).to be_between(2, 9)
      expect(private_keys.last).to be_between(2, 9)
    end
  end

  describe 'public_keys()' do
    it 'returns public keys based on private keys' do
      public_keys = subject.public_keys(private_key_a, private_key_b, secret_creators)

      expect(public_keys).to be_an(Array)
      expect(public_keys.first).to be_an(Integer)
      expect(public_keys.last).to be_an(Integer)
      expect(public_keys.first).to eq(public_key_a)
      expect(public_keys.last).to eq(public_key_b)
    end
  end

  describe 'secret()' do
    it 'returns a secret to decrypt the required variable' do
      secret = subject.secret(encrypted_values.transform_keys!(&:to_s), private_key_a, private_key_b, secret_creators)

      expect(secret).to be_an(Integer)
      expect(secret).to eq(16)
    end
  end

  describe 'decrypt()' do
    it 'decrypts the encrypted secret variable value' do
      encrypted_value = AES256.encrypt(encrypted_values.dig(:value), '16')

      decrypted_value = subject.decrypt('16', encrypted_value)

      expect(decrypted_value).to eq(encrypted_values.dig(:value))
    end
  end
end

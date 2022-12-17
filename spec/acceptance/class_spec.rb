# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'vaultbot class:' do
  it_behaves_like 'an idempotent resource' do
    let(:manifest) do
      <<-PUPPET
      vaultbot::bundle { 'test':
        vault_addr => 'http://127.0.0.1:8200',
        vault_auth_method => 'token',
        vault_token => 'xxxxx',
        pki_mount => 'pki',
        pki_role_name => 'example',
        pki_common_name => 'test.example.com',
        pki_cert_path => '/run/test_cert.pem',
        pki_privkey_path => '/run/test_pkey.pem',
      }
      PUPPET
    end
  end

  version = '1.13.0'
  extract_binary = "/opt/vaultbot/v#{version}/vaultbot"

  describe file(extract_binary) do
    it { is_expected.to be_file }
  end

  describe file('/usr/local/bin/vaultbot') do
    it { is_expected.to be_linked_to extract_binary }
  end

  describe file('/etc/vaultbot/vaultbot.conf') do
    it { is_expected.to be_file }
  end

  describe file('/etc/vaultbot/vaultbot-test.conf') do
    it { is_expected.to be_file }
  end

  describe service('vaultbot@test.timer') do
    it { is_expected.to be_enabled }
    it { is_expected.to be_running }
  end
end

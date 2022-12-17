require 'spec_helper'

describe 'vaultbot::bundle' do
  let(:title) { 'test_service' }
  let(:basic_params) do
    {
      vault_addr: 'https://vault.example.com',
      vault_auth_method: 'token',
      vault_token: 'test-vault-token',
      pki_mount: 'test-pki',
      pki_role_name: 'test-pki-role',
      pki_common_name: 'test-pki-cn.example.com',
      pki_cert_path: '/etc/ssl/test-cert.pem',
      pki_privkey_path: '/etc/ssl/test-pkey.pem',
    }
  end
  let(:custom_params) do
    {
      logfile: '/var/log/vaultbot.log',
      renew_hook: '/usr/local/bin/renew_hook',
      auto_confirm: true,
      vault_addr: 'https://vault.example.com',
      vault_cacert: '/etc/ssl/example.com.pem',
      vault_capath: '/etc/ssl/example.com.dir',
      vault_client_cert: '/etc/ssl/vaultbot_cert.pem',
      vault_client_key: '/etc/ssl/vaultbot_pkey.pem',
      vault_client_timeout: 123,
      vault_skip_verify: true,
      vault_tls_server_name: 'vault.example.com',
      vault_max_retries: 234,
      vault_token: 'test-vault-token',
      vault_renew_token: true,
      vault_auth_method: 'token',
      vault_certificate_role: 'vaultbot_cert_role',
      vault_aws_auth_role: 'vaultbot_aws_role',
      vault_aws_auth_mount: 'vaultbot_aws_mount',
      vault_aws_auth_header: 'vaultbot_aws_header',
      vault_aws_auth_nonce: 'vaultbot_aws_nonce',
      vault_aws_auth_nonce_path: 'vaultbot_aws_nonce_path',
      vault_app_role_mount: 'vaultbot_approle_mount',
      vault_app_role_role_id: 'vault-app-role-id',
      vault_app_role_secret_id: 'vault-app-secret-id',
      pki_mount: 'test-pki',
      pki_role_name: 'test-pki-role',
      pki_common_name: 'test-pki-cn.example.com',
      pki_alt_names: ['test-a.example.com', 'test-b.example.com'],
      pki_ip_sans: ['1.2.3.4', '2.3.4.5'],
      pki_ttl: '720h',
      pki_exclude_cn_from_sans: true,
      pki_private_key_format: 'der',
      pki_renew_percent: 0.85,
      pki_renew_time: '72h',
      pki_force_renew: false,
      pki_cert_path: '/etc/ssl/test-cert.pem',
      pki_cachain_path: '/etc/ssl/test-chain.pem',
      pki_privkey_path: '/etc/ssl/test-pkey.pem',
      pki_pembundle_path: '/etc/ssl/test-bundle.pem',
      pki_jks_path: '/etc/ssl/test-keychain.jks',
      pki_jks_password: sensitive('kenneth123'),
      pki_jks_cert_alias: 'test-cert',
      pki_jks_cachain_alias: 'test-chain',
      pki_jks_privkey_alias: 'test-pkey',
      pki_pkcs12_path: '/etc/ssl/test-keychain.pkcs12',
      pki_pkcs12_umask: '0640',
      pki_pkcs12_password: sensitive('kenneth1234'),
    }
  end

  ### Test sanity checks just for Ubuntu 20.04
  test_on = {
    supported_os: [
      {
        'operatingsystem' => 'Ubuntu',
        'operatingsystemrelease' => ['20.04'],
      },
    ],
  }
  on_supported_os(test_on).each do |_, os_facts|
    let(:facts) { os_facts }

    # Ensure an error is raised when required field is missing
    [
      [ { vault_addr: :undef } ],
      [ { pki_mount: :undef } ],
      [ { pki_role_name: :undef } ],
      [ { pki_common_name: :undef } ],
      [ { vault_app_role_role_id: :undef, vault_auth_method: 'approle' } ],
      [ { vault_app_role_secret_id: :undef, vault_auth_method: 'approle' } ],
      [ { vault_aws_auth_role: :undef, vault_auth_method: 'aws-iam' } ],
      [ { vault_aws_auth_role: :undef, vault_auth_method: 'aws-ec2' } ],
      [ { vault_gcp_auth_role: :undef, vault_auth_method: 'gcp-iam' } ],
      [ { vault_gcp_auth_role: :undef, vault_auth_method: 'gcp-gce' } ],
      [ { vault_client_cert: :undef, vault_auth_method: 'cert' } ],
      [ { vault_client_key: :undef, vault_auth_method: 'cert' } ],
      [ { vault_token: :undef, vault_auth_method: 'token' } ],
      [
        {
          pki_cert_path: :undef,
          pki_privkey_path: :undef,
          pki_pembundle_path: :undef,
          pki_jks_path: :undef,
          pki_pkcs12_path: :undef,
        },
        %r{\$pki_cert_path.* required},
      ],
    ].each do |x|
      context "with #{x[0]}" do
        field = x[0].keys[0]
        let(:params) { basic_params.merge(x[0]) }

        it { is_expected.to compile.and_raise_error(x[1] ? x[1] : %r{\$#{field} .* required}) }
      end
    end

    # Ensure no error is raised when required fields are specified as the vaultbot class parameters
    context 'with class params but without resource params' do
      let(:pre_condition) do
        <<-PUPPET
        class { vaultbot:
          vault_addr => 'https://vault.example.com',
          vault_auth_method => 'token',
          vault_token => 'test-vault-token',
          pki_mount => 'test-pki',
          pki_role_name => 'test-pki-role',
        }
        PUPPET
      end
      let(:params) do
        {
          pki_common_name: 'test-pki-cn.example.com',
          pki_cert_path: '/etc/ssl/test-cert.pem',
          pki_privkey_path: '/etc/ssl/test-pkey.pem',
        }
      end

      it { is_expected.to compile }
    end
  end

  # Test resources
  test_on = {
    'hardwaremodels' => ['x86_64', 'aarch64'],
  }
  on_supported_os(test_on).each do |os, os_facts|
    let(:facts) { os_facts }
    context "on #{os} with basic params" do
      let(:params) { basic_params }

      it 'creates config' do
        bundle_cfg = params.keys.sort.reduce([]) { |memo, k| memo + [ "#{k.upcase}='#{params[k]}'" ] }.join("\n") + "\n"
        is_expected.to contain_file('/etc/vaultbot/vaultbot-test_service.conf')
          .with_ensure('present')
          .with_owner('root')
          .with_group('root')
          .with_mode('0644')
          .with_content(bundle_cfg)
      end
      it 'creates timer' do
        is_expected.to contain_service('vaultbot@test_service.timer')
          .with_ensure('running')
          .with_enable(true)
      end
    end

    context "on #{os} with custom params" do
      let(:params) { custom_params }

      it 'creates config' do
        res = params.merge(
          pki_alt_names: params[:pki_alt_names].join(','),
          pki_ip_sans: params[:pki_ip_sans].join(','),
          pki_jks_password: 'kenneth123',
          pki_pkcs12_password: 'kenneth1234',
        )
        bundle_cfg = res.keys.sort.reduce([]) do |memo, k|
          memo + [ "#{k.upcase}='#{res[k]}'" ]
        end

        is_expected.to contain_file('/etc/vaultbot/vaultbot-test_service.conf')
          .with_ensure('present')
          .with_owner('root')
          .with_group('root')
          .with_mode('0644')
          .with_content(bundle_cfg.join("\n") + "\n")
      end
      it 'creates timer' do
        is_expected.to contain_service('vaultbot@test_service.timer')
          .with_ensure('running')
          .with_enable(true)
      end
    end

    context "on #{os} with ensure=>absent" do
      let(:params) { { ensure: 'absent' } }

      it { is_expected.to contain_file('/etc/vaultbot/vaultbot-test_service.conf').with_ensure('absent') }
      it { is_expected.to contain_service('vaultbot@test_service.timer').with_ensure('stopped').with_enable(false) }
    end
  end
end

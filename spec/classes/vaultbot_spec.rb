require 'spec_helper'

describe 'vaultbot' do
  test_on = {
    'hardwaremodels' => ['x86_64', 'aarch64'],
  }
  on_supported_os(test_on).each do |os, os_facts|
    arch = {
      'amd64' => 'amd64',
      'x86_64' => 'amd64',
      'aarch64' => 'arm64',
    }[os_facts[:os]['architecture']]

    context "on #{os}" do
      let(:facts) { os_facts }

      # Defaults
      context 'with defaults' do
        version = '1.13.0'
        archives_top_dir = '/opt/vaultbot'
        extract_dir = "#{archives_top_dir}/v#{version}"
        extract_binary = "#{extract_dir}/vaultbot"
        config_dir = '/etc/vaultbot'
        config_file = "#{config_dir}/vaultbot.conf"

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('vaultbot') }
        it { is_expected.to contain_class('vaultbot::install').that_comes_before('Class[vaultbot::config]') }
        it { is_expected.to contain_class('vaultbot::config').that_notifies('Class[vaultbot::service]') }
        it { is_expected.to contain_class('vaultbot::service') }

        ## Install
        [archives_top_dir, extract_dir].each do |d|
          it { is_expected.to contain_file(d).with_ensure('directory').with_owner('root').with_group('root').with_mode('0755') }
        end
        it do
          is_expected.to contain_archive("#{extract_dir}.tar.gz")
            .with_ensure('present')
            .with_source("https://gitlab.com/msvechla/vaultbot/-/releases/v#{version}/downloads/vaultbot_#{version}_linux_#{arch}.tar.gz")
            .with_proxy_server(nil)
            .with_checksum_verify(true)
            .with_checksum_url("https://gitlab.com/msvechla/vaultbot/-/releases/v#{version}/downloads/vaultbot_#{version}_checksums.txt")
            .with_extract(true)
            .with_extract_path(extract_dir)
            .with_creates(extract_binary)
            .that_requires("File[#{extract_dir}]")
        end
        it do
          is_expected.to contain_file(extract_binary)
            .with_owner('root')
            .with_group('root')
            .with_mode('0755')
            .that_requires("Archive[#{extract_dir}.tar.gz]")
        end
        it do
          is_expected.to contain_file('/usr/local/bin/vaultbot')
            .with_ensure('link')
            .with_target(extract_binary)
            .that_requires("File[#{extract_binary}]")
        end

        ## Config
        it { is_expected.to contain_file(config_dir).with_ensure('directory').with_owner('root').with_group('root').with_mode('0755') }
        it do
          is_expected.to contain_file(config_file)
            .with_ensure('present')
            .with_owner('root')
            .with_group('root')
            .with_mode('0644')
            .with_content("\n")
        end

        ## Service
        it do
          is_expected.to contain_file('/etc/systemd/system/vaultbot@.service')
            .with_ensure('present')
            .with_owner('root')
            .with_group('root')
            .with_mode('0644')
            .with_content(%r{^EnvironmentFile=-/etc/vaultbot/vaultbot.conf$})
            .with_content(%r{^EnvironmentFile=-/etc/vaultbot/vaultbot-%i.conf$})
            .with_content(%r{^SyslogIdentifier=vaultbot-%i$})
            .with_content(%r{^ExecStart=/usr/local/bin/vaultbot$})
        end
        it do
          is_expected.to contain_file('/etc/systemd/system/vaultbot@.timer')
            .with_ensure('present')
            .with_owner('root')
            .with_group('root')
            .with_mode('0644')
            .with_content(%r{^OnCalendar=daily$})
            .with_content(%r{^OnBootSec=15min$})
            .with_content(%r{^RandomizedDelaySec=15min$})
        end
      end

      # Custom params
      context 'with custom params' do
        let(:facts) { os_facts }
        let(:config_params) do
          {
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
            pki_ttl: '720h',
            pki_exclude_cn_from_sans: true,
            pki_private_key_format: 'der',
            pki_renew_percent: 0.85,
            pki_renew_time: '72h',
            pki_force_renew: false,
          }
        end
        let(:params) do
          {
            version: '1.23.4',
            ensure: 'present',
            download_url: 'https://example.com/vaultbot/v<%= $version %><%= $download_extension %>',
            download_extension: '.zip',
            checksum_verify: false,
            checksum_url: 'https://example.com/vaultbot/v<%= $version %>/checksums.txt',
            binary_name: 'vaultbot-1.23',
            bin_dir: '/usr/local/bin',
            archives_top_dir: '/usr/local/share/vaultbot',
            etc_dir: '/usr/local/etc/vaultbot',
            proxy_url: 'http://proxy.example.com:8766',
            service_manage: true,
            on_calendar: '*-*-* 03:04:05',
            on_boot_sec: '',
            randomized_delay_sec: '',
            exec_start: '/usr/local/bin/vaultbot-1.23 -v',
            syslog_identifier: 'vaultbot-1.23-%i',
          }.merge(config_params)
        end

        version = '1.23.4'
        archives_top_dir = '/usr/local/share/vaultbot'
        extract_dir = "#{archives_top_dir}/v#{version}"
        extract_binary = "#{extract_dir}/vaultbot-1.23"
        config_dir = '/usr/local/etc/vaultbot'
        config_file = "#{config_dir}/vaultbot.conf"
        download_url = "https://example.com/vaultbot/v#{version}.zip"
        checksum_url = "https://example.com/vaultbot/v#{version}/checksums.txt"

        ## Install
        [archives_top_dir, extract_dir].each do |d|
          it { is_expected.to contain_file(d).with_ensure('directory') }
        end
        it do
          is_expected.to contain_archive("#{extract_dir}#{params[:download_extension]}")
            .with_ensure('present')
            .with_source(download_url)
            .with_proxy_server(params[:proxy_url])
            .with_checksum_verify(params[:checksum_verify])
            .with_checksum_url(checksum_url)
            .with_extract(true)
            .with_extract_path(extract_dir)
            .with_creates(extract_binary)
        end
        it { is_expected.to contain_file(extract_binary).with_ensure('present') }
        it { is_expected.to contain_file("#{params[:bin_dir]}/#{params[:binary_name]}").with_ensure('link').with_target(extract_binary) }

        ## Config
        it { is_expected.to contain_file(config_dir).with_ensure('directory').with_owner('root').with_group('root').with_mode('0755') }
        it do
          cfg = config_params.keys.sort.reduce([]) do |memo, k|
            memo + [ "#{k.upcase}='#{params[k]}'" ]
          end

          is_expected.to contain_file(config_file).with_ensure('present').with_content(cfg.join("\n") + "\n")
        end

        ## Service
        it do
          is_expected.to contain_file('/etc/systemd/system/vaultbot@.service')
            .with_ensure('present')
            .with_content(%r{^EnvironmentFile=-#{config_file}$})
            .with_content(%r{^EnvironmentFile=-#{config_dir}/vaultbot-%i.conf$})
            .with_content(%r{^SyslogIdentifier=#{params[:syslog_identifier]}$})
            .with_content(%r{^ExecStart=#{params[:exec_start]}$})
        end
        it do
          is_expected.to contain_file('/etc/systemd/system/vaultbot@.timer')
            .with_ensure('present')
            .with_content(%r{^OnCalendar=\*-\*-\* 03:04:05$})
            .without_content(%r{^OnBootSec=})
            .without_content(%r{^RandomizedDelaySec=})
        end
      end

      # Do not manage service & timer
      context 'with service_manage=>false' do
        let(:params) { { service_manage: false } }

        it { is_expected.not_to contain_file('/etc/systemd/system/vaultbot@.service') }
        it { is_expected.not_to contain_file('/etc/systemd/system/vaultbot@.timer') }
      end

      # Deprovision
      context 'with ensure=>absent' do
        let(:params) { { ensure: 'absent' } }

        version = '1.13.0'
        archives_top_dir = '/opt/vaultbot'
        extract_dir = "#{archives_top_dir}/v#{version}"
        extract_binary = "#{extract_dir}/vaultbot"
        config_dir = '/etc/vaultbot'
        config_file = "#{config_dir}/vaultbot.conf"

        [archives_top_dir, extract_dir].each do |d|
          it { is_expected.to contain_file(d).with_ensure('absent') }
        end
        it { is_expected.to contain_archive("#{extract_dir}.tar.gz").with_ensure('absent') }
        it { is_expected.to contain_file(extract_binary).with_ensure('absent') }
        it { is_expected.to contain_file('/usr/local/bin/vaultbot').with_ensure('absent') }
        it { is_expected.to contain_file(config_dir).with_ensure('absent') }
        it { is_expected.to contain_file(config_file).with_ensure('absent') }
        it { is_expected.to contain_file('/etc/systemd/system/vaultbot@.service').with_ensure('absent') }
        it { is_expected.to contain_file('/etc/systemd/system/vaultbot@.timer').with_ensure('absent') }
      end
    end
  end
end

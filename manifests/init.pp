# @summary Installs and configures vaultbot
#
# @example Install vaultbot with default settings
#   include vaultbot
#
# @example Provide the default bundle config
#   class { 'vaultbot':
#     FIXME
#   }
#
# @see https://gitlab.com/msvechla/vaultbot
#
# @param version
#   The vaultbot version to install.
# @param ensure
#   This specifies whether to install vaultbot. Should be one of [present, absent].
# @param install_method
#   This sets the installation method. Only 'archive' method is supported at the moment.
# @param download_url
#   URL template to download the vaultbot release from. This is `inline_epp()`-processed template with the following variables
#   available:
#     - version: See `version` parameter
#     - os: OS kernel (windows/linux/darwin)
#     - arch: Machine architecture (amd64/arm64)
#     - download_extension: See `download_extension` parameter
# @param download_extension
#   Extension of the archive to download. This determines extractor indirectly.
# @param checksum_verify
#   If set to 'true', checksum of the archive downloaded will be verified.
# @param checksum_url
#   URL of a file containing the archive checksums.
# @param binary_name
#   Name of vaultbot binary to install into.
# @param bin_dir
#   Path to install vaultbot into.
# @param archives_top_dir
#   Path to store downloaded archive into.
# @param etc_dir
#   Path to store vaultbot configs into.
# @param proxy_url
#   If set, use the URL as a HTTP proxy to use when downloading files.
# @param service_manage
#   If set to `true`, manage the vaultbot timer and service.
# @param on_calendar
#   Systemd timer `OnCalendar` value. This defines when to run the vaultbot service.
# @param on_boot_sec
#   Systemd timer `OnBootSec` value. This defines how long to wait before starting the vaultbot service after system reboot.
#   Disabled if set to empty string ('').
# @param randomized_delay_sec
#   Systemd timer `RandomizedDelaySec` value. This defines a random delay before starting the service from the timer.
#   Disabled if set to empty string ('').
# @param exec_start
#   Systemd service `ExecStart` value.
# @param syslog_identifier
#   Systemd service `SyslogIdentifier` value.
# @param auto_confirm
#   If set to `true`, user prompts will be auto confirmed with yes.
# @param vault_addr
#   The address of the Vault server expressed as a URL and port.
# @param vault_cacert
#   Path to a PEM-encoded CA cert file to use to verify the Vault server SSL certificate.
# @param vault_capath
#   Path to a directory of PEM-encoded CA cert files to verify the Vault server SSL certificate. If `vault_cacert` is specified,
#   its value will take precedence.
# @param vault_client_cert
#   Path to a PEM-encoded client certificate for TLS authentication to the Vault server.
# @param vault_client_key
#   Path to an unencrypted PEM-encoded private key matching the client certificate.
# @param vault_client_timeout
#   Timeout variable for the vault client.
# @param vault_skip_verify
#   If set to `true`, do not verify Vault's presented certificate before communicating with it. Setting this variable is not
#   recommended except during testing.
# @param vault_tls_server_name
#   If set, use the given name as the SNI host when connecting via TLS.
# @param vault_max_retries
#   The maximum number of retries when a 5xx error code is encountered.
# @param vault_token
#   The Vault authentication token.
# @param vault_renew_token
#   If set, vaultbot tries to automatically renew the current token.
# @param vault_auth_method
#   The method used to authenticate to vault. Should be one of [agent, cert, approle, token, aws-iam, aws-ec2, gcp-gce, gcp-iam].
# @param vault_certificate_role
#   The certificate role to authenticate against, when using the cert auth method.
# @param vault_aws_auth_role
#   The role to use for AWS IAM authentication.
# @param vault_aws_auth_mount
#   The mount path for the vault AWS auth method.
# @param vault_aws_auth_header
#   The header to use during vault AWS IAM authentication. If empty no header will be set.
# @param vault_aws_auth_nonce
#   The nonce to use during vault AWS EC2 authentication.
# @param vault_aws_auth_nonce_path
#   If set, the nonce that is used during vault AWS EC2 authentication will be written to this path.
# @param vault_gcp_auth_role
#   The role to use for GCP authentication.
# @param vault_gcp_auth_service_account_email
#   The service account email to use for GCP IAM authentication.
# @param vault_gcp_auth_mount
#   The mount path for the vault GCP auth method.
# @param vault_app_role_mount
#   The mount path for the AppRole backend.
# @param vault_app_role_role_id
#   RoleID of the AppRole.
# @param vault_app_role_secret_id
#   SecretID belonging to AppRole.
# @param pki_mount
#   Specifies the PKI backend mount path.
# @param pki_role_name
#   Specifies the name of the role to create the certificate against.
# @param pki_ttl
#   Specifies requested Time To Live.
# @param pki_exclude_cn_from_sans
#   If set to `true`, the given `pki_common_name` will not be included in Subject Alternate Names.
# @param pki_private_key_format
#   Specifies the format for marshaling the private key. Should be one of [der, pkcs8].
# @param pki_renew_percent
#   Percentage of requested certificate TTL, which triggers a renewal when passed (>0.00, <1.00).
# @param pki_renew_time
#   Time in hours before certificate expiry, which triggers a renewal (e.g. 12h, 1m). Takes precedence over `pki_renew_percent`
#   when set.
# @param pki_force_renew
#   If set to `true`, the certificate will be renewed without checking the expiry.
class vaultbot (
  # Install options
  String[1] $version = '1.14.3',
  Enum['absent','present'] $ensure = 'present',
  Enum['archive'] $install_method = 'archive',
  String[1] $download_url = 'https://gitlab.com/msvechla/vaultbot/-/releases/v<%= $version %>/downloads/vaultbot_<%= $version %>_<%= $os %>_<%= $arch %><%= $download_extension %>',
  String[1] $download_extension = '.tar.gz',
  Boolean $checksum_verify = true,
  String[1] $checksum_url = 'https://gitlab.com/msvechla/vaultbot/-/releases/v<%= $version %>/downloads/vaultbot_<%= $version %>_checksums.txt',
  String[1] $binary_name = 'vaultbot',
  Stdlib::AbsolutePath $bin_dir = '/usr/local/bin',
  Stdlib::AbsolutePath $archives_top_dir = '/opt/vaultbot',
  Stdlib::AbsolutePath $etc_dir = '/etc/vaultbot',
  Optional[String[1]] $proxy_url = undef,
  Boolean $service_manage = true,
  # Timer options
  String[1] $on_calendar = 'daily',
  String $on_boot_sec = '15min',
  String $randomized_delay_sec = '15min',
  # Service options
  String[1] $exec_start = "${bin_dir}/${binary_name}",
  String[1] $syslog_identifier = 'vaultbot-%i',
  # Bundle common params
  Optional[Boolean] $auto_confirm = undef,
  ## common Vault options
  Optional[String[1]] $vault_addr = undef,
  Optional[Stdlib::Absolutepath] $vault_cacert = undef,
  Optional[Stdlib::Absolutepath] $vault_capath = undef,
  Optional[Stdlib::Absolutepath] $vault_client_cert = undef,
  Optional[Stdlib::Absolutepath] $vault_client_key = undef,
  Optional[Integer[0]] $vault_client_timeout = undef,
  Optional[Boolean] $vault_skip_verify = undef,
  Optional[String] $vault_tls_server_name = undef,
  Optional[Integer[0]] $vault_max_retries = undef,
  Optional[String[1]] $vault_token = undef,
  Optional[Boolean] $vault_renew_token = undef,
  Optional[Enum['agent','cert','approle','token','aws-iam','aws-ec2','gcp-gce','gcp-iam']] $vault_auth_method = undef,
  Optional[String[1]] $vault_certificate_role = undef,
  Optional[String[1]] $vault_aws_auth_role = undef,
  Optional[String[1]] $vault_aws_auth_mount = undef,
  Optional[String[1]] $vault_aws_auth_header = undef,
  Optional[String[1]] $vault_aws_auth_nonce = undef,
  Optional[String[1]] $vault_aws_auth_nonce_path = undef,
  Optional[String[1]] $vault_gcp_auth_role = undef,
  Optional[String[1]] $vault_gcp_auth_service_account_email = undef,
  Optional[String[1]] $vault_gcp_auth_mount = undef,
  Optional[String[1]] $vault_app_role_mount = undef,
  Optional[String[1]] $vault_app_role_role_id = undef,
  Optional[String[1]] $vault_app_role_secret_id = undef,
  ## common Vault PKI options
  Optional[String[1]] $pki_mount = undef,
  Optional[String[1]] $pki_role_name = undef,
  Optional[String[1]] $pki_ttl = undef,
  Optional[Boolean] $pki_exclude_cn_from_sans = undef,
  Optional[Enum['der','pkcs8']] $pki_private_key_format = undef,
  Optional[Float[0.00,1.00]] $pki_renew_percent = undef,
  Optional[String[1]] $pki_renew_time = undef,
  Optional[Boolean] $pki_force_renew = undef,

) {
  contain vaultbot::install
  contain vaultbot::config
  contain vaultbot::service

  Class['vaultbot::install']
  -> Class['vaultbot::config']
  ~> Class['vaultbot::service']
}

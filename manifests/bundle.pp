# @summary Manages a certificate bundle with vaultbot
#
# @example Create a certificate bundle
#   FIXME
#
# @see https://gitlab.com/msvechla/vaultbot
#
# @param ensure
#   This specifies whether to create the bundle. Should be one of [present, absent]. Defaults to 'present'.
# @param bundle_name
#   This sets the certificate bundle name.
# @param logfile
#   Path to the vaultbot logfile. Defaults to stdout.
# @param renew_hook
#   Command to execute after certificate has beed updated.
# @param auto_confirm
#   If set to `true`, user prompts will be auto confirmed with yes.
# @param vault_addr
#   The address of the Vault server expressed as a URL and port (default: http://127.0.0.1:8200).
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
#   If set to `true`, vaultbot tries to automatically renew the current token.
# @param vault_auth_method
#   The method used to authenitcate to vault. Should be one of [agent, cert, approle, token, aws-iam, aws-ec2, gcp-gce, gcp-iam].
# @param vault_certificate_role
#   The certificate role to authenticate against, when using the cert auth mehtod.
# @param vault_aws_auth_role
#   The role to use for AWS IAM authentication.
# @param vault_aws_auth_mount
#   The mount path for the vault AWS auth method (default: aws).
# @param vault_aws_auth_header
#   The header to use during vault AWS IAM authentication. If empty no header will be set.
# @param vault_aws_auth_nonce
#   The nonce to use during vault AWS EC2 authentication.
# @param vault_aws_auth_nonce_path
#   If set, the nonce that is used during vault AWS EC2 authentication will be written to this path.
# @param vault_gcp_auth_role
#   The role to use for GCP authentication.
# @param vault_gcp_auth_service_account_email
#   The service account email to use for GCP IAM authentiation.
# @param vault_gcp_auth_mount
#   The mount path for the vault GCP auth method (default: gcp).
# @param vault_app_role_mount
#   The mount path for the AppRole backend (default: approle).
# @param vault_app_role_role_id
#   RoleID of the AppRole.
# @param vault_app_role_secret_id
#   SecretID belonging to AppRole.
# @param pki_mount
#   Specifies the PKI backend mount path (default: pki).
# @param pki_role_name
#   Specifies the name of the role to create the certificate against.
# @param pki_common_name
#   Specifies the requested CN for the certificate.
# @param pki_alt_names
#   Array of strings which specifies requested Subject Alternative Names.
# @param pki_ip_sans
#   Array of strings which specifies requested IP Subject Alternative Names.
# @param pki_ttl
#   Specifies requested Time To Live.
# @param pki_exclude_cn_from_sans
#   If set to `true`, the given `pki_common_name` will not be included in Subject Alternate Names.
# @param pki_private_key_format
#   Specifies the format for marshaling the private key. Should be one of [der, pkcs8].
# @param pki_renew_percent
#   Percentage of requested certificate TTL, which triggers a renewal when passed (>0.00, <1.00) (default: 0.75).
# @param pki_renew_time
#   Time in hours before certificate expiry, which triggers a renewal (e.g. 12h, 1m). Takes precedence over `pki_renew_percent`
#   when set.
# @param pki_force_renew
#   If set to `true`, the certificate will be renewed without checking the expiry.
# @param pki_cert_path
#   Path to the requested / to be updated certificate.
# @param pki_cachain_path
#   Path to the CA Chain of the requested / to be updated certificate (default: chain.pem).
# @param pki_privkey_path
#   Path to the private key of the requested / to be updated certificate (default: key.pem).
# @param pki_pembundle_path
#   Path to the PEM bundle of the requested / to be updated certificate, private key and ca chain.
# @param pki_jks_path
#   Path to a JAVA KeyStore where the certificates should be exported.
# @param pki_jks_password
#   JAVA KeyStore password (default: ChangeIt).
# @param pki_jks_cert_alias
#   Alias in the JAVA KeyStore of the requested / to be updated certificate (default: cert.pem).
# @param pki_jks_cachain_alias
#   Alias in the JAVA KeyStore of the CA Chain of the requested / to be updated certificate (default: chain.pem).
# @param pki_jks_privkey_alias
#   Alias in the JAVA KeyStore of the private key of the requested / to be updated certificate (default: key.pem).
# @param pki_pkcs12_path
#   Path to a PKCS#12 KeyStore where the certificates should be exported to.
# @param pki_pkcs12_umask
#   File mode of the generated PKCS#12 KeyStore. Existing keystore will keep it's mode. Octal format required (e.g. 0644)
#   (default: 0600).
# @param pki_pkcs12_password
#   Default password is "ChangeIt", a commonly-used password for PKCS#12 files. Due to the weak encryption used by PKCS#12, it is
#   RECOMMENDED that you use the default password when encoding PKCS#12 files, and protect the PKCS#12 files using other means
#   (default: ChangeIt).
define vaultbot::bundle (
  Enum['absent','present'] $ensure = 'present',
  String[1] $bundle_name = $title,
  # General options
  Optional[Stdlib::Absolutepath] $logfile = undef,
  Optional[Stdlib::Absolutepath] $renew_hook = undef,
  Optional[Boolean] $auto_confirm = undef,
  # Vault options
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
  # Vault PKI options
  Optional[String[1]] $pki_mount = undef,
  Optional[String[1]] $pki_role_name = undef,
  Optional[String[1]] $pki_common_name = undef,
  Optional[Array[String[1]]] $pki_alt_names = undef,
  Optional[Array[String[1]]] $pki_ip_sans = undef,
  Optional[String[1]] $pki_ttl = undef,
  Optional[Boolean] $pki_exclude_cn_from_sans = undef,
  Optional[Enum['der','pkcs8']] $pki_private_key_format = undef,
  Optional[Float[0.00,1.00]] $pki_renew_percent = undef,
  Optional[String[1]] $pki_renew_time = undef,
  Optional[Boolean] $pki_force_renew = undef,
  ## PEM
  Optional[Stdlib::Absolutepath] $pki_cert_path = undef,
  Optional[Stdlib::Absolutepath] $pki_cachain_path = undef,
  Optional[Stdlib::Absolutepath] $pki_privkey_path = undef,
  Optional[Stdlib::Absolutepath] $pki_pembundle_path = undef,
  ## JKS
  Optional[Stdlib::Absolutepath] $pki_jks_path = undef,
  Optional[Sensitive[String[1]]] $pki_jks_password = undef,
  Optional[String[1]] $pki_jks_cert_alias = undef,
  Optional[String[1]] $pki_jks_cachain_alias = undef,
  Optional[String[1]] $pki_jks_privkey_alias = undef,
  ## PKCS12
  Optional[Stdlib::Absolutepath] $pki_pkcs12_path = undef,
  Optional[String[1]] $pki_pkcs12_umask = undef,
  Optional[Sensitive[String[1]]] $pki_pkcs12_password = undef,
) {
  include vaultbot

  if $ensure == 'absent' {
    $env = []
  } else {
    # Sanity checks
    unless $vault_addr {
      fail('$vault_addr is required!')
    }

    unless $pki_mount and $pki_role_name and $pki_common_name {
      fail('$pki_mount and $pki_role_name and $pki_common_name are required!')
    }

    unless $pki_cert_path or $pki_privkey_path or $pki_pembundle_path or $pki_jks_path or $pki_pkcs12_path {
      fail('At least one of $pki_cert_path/$pki_privkey_path/$pki_pembundle_path/$pki_jks_path/$pki_pkcs12_path is required')
    }

    case $vault_auth_method {
      'approle': {
        unless $vault_app_role_role_id and $vault_app_role_secret_id {
          fail('$vault_app_role_role_id & $vault_app_role_secret_id are required for auth method "approle"')
        }
      }
      'aws-iam', 'aws-ec2': {
        unless $vault_aws_auth_role {
          fail('$vault_aws_auth_role is required for auth methods "aws-iam"/"aws-ec2"')
        }
      }
      'cert': {
        unless $vault_client_cert and $vault_client_key {
          fail('$vault_client_cert & $vault_client_key are required for auth method "approle"')
        }
      }
      'token': {
        unless $vault_token {
          fail('$vault_token is required for auth method "token"')
        }
      }
      default: {
        # Should never happens because of Enum
        fail("Vault auth method '${vault_auth_method}' is not supported")
      }
    }

    # Vaultbot can accept parameters as env variables
    $env_hash = {
      logfile                   => $logfile,
      renew_hook                => $renew_hook,
      auto_confirm              => $auto_confirm,
      vault_addr                => $vault_addr,
      vault_cacert              => $vault_cacert,
      vault_capath              => $vault_capath,
      vault_client_cert         => $vault_client_cert,
      vault_client_key          => $vault_client_key,
      vault_client_timeout      => $vault_client_timeout,
      vault_skip_verify         => $vault_skip_verify,
      vault_tls_server_name     => $vault_tls_server_name,
      vault_max_retries         => $vault_max_retries,
      vault_token               => $vault_token,
      vault_renew_token         => $vault_renew_token,
      vault_auth_method         => $vault_auth_method,
      vault_certificate_role    => $vault_certificate_role,
      vault_aws_auth_role       => $vault_aws_auth_role,
      vault_aws_auth_mount      => $vault_aws_auth_mount,
      vault_aws_auth_header     => $vault_aws_auth_header,
      vault_aws_auth_nonce      => $vault_aws_auth_nonce,
      vault_aws_auth_nonce_path => $vault_aws_auth_nonce_path,
      vault_app_role_mount      => $vault_app_role_mount,
      vault_app_role_role_id    => $vault_app_role_role_id,
      vault_app_role_secret_id  => $vault_app_role_secret_id,
      pki_mount                 => $pki_mount,
      pki_role_name             => $pki_role_name,
      pki_common_name           => $pki_common_name,
      pki_alt_names             => $pki_alt_names.then |$x| { $x.join(',') },
      pki_ip_sans               => $pki_ip_sans.then |$x| { $x.join(',') },
      pki_ttl                   => $pki_ttl,
      pki_exclude_cn_from_sans  => $pki_exclude_cn_from_sans,
      pki_private_key_format    => $pki_private_key_format,
      pki_renew_percent         => $pki_renew_percent,
      pki_renew_time            => $pki_renew_time,
      pki_force_renew           => $pki_force_renew,
      pki_cert_path             => $pki_cert_path,
      pki_cachain_path          => $pki_cachain_path,
      pki_privkey_path          => $pki_privkey_path,
      pki_pembundle_path        => $pki_pembundle_path,
      pki_jks_path              => $pki_jks_path,
      pki_jks_password          => $pki_jks_password.then |$x| { $x.unwrap },
      pki_jks_cert_alias        => $pki_jks_cert_alias,
      pki_jks_cachain_alias     => $pki_jks_cachain_alias,
      pki_jks_privkey_alias     => $pki_jks_privkey_alias,
      pki_pkcs12_path           => $pki_pkcs12_path,
      pki_pkcs12_umask          => $pki_pkcs12_umask,
      pki_pkcs12_password       => $pki_pkcs12_password.then |$x| { $x.unwrap },
    }
    $env = $env_hash.keys().sort().reduce([]) |Array[String[1]] $memo, Optional[String[1]] $v| {
      $env_hash[$v]
      .then |$x| { $memo + ["${v.upcase}='${x}'"] }
      .lest |  | { $memo }
    }
  }

  file { "${vaultbot::etc_dir}/vaultbot-${bundle_name}.conf":
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "${env.join("\n")}\n",
  }

  $timer_ensure = $ensure ? {
    'absent' => 'stopped',
    default  => 'running',
  }

  $timer_enable = $ensure ? {
    'absent' => false,
    default  => true,
  }

  service { "vaultbot@${bundle_name}.timer":
    ensure => $timer_ensure,
    enable => $timer_enable,
  }
}

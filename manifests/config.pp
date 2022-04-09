# @summary Manages the vaultbot global config
#
# @api private
class vaultbot::config {
  assert_private()

  $directory_ensure = $vaultbot::ensure ? {
    'absent' => 'absent',
    default  => 'directory',
  }

  $env_hash = {
    auto_confirm                         => $vaultbot::auto_confirm,
    vault_addr                           => $vaultbot::vault_addr,
    vault_cacert                         => $vaultbot::vault_cacert,
    vault_capath                         => $vaultbot::vault_capath,
    vault_client_cert                    => $vaultbot::vault_client_cert,
    vault_client_key                     => $vaultbot::vault_client_key,
    vault_client_timeout                 => $vaultbot::vault_client_timeout,
    vault_skip_verify                    => $vaultbot::vault_skip_verify,
    vault_tls_server_name                => $vaultbot::vault_tls_server_name,
    vault_max_retries                    => $vaultbot::vault_max_retries,
    vault_token                          => $vaultbot::vault_token,
    vault_renew_token                    => $vaultbot::vault_renew_token,
    vault_auth_method                    => $vaultbot::vault_auth_method,
    vault_certificate_role               => $vaultbot::vault_certificate_role,
    vault_aws_auth_role                  => $vaultbot::vault_aws_auth_role,
    vault_aws_auth_mount                 => $vaultbot::vault_aws_auth_mount,
    vault_aws_auth_header                => $vaultbot::vault_aws_auth_header,
    vault_aws_auth_nonce                 => $vaultbot::vault_aws_auth_nonce,
    vault_aws_auth_nonce_path            => $vaultbot::vault_aws_auth_nonce_path,
    vault_gcp_auth_role                  => $vaultbot::vault_gcp_auth_role,
    vault_gcp_auth_service_account_email => $vaultbot::vault_gcp_auth_service_account_email,
    vault_gcp_auth_mount                 => $vaultbot::vault_gcp_auth_mount,
    vault_app_role_mount                 => $vaultbot::vault_app_role_mount,
    vault_app_role_role_id               => $vaultbot::vault_app_role_role_id,
    vault_app_role_secret_id             => $vaultbot::vault_app_role_secret_id,
    pki_mount                            => $vaultbot::pki_mount,
    pki_role_name                        => $vaultbot::pki_role_name,
    pki_ttl                              => $vaultbot::pki_ttl,
    pki_exclude_cn_from_sans             => $vaultbot::pki_exclude_cn_from_sans,
    pki_private_key_format               => $vaultbot::pki_private_key_format,
    pki_renew_percent                    => $vaultbot::pki_renew_percent,
    pki_renew_time                       => $vaultbot::pki_renew_time,
    pki_force_renew                      => $vaultbot::pki_force_renew,
  }
  $env = $env_hash.keys().sort().reduce([]) |Array[String[1]] $memo, Optional[String[1]] $v| {
    $env_hash[$v]
    .then |$x| { $memo + ["${v.upcase}='${x}'"] }
    .lest |  | { $memo }
  }

  file {
    default:
      owner => 'root',
      group => 'root',
      ;
    $vaultbot::etc_dir:
      ensure => $directory_ensure,
      force  => true,
      mode   => '0755',
      ;
    "${vaultbot::etc_dir}/vaultbot.conf":
      ensure  => $vaultbot::ensure,
      content => "${env.join("\n")}\n",
      mode    => '0644',
      ;
  }
}

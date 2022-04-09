# @summary Installs vaultbot
#
# @api private
class vaultbot::install {
  assert_private()

  # Sanity checks
  case $facts['os']['architecture'] {
    'aarch64':        { $arch = 'arm64' }
    /(x86_64|amd64)/: { $arch = 'amd64' }
    default:          { fail("Unsupported kernel architecture: ${facts['os']['architecture']}") }
  }

  $os = $facts['kernel'].downcase
  unless $os in ['darwin','linux','windows'] {
    fail("Unsupported kernel: ${os}")
  }

  $url_vars = {
    version            => $vaultbot::version,
    os                 => $os,
    arch               => $arch,
    download_extension => $vaultbot::download_extension,
  }

  $real_download_url = inline_epp($vaultbot::download_url, $url_vars)
  $real_checksum_url = inline_epp($vaultbot::checksum_url, $url_vars)

  case $vaultbot::install_method {
    'archive': {
      $extract_dir = "${vaultbot::archives_top_dir}/v${vaultbot::version}"
      $extract_binary = "${extract_dir}/${vaultbot::binary_name}"

      $directory_ensure = $vaultbot::ensure ? {
        'absent' => 'absent',
        default  => 'directory',
      }
      $link_ensure = $vaultbot::ensure ? {
        'absent' => 'absent',
        default  => 'link',
      }

      $download_filename = "vaultbot_${vaultbot::version}_${os}_${arch}${vaultbot::download_extension}"

      file { [$vaultbot::archives_top_dir, $extract_dir]:
        ensure => $directory_ensure,
        force  => true,
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
      }
      -> archive { "${extract_dir}${vaultbot::download_extension}":
        ensure          => $vaultbot::ensure,
        source          => $real_download_url,
        checksum_verify => $vaultbot::checksum_verify,
        checksum_url    => $real_checksum_url,
        extract         => true,
        extract_path    => $extract_dir,
        creates         => $extract_binary,
        proxy_server    => $vaultbot::proxy_url,
      }
      -> file { $extract_binary:
        ensure => $vaultbot::ensure,
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
      }
      -> file { "${vaultbot::bin_dir}/${vaultbot::binary_name}":
        ensure => $link_ensure,
        target => $extract_binary,
        force  => true,
      }
    }  # /case archive

    default: {
      fail("Unsupported installation method ${vaultbot::install_method}")
    }
  }  # /case
}

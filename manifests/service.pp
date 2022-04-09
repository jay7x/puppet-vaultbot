# @summary Manages the vaultbot service
#
# @api private
class vaultbot::service {
  assert_private()

  if $vaultbot::service_manage {
    file {
      default:
        ensure => $vaultbot::ensure,
        owner  => 'root',
        group  => 'root',
        mode   => '0644',
        ;
      '/etc/systemd/system/vaultbot@.service':
        content => epp('vaultbot/vaultbot@.service.epp', {
            'etc_dir'           => $vaultbot::etc_dir,
            'exec_start'        => $vaultbot::exec_start,
            'syslog_identifier' => $vaultbot::syslog_identifier,
        }),
        ;
      '/etc/systemd/system/vaultbot@.timer':
        content => epp('vaultbot/vaultbot@.timer.epp', {
            'on_calendar'          => $vaultbot::on_calendar,
            'on_boot_sec'          => $vaultbot::on_boot_sec,
            'randomized_delay_sec' => $vaultbot::randomized_delay_sec,
        }),
        ;
    }
  }
}

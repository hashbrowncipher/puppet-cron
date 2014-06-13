define cron::staleness_check(
  $threshold,
  $params,
) {
  validate_hash($params)

  $threshold_s = human_time_to_seconds($threshold)

  # Check whether we are fresh five times per threshold.
  $check_every = $threshold_s / 5

  $actual_command = "/nail/sys/bin/success_wrapper ${name} ${command}"

  $check_title = "${name}_staleness"
  $overrides = {
    'command' => "/usr/lib/nagios/plugins/check_file_age /nail/run/success_wrapper/${name} -c ${threshold_s}",
    'check_every' => $check_every,
  }

  $check_data = { "$check_title" =>
    merge(
      $params,
      $overrides
    )
  }
  create_resources('monitoring_check', $check_data)

  file { "/nail/run/success_wrapper/${name}":
    ensure => 'file',
    owner  => $user,
    group  => 'root',
    mode   => '640',
  } ->
  Monitoring_check[$check_title]
}

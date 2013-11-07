import "smallworld.pp"

$installation_iso_file = "/vagrant/install/CORE420_UNIX.iso"
$mount_path = "/mnt/smallworld_install"

class { "smallworld":
  target_dir          => "/opt/smallworld",
  owning_user         => "vagrant",
  installation_source => $mount_path,
}

Mount[$mount_path] -> Class["smallworld"]

mount { $mount_path:
  ensure  => mounted,
  device  => "${installation_iso_file}",
  options => "loop,ro,noauto",
  fstype  => "iso9660",
  require => File["${mount_path}"],
}

file { $mount_path:
  ensure => directory,
}

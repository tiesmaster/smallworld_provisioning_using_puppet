import "smallworld.pp"

/* $wanted_smallworld_version = "v4.2"*/
$wanted_smallworld_version = "v4.3"

$installation_iso_file = $wanted_smallworld_version ? {
  "v4.2" => "/vagrant/install/CORE420_UNIX.iso",
  "v4.3" => "/vagrant/install/SWCST430unix.iso",
}
$mount_path = "/mnt/smallworld_install"

class { "smallworld":
  target_dir          => "/opt/smallworld",
  owning_user         => "vagrant",
  installation_source => $mount_path,
  version             => $wanted_smallworld_version,
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

class smallworld (
  $target_dir = undef,
  $owning_user = undef,
  $installation_source = undef,
) {

  $smallworld_gis = "${target_dir}/GIS42"

  smallworld::install { "smallworld install":
    target_dir          => $target_dir,
    owning_user         => $owning_user,
    installation_source => $installation_source,
  }

  smallworld::configure { "smallworld configuration":
    smallworld_gis => $smallworld_gis,
    configure_user => $owning_user,
  }

  smallworld::test { "smallworld test run":
    smallworld_gis  => $smallworld_gis,
    configured_user => $owning_user,
  }
}

define smallworld::install (
  $target_dir = undef,
  $owning_user = undef,
  $installation_source = undef,
) {

  include smallworld::install::deps
  include smallworld::runtime::deps

  $target_dir_opt = "-targetdir ${target_dir}"
  $owner_opt = "-owner ${owning_user}"
  $emacs_opt = "-emacs no"
  $platform_opt = "-platforms local"
  $other_opts = "-force_os_rev -nolog"

  $install_opts = "${target_dir_opt} ${owner_opt} ${emacs_opt} ${platform_opt} ${other_opts}"

  $answer_file = "/vagrant/manifests/smallworld_install.answer_file"

  exec { "install smallworld":
    command  => "${installation_source}/product/install.sh ${install_opts} < ${answer_file}",
    provider => shell,
    creates  => $target_dir,
    require => [
      File["/bin/arch"],
      Package["csh"],
    ],
  }
}

define smallworld::configure (
  $smallworld_gis = undef,
  $configure_user = undef,
) {

  exec { "configure smallworld":
    command   => "echo ${configure_user} | ${smallworld_gis}/bin/share/gis_config -user",
    provider  => shell,
    require   => Exec["install smallworld"],
  }

  file { "${smallworld_gis}/config/gis_aliases":
    ensure  => link,
    target  => "${smallworld_gis}/config/magik_images/resources/base/data/gis_aliases",
    require => Exec["install smallworld"],
  }

  exec { "patches font file":
    command  => "sed -i -e 's/urw/*/' -e 's/0/*/' ${smallworld_gis}/config/font/urw_helvetica",
    provider => shell,
    require  => Exec["install smallworld"],
  }
}

define smallworld::test (
  $smallworld_gis = undef,
  $configured_user = undef,
) {

  exec { "test smallworld":
    command   => "sudo -H -u ${configured_user} sh -l -c 'gis -i gis'",
    provider  => shell,
    logoutput => true,
    require   => File["${smallworld_gis}/config/gis_aliases"],
  }

# gis -i -a /opt/smallworld/cambridge_db/config/magik_images/resources/base/data/gis_aliases build_cam_db_closed
# gis -i -a /opt/smallworld/cambridge_db/config/magik_images/resources/base/data/gis_aliases build_cam_db_closed_swaf
}

class smallworld::install::deps {

  file { "/bin/arch":
    ensure => link,
    target => "/usr/bin/arch",
  }

  package { "csh":
    ensure => installed,
  }
}

class smallworld::runtime::deps {

  package { "dependent packages for sw_magik_motif":
    name   => [
      "libxaw3dxft6",
      "libxp6",
      "gsfonts-x11",
    ],
    ensure => installed,
  }

  file { "/usr/lib/libXaw3d.so.7":
    ensure => link,
    target => "/usr/lib/libXaw3dxft.so.6",
  }
}

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

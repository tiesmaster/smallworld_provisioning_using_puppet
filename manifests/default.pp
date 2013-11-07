class smallworld (
  $target_dir = undef,
  $target_user = undef,
  $installation_source = undef,
) {

  include install::deps

# install smallworld

  $install_dir = "-targetdir ${target_dir}"
  $install_features = "-force_os_rev -platforms local -emacs no -owner ${target_user}"
  $install_answer_file = "/vagrant/manifests/smallworld_install.answer_file"
  $install_opts = "${install_features} -nolog ${install_dir} < ${install_answer_file}"

  exec { "install smallworld":
    command  => "${installation_source}/product/install.sh ${install_opts}",
    provider => shell,
    creates  => "${target_dir}",
    require => [
      File["/bin/arch"],
      Package["csh"],
    ],
  }

# configure smallworld

  exec { "configure smallworld":
    command   => "echo ${target_user} | ${target_dir}/GIS42/bin/share/gis_config -user",
    provider  => shell,
    require   => Exec["install smallworld"],
  }

  file { "${target_dir}/GIS42/config/gis_aliases":
    ensure  => link,
    target  => "${target_dir}/GIS42/config/magik_images/resources/base/data/gis_aliases",
    require => Exec["install smallworld"],
  }

# runtime deps: sw_magik_motif

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

  exec { "patches font file":
    command  => "sed -i -e 's/urw/*/' -e 's/0/*/' ${target_dir}/GIS42/config/font/urw_helvetica",
    provider => shell,
    require  => Exec["install smallworld"],
  }

# tests

  exec { "test smallworld":
    command   => "sudo -H -u ${target_user} sh -l -c 'gis -i gis'",
    provider  => shell,
    logoutput => true,
    require   => File["${target_dir}/GIS42/config/gis_aliases"],
  }
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

$installation_iso_file = "/vagrant/install/CORE420_UNIX.iso"
$mount_path = "/mnt/smallworld_install"


class { "smallworld":
  target_dir          => "/opt/smallworld",
  target_user         => "vagrant",
  installation_source => $mount_path,
}

Mount["${mount_path}"] -> Class["smallworld"]

mount { "${mount_path}":
  ensure  => mounted,
  device  => "${installation_iso_file}",
  options => "loop,ro,noauto",
  fstype  => "iso9660",
  require => File["${mount_path}"],
}

file { "${mount_path}":
  ensure => directory,
}

# gis -i -a /opt/smallworld/cambridge_db/config/magik_images/resources/base/data/gis_aliases build_cam_db_closed
# gis -i -a /opt/smallworld/cambridge_db/config/magik_images/resources/base/data/gis_aliases build_cam_db_closed_swaf
